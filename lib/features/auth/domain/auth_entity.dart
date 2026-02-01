class AuthEntity {
  int? userId;
  String? name;
  String? email;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastActivityAt;
  AuthEntity({
    this.userId,
    this.name,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.lastActivityAt,
  });
}
