import '../domain/roadmap_entity.dart';

class RoadmapRepository {
  Future<List<RoadmapEntity>> getRoadmaps() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      RoadmapEntity(
        id: 1,
        title: 'C++',
        level: 'مبتدئ',
        description: 'لبناء تطبيقات وتطويرها...',
      ),
      RoadmapEntity(
        id: 2,
        title: 'Python',
        level: 'محترف',
        description: 'لبناء تطبيقات وتطويرها...',
      ),
      RoadmapEntity(
        id: 3,
        title: 'HTML',
        level: 'متوسط',
        description: 'لبناء واجهات الويب...',
      ),
      RoadmapEntity(
        id: 4,
        title: 'CSS',
        level: 'مبتدئ',
        description: 'لتنسيق صفحات الويب...',
      ),
    ];
  }
}
