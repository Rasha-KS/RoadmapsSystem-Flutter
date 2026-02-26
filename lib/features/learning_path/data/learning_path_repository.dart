import 'package:roadmaps/core/constants/xp_rules.dart';
import 'package:roadmaps/features/learning_path/data/learning_path_model.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';

class LearningPathRepository {
  Future<List<LearningUnitEntity>> getLearningPath({
    required int roadmapId,
    required int userXp,
    required Set<int> completedUnitIds,
  }) async {
    final Map<String, dynamic> response = await getLearningPathJson(
      roadmapId: roadmapId,
      userXp: userXp,
      completedUnitIds: completedUnitIds,
    );

    final List<dynamic> unitsJson = response['units'] as List<dynamic>? ?? [];
    return unitsJson
        .whereType<Map<String, dynamic>>()
        .map((json) => LearningUnitModel.fromJson(json).toEntity())
        .toList();
  }

  Future<Map<String, dynamic>> getLearningPathJson({
    required int roadmapId,
    required int userXp,
    required Set<int> completedUnitIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final List<LearningUnitEntity> units = [
      LearningUnitEntity(
        id: 1,
        roadmapId: roadmapId,
        title: 'الدرس 1',
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
        title: 'التحدي النهائي',
        position: 7,
        type: LearningUnitType.challenge,
        status: LearningUnitStatus.locked,
        requiredXp: XpRules.challengeUnlockMinXp,
      ),
    ];

    final List<LearningUnitEntity> updated = _applyUnlockLogic(
      units,
      completedUnitIds,
      userXp,
    );

    return <String, dynamic>{
      'path_id': roadmapId,
      'units': updated
          .map((unit) => LearningUnitModel.fromEntity(unit).toJson())
          .toList(),
    };
  }

  List<LearningUnitEntity> _applyUnlockLogic(
    List<LearningUnitEntity> units,
    Set<int> completedUnitIds,
    int userXp,
  ) {
    if (units.isEmpty) return <LearningUnitEntity>[];

    final List<LearningUnitEntity> sortedUnits = [...units]
      ..sort((a, b) => a.position.compareTo(b.position));
    final List<LearningUnitEntity> updated = <LearningUnitEntity>[];

    for (int i = 0; i < sortedUnits.length; i++) {
      final LearningUnitEntity unit = sortedUnits[i];
      final bool isCompleted = completedUnitIds.contains(unit.id);

      if (isCompleted) {
        updated.add(unit.copyWith(status: LearningUnitStatus.completed));
        continue;
      }

      if (i == 0) {
        updated.add(unit.copyWith(status: LearningUnitStatus.unlocked));
        continue;
      }

      if (unit.type == LearningUnitType.lesson) {
        final LearningUnitEntity previous = updated[i - 1];
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
            .every((lesson) => completedUnitIds.contains(lesson.id));
        updated.add(
          allPreviousLessonsDone
              ? unit.copyWith(status: LearningUnitStatus.unlocked)
              : unit,
        );
        continue;
      }

      if (unit.type == LearningUnitType.challenge) {
        final bool allPreviousUnitsCompleted = sortedUnits
            .where((other) => other.position < unit.position)
            .every((other) => completedUnitIds.contains(other.id));
        final bool hasRequiredXp = userXp >= unit.requiredXp;

        updated.add(
          allPreviousUnitsCompleted && hasRequiredXp
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
