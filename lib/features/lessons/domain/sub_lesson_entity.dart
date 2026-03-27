import 'package:roadmaps/features/lessons/domain/resource_entity.dart';

class SubLessonEntity {
  final int id;
  final int lessonId;
  final String title;
  final int position;
  final String? description;
  final int resourcesCount;
  final List<ResourceEntity> resources;

  const SubLessonEntity({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.position,
    required this.description,
    required this.resourcesCount,
    required this.resources,
  });

  SubLessonEntity copyWith({
    String? title,
    int? position,
    String? description,
    int? resourcesCount,
    List<ResourceEntity>? resources,
  }) {
    return SubLessonEntity(
      id: id,
      lessonId: lessonId,
      title: title ?? this.title,
      position: position ?? this.position,
      description: description ?? this.description,
      resourcesCount: resourcesCount ?? this.resourcesCount,
      resources: resources ?? this.resources,
    );
  }
}
