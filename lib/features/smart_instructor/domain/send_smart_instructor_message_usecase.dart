import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

class SendSmartInstructorMessageUseCase {
  final SmartInstructorRepository repository;

  SendSmartInstructorMessageUseCase(this.repository);

  Future<SmartInstructorMessageEntity> call({required String content}) {
    return repository.sendUserMessage(content: content);
  }
}
