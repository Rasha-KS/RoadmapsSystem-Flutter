import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/announcement_entity.dart';
import 'announcement_model.dart';

class AnnouncementsRepository {
  AnnouncementsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  String? _lastLoadErrorMessage;

  String? get lastLoadErrorMessage => _lastLoadErrorMessage;

  Future<List<AnnouncementEntity>> getActiveAnnouncements() async {
    try {
      // Fetch announcements for the Home announcements section.
      final response = await _apiClient.get(
        ApiConstants.url(ApiConstants.announcements),
      );

      if (response.containsKey('success') && response['success'] != true) {
        final message = response['message'];
        throw ApiException(
          message is String && message.trim().isNotEmpty
              ? message.trim()
              : 'تعذر تحميل الإعلانات.',
        );
      }

      final items = _extractList(
        response['data'],
        keys: const ['announcements', 'items', 'data', 'results'],
      );

      final announcements = items.map(AnnouncementModel.fromJson).toList();
      _lastLoadErrorMessage = null;
      return announcements;
    } on TimeoutApiException {
      _lastLoadErrorMessage = 'تعذر تحميل الإعلانات حاليًا. حاول مرة أخرى.';
      return <AnnouncementEntity>[];
    } on NetworkException {
      _lastLoadErrorMessage =
          'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.';
      return <AnnouncementEntity>[];
    } on ParsingException {
      _lastLoadErrorMessage = 'تعذر قراءة بيانات الإعلانات.';
      return <AnnouncementEntity>[];
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
