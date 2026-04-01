import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/mock/mock_user.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<UserEntity> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return MockUserDataSource.currentUser;
  }

  @override
  Future<UserEntity> updateCurrentUser({
    String? username,
    String? email,
    String? password,
    String? profileImageUrl,
    bool? isNotificationsEnabled,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));

    // Password is accepted to keep the contract backend-ready.
    final _ = password;

    final current = MockUserDataSource.currentUser;
    final updated = current.copyWith(
      username: username,
      email: email,
      profileImageUrl: profileImageUrl,
      isNotificationsEnabled: isNotificationsEnabled,
      updatedAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );

    MockUserDataSource.currentUser = updated;
    return updated;
  }

  @override
  Future<void> deleteCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 160));
  }
}
