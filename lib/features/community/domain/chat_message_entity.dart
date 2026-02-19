class ChatMessageEntity {
  final int id;
  final int chatRoomId;
  final int userId;
  final String? content;
  final DateTime sentAt;
  final String? attachmentPath;
  final bool isLocal;

  const ChatMessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.userId,
    required this.sentAt,
    this.content,
    this.attachmentPath,
    this.isLocal = false,
  });

  ChatMessageEntity copyWith({
    int? id,
    int? chatRoomId,
    int? userId,
    String? content,
    DateTime? sentAt,
    String? attachmentPath,
    bool? isLocal,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
