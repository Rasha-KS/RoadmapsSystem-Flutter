import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/domain/community_repository.dart';

class GetMessagesByRoomUseCase {
  final CommunityRepository repository;

  GetMessagesByRoomUseCase(this.repository);

  Future<List<ChatMessageEntity>> call(int roomId) {
    return repository.getMessagesByRoom(roomId);
  }
}
