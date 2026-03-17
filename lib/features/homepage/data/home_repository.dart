import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import '../domain/home_entity.dart';
import 'home_model.dart';

class HomeRepository {
  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<HomeCourseEntity>> getRecommendedCourses() async {
    // Fetch suggested roadmaps for the Home "recommended" section.
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.suggestedRoadmaps),
    );
    _ensureSuccess(response);

    final items = _extractList(
      response['data'],
      keys: const ['roadmaps', 'suggested_roadmaps', 'items', 'data', 'results'],
    );

    return items.map(_mapSuggestedRoadmap).toList();
  }

  Future<List<HomeCourseEntity>> getMyCourses() async {
    // Fetch the latest 3 enrollments for the Home "my courses" section.
    final response = await _apiClient.get(
      '${ApiConstants.url(ApiConstants.enrollments)}?per_page=3',
    );
    _ensureSuccess(response);

    final items = _extractList(
      response['data'],
      keys: const ['enrollments', 'items', 'data', 'results'],
    );

    return items.map(_mapEnrollment).toList();
  }

  Future<void> deleteMyCourse(int courseId) async {
    // Unenroll the user from a roadmap.
    final response = await _apiClient.delete(
      ApiConstants.url(ApiConstants.unenrollRoadmap(courseId)),
    );
    if (_isNotEnrolled(response)) {
      return;
    }
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر إلغاء الاشتراك في المسار.',
    );
  }

  Future<void> resetMyCourse(int courseId) async {
    // Reset uses the same enroll endpoint as requested.
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.enrollRoadmap(courseId)),
    );
    if (_isAlreadyEnrolled(response)) {
      return;
    }
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر إعادة ضبط المسار.',
    );
  }

  Future<void> enrollCourse(int courseId) async {
    // Enroll the user in a roadmap.
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.enrollRoadmap(courseId)),
    );

    if (_isAlreadyEnrolled(response)) {
      return;
    }

    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر الاشتراك في المسار.',
    );
  }

  Future<HomeCourseEntity> getRoadmapDetails(int roadmapId) async {
    // Fetch roadmap details when opening from the card.
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.roadmapDetails(roadmapId)),
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر تحميل بيانات المسار.',
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParsingException();
    }

    return HomeCourseModel(
      id: _asInt(data['id']),
      title: _asString(data['title']),
      level: _asString(
        data['level_arabic'] ?? data['level'],
        fallback: 'غير محدد',
      ),
      description: _asString(data['description'], fallback: ''),
      status: _asOptionalString(data['status']),
    );
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    String fallbackMessage = 'تعذر تحميل البيانات.',
  }) {
    if (response.containsKey('success') && response['success'] != true) {
      final message = _normalizeMessage(response['message']);
      throw ApiException(
        message ?? fallbackMessage,
      );
    }
  }

  bool _isAlreadyEnrolled(Map<String, dynamic> response) {
    if (response['success'] == true) return false;

    final message = response['message'];
    if (message is String &&
        message.toLowerCase().contains('already enrolled')) {
      return true;
    }

    final errors = response['errors'];
    if (errors is Map<String, dynamic> && errors['status'] == 'active') {
      return true;
    }

    return false;
  }

  bool _isNotEnrolled(Map<String, dynamic> response) {
    if (response['success'] == true) return false;

    final message = response['message'];
    if (message is String &&
        message.toLowerCase().contains('not enrolled')) {
      return true;
    }

    final errors = response['errors'];
    if (errors is Map<String, dynamic> && errors['status'] == 'inactive') {
      return true;
    }

    return false;
  }

  String? _normalizeMessage(dynamic message) {
    if (message is! String) return null;
    final text = message.trim();
    if (text.isEmpty) return null;

    final lower = text.toLowerCase();
    if (lower.contains('already enrolled')) {
      return 'أنت مشترك بالفعل في هذا المسار.';
    }
    if (lower.contains('not enrolled')) {
      return 'أنت غير مشترك في هذا المسار.';
    }
    if (lower.contains('unauthorized')) {
      return 'يرجى تسجيل الدخول مرة أخرى.';
    }
    return text;
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

  HomeCourseEntity _mapSuggestedRoadmap(Map<String, dynamic> json) {
    final payload = _extractRoadmapPayload(json);

    return HomeCourseModel(
      id: _asInt(payload['id']),
      title: _asString(payload['title'] ?? payload['name']),
      level: _asString(
        payload['level'] ?? payload['level_name'] ?? payload['difficulty'],
        fallback: 'غير محدد',
      ),
      description: _asString(
        payload['description'] ?? payload['summary'],
        fallback: '',
      ),
      status: _asOptionalString(payload['status'] ?? json['status']),
    );
  }

  HomeCourseEntity _mapEnrollment(Map<String, dynamic> json) {
    final payload = _extractRoadmapPayload(json);
    final status = _asOptionalString(
      json['status'] ?? json['enrollment_status'] ?? json['state'],
    );

    return HomeCourseModel(
      id: _asInt(payload['id'] ?? json['roadmap_id']),
      title: _asString(
        payload['title'] ?? payload['name'] ?? json['roadmap_title'],
      ),
      level: _asString(
        payload['level'] ?? payload['level_name'] ?? payload['difficulty'],
        fallback: 'غير محدد',
      ),
      description: _asString(
        payload['description'] ?? payload['summary'],
        fallback: '',
      ),
      status: status ?? 'غير محدد',
    );
  }

  Map<String, dynamic> _extractRoadmapPayload(Map<String, dynamic> json) {
    final roadmap = json['roadmap'];
    if (roadmap is Map<String, dynamic>) return roadmap;
    final roadmapItem = json['roadmap_item'];
    if (roadmapItem is Map<String, dynamic>) return roadmapItem;
    return json;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw const ParsingException();
  }

  String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    return fallback;
  }

  String? _asOptionalString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}
