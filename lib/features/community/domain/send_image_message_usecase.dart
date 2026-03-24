import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/data/community_repository.dart';

class SendImageMessageUseCase {
  final CommunityRepository repository;

  SendImageMessageUseCase({
    required this.repository,
  });

  Future<ChatMessageEntity> call({
    required int roomId,
    required int userId,
    required String attachmentPath,
  }) async {
    return repository.sendMessage(
      roomId: roomId,
      userId: userId,
      attachmentPath: attachmentPath,
      isLocal: true,
    );
  }
}
