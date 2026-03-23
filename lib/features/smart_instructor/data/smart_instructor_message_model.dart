import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

class SmartInstructorMessageModel extends SmartInstructorMessageEntity {
  const SmartInstructorMessageModel({
    required super.id,
    required super.isFromUser,
    required super.sentAt,
    super.status = SmartInstructorMessageStatus.sent,
    super.failureMessage,
    super.text,
    super.attachmentPath,
  });

  factory SmartInstructorMessageModel.fromJson(Map<String, dynamic> json) {
    final role = _asString(json['role'], fallback: '').toLowerCase();
    final body = json['body'] ?? json['text'];

    return SmartInstructorMessageModel(
      id: _asInt(json['id']),
      text: _asString(body, fallback: ''),
      attachmentPath: json['attachment_path'] as String?,
      isFromUser: role == 'user',
      sentAt: _asDateTime(json['created_at']) ?? DateTime.now(),
      status: SmartInstructorMessageStatus.sent,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw const FormatException('Invalid integer value');
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
