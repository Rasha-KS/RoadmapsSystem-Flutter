import '../domain/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.scheduledAt,
    required super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final dynamic scheduledAtRaw = json['scheduled_at'];

    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      scheduledAt: scheduledAtRaw is DateTime
          ? scheduledAtRaw
          : DateTime.parse(scheduledAtRaw.toString()),
      isRead: (json['is_read'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'scheduled_at': scheduledAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
