import '../domain/roadmap_entity.dart';

class RoadmapRepository {

  Future<List<RoadmapEntity>> getRoadmaps() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      RoadmapEntity(
        id: 1,
        title: 'C++',
        level: 'مبتدئ',
       description: 'دورة تركّز على مفاهيم البرمجة المتقدمة باستخدام C++، مثل هياكل البيانات، الخوارزميات، إدارة الذاكرة، وحل المشاكل البرمجية بطريقة منهجية.',
    ),
      RoadmapEntity(
        id: 2,
        title: 'Python',
        level: 'محترف',
        description: 'دورة شاملة لتعلّم أساسيات لغة بايثون من الصفر، تشمل المتغيرات، الجمل الشرطية، الحلقات، والدوال، مع أمثلة عملية تساعدك على بناء تفكير برمجي صحيح.',
    ),
      RoadmapEntity(
        id: 3,
        title: 'Flutter',
        level: 'متوسط',
       description: 'دورة متقدمة لتطوير تطبيقات الموبايل باستخدام Flutter، تتناول بناء واجهات احترافية، إدارة الحالة، الربط مع APIs، وتحسين الأداء لتطبيقات حقيقية.',
     ),
      RoadmapEntity(
        id: 4,
        title: 'CSS',
        level: 'مبتدئ',
        description: 'دورة شاملة لتعلّم أساسيات لغة بايثون من الصفر، تشمل المتغيرات، الجمل الشرطية، الحلقات، والدوال، مع أمثلة عملية تساعدك على بناء تفكير برمجي صحيح.',
    ),
    ];
  }
  
  Future<List<RoadmapEntity>> getMyCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
    RoadmapEntity(
      id: 4,
      title: 'JavaScript',
      level: 'مبتدئ',
      status:"في تقدم",
      description: 'دورة مخصصة لتعلّم أساسيات لغة JavaScript، تركّز على برمجة واجهات الويب التفاعلية، التعامل مع المتغيرات والدوال، الأحداث (Events)، والتفاعل مع عناصر الصفحة لبناء تجربة مستخدم ديناميكية.',
    ),

     RoadmapEntity(
      id: 4,
      title: 'JavaScript',
      level: 'مبتدئ',
      status:"في تقدم",
      description: 'دورة مخصصة لتعلّم أساسيات لغة JavaScript، تركّز على برمجة واجهات الويب التفاعلية، التعامل مع المتغيرات والدوال، الأحداث (Events)، والتفاعل مع عناصر الصفحة لبناء تجربة مستخدم ديناميكية.',
    ),

    ];
  }
}
