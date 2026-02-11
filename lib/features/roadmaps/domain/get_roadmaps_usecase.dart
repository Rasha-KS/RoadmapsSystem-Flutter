import '../data/roadmap_repository.dart';
import 'roadmap_entity.dart';

class GetRoadmapsUseCase {
  final RoadmapRepository repository;

  GetRoadmapsUseCase(this.repository);

  Future<List<RoadmapEntity>> call() {
    return repository.getRoadmaps();
  }
}
