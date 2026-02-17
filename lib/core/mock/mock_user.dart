import 'package:roadmaps/core/entities/user_entity.dart';

class MockUserDataSource {
  static UserEntity currentUser = UserEntity(
    id: 1,
    username: 'RASHA_KS',
    email: 'iris@example.com',
    createdAt: DateTime(2025, 7, 20),
    updatedAt: DateTime(2026, 1, 18),
    lastActivityAt: DateTime(2026, 2, 14),
    isNotificationsEnabled: true,
    profileImageUrl: 'https://i.pravatar.cc/150?img=1',
  );
}
