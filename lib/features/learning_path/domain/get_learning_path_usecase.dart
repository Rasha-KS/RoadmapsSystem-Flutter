import 'package:roadmaps/features/learning_path/data/learning_path_repository.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';


class GetLearningPathUseCase {
  final LearningPathRepository repository;

  GetLearningPathUseCase(this.repository);

  Future<List<LearningUnitEntity>> call({
    required int roadmapId,
    required int userXp,
    required Set<int> completedUnitIds,
  }) {
    return repository.getLearningPath(
      roadmapId: roadmapId,
      userXp: userXp,
      completedUnitIds: completedUnitIds,
    );
  }

  Future<Map<String, dynamic>> asJson({
    required int roadmapId,
    required int userXp,
    required Set<int> completedUnitIds,
  }) {
    return repository.getLearningPathJson(
      roadmapId: roadmapId,
      userXp: userXp,
      completedUnitIds: completedUnitIds,
    );
  }
}
