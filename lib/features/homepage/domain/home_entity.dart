class HomeCourseEntity {
  final int id;
  final String title;
  final String level;
  final String description;
  final String? status;

  HomeCourseEntity({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
     this.status
  });

  HomeCourseEntity copyWith({
    int? id,
    String? title,
    String? level,
    String? description,
    String? status,
  }) {
    return HomeCourseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
