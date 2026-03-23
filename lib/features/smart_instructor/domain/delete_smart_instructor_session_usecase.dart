import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';

class DeleteSmartInstructorSessionUseCase {
  final SmartInstructorRepository repository;

  DeleteSmartInstructorSessionUseCase(this.repository);

  Future<void> call(int sessionId) {
    return repository.deleteSession(sessionId);
  }
}
