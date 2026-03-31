import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/auth/token_manager.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/core/data/user/user_model.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

class ApiUserRepository implements UserRepository {
  ApiUserRepository({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager;

  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  @override
  Future<UserEntity> getCurrentUser() async {
    final token = await _tokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('لم يتم تسجيل الدخول بعد.');
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.url(ApiConstants.profile),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response['success'] != true) {
        final message = response['message'];
        throw ApiException(
          message is String && message.trim().isNotEmpty
              ? message.trim()
              : 'تعذر تحميل الملف الشخصي.',
        );
      }

      final data = response['data'];
      final payload = data is Map<String, dynamic> && data['user'] is Map
          ? data['user']
          : data;
      if (payload is! Map<String, dynamic>) {
        throw ParsingException();
      }

      return UserModel.fromJson(payload);
    } on UnauthorizedException {
      await _tokenManager.clearToken();
      rethrow;
    }
  }

  @override
  Future<UserEntity> updateCurrentUser({
    String? username,
    String? email,
    String? password,
    String? profileImageUrl,
    bool? isNotificationsEnabled,
  }) async {
    final current = await getCurrentUser();
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    if (profileImageUrl != null) {
      body['profile_image_url'] = profileImageUrl;
    }
    if (isNotificationsEnabled != null) {
      body['is_notifications_enabled'] = isNotificationsEnabled;
    }

    final response = await _apiClient.put(
      ApiConstants.url(ApiConstants.updateAccount),
      headers: await _authHeaders(),
      body: body,
    );
    if (response['success'] != true) {
      final message = response['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : 'تعذر تحديث بيانات الحساب.',
      );
    }

    final data = response['data'];
    final payload = data is Map<String, dynamic> && data['user'] is Map
        ? data['user']
        : data is Map<String, dynamic>
            ? data
            : <String, dynamic>{};
    if (payload.isEmpty) {
      return current.copyWith(
        username: username,
        email: email,
        profileImageUrl: profileImageUrl,
        isNotificationsEnabled: isNotificationsEnabled,
        updatedAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );
    }

    return UserModel.fromJson(payload);
  }

  @override
  Future<void> deleteCurrentUser() async {
    await _tokenManager.clearToken();
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
