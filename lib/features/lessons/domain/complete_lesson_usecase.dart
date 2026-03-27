import 'package:roadmaps/features/lessons/data/lesson_repository.dart';

class CompleteLessonUseCase {
  final LessonRepository repository;

  CompleteLessonUseCase(this.repository);

  Future<void> call(int lessonId) {
    return repository.completeLesson(lessonId);
  }
}
