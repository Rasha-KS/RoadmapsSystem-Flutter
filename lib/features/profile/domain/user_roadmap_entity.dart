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
}
