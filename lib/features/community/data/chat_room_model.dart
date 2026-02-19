import 'package:roadmaps/features/community/domain/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.roadmapId,
    required super.name,
    required super.isActive,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as int,
      roadmapId: json['roadmap_id'] as int,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}
