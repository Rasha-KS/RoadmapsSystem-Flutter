import 'package:roadmaps/core/data/user/user_model.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.chatRoomId,
    required super.userId,
    required super.sentAt,
    super.content,
    super.attachmentPath,
    super.senderName,
    super.senderAvatarUrl,
    super.status,
    super.failureMessage,
    super.isLocal,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackRoomId,
    int fallbackUserId = 0,
    String? fallbackContent,
    DateTime? fallbackSentAt,
  }) {
    final userPayload = _extractMap(json, const ['user', 'sender', 'author']);
    final roomPayload = _extractMap(json, const ['room', 'chat_room']);

    return ChatMessageModel(
      id: _asInt(json['id']) ?? DateTime.now().microsecondsSinceEpoch,
      chatRoomId: _asInt(json['chat_room_id']) ??
          _asInt(json['room_id']) ??
          _asInt(roomPayload?['id']) ??
          fallbackRoomId,
      userId: _asInt(json['user_id']) ??
          _asInt(json['sender_id']) ??
          _asInt(json['author_id']) ??
          _asInt(userPayload?['id']) ??
          fallbackUserId,
      content: _asString(json['content']) ??
          _asString(json['message']) ??
          _asString(json['text']) ??
          fallbackContent,
      sentAt: _asDate(json['sent_at']) ??
          _asDate(json['created_at']) ??
          _asDate(json['timestamp']) ??
          _asDate(json['inserted_at']) ??
          fallbackSentAt ??
          DateTime.now(),
      attachmentPath: _normalizeUrl(
        _asString(json['attachment_path']) ??
            _asString(json['attachment']) ??
            _asString(json['image']) ??
            _asString(json['image_url']) ??
            _asString(json['file_url']),
      ),
      senderName: _asString(json['username']) ??
          _asString(json['user_name']) ??
          _asString(json['author_name']) ??
          _asString(userPayload?['username']) ??
          _asString(userPayload?['name']),
      senderAvatarUrl: _normalizeUrl(
        _asString(json['profile_picture']) ??
            _asString(json['profile_image_url']) ??
            _asString(json['profile_image']) ??
            _asString(json['avatar']) ??
            _asString(json['avatar_url']) ??
            _asString(userPayload?['profile_picture']) ??
            _asString(userPayload?['profile_image_url']) ??
            _asString(userPayload?['profile_image']) ??
            _asString(userPayload?['avatar']) ??
            _asString(userPayload?['avatar_url']),
      ),
      status: ChatMessageStatus.sent,
      isLocal: _asBool(json['is_local']) ?? false,
    );
  }

  static Map<String, dynamic>? _extractMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.cast<String, dynamic>();
      }
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _asString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static DateTime? _asDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) {
      final milliseconds = value > 9999999999 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }

    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value?.toString().trim().toLowerCase();
    if (text == '1' || text == 'true') return true;
    if (text == '0' || text == 'false') return false;
    return null;
  }

  static String? _normalizeUrl(String? value) {
    return UserModel.normalizeProfileImageUrl(value);
  }
}
