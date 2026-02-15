import '../data/home_repository.dart';

class ResetMyCourseUseCase {
  final HomeRepository repository;

  ResetMyCourseUseCase(this.repository);

  Future<void> call(int courseId) {
    return repository.resetMyCourse(courseId);
  }
}
