import '../domain/chat_message_entity.dart';
import '../domain/chat_room_entity.dart';

abstract class CommunityRepository {
  String? get lastRoomsLoadErrorMessage;

  String? get lastMessagesLoadErrorMessage;

  Future<List<ChatRoomEntity>> getUserCommunityRooms();

  Future<List<ChatMessageEntity>> getMessagesByRoom(int roomId);

  Future<ChatMessageEntity> sendMessage({
    required int roomId,
    required int userId,
    String? content,
    String? attachmentPath,
    bool isLocal,
  });
}
