class RoadmapEntity {
  final int id;
  final String title; // مثال: Python, C++
  final String level; // مبتدئ/متوسط/محترف
  final String description; // وصف مختصر
  final String? status;

  RoadmapEntity({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    this.status
  });
}
