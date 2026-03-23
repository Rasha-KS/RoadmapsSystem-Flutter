enum SmartInstructorMessageStatus {
  sending,
  sent,
  failed,
}

class SmartInstructorMessageEntity {
  final int id;
  final String? text;
  final String? attachmentPath;
  final bool isFromUser;
  final DateTime sentAt;
  final SmartInstructorMessageStatus status;
  final String? failureMessage;

  const SmartInstructorMessageEntity({
    required this.id,
    required this.isFromUser,
    required this.sentAt,
    this.status = SmartInstructorMessageStatus.sent,
    this.failureMessage,
    this.text,
    this.attachmentPath,
  });

  SmartInstructorMessageEntity copyWith({
    int? id,
    String? text,
    String? attachmentPath,
    bool? isFromUser,
    DateTime? sentAt,
    SmartInstructorMessageStatus? status,
    String? failureMessage,
  }) {
    return SmartInstructorMessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      isFromUser: isFromUser ?? this.isFromUser,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }
}
