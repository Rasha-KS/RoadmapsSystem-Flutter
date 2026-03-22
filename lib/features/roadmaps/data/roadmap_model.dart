import 'package:roadmaps/core/utils/roadmap_display.dart';

import '../domain/roadmap_entity.dart';

class RoadmapModel extends RoadmapEntity {
  const RoadmapModel({
    required super.id,
    required super.title,
    required super.level,
    required super.description,
    super.status,
    super.isActive,
    super.isEnrolled,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final isEnrolled = _asBool(json['is_enrolled']);
    final level = RoadmapDisplay.level(
      json['level_arabic'] ?? json['level'] ?? json['difficulty'],
    );
    final rawStatus = json['status'];
    final status = rawStatus == null || rawStatus.toString().trim().isEmpty
        ? (isEnrolled ? 'مشترك' : null)
        : RoadmapDisplay.status(rawStatus);

    return RoadmapModel(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      level: level,
      description: _asString(json['description']),
      status: status,
      isActive: _asBool(json['is_active'], fallback: true),
      isEnrolled: isEnrolled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'level': level,
        'description': description,
        'status': status,
        'is_active': isActive,
        'is_enrolled': isEnrolled,
      };

  static int _asInt(dynamic value) {
    if (value is int) return value;

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;

    throw const FormatException('Invalid roadmap id');
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
}
