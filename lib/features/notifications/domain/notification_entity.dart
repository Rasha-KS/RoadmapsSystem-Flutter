class NotificationEntity {
  final int id;
  final String title;
  final String message;
  final DateTime scheduledAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.scheduledAt,
    required this.isRead,
  });
}
