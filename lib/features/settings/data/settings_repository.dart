import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'settings_model.dart';

class SettingsRepository {
  SettingsRepository({
    required UserRepository userRepository,
    required ApiClient apiClient,
  })  : _userRepository = userRepository,
        _apiClient = apiClient;

  final UserRepository _userRepository;
  final ApiClient _apiClient;

  Future<UserEntity> getSettingsData() async {
    final user = await _userRepository.getCurrentUser();
    return SettingsModel(
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

  Future<UserEntity> toggleNotifications(bool enabled) async {
    return _userRepository.updateCurrentUser(isNotificationsEnabled: enabled);
  }

  Future<UserEntity> updateAccount({
    String? username,
    String? email,
    String? password,
    String? profileImageUrl,
  }) async {
    return _userRepository.updateCurrentUser(
      username: username,
      email: email,
      password: password,
      profileImageUrl: profileImageUrl,
    );
  }

  Future<String> uploadProfileImage({required String localFilePath}) async {
    await Future.delayed(const Duration(milliseconds: 450));

    // Temporary mock until backend API is ready.
    final avatarId = (DateTime.now().millisecondsSinceEpoch % 70) + 1;
    return 'https://i.pravatar.cc/150?img=$avatarId';
  }

  Future<void> deleteAccount() async {
    await _userRepository.deleteCurrentUser();
  }

  Future<void> logout() async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.logout),
    );

    if (response['success'] != true) {
      final message = response['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : 'تعذر تسجيل الخروج.',
      );
    }
  }
}
