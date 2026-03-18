class RoadmapEntity {
  final int id;
  final String title;
  final String level;
  final String description;
  final String? status;
  final bool isActive;
  final bool isEnrolled;

  const RoadmapEntity({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    this.status,
    this.isActive = true,
    this.isEnrolled = false,
  });

  RoadmapEntity copyWith({
    int? id,
    String? title,
    String? level,
    String? description,
    String? status,
    bool clearStatus = false,
    bool? isActive,
    bool? isEnrolled,
  }) {
    return RoadmapEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      description: description ?? this.description,
      status: clearStatus ? null : (status ?? this.status),
      isActive: isActive ?? this.isActive,
      isEnrolled: isEnrolled ?? this.isEnrolled,
    );
  }
}
