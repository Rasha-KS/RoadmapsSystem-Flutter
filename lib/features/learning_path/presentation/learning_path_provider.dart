import 'dart:async';

import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import 'package:roadmaps/core/cache/lesson_content_cache.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/roadmaps/domain/roadmap_entity.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';

import '../domain/get_learning_path_usecase.dart';
import '../domain/learning_path_entity.dart';
import '../domain/learning_unit_entity.dart';
import 'package:roadmaps/features/lessons/domain/prefetch_lesson_content_usecase.dart';

enum LearningPathState { loading, loaded, connectionError }

class LearningPathProvider extends SafeChangeNotifier {
  final GetLearningPathUseCase useCase;
  final PrefetchLessonContentUseCase _prefetchLessonContentUseCase;
  final ProfileProvider? _profileProvider;
  final HomeProvider? _homeProvider;
  final RoadmapsProvider? _roadmapsProvider;
  final LessonContentCache _lessonContentCache = LessonContentCache.instance;

  LearningPathProvider(
    this.useCase,
    this._prefetchLessonContentUseCase,
    {
      ProfileProvider? profileProvider,
      HomeProvider? homeProvider,
      RoadmapsProvider? roadmapsProvider,
    }
  )  : _profileProvider = profileProvider,
        _homeProvider = homeProvider,
        _roadmapsProvider = roadmapsProvider;

  int _currentRoadmapId = 0;
  LearningPathEntity? _path;
  LearningPathState _state = LearningPathState.loading;
  String? _errorMessage;
  final Map<int, Set<int>> _checkpointAttemptsByRoadmap = {};
  final Map<int, Set<int>> _confirmedCheckpointRetakesByRoadmap = {};
  final Map<int, Set<int>> _optimisticCompletedUnitsByRoadmap = {};

  LearningPathState get state => _state;
  String? get errorMessage => _errorMessage;
  RoadmapEntity? get roadmap => _path?.roadmap;
  List<LearningUnitEntity> get units => _path?.units ?? <LearningUnitEntity>[];
  int get currentRoadmapId => _currentRoadmapId;
  int get userXp {
    final roadmapId = _currentRoadmapId;
    if (roadmapId <= 0) return 0;
    return _profileProvider?.getRoadmapXp(roadmapId) ?? 0;
  }

  String get roadmapTitle => roadmap?.title ?? '';
  String get roadmapDescription => roadmap?.description ?? '';

  double get completionRatio {
    if (units.isEmpty) return 0;
    final completed = units.where((unit) => unit.isCompleted).length;
    return completed / units.length;
  }

  bool isCheckpointCompleted(int unitId) {
    return units.any((unit) => unit.id == unitId && unit.isCompleted);
  }

  bool hasCheckpointAttempted(int unitId) {
    final attempts =
        _checkpointAttemptsByRoadmap[_currentRoadmapId]?.contains(unitId) ??
            false;
    return attempts;
  }

  bool hasConfirmedRetake(int unitId) {
    return _confirmedCheckpointRetakesByRoadmap[_currentRoadmapId]?.contains(
          unitId,
        ) ??
        false;
  }

