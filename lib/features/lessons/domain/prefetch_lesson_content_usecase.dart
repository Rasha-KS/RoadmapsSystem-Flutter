import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';

import '../data/lesson_repository.dart';

class PrefetchLessonContentUseCase {
  PrefetchLessonContentUseCase(this.repository);

  final LessonRepository repository;

  Future<void> call({required List<LearningUnitEntity> units}) async {
    final lessonIds = <int>{};

    for (final unit in units) {
      if (unit.type != LearningUnitType.lesson || unit.entityId <= 0) {
        continue;
      }
      lessonIds.add(unit.entityId);
    }

    for (final lessonId in lessonIds) {
      try {
        await repository.getSubLessons(lessonId);
      } catch (_) {}
    }
  }
}
