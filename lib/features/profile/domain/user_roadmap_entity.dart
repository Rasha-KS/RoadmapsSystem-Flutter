class UserRoadmapEntity {
  final int enrollmentId;
  final int userId;
  final int roadmapId;
  final String title;
  final String level;
  final String description;
  final bool isActive;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int xpPoints;
  final int progressPercentage;

  UserRoadmapEntity({
    required this.enrollmentId,
    required this.userId,
    required this.roadmapId,
    required this.title,
    required this.level,
    required this.description,
    required this.isActive,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    required this.xpPoints,
    required this.progressPercentage,
  });

  UserRoadmapEntity copyWith({
    int? enrollmentId,
    int? userId,
    int? roadmapId,
    String? title,
    String? level,
    String? description,
    bool? isActive,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? xpPoints,
    int? progressPercentage,
  }) {
    return UserRoadmapEntity(
      enrollmentId: enrollmentId ?? this.enrollmentId,
      userId: userId ?? this.userId,
      roadmapId: roadmapId ?? this.roadmapId,
      title: title ?? this.title,
      level: level ?? this.level,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      xpPoints: xpPoints ?? this.xpPoints,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}
