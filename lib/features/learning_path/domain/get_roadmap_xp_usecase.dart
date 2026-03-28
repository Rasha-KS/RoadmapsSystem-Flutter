import 'package:roadmaps/features/learning_path/data/learning_path_repository.dart';

class GetRoadmapXpUseCase {
  final LearningPathRepository repository;

  GetRoadmapXpUseCase(this.repository);

  Future<int> call({required int roadmapId}) {
    return repository.getRoadmapXp(roadmapId: roadmapId);
  }
}
