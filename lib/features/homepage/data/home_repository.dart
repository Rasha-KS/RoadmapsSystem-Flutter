import '../domain/home_entity.dart';

class HomeRepository {
 final List<HomeCourseEntity> _recommendedCourses = [
  HomeCourseEntity(
    id: 1,
    title: 'Python',
    level: 'مبتدئ',
    status: 'متاح',
    description: 'تعلّم أساسيات لغة Python والبرمجة العملية مع أمثلة تطبيقية وتمارين عملية تساعدك على فهم المفاهيم الأساسية وتطوير مهاراتك البرمجية خطوة بخطوة.',
  ),
  HomeCourseEntity(
    id: 2,
    title: 'C++',
    level: 'متوسط',
    status: 'متاح',
    description: 'التركيز على هياكل البيانات والخوارزميات وأساسيات إدارة الذاكرة، مع تطبيقات عملية وأمثلة على حل المشكلات البرمجية بطريقة فعّالة لتحسين مهاراتك في تطوير البرمجيات.',
  ),
  HomeCourseEntity(
    id: 3,
    title: 'Flutter',
    level: 'محترف',
    status: 'متاح',
    description: 'بناء تطبيقات موبايل إنتاجية باستخدام Flutter وواجهات برمجة التطبيقات، مع تعلم أفضل الممارسات في التصميم، إدارة الحالة، والتكامل مع قواعد البيانات والخدمات الخارجية لتطوير تطبيقات متكاملة.',
  ),
];

final List<HomeCourseEntity> _myCourses = [
  HomeCourseEntity(
    id: 4,
    title: 'JavaScript',
    level: 'مبتدئ',
    status: 'قيد التقدم',
    description: 'أساسيات تطوير الواجهات الأمامية والتعامل مع DOM، مع أمثلة عملية تساعدك على إنشاء صفحات ويب ديناميكية وتطبيقات بسيطة تفاعلية.',
  ),
  HomeCourseEntity(
    id: 5,
    title: 'JavaScript',
    level: 'مبتدئ',
    status: 'قيد التقدم',
    description: 'تمارين عملية لتطوير واجهات ويب ديناميكية، تشمل التعامل مع الأحداث، النماذج، والتحديثات اللحظية للصفحات بطريقة سلسة تساعد على ترسيخ المفاهيم الأساسية للغة.',
  ),
];


  Future<List<HomeCourseEntity>> getRecommendedCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<HomeCourseEntity>.from(_recommendedCourses);
  }

  Future<List<HomeCourseEntity>> getMyCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<HomeCourseEntity>.from(_myCourses);
  }

  Future<void> deleteMyCourse(int courseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _myCourses.removeWhere((course) => course.id == courseId);
  }

  Future<void> resetMyCourse(int courseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _myCourses.indexWhere((course) => course.id == courseId);
    if (index == -1) return;

    final course = _myCourses[index];
    _myCourses[index] = HomeCourseEntity(
      id: course.id,
      title: course.title,
      level: course.level,
      description: course.description,
      status: 'تمت إعادة الضبط',
    );
  }

  Future<void> enrollCourse(int courseId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _recommendedCourses.indexWhere((course) => course.id == courseId);
    if (index == -1) return;

    final course = _recommendedCourses.removeAt(index);
    final isAlreadyEnrolled = _myCourses.any((item) => item.id == course.id);
    if (isAlreadyEnrolled) return;

    _myCourses.add(
      HomeCourseEntity(
        id: course.id,
        title: course.title,
        level: course.level,
        description: course.description,
        status: 'في تقدم',
      ),
    );
  }
}
