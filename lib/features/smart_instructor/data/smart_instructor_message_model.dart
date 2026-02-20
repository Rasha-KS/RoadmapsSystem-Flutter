import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

class SmartInstructorMessageModel extends SmartInstructorMessageEntity {
  const SmartInstructorMessageModel({
    required super.id,
    required super.isFromUser,
    required super.sentAt,
    super.text,
    super.attachmentPath,
  });

  factory SmartInstructorMessageModel.fromJson(Map<String, dynamic> json) {
    return SmartInstructorMessageModel(
      id: json['id'] as int,
      text: json['text'] as String?,
      attachmentPath: json['attachment_path'] as String?,
      isFromUser: json['is_from_user'] as bool,
      sentAt: json['sent_at'] as DateTime,
    );
  }
}
