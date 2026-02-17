import 'package:roadmaps/features/community/domain/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.chatRoomId,
    required super.userId,
    required super.sentAt,
    super.content,
    super.attachmentPath,
    super.isLocal,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      chatRoomId: json['chat_room_id'] as int,
      userId: json['user_id'] as int,
      content: json['content'] as String?,
      sentAt: json['sent_at'] as DateTime,
      attachmentPath: json['attachment_path'] as String?,
      isLocal: (json['is_local'] as bool?) ?? false,
    );
  }
}
