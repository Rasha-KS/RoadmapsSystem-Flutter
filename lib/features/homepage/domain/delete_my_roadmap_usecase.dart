import '../data/home_repository.dart';

class DeleteMyCourseUseCase {
  final HomeRepository repository;

  DeleteMyCourseUseCase(this.repository);

  Future<void> call(int courseId) {
    return repository.deleteMyCourse(courseId);
  }
}
