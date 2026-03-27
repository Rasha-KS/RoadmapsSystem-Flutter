import 'package:roadmaps/features/lessons/data/lesson_repository.dart';
import 'package:roadmaps/features/lessons/domain/resource_entity.dart';

class GetLessonResourcesUseCase {
  final LessonRepository repository;

  GetLessonResourcesUseCase(this.repository);

  Future<List<ResourceEntity>> call(int subLessonId) {
    return repository.getLessonResources(subLessonId);
  }
}
