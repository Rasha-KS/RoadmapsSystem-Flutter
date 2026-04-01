import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/auth/token_manager.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/features/lessons/data/lesson_model.dart';
import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';
import 'package:roadmaps/features/lessons/domain/resource_entity.dart';
import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';

class LessonRepository {
  LessonRepository({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager;

  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  Future<LessonEntity?> getLesson(String learningUnitId) async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.unitLessons(int.parse(learningUnitId))),
      headers: await _authHeaders(),
      timeout: const Duration(seconds: 60),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل الدرس.');

    final lessons = _extractList(response['data']);
    if (lessons.isEmpty) {
      return null;
    }

    return LessonModel.fromJson(lessons.first).toEntity();
  }

  Future<List<SubLessonEntity>> getSubLessons(int lessonId) async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.lessonSubLessons(lessonId)),
      headers: await _authHeaders(),
      timeout: const Duration(seconds: 60),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل الدروس الفرعية.');

    final items = _extractList(response['data']);
    final subLessons = items
        .map(SubLessonModel.fromJson)
        .map((item) => item.toEntity())
        .toList(growable: false);
    return subLessons;
  }

  Future<List<ResourceEntity>> getLessonResources(int subLessonId) async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.subLessonResources(subLessonId)),
      headers: await _authHeaders(),
      timeout: const Duration(seconds: 60),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل المصادر.');

    final items = _extractList(response['data']);
    final resources = items
        .map(ResourceModel.fromJson)
        .map((item) => item.toEntity())
        .toList(growable: false);
    return resources;
  }

  Future<void> completeLesson(int lessonId) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.completeLesson(lessonId)),
      headers: await _authHeaders(),
      timeout: const Duration(seconds: 60),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر إكمال الدرس.');
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    throw const ParsingException();
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

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenManager.getToken();
    if (token == null || token.trim().isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{
      'Authorization': 'Bearer ${token.trim()}',
    };
  }
}
