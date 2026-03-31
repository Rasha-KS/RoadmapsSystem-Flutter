import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/roadmap_entity.dart';
import 'roadmap_model.dart';

class RoadmapRepository {
  RoadmapRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  String? _lastLoadErrorMessage;

  String? get lastLoadErrorMessage => _lastLoadErrorMessage;

  Future<List<RoadmapEntity>> getRoadmaps() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.url(ApiConstants.roadmaps),
      );
      _ensureSuccess(
        response,
        fallbackMessage: 'تعذر تحميل المسارات.',
      );

      final items = _extractList(
        response['data'],
        keys: const ['roadmaps', 'items', 'data', 'results'],
      );

      final roadmaps = items
          .map(RoadmapModel.fromJson)
          .where((roadmap) => roadmap.isActive)
          .toList();
      _lastLoadErrorMessage = null;
      return roadmaps;
    } on TimeoutApiException {
      _lastLoadErrorMessage = 'تعذر تحميل المسارات حاليًا. حاول مرة أخرى.';
      return <RoadmapEntity>[];
    } on NetworkException {
      _lastLoadErrorMessage = 'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.';
      return <RoadmapEntity>[];
    } on ParsingException {
      _lastLoadErrorMessage = 'تعذر قراءة بيانات المسارات.';
      return <RoadmapEntity>[];
    }
  }

  Future<List<RoadmapEntity>> getMyCourses() async {
    final roadmaps = await getRoadmaps();
    return roadmaps.where((roadmap) => roadmap.isEnrolled).toList();
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
