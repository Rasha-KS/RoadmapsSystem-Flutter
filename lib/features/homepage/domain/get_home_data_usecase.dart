import 'package:roadmaps/features/homepage/domain/home_entity.dart';
import '../data/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<List<HomeCourseEntity>> callRecommended() {
    return repository.getRecommendedCourses();
  }

  Future<List<HomeCourseEntity>> callMyCourses() {
    return repository.getMyCourses();
  }
}
