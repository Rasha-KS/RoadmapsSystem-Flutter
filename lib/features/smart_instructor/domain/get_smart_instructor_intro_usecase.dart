import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_intro_entity.dart';

class GetSmartInstructorIntroUseCase {
  final SmartInstructorRepository repository;

  GetSmartInstructorIntroUseCase(this.repository);

  Future<SmartInstructorIntroEntity> call() {
    return repository.getIntro();
  }
}
