import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/learning_path_entity.dart';
import 'learning_path_model.dart';

class LearningPathRepository {
  LearningPathRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<LearningPathEntity> getLearningPath({required int roadmapId}) async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.learningPath(roadmapId)),
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر تحميل المسار التعليمي.',
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParsingException();
    }

    return LearningPathModel.fromJson(data).toEntity();
  }

  Future<int> getRoadmapXp({required int roadmapId}) async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.roadmapXp(roadmapId)),
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر تحميل نقاط الخبرة للمسار.',
    );

    final dynamic payload = response['data'] ?? response;
    final xp = _extractXp(payload);
    if (xp == null) {
      throw const ParsingException();
    }
    return xp;
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    if (response.containsKey('success') && response['success'] != true) {
      final message = response['message']?.toString().trim();
      throw ApiException(
        message == null || message.isEmpty ? fallbackMessage : message,
      );
    }
  }

  int? _extractXp(dynamic payload) {
    if (payload is int) return payload;
    if (payload is num) return payload.toInt();

    if (payload is Map<String, dynamic>) {
      final candidates = <dynamic>[
        payload['xp'],
        payload['xp_points'],
        payload['points'],
        payload['value'],
      ];
      for (final candidate in candidates) {
        final parsed = _extractXp(candidate);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    final parsed = int.tryParse(payload?.toString() ?? '');
    return parsed;
  }
}
