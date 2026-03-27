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
  final String label;
  final int position;
  final LearningUnitType type;
  final LearningUnitStatus status;
  final int entityId;
  final String? description;
  final bool isLocked;
  final bool isCompleted;
  final bool isActive;
  final bool trackingExists;
  final bool trackingIsComplete;
  final DateTime? trackingLastUpdatedAt;
  final int requiredXp;

  LearningUnitEntity({
    required this.id,
    required this.roadmapId,
    required this.title,
    required this.label,
    required this.position,
    required this.type,
    required this.status,
    required this.entityId,
    required this.description,
    required this.isLocked,
    required this.isCompleted,
    required this.isActive,
    required this.trackingExists,
    required this.trackingIsComplete,
    required this.trackingLastUpdatedAt,
    this.requiredXp = 0,
  });

  LearningUnitEntity copyWith({
    LearningUnitStatus? status,
    bool? isLocked,
    bool? isCompleted,
  }) {
    return LearningUnitEntity(
      id: id,
      roadmapId: roadmapId,
      title: title,
      label: label,
      position: position,
      type: type,
      status: status ?? this.status,
      entityId: entityId,
      description: description,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive,
      trackingExists: trackingExists,
      trackingIsComplete: trackingIsComplete,
      trackingLastUpdatedAt: trackingLastUpdatedAt,
      requiredXp: requiredXp,
    );
  }
}
