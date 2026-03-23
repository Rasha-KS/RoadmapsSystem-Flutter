class SmartInstructorSessionEntity {
  final int id;
  final int? userId;
  final String title;
  final DateTime? lastActivityAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SmartInstructorSessionEntity({
    required this.id,
    required this.title,
    this.userId,
    this.lastActivityAt,
    this.createdAt,
    this.updatedAt,
  });
}
