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
}
