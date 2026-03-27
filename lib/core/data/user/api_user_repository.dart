import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/auth/token_manager.dart';
import 'package:roadmaps/core/cache/user_profile_cache.dart';
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
  final UserProfileCache _profileCache = UserProfileCache.instance;

  UserEntity? _cachedUser;

  @override
  Future<UserEntity?> getCachedCurrentUser() async {
    final cached = _cachedUser;
    if (cached != null) {
      return cached;
    }

    final stored = await _profileCache.readCurrentUser();
    _cachedUser = stored;
    return stored;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final token = await _tokenManager.getToken();
    if (token == null || token.isEmpty) {
      final cached = await getCachedCurrentUser();
      if (cached != null) {
        return cached;
      }
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

      final user = UserModel.fromJson(payload);
      _cachedUser = user;
      await _profileCache.writeCurrentUserIfChanged(user);
      return user;
    } on NetworkException {
      final cached = await getCachedCurrentUser();
      if (cached != null) {
        return cached;
      }
      rethrow;
    } on ParsingException {
      final cached = await getCachedCurrentUser();
      if (cached != null) {
        return cached;
      }
      rethrow;
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
    final current = _cachedUser ?? await getCurrentUser();

    // Password is accepted to keep the contract backend-ready.
    final _ = password;

    final updated = current.copyWith(
      username: username,
      email: email,
      profileImageUrl: profileImageUrl,
      isNotificationsEnabled: isNotificationsEnabled,
      updatedAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );

    _cachedUser = updated;
    await _profileCache.writeCurrentUserIfChanged(updated);
    return updated;
  }

  @override
  Future<void> deleteCurrentUser() async {
    _cachedUser = null;
    await _tokenManager.clearToken();
    await _profileCache.clearCurrentUser();
  }
}
