import 'package:roadmaps/features/community/domain/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.roadmapId,
    required super.name,
    required super.isActive,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    final roomPayload =
        _extractMap(json, const ['chat_room', 'room', 'community_room']) ??
        json;
    final roadmapPayload = _extractMap(
      roomPayload,
      const ['roadmap', 'community'],
    );

    return ChatRoomModel(
      id: _asInt(roomPayload['chat_room_id']) ??
          _asInt(roomPayload['id']) ??
          _asInt(json['chat_room_id']) ??
          _asInt(json['id']) ??
          0,
      roadmapId: _asInt(roomPayload['roadmap_id']) ??
          _asInt(json['roadmap_id']) ??
          _asInt(roadmapPayload?['id']) ??
          0,
      name: _asString(roomPayload['name']) ??
          _asString(roomPayload['title']) ??
          _asString(roomPayload['community_name']) ??
          _asString(roomPayload['roadmap_name']) ??
          _asString(roadmapPayload?['title']) ??
          _asString(roadmapPayload?['name']) ??
          'Community',
      isActive: _asBool(roomPayload['is_active']) ??
          _asBool(roomPayload['active']) ??
          true,
    );
  }

  static Map<String, dynamic>? _extractMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.cast<String, dynamic>();
      }
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _asString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value?.toString().trim().toLowerCase();
    if (text == '1' || text == 'true') return true;
    if (text == '0' || text == 'false') return false;
    return null;
  }
}
