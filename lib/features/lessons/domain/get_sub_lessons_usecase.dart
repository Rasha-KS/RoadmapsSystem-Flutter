import 'package:roadmaps/features/lessons/data/lesson_repository.dart';
import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';

class GetSubLessonsUseCase {
  final LessonRepository repository;

  GetSubLessonsUseCase(this.repository);

  Future<List<SubLessonEntity>> call(int lessonId) {
    return repository.getSubLessons(lessonId);
  }
}
