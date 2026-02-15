class ProfileUserEntity {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;
  final String? profileImageUrl;


  ProfileUserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
    this.profileImageUrl,
  });
}
