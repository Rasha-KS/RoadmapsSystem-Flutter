import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/core/cache/lesson_content_cache.dart';

import '../domain/learning_path_entity.dart';
import 'learning_path_model.dart';

class LearningPathRepository {
  LearningPathRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final LessonContentCache _cache = LessonContentCache.instance;

  Future<LearningPathEntity> getLearningPath({required int roadmapId}) async {
    try {
      final cached = await _cache.readLearningPath(roadmapId);
      if (cached != null) {
        final overriddenCached = await _cache.applyProgressOverrides(cached);
        if (!identical(overriddenCached, cached)) {
          try {
            await _cache.writeLearningPath(roadmapId, overriddenCached);
          } catch (_) {}
        }
        return overriddenCached;
      }
    } catch (_) {}

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

    final entity = LearningPathModel.fromJson(data).toEntity();
    final overriddenEntity = await _cache.applyProgressOverrides(entity);
    try {
      await _cache.writeLearningPath(roadmapId, overriddenEntity);
    } catch (_) {}
    return overriddenEntity;
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
}
