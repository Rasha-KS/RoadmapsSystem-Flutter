import '../domain/user_roadmap_entity.dart';

class UserRoadmapModel extends UserRoadmapEntity {
  UserRoadmapModel({
    required super.enrollmentId,
    required super.userId,
    required super.roadmapId,
    required super.title,
    required super.level,
    required super.description,
    required super.isActive,
    required super.status,
    required super.startedAt,
    required super.completedAt,
    required super.xpPoints,
    required super.progressPercentage,
  });

  factory UserRoadmapModel.fromJson(Map<String, dynamic> json) {
    return UserRoadmapModel(
      enrollmentId: json['enrollment_id'] as int,
      userId: json['user_id'] as int,
      roadmapId: json['roadmap_id'] as int,
      title: json['title'] as String,
      level: json['level'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as bool,
      status: json['status'] as String,
      startedAt: json['started_at'] as DateTime,
      completedAt: json['completed_at'] as DateTime?,
      xpPoints: json['xp_points'] as int,
      progressPercentage: json['progress_percentage'] as int,
    );
  }
}
