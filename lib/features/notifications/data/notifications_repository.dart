import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/notification_entity.dart';
import 'notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  // Temporary fake table until notifications API is connected.
  final List<Map<String, dynamic>> _notificationsTable = [
  {
    'id': 1,
    'title': 'تذكير بالدرس',
    'message': 'لا تنسَ إكمال درس المؤشرات في C++ اليوم.',
    'scheduled_at': DateTime(2026, 2, 1),
    'is_read': false,
  },
  {
    'id': 2,
    'title': 'تحدٍ جديد',
    'message': 'تم إضافة تحدٍ جديد في مسار الخوارزميات. جرّب حلّه الآن!',
    'scheduled_at': DateTime(2026, 1, 28),
    'is_read': false,
  },
  {
    'id': 3,
    'title': 'فعالية تقنية',
    'message': 'محاضرة مباشرة حول استخدام Python في الذكاء الاصطناعي اليوم الساعة 6 مساءً.',
    'scheduled_at': DateTime(2026, 1, 24),
    'is_read': true,
  },
 {
  'id': 4,
  'title': 'درس جديد',
  'message': 'تمت إضافة درس جديد في مسار HTML بعنوان: أساسيات النماذج (Forms).',
  'scheduled_at': DateTime(2026, 1, 20),
  'is_read': true,
},
  {
    'id': 5,
    'title': 'مخيم تدريبي',
    'message': 'التسجيل مفتوح لمخيم تطوير الويب لمدة 5 أيام. المقاعد محدودة.',
    'scheduled_at': DateTime(2026, 1, 15),
    'is_read': true,
  },
  {
    'id': 6,
    'title': 'تذكير بالتعلم',
    'message': 'لم تدخل التطبيق منذ 3 أيام. عد لإكمال مسارك في البرمجة.',
    'scheduled_at': DateTime(2026, 1, 10),
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

  Future<int> getUnreadCount() async {
    // Fetch unread notifications count for the bell icon indicator.
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.notificationsUnreadCount),
    );

    if (response.containsKey('success') && response['success'] != true) {
      final message = response['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : 'تعذر تحميل عدد الإشعارات.',
      );
    }

    final dynamic data = response['data'];
    final dynamic countValue = data is Map<String, dynamic>
        ? (data['unread_count'] ?? data['count'])
        : (response['unread_count'] ?? response['count']);
    final parsed = int.tryParse(countValue?.toString() ?? '');
    if (parsed == null) {
      throw const ParsingException();
    }
    return parsed;
  }
}
