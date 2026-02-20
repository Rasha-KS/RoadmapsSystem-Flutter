import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

class SendSmartInstructorImageMessageUseCase {
  final SmartInstructorRepository repository;

  SendSmartInstructorImageMessageUseCase(this.repository);

  Future<SmartInstructorMessageEntity> call({required String attachmentPath}) {
    return repository.sendImageMessage(attachmentPath: attachmentPath);
  }
}
