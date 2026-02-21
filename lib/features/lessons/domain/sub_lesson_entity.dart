import 'package:roadmaps/features/lessons/domain/resource_entity.dart';

class SubLessonEntity {
  final String id;
  final String title;
  final String introductionTitle;
  final String introductionDescription;
  final List<ResourceEntity> resources;

  const SubLessonEntity({
    required this.id,
    required this.title,
    required this.introductionTitle,
    required this.introductionDescription,
    required this.resources,
  });
}
