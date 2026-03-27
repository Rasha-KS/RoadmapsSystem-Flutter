import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';

class LessonEntity {
  final int id;
  final String title;
  final String description;
  final List<SubLessonEntity> subLessons;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.subLessons,
  });

  LessonEntity copyWith({
    String? title,
    String? description,
    List<SubLessonEntity>? subLessons,
  }) {
    return LessonEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subLessons: subLessons ?? this.subLessons,
    );
  }
}
