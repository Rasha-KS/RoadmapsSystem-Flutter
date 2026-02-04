import '../domain/home_entity.dart';

class HomeRepository {
  Future<List<HomeCourseEntity>> getRecommendedCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      HomeCourseEntity(
        id: 1,
        title: 'Python',
        level: 'مبتدئ',
        description: 'تعلم أساسيات بايثون',
      ),
      HomeCourseEntity(
        id: 2,
        title: 'C++',
        level: 'متوسط',
        description: 'هياكل بيانات وخوارزميات',
      ),
    ];
  }

  Future<List<HomeCourseEntity>> getMyCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      HomeCourseEntity(
        id: 3,
        title: 'JavaScript',
        level: 'مبتدئ',
        description: 'برمجة الواجهات',
      ),
    ];
  }
}
