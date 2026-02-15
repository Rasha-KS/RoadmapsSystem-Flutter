import '../data/profile_repository.dart';

class DeleteUserRoadmapUseCase {
  final ProfileRepository repository;

  DeleteUserRoadmapUseCase(this.repository);

  Future<void> call(int enrollmentId) {
    return repository.deleteUserRoadmap(enrollmentId);
  }
}

