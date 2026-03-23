import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_intro_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_session_entity.dart';

abstract class SmartInstructorRepository {
  Future<SmartInstructorIntroEntity> getIntro();

  Future<List<SmartInstructorSessionEntity>> getSessions();

  Future<SmartInstructorSessionEntity> createSession({
    required String title,
  });

  Future<List<SmartInstructorMessageEntity>> getMessages({
    required int sessionId,
  });

  Future<List<SmartInstructorMessageEntity>> sendMessage({
    required int sessionId,
    required String content,
  });

  Future<SmartInstructorMessageEntity> sendImageMessage({
    required String attachmentPath,
  });

  Future<void> deleteSession(int sessionId);
}
