import 'package:roadmaps/features/learning_path/data/learning_path_repository.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';


class GetLearningPathUseCase {
  final LearningPathRepository repository;

  GetLearningPathUseCase(this.repository);

  Future<List<LearningUnitEntity>> call({
    required int roadmapId,
    required int userXp,
    required Set<int> completedLessonIds,
  }) {
    return repository.getLearningPath(
      roadmapId: roadmapId,
      userXp: userXp,
      completedLessonIds: completedLessonIds,
    );
  }
}
