import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

import '../domain/user_roadmap_entity.dart';
import 'profile_user_model.dart';
import 'user_roadmap_model.dart';

class ProfileRepository {
  ProfileRepository({
    required UserRepository userRepository,
    ApiClient? apiClient,
  })  : _userRepository = userRepository,
        _apiClient = apiClient ?? ApiClient();

  final UserRepository _userRepository;
  final ApiClient _apiClient;
  final List<UserRoadmapModel> _cachedRoadmaps = [];

  Future<UserEntity> getUserProfile() async {
    final user = await _userRepository.getCurrentUser();
    return ProfileUserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastActivityAt: user.lastActivityAt,
      isNotificationsEnabled: user.isNotificationsEnabled,
      profileImageUrl: user.profileImageUrl,
    );
  }

  Future<List<UserRoadmapEntity>> getUserRoadmaps(int userId) async {
    final response = await _apiClient.get(
      '${ApiConstants.url(ApiConstants.enrollments)}?per_page=1000',
    );
    _ensureSuccess(response);

    final items = _extractEnrollments(response['data']);
    final roadmaps = items.map(UserRoadmapModel.fromJson).toList();

    _cachedRoadmaps
      ..clear()
      ..addAll(roadmaps);

    return roadmaps;
  }

  Future<void> deleteUserRoadmap(int enrollmentId) async {
    final roadmapId = await _resolveRoadmapId(enrollmentId);
    final response = await _apiClient.delete(
      ApiConstants.url(ApiConstants.unenrollRoadmap(roadmapId)),
    );
    if (_isAlreadyUnenrolled(response)) {
      return;
    }
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر إلغاء الاشتراك في المسار.',
    );
  }

  Future<void> resetUserRoadmap(int enrollmentId) async {
    final roadmapId = await _resolveRoadmapId(enrollmentId);
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.enrollRoadmap(roadmapId)),
    );
    if (_isAlreadyEnrolled(response)) {
      return;
    }
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر إعادة ضبط المسار.',
    );
  }

  Future<int> _resolveRoadmapId(int enrollmentId) async {
    for (final roadmap in _cachedRoadmaps) {
      if (roadmap.enrollmentId == enrollmentId) {
        return roadmap.roadmapId;
      }
    }

    final roadmaps = await getUserRoadmaps(0);
    for (final roadmap in roadmaps) {
      if (roadmap.enrollmentId == enrollmentId) {
        return roadmap.roadmapId;
      }
    }

    throw ApiException('لم يتم العثور على المسار المطلوب.', statusCode: 404);
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    String fallbackMessage = 'تعذر تحميل البيانات.',
  }) {
    if (response.containsKey('success') && response['success'] != true) {
      final message = _normalizeMessage(response['message']);
      throw ApiException(message ?? fallbackMessage);
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

  bool _isAlreadyUnenrolled(Map<String, dynamic> response) {
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

  List<Map<String, dynamic>> _extractEnrollments(dynamic payload) {
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
}
