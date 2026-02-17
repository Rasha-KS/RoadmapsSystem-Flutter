class ChatRoomEntity {
  final int id;
  final int roadmapId;
  final String name;
  final bool isActive;

  const ChatRoomEntity({
    required this.id,
    required this.roadmapId,
    required this.name,
    required this.isActive,
  });
}
