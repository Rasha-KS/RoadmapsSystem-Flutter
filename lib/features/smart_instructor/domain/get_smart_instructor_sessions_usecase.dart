import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_session_entity.dart';

class GetSmartInstructorSessionsUseCase {
  final SmartInstructorRepository repository;

  GetSmartInstructorSessionsUseCase(this.repository);

  Future<List<SmartInstructorSessionEntity>> call() {
    return repository.getSessions();
  }
}
