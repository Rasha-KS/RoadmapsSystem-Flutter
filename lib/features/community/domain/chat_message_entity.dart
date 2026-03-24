enum ChatMessageStatus {
  sending,
  sent,
  failed,
}

class ChatMessageEntity {
  static const Object _unset = Object();

  final int id;
  final int chatRoomId;
  final int userId;
  final String? content;
  final DateTime sentAt;
  final String? attachmentPath;
  final String? senderName;
  final String? senderAvatarUrl;
  final ChatMessageStatus status;
  final String? failureMessage;
  final bool isLocal;

  const ChatMessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.userId,
    required this.sentAt,
    this.content,
    this.attachmentPath,
    this.senderName,
    this.senderAvatarUrl,
    this.status = ChatMessageStatus.sent,
    this.failureMessage,
    this.isLocal = false,
  });

  ChatMessageEntity copyWith({
    int? id,
    int? chatRoomId,
    int? userId,
    String? content,
    DateTime? sentAt,
    String? attachmentPath,
    String? senderName,
    String? senderAvatarUrl,
    ChatMessageStatus? status,
    Object? failureMessage = _unset,
    bool? isLocal,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      status: status ?? this.status,
      failureMessage: failureMessage == _unset
          ? this.failureMessage
          : failureMessage as String?,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
