import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/announcement_entity.dart';
import 'announcement_model.dart';

class AnnouncementsRepository {
  AnnouncementsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<AnnouncementEntity>> getActiveAnnouncements() async {
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

    return items.map(AnnouncementModel.fromJson).toList();
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
