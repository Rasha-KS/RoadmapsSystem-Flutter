enum LearningUnitType {
  lesson,
  quiz,
  challenge,
}

enum LearningUnitStatus {
  locked,
  unlocked,
  completed,
}

class LearningUnitEntity {
  final int id;
  final int roadmapId;
  final String title;
  final int position;
  final LearningUnitType type;
  final LearningUnitStatus status;
  final int requiredXp;

  LearningUnitEntity({
    required this.id,
    required this.roadmapId,
    required this.title,
    required this.position,
    required this.type,
    required this.status,
    this.requiredXp = 0,
  });

  LearningUnitEntity copyWith({
    LearningUnitStatus? status,
  }) {
    return LearningUnitEntity(
      id: id,
      roadmapId: roadmapId,
      title: title,
      position: position,
      type: type,
      status: status ?? this.status,
      requiredXp: requiredXp,
    );
  }
}
