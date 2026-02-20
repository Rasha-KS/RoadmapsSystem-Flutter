import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_intro_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

abstract class SmartInstructorRepository {
  Future<SmartInstructorIntroEntity> getIntro();

  Future<List<SmartInstructorMessageEntity>> getMessages();

  Future<SmartInstructorMessageEntity> sendUserMessage({
    required String content,
  });

  Future<SmartInstructorMessageEntity> sendImageMessage({
    required String attachmentPath,
  });
}
