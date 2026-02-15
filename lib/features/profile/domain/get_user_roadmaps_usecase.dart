import '../data/profile_repository.dart';
import 'user_roadmap_entity.dart';

class GetUserRoadmapsUseCase {
  final ProfileRepository repository;

  GetUserRoadmapsUseCase(this.repository);

  Future<List<UserRoadmapEntity>> call() {
    return repository.getUserRoadmaps();
  }
}

