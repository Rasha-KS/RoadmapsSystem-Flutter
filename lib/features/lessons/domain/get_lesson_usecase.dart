import 'package:roadmaps/features/lessons/data/lesson_repository.dart';
import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';

class GetLessonUseCase {
  final LessonRepository repository;

  GetLessonUseCase(this.repository);

  Future<LessonEntity?> call(String learningUnitId) {
    return repository.getLesson(learningUnitId);
  }
}
