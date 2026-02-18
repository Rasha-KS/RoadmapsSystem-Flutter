import '../domain/notification_entity.dart';
import 'notification_model.dart';

class NotificationsRepository {
  // Temporary fake table until notifications API is connected.
  final List<Map<String, dynamic>> _notificationsTable = [
    {
      'id': 1,
      'title': 'عنوان الإشعار',
      'message': 'نحن ننتظرك لإكمال مسارك في ++C',
      'scheduled_at': DateTime(2026, 2, 1),
      'is_read': false,
    },
    {
      'id': 2,
      'title': 'عنوان الإشعار',
      'message': 'إعلان لمخيم تدريبي في HTML طوّر من مهاراتك وتعلم لغة جديدة',
      'scheduled_at': DateTime(2026, 1, 21),
      'is_read': false,
    },
    {
      'id': 3,
      'title': 'عنوان الإشعار',
      'message': 'إعلان لحضور محاضرة عن استعمال Python في AI',
      'scheduled_at': DateTime(2026, 1, 18),
      'is_read': true,
    },
    {
      'id': 4,
      'title': 'عنوان الإشعار',
      'message': 'صوّر من مهاراتك وتعلّم لغة جديدة',
      'scheduled_at': DateTime(2026, 1, 12),
      'is_read': true,
    },
    {
      'id': 5,
      'title': 'عنوان الإشعار',
      'message': 'نحن ننتظرك لإكمال مسارك في ++C',
      'scheduled_at': DateTime(2026, 1, 9),
      'is_read': true,
    },
    {
      'id': 6,
      'title': 'عنوان الإشعار',
      'message': 'إعلان لمخيم تدريبي في HTML طوّر من مهاراتك وتعلم لغة جديدة',
      'scheduled_at': DateTime(2026, 1, 4),
      'is_read': true,
    },
  ];

  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 320));

    final items = _notificationsTable
        .map(NotificationModel.fromJson)
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return items;
  }
}
