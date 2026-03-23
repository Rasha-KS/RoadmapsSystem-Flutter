import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/notification_entity.dart';
import 'notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.notifications),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل الإشعارات.');

    final items = _extractList(
      response['data'],
      keys: const ['notifications', 'items', 'data', 'results'],
    );

    return items.map(NotificationModel.fromJson).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.notificationsUnreadCount),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل عدد الإشعارات.');

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

  Future<void> readAllNotifications() async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.notificationsReadAll),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تعليم الإشعارات كمقروءة.');
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    String fallbackMessage = 'تعذر تحميل البيانات.',
  }) {
    if (response.containsKey('success') && response['success'] != true) {
      final message = response['message']?.toString().trim();
      throw ApiException(
        message == null || message.isEmpty ? fallbackMessage : message,
      );
    }
  }

  List<Map<String, dynamic>> _extractList(
    dynamic payload, {
    required List<String> keys,
  }) {
    if (payload == null) return [];

    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    if (payload is Map<String, dynamic>) {
      for (final key in keys) {
        final value = payload[key];
        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    throw const ParsingException();
  }
}
