import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

class GetSmartInstructorMessagesUseCase {
  final SmartInstructorRepository repository;

  GetSmartInstructorMessagesUseCase(this.repository);

  Future<List<SmartInstructorMessageEntity>> call() {
    return repository.getMessages();
  }
}
