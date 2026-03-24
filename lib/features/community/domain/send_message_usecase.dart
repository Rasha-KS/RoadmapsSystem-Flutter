import 'package:roadmaps/features/community/data/community_repository.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';

class SendMessageUseCase {
  final CommunityRepository repository;

  SendMessageUseCase({required this.repository});

  Future<ChatMessageEntity> call({
    required int roomId,
    required int userId,
    required String content,
  }) async {
    return repository.sendMessage(
      roomId: roomId,
      userId: userId,
      content: content,
      isLocal: true,
    );
  }
}
