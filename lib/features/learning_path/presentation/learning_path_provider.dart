import 'package:flutter/material.dart';
import '../domain/learning_unit_entity.dart';
import '../domain/get_learning_path_usecase.dart';

enum LearningPathState { loading, loaded, connectionError }

class LearningPathProvider extends ChangeNotifier {
  final GetLearningPathUseCase useCase;

  LearningPathProvider(this.useCase);

  int _currentRoadmapId = 0;
  List<LearningUnitEntity> _units = [];
  LearningPathState _state = LearningPathState.loading;
  final Map<int, Set<int>> _completedLessonsByRoadmap = {};
  final Map<int, int> _userXpByRoadmap = {};

  List<LearningUnitEntity> get units => _units;
  LearningPathState get state => _state;
  Set<int> get completedLessonIds =>
      _completedLessonsByRoadmap[_currentRoadmapId] ?? <int>{};
  int get userXp => _userXpByRoadmap[_currentRoadmapId] ?? 0;

  double get completionRatio {
    if (_units.isEmpty) return 0;
    final int completed = _units
        .where((unit) => unit.status == LearningUnitStatus.completed)
        .length;
    return completed / _units.length;
  }

  Future<void> loadPath(int roadmapId, {bool showLoader = true}) async {
    _currentRoadmapId = roadmapId;
    _completedLessonsByRoadmap.putIfAbsent(roadmapId, () => <int>{});
    _userXpByRoadmap.putIfAbsent(roadmapId, () => 0);

    if (showLoader) {
      _state = LearningPathState.loading;
      notifyListeners();
    }

    try {
      final fetchedUnits = await useCase(
        roadmapId: roadmapId,
        userXp: _userXpByRoadmap[roadmapId] ?? 0,
        completedLessonIds: _completedLessonsByRoadmap[roadmapId] ?? <int>{},
      );

      if (fetchedUnits.isEmpty) {
        _units = <LearningUnitEntity>[];
        _state = LearningPathState.loaded;
        notifyListeners();
        return;
      }

      _units = fetchedUnits;
      _state = LearningPathState.loaded;
    } catch (_) {
      _state = LearningPathState.connectionError;
    }

    notifyListeners();
  }

  Future<void> completeUnit({required int unitId, int earnedXp = 0}) async {
    if (_currentRoadmapId <= 0) return;

    final completedIds = _completedLessonsByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int>{},
    );
    if (completedIds.contains(unitId)) return;

    completedIds.add(unitId);
    _userXpByRoadmap[_currentRoadmapId] =
        (_userXpByRoadmap[_currentRoadmapId] ?? 0) + earnedXp;

    await loadPath(_currentRoadmapId, showLoader: false);
  }

  Future<void> resetProgress({int? roadmapId}) async {
    final id = roadmapId ?? _currentRoadmapId;
    if (id <= 0) {
      notifyListeners();
      return;
    }

    _completedLessonsByRoadmap[id] = <int>{};
    _userXpByRoadmap[id] = 0;

    if (_currentRoadmapId == id) {
      await loadPath(id, showLoader: false);
    } else {
      notifyListeners();
    }
  }
}
