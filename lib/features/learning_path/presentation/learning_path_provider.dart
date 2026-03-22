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
  final Map<int, Set<int>> _completedUnitIdsByRoadmap = {};
  final Map<int, int> _userXpByRoadmap = {};
  final Map<int, Map<int, int>> _unitXpByRoadmap = {};
  final Map<int, Map<int, int>> _checkpointAttemptsByRoadmap = {};
  final Map<int, Set<int>> _confirmedCheckpointRetakesByRoadmap = {};

  List<LearningUnitEntity> get units => _units;
  LearningPathState get state => _state;
  Set<int> get completedUnitIds =>
      _completedUnitIdsByRoadmap[_currentRoadmapId] ?? <int>{};
  int get userXp => _userXpByRoadmap[_currentRoadmapId] ?? 0;

  double get completionRatio {
    if (_units.isEmpty) return 0;
    final int completed = _units
        .where((unit) => unit.status == LearningUnitStatus.completed)
        .length;
    return completed / _units.length;
  }

  bool isCheckpointCompleted(int unitId) {
    LearningUnitEntity? unit;
    for (final LearningUnitEntity current in _units) {
      if (current.id == unitId) {
        unit = current;
        break;
      }
    }
    if (unit == null || unit.type != LearningUnitType.quiz) {
      return false;
    }
    return completedUnitIds.contains(unitId);
  }

  bool hasCheckpointAttempted(int unitId) {
    final int attempts =
        _checkpointAttemptsByRoadmap[_currentRoadmapId]?[unitId] ?? 0;
    return attempts > 0;
  }

  bool hasConfirmedRetake(int unitId) {
    return _confirmedCheckpointRetakesByRoadmap[_currentRoadmapId]?.contains(
          unitId,
        ) ??
        false;
  }

  void registerCheckpointAttemptStart(int unitId) {
    if (_currentRoadmapId <= 0) return;
    final Map<int, int> checkpointAttempts =
        _checkpointAttemptsByRoadmap.putIfAbsent(
          _currentRoadmapId,
          () => <int, int>{},
        );
    checkpointAttempts[unitId] = (checkpointAttempts[unitId] ?? 0) + 1;
  }

  void markRetakeConfirmed(int unitId) {
    if (_currentRoadmapId <= 0) return;
    final Set<int> confirmedRetakes =
        _confirmedCheckpointRetakesByRoadmap.putIfAbsent(
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
    _completedUnitIdsByRoadmap.putIfAbsent(roadmapId, () => <int>{});
    _userXpByRoadmap.putIfAbsent(roadmapId, () => 0);
    _unitXpByRoadmap.putIfAbsent(roadmapId, () => <int, int>{});
    _checkpointAttemptsByRoadmap.putIfAbsent(roadmapId, () => <int, int>{});
    _confirmedCheckpointRetakesByRoadmap.putIfAbsent(roadmapId, () => <int>{});

    if (showLoader) {
      _state = LearningPathState.loading;
      notifyListeners();
    }

    try {
      final fetchedUnits = await useCase(
        roadmapId: roadmapId,
        userXp: _userXpByRoadmap[roadmapId] ?? 0,
        completedUnitIds: _completedUnitIdsByRoadmap[roadmapId] ?? <int>{},
      );

      _units = fetchedUnits;
      _state = LearningPathState.loaded;
    } catch (_) {
      _state = LearningPathState.connectionError;
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> loadPathAsJson(int roadmapId) async {
    _currentRoadmapId = roadmapId;
    _completedUnitIdsByRoadmap.putIfAbsent(roadmapId, () => <int>{});
    _userXpByRoadmap.putIfAbsent(roadmapId, () => 0);
    _unitXpByRoadmap.putIfAbsent(roadmapId, () => <int, int>{});
    _checkpointAttemptsByRoadmap.putIfAbsent(roadmapId, () => <int, int>{});
    _confirmedCheckpointRetakesByRoadmap.putIfAbsent(roadmapId, () => <int>{});

    return useCase.asJson(
      roadmapId: roadmapId,
      userXp: _userXpByRoadmap[roadmapId] ?? 0,
      completedUnitIds: _completedUnitIdsByRoadmap[roadmapId] ?? <int>{},
    );
  }

  Future<void> completeUnit({required int unitId, int earnedXp = 0}) async {
    if (_currentRoadmapId <= 0) return;

    final Set<int> completedIds = _completedUnitIdsByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int>{},
    );
    final Map<int, int> unitXp = _unitXpByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int, int>{},
    );
    if (completedIds.contains(unitId)) return;

    completedIds.add(unitId);
    if (earnedXp > 0) {
      unitXp[unitId] = earnedXp;
      _userXpByRoadmap[_currentRoadmapId] =
          (_userXpByRoadmap[_currentRoadmapId] ?? 0) + earnedXp;
    }

    await loadPath(_currentRoadmapId, showLoader: false);
  }

  Future<void> submitCheckpointAttempt({
    required int unitId,
    required bool passed,
    required int earnedXp,
  }) async {
    if (_currentRoadmapId <= 0) return;

    final Set<int> completedIds = _completedUnitIdsByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int>{},
    );
    final Map<int, int> unitXp = _unitXpByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int, int>{},
    );

    clearRetakeConfirmed(unitId);

    final bool hasPassedBefore = completedIds.contains(unitId);

    if (!passed) {
      // Keep unlock state if the checkpoint was passed at least once before.
      if (!hasPassedBefore) {
        completedIds.remove(unitId);
      }
      await loadPath(_currentRoadmapId, showLoader: false);
      return;
    }

    final int previousXp = unitXp[unitId] ?? 0;
    unitXp[unitId] = earnedXp;
    completedIds.add(unitId);
    _userXpByRoadmap[_currentRoadmapId] =
        ((_userXpByRoadmap[_currentRoadmapId] ?? 0) - previousXp + earnedXp)
            .clamp(0, 1 << 31);

    await loadPath(_currentRoadmapId, showLoader: false);
  }

  Future<void> resetCheckpointProgress({required int unitId}) async {
    if (_currentRoadmapId <= 0) return;

    final Map<int, int> unitXp = _unitXpByRoadmap.putIfAbsent(
      _currentRoadmapId,
      () => <int, int>{},
    );

    // Retake removes checkpoint XP, but keeps unlock state once passed.
    final int removedXp = unitXp.remove(unitId) ?? 0;
    if (removedXp > 0) {
      _userXpByRoadmap[_currentRoadmapId] =
          ((_userXpByRoadmap[_currentRoadmapId] ?? 0) - removedXp).clamp(
            0,
            1 << 31,
          );
    }

    await loadPath(_currentRoadmapId, showLoader: false);
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

    _completedUnitIdsByRoadmap[id] = <int>{};
    _userXpByRoadmap[id] = 0;
    _unitXpByRoadmap[id] = <int, int>{};
    _checkpointAttemptsByRoadmap[id] = <int, int>{};
    _confirmedCheckpointRetakesByRoadmap[id] = <int>{};

    if (!updateState) {
      return;
    }

    if (_currentRoadmapId == id) {
      await loadPath(id, showLoader: false);
    } else {
      notifyListeners();
    }
  }
}
