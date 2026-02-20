class SmartInstructorMessageEntity {
  final int id;
  final String? text;
  final String? attachmentPath;
  final bool isFromUser;
  final DateTime sentAt;

  const SmartInstructorMessageEntity({
    required this.id,
    required this.isFromUser,
    required this.sentAt,
    this.text,
    this.attachmentPath,
  });
}
