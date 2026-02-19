import 'package:roadmaps/core/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getCurrentUser();

  Future<UserEntity> updateCurrentUser({
    String? username,
    String? email,
    String? password,
    String? profileImageUrl,
    bool? isNotificationsEnabled,
  });

  Future<void> deleteCurrentUser();
}
