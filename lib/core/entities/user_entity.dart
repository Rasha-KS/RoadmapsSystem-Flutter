class UserEntity {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;
  final String? profileImageUrl;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
    this.profileImageUrl,
  });
}
