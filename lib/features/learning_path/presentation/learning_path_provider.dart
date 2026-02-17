import 'package:flutter/material.dart';
import '../domain/learning_unit_entity.dart';
import '../domain/get_learning_path_usecase.dart';

class LearningPathProvider extends ChangeNotifier {
  final GetLearningPathUseCase useCase;

  LearningPathProvider(this.useCase);

  int _currentRoadmapId = 0;
  List<LearningUnitEntity> _units = [];
  bool _loading = false;
  final Map<int, Set<int>> _completedLessonsByRoadmap = {};
  final Map<int, int> _userXpByRoadmap = {};

  List<LearningUnitEntity> get units => _units;
  bool get isLoading => _loading;
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
      _loading = true;
      notifyListeners();
    }

    try {
      _units = await useCase(
        roadmapId: roadmapId,
        userXp: _userXpByRoadmap[roadmapId] ?? 0,
        completedLessonIds: _completedLessonsByRoadmap[roadmapId] ?? <int>{},
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
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
