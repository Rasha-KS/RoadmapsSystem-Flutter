import '../data/home_repository.dart';

class EnrollCourseUseCase {
  final HomeRepository repository;

  EnrollCourseUseCase(this.repository);

  Future<void> call(int courseId) {
    return repository.enrollCourse(courseId);
  }
}
