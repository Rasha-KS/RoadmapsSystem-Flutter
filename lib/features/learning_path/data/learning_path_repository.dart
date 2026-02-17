import '../domain/learning_unit_entity.dart';

class LearningPathRepository {
  Future<List<LearningUnitEntity>> getLearningPath({
    required int roadmapId,
    required int userXp,
    required Set<int> completedLessonIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final units = [
      LearningUnitEntity(
        id: 1,
        roadmapId: roadmapId,
        title: 'الدرس  1',
        position: 1,
        type: LearningUnitType.lesson,
        status: LearningUnitStatus.locked,
      ),
      LearningUnitEntity(
        id: 2,
        roadmapId: roadmapId,
        title: 'الدرس 2',
        position: 2,
        type: LearningUnitType.lesson,
        status: LearningUnitStatus.locked,
      ),
      LearningUnitEntity(
        id: 3,
        roadmapId: roadmapId,
        title: 'الدرس 3',
        position: 3,
        type: LearningUnitType.lesson,
        status: LearningUnitStatus.locked,
      ),
      LearningUnitEntity(
        id: 4,
        roadmapId: roadmapId,
        title: 'اختبار',
        position: 4,
        type: LearningUnitType.quiz,
        status: LearningUnitStatus.locked,
      ),
      LearningUnitEntity(
        id: 5,
        roadmapId: roadmapId,
        title: 'الدرس 4',
        position: 5,
        type: LearningUnitType.lesson,
        status: LearningUnitStatus.locked,
      ),
      LearningUnitEntity(
        id: 6,
        roadmapId: roadmapId,
        title: 'الدرس 5',
        position: 6,
        type: LearningUnitType.lesson,
        status: LearningUnitStatus.locked,
      ),
      LearningUnitEntity(
        id: 7,
        roadmapId: roadmapId,
        title: 'التحدي النهائي ',
        position: 7,
        type: LearningUnitType.challenge,
        status: LearningUnitStatus.locked,
        requiredXp: 120,
      ),
    ];

    return _applyUnlockLogic(units, completedLessonIds, userXp);
  }

  List<LearningUnitEntity> _applyUnlockLogic(
    List<LearningUnitEntity> units,
    Set<int> completedLessonIds,
    int userXp,
  ) {
    final sortedUnits = [...units]
      ..sort((a, b) => a.position.compareTo(b.position));
    final List<LearningUnitEntity> updated = [];

    for (int i = 0; i < sortedUnits.length; i++) {
      final unit = sortedUnits[i];

      if (completedLessonIds.contains(unit.id)) {
        updated.add(unit.copyWith(status: LearningUnitStatus.completed));
        continue;
      }

      if (i == 0) {
        updated.add(unit.copyWith(status: LearningUnitStatus.unlocked));
        continue;
      }

      if (unit.type == LearningUnitType.lesson) {
        final previous = updated[i - 1];
        updated.add(
          previous.status == LearningUnitStatus.completed
              ? unit.copyWith(status: LearningUnitStatus.unlocked)
              : unit,
        );
        continue;
      }

      if (unit.type == LearningUnitType.quiz) {
        final bool allPreviousLessonsDone = sortedUnits
            .where(
              (other) =>
                  other.position < unit.position &&
                  other.type == LearningUnitType.lesson,
            )
            .every((lesson) => completedLessonIds.contains(lesson.id));
        updated.add(
          allPreviousLessonsDone
              ? unit.copyWith(status: LearningUnitStatus.unlocked)
              : unit,
        );
        continue;
      }

      updated.add(
        userXp >= unit.requiredXp
            ? unit.copyWith(status: LearningUnitStatus.unlocked)
            : unit,
      );
    }

    return updated;
  }
}
