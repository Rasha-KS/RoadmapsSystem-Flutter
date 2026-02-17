import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'settings_model.dart';

class SettingsRepository {
  SettingsRepository({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;

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
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
