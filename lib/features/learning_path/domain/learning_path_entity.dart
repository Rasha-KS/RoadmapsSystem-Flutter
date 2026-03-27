import 'package:roadmaps/features/roadmaps/domain/roadmap_entity.dart';

import 'learning_unit_entity.dart';

class LearningPathEntity {
  final RoadmapEntity roadmap;
  final List<LearningUnitEntity> units;

  const LearningPathEntity({
    required this.roadmap,
    required this.units,
  });
}