  void registerCheckpointAttemptStart(int unitId) {
    if (_currentRoadmapId <= 0) return;
    final attempts = _checkpointAttemptsByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int>{},
    );
    attempts.add(unitId);
  }

  void markRetakeConfirmed(int unitId) {
    if (_currentRoadmapId <= 0) return;
    final confirmedRetakes = _confirmedCheckpointRetakesByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int>{},
    );
    confirmedRetakes.add(unitId);
  }

  void clearRetakeConfirmed(int unitId) {
    if (_currentRoadmapId <= 0) return;
    _confirmedCheckpointRetakesByRoadmap[_currentRoadmapId]?.remove(unitId);
  }

  Future<void> loadPath(int roadmapId, {bool showLoader = true}) async {
    _currentRoadmapId = roadmapId;
    _errorMessage = null;

    if (showLoader) {
      _state = LearningPathState.loading;
      notifyListeners();
    }

    try {
      final loadedPath = await useCase(roadmapId: roadmapId);
      _path = loadedPath;
      _restoreOptimisticCompletionsForRoadmap(roadmapId);
      _state = LearningPathState.loaded;
      _syncProfileProgress();
    } catch (error) {
      _path = null;
      _state = LearningPathState.connectionError;
      _errorMessage = _normalizeError(error);
    }

    notifyListeners();

    if (_state == LearningPathState.loaded && _path != null) {
      unawaited(
        _prefetchLessonContentUseCase.call(units: _path!.units),
      );
    }
  }

  Future<void> refreshPath() async {
    if (_currentRoadmapId <= 0) return;
    await _lessonContentCache.clearContentCache();
    await loadPath(_currentRoadmapId, showLoader: false);
  }

  Future<void> completeUnit({required int unitId}) async {
    if (_currentRoadmapId <= 0) return;
    await _lessonContentCache.markUnitCompleted(_currentRoadmapId, unitId);
    _applyOptimisticCompletion(unitId);

    _syncProfileProgress();
    notifyListeners();
  }

  Future<void> submitCheckpointAttempt({
    required int unitId,
    required bool passed,
  }) async {
    if (_currentRoadmapId <= 0) return;
    if (passed) {
      markRetakeConfirmed(unitId);
      await completeUnit(unitId: unitId);
      return;
    }
    await refreshPath();
  }

  Future<void> resetCheckpointProgress({required int unitId}) async {
    if (_currentRoadmapId <= 0) return;
    clearRetakeConfirmed(unitId);
    await refreshPath();
  }

  Future<void> resetProgress({
    int? roadmapId,
    bool updateState = true,
  }) async {
    final id = roadmapId ?? _currentRoadmapId;
    if (id <= 0) {
      notifyListeners();
      return;
    }

    if (!updateState) {
      return;
    }

    await _lessonContentCache.clearAll();
    _clearOptimisticOverridesForRoadmap(id);

    if (_currentRoadmapId == id) {
      _path = null;
      _state = LearningPathState.loading;
      _syncProfileProgress(roadmapId: id, progressPercentage: 0);
      notifyListeners();
      return;
    }

    notifyListeners();
  }

  void _applyOptimisticCompletion(int unitId) {
    final path = _path;
    if (path == null) return;

    final units = [...path.units];
    final index = units.indexWhere((unit) => unit.id == unitId);
    if (index == -1) return;

    units[index] = units[index].copyWith(
      status: LearningUnitStatus.completed,
      isLocked: false,
      isCompleted: true,
    );

    if (index + 1 < units.length) {
      final nextUnit = units[index + 1];
      if (nextUnit.status == LearningUnitStatus.locked) {
        units[index + 1] = nextUnit.copyWith(
          status: LearningUnitStatus.unlocked,
          isLocked: false,
        );
      }
    }

    final completedUnits = _optimisticCompletedUnitsByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int>{},
    );
    completedUnits.add(unitId);

    _path = LearningPathEntity(
      roadmap: path.roadmap,
      units: units,
    );
    _state = LearningPathState.loaded;
  }

  void _clearOptimisticOverridesForRoadmap(int roadmapId) {
    _optimisticCompletedUnitsByRoadmap.remove(roadmapId);
  }

  void _restoreOptimisticCompletionsForRoadmap(int roadmapId) {
    final completedUnits =
        _optimisticCompletedUnitsByRoadmap[roadmapId] ?? const <int>{};
    if (completedUnits.isEmpty) {
      return;
    }

    for (final unitId in completedUnits) {
      _applyOptimisticCompletion(unitId);
    }
  }

  void _syncProfileProgress({
    int? roadmapId,
    int? progressPercentage,
  }) {
    final profileProvider = _profileProvider;
    final homeProvider = _homeProvider;
    final roadmapsProvider = _roadmapsProvider;

    final targetRoadmapId = roadmapId ?? _currentRoadmapId;
    if (targetRoadmapId <= 0) return;

    final progress = progressPercentage ??
        (completionRatio * 100).round().clamp(0, 100);
    final normalizedStatus = progress >= 100 ? 'completed' : 'active';
    unawaited(
      _lessonContentCache.writeRoadmapProgress(targetRoadmapId, progress),
    );
    profileProvider?.updateRoadmapProgress(
      roadmapId: targetRoadmapId,
      progressPercentage: progress,
    );
    homeProvider?.updateCourseStatus(
      courseId: targetRoadmapId,
      status: normalizedStatus,
    );
    roadmapsProvider?.updateRoadmapStatus(
      roadmapId: targetRoadmapId,
      status: normalizedStatus,
    );
  }

  String _normalizeError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تحميل المسار وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'تعذر تحميل المسار. حاول مرة أخرى.';
  }
}
