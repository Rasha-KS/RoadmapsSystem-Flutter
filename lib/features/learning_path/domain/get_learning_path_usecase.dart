import 'package:roadmaps/features/learning_path/data/learning_path_repository.dart';
import 'package:roadmaps/features/learning_path/domain/learning_path_entity.dart';


class GetLearningPathUseCase {
  final LearningPathRepository repository;

  GetLearningPathUseCase(this.repository);

  Future<LearningPathEntity> call({required int roadmapId}) {
    return repository.getLearningPath(roadmapId: roadmapId);
  }
}
