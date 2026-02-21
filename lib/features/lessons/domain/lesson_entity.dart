import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';

class LessonEntity {
  final String id;
  final String title;
  final List<SubLessonEntity> subLessons;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.subLessons,
  });
}
