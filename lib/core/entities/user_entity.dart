class UserEntity {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;
  final bool isNotificationsEnabled;
  final String? profileImageUrl;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
    this.isNotificationsEnabled = false,
    this.profileImageUrl,
  });

  UserEntity copyWith({
    int? id,
    String? username,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
    bool? isNotificationsEnabled,
    String? profileImageUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
