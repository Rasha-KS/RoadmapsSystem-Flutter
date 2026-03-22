import 'package:roadmaps/core/utils/roadmap_display.dart';

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
    final roadmap = _extractRoadmap(json);
    final startedAt = _parseDateTime(json['started_at']);
    final completedAt = _parseDateTime(json['completed_at']);
    final status = RoadmapDisplay.status(
      json['status'] ?? json['enrollment_status'] ?? json['state'],
    );

    return UserRoadmapModel(
      enrollmentId: _asInt(json['id'] ?? json['enrollment_id']),
      userId: _asInt(json['user_id']),
      roadmapId: _asInt(roadmap['id'] ?? json['roadmap_id']),
      title: _asString(roadmap['title'] ?? roadmap['name'] ?? json['title']),
      level: RoadmapDisplay.level(
        roadmap['level'] ?? roadmap['level_arabic'] ?? json['level'],
      ),
      description: _asString(
        roadmap['description'] ?? roadmap['summary'] ?? json['description'],
        fallback: '',
      ),
      isActive: _asBool(roadmap['is_active'] ?? json['is_active'], fallback: true),
      status: status,
      startedAt: startedAt ?? DateTime.now(),
      completedAt: completedAt,
      xpPoints: _asInt(json['xp_points'], fallback: 0),
      progressPercentage: _asInt(
        json['progress_percentage'],
        fallback: completedAt != null ? 100 : 0,
      ),
    );
  }

  static Map<String, dynamic> _extractRoadmap(Map<String, dynamic> json) {
    final roadmap = json['roadmap'];
    if (roadmap is Map<String, dynamic>) {
      return roadmap;
    }

    return json;
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    return fallback;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
    return fallback;
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();
    switch (normalized) {
      case '1':
      case 'true':
      case 'yes':
        return true;
      case '0':
      case 'false':
      case 'no':
        return false;
      default:
        return fallback;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
