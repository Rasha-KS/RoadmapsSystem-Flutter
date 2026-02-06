import '../domain/home_entity.dart';

class HomeRepository {
  Future<List<HomeCourseEntity>> getRecommendedCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
    HomeCourseEntity(
      id: 1,
      title: 'Python',
      level: 'مبتدئ',
      description: 'دورة شاملة لتعلّم أساسيات لغة بايثون من الصفر، تشمل المتغيرات، الجمل الشرطية، الحلقات، والدوال، مع أمثلة عملية تساعدك على بناء تفكير برمجي صحيح.',
    ),
    HomeCourseEntity(
      id: 2,
      title: 'C++',
      level: 'متوسط',
      description: 'دورة تركّز على مفاهيم البرمجة المتقدمة باستخدام C++، مثل هياكل البيانات، الخوارزميات، إدارة الذاكرة، وحل المشاكل البرمجية بطريقة منهجية.',
    ),
    HomeCourseEntity(
      id: 3,
      title: 'Flutter',
      level: 'عالي',
      description: 'دورة متقدمة لتطوير تطبيقات الموبايل باستخدام Flutter، تتناول بناء واجهات احترافية، إدارة الحالة، الربط مع APIs، وتحسين الأداء لتطبيقات حقيقية.',
    ),

    ];
  }

  Future<List<HomeCourseEntity>> getMyCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
    HomeCourseEntity(
      id: 4,
      title: 'JavaScript',
      level: 'مبتدئ',
      status:"في تقدم",
      description: 'دورة مخصصة لتعلّم أساسيات لغة JavaScript، تركّز على برمجة واجهات الويب التفاعلية، التعامل مع المتغيرات والدوال، الأحداث (Events)، والتفاعل مع عناصر الصفحة لبناء تجربة مستخدم ديناميكية.',
    ),

     HomeCourseEntity(
      id: 4,
      title: 'JavaScript',
      level: 'مبتدئ',
      status:"في تقدم",
      description: 'دورة مخصصة لتعلّم أساسيات لغة JavaScript، تركّز على برمجة واجهات الويب التفاعلية، التعامل مع المتغيرات والدوال، الأحداث (Events)، والتفاعل مع عناصر الصفحة لبناء تجربة مستخدم ديناميكية.',
    ),

    ];
  }
}
