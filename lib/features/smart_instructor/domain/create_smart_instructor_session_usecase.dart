import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_session_entity.dart';

class CreateSmartInstructorSessionUseCase {
  final SmartInstructorRepository repository;

  CreateSmartInstructorSessionUseCase(this.repository);

  Future<SmartInstructorSessionEntity> call({required String title}) {
    return repository.createSession(title: title);
  }
}
