import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/notification_entity.dart';
import 'notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;
  String? _lastLoadErrorMessage;

  String? get lastLoadErrorMessage => _lastLoadErrorMessage;

  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.url(ApiConstants.notifications),
      );
      _ensureSuccess(response, fallbackMessage: 'تعذر تحميل الإشعارات.');

      final items = _extractList(
        response['data'],
        keys: const ['notifications', 'items', 'data', 'results'],
      );

      final notifications = items.map(NotificationModel.fromJson).toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      _lastLoadErrorMessage = null;
      return notifications;
    } on TimeoutApiException {
      _lastLoadErrorMessage = 'تعذر تحميل الإشعارات حاليًا. حاول مرة أخرى.';
      return <NotificationEntity>[];
    } on NetworkException {
      _lastLoadErrorMessage =
          'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.';
      return <NotificationEntity>[];
    } on ParsingException {
      _lastLoadErrorMessage = 'تعذر قراءة بيانات الإشعارات.';
      return <NotificationEntity>[];
    }
  }

  Future<int> getUnreadCount() async {
    try {
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
      _lastLoadErrorMessage = null;
      return parsed;
    } on TimeoutApiException {
      _lastLoadErrorMessage = 'تعذر تحميل عدد الإشعارات حاليًا. حاول مرة أخرى.';
      return 0;
    } on NetworkException {
      _lastLoadErrorMessage =
          'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.';
      return 0;
    } on ParsingException {
      _lastLoadErrorMessage = 'تعذر قراءة عدد الإشعارات.';
      return 0;
    }
  }

  Future<void> readAllNotifications() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.url(ApiConstants.notificationsReadAll),
      );
      _ensureSuccess(response, fallbackMessage: 'تعذر تعليم الإشعارات كمقروءة.');
    } on TimeoutApiException {
      _lastLoadErrorMessage = 'تعذر تحديث الإشعارات حاليًا. حاول مرة أخرى.';
    } on NetworkException {
      _lastLoadErrorMessage =
          'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.';
    }
  }

  Future<void> saveDeviceToken({
    required String token,
    required String deviceType,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.saveDeviceToken),
      body: <String, dynamic>{
        'token': token,
        'device_type': deviceType,
      },
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر حفظ رمز الجهاز.');
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
