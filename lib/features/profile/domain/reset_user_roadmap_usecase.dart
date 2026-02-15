import '../data/profile_repository.dart';

class ResetUserRoadmapUseCase {
  final ProfileRepository repository;

  ResetUserRoadmapUseCase(this.repository);

  Future<void> call(int enrollmentId) {
    return repository.resetUserRoadmap(enrollmentId);
  }
}

