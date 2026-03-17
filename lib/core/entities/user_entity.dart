class UserEntity {
  final int id;
  final String username;
  final String email;
  final String? role;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;
  final DateTime? lastLoginAt;
  final bool isNotificationsEnabled;
  final String? profileImageUrl;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
    this.lastLoginAt,
    this.isNotificationsEnabled = false,
    this.profileImageUrl,
  });

  UserEntity copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
    DateTime? lastLoginAt,
    bool? isNotificationsEnabled,
    String? profileImageUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
