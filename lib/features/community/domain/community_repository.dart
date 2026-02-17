import 'chat_message_entity.dart';
import 'chat_room_entity.dart';

abstract class CommunityRepository {
  Future<List<int>> getUserEnrolledRoadmapIds(int userId);

  Future<List<ChatRoomEntity>> getChatRoomsByRoadmapIds(List<int> roadmapIds);

  Future<List<ChatMessageEntity>> getMessagesByRoom(int roomId);

  Future<ChatMessageEntity> sendMessage({
    required int roomId,
    required int userId,
    String? content,
    String? attachmentPath,
    bool isLocal,
  });
}
