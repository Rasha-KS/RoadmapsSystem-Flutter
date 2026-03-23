import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_session_entity.dart';

class SmartInstructorSessionModel extends SmartInstructorSessionEntity {
  const SmartInstructorSessionModel({
    required super.id,
    required super.title,
    super.userId,
    super.lastActivityAt,
    super.createdAt,
    super.updatedAt,
  });

  factory SmartInstructorSessionModel.fromJson(Map<String, dynamic> json) {
    return SmartInstructorSessionModel(
      id: _asInt(json['id']),
      userId: _asNullableInt(json['user_id']),
      title: _asString(json['title'], fallback: 'محادثة جديدة'),
      lastActivityAt: _asDateTime(json['last_activity_at']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw const FormatException('Invalid integer value');
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String _asString(dynamic value, {required String fallback}) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    return fallback;
  }

  static DateTime? _asDateTime(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
