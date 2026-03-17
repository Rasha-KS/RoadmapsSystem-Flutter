import '../data/home_repository.dart';
import 'home_entity.dart';

class GetRoadmapDetailsUseCase {
  final HomeRepository repository;

  GetRoadmapDetailsUseCase(this.repository);

  Future<HomeCourseEntity> call(int roadmapId) {
    return repository.getRoadmapDetails(roadmapId);
  }
}
