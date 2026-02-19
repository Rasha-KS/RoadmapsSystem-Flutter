import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/domain/chat_room_entity.dart';
import 'package:roadmaps/features/community/data/community_repository.dart';

import 'chat_message_model.dart';
import 'chat_room_model.dart';

class MockCommunityRepository implements CommunityRepository {
  final List<Map<String, dynamic>> _roadmapEnrollmentsTable = [
    {
      'id': 101,
      'user_id': 1,
      'roadmap_id': 1,
      'started_at': DateTime(2026, 1, 1),
      'completed_at': null,
      'xp_points': 50,
      'status': 'in_progress',
    },
    {
      'id': 102,
      'user_id': 1,
      'roadmap_id': 2,
      'started_at': DateTime(2026, 1, 25),
      'completed_at': null,
      'xp_points': 50,
      'status': 'in_progress',
    },
    {
      'id': 103,
      'user_id': 1,
      'roadmap_id': 4,
      'started_at': DateTime(2026, 2, 1),
      'completed_at': null,
      'xp_points': 20,
      'status': 'in_progress',
    },
  ];

  final List<Map<String, dynamic>> _chatRoomsTable = [
    {
      'id': 1,
      'roadmap_id': 1,
      'name': 'Flutter',
      'is_active': true,
    },
    {
      'id': 2,
      'roadmap_id': 2,
      'name': 'Python',
      'is_active': true,
    },
    {
      'id': 3,
      'roadmap_id': 3,
      'name': 'C++',
      'is_active': true,
    },
    {
      'id': 4,
      'roadmap_id': 4,
      'name': 'JavaScript',
      'is_active': true,
    },
  ];

  final List<Map<String, dynamic>> _chatMessagesTable = [
    {
      'id': 1,
      'chat_room_id': 1,
      'user_id': 2,
      'content': 'Welcome to Flutter community',
      'sent_at': DateTime(2026, 2, 10, 10, 30),
      'attachment_path': null,
    },
    {
      'id': 2,
      'chat_room_id': 1,
      'user_id': 1,
      'content': 'Thanks, happy to join',
      'sent_at': DateTime(2026, 2, 10, 11, 05),
      'attachment_path': null,
    },
    {
      'id': 3,
      'chat_room_id': 2,
      'user_id': 3,
      'content': 'Python tips thread',
      'sent_at': DateTime(2026, 2, 13, 14, 20),
      'attachment_path': null,
    },
  ];

  @override
  Future<List<int>> getUserEnrolledRoadmapIds(int userId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _roadmapEnrollmentsTable
        .where((item) => item['user_id'] == userId)
        .map((item) => item['roadmap_id'] as int)
        .toList();
  }

  @override
  Future<List<ChatRoomEntity>> getChatRoomsByRoadmapIds(List<int> roadmapIds) async {
    await Future.delayed(const Duration(milliseconds: 160));
    final ids = roadmapIds.toSet();

    return _chatRoomsTable
        .where((item) => ids.contains(item['roadmap_id']) && item['is_active'] == true)
        .map(ChatRoomModel.fromJson)
        .toList();
  }

  @override
  Future<List<ChatMessageEntity>> getMessagesByRoom(int roomId) async {
    await Future.delayed(const Duration(milliseconds: 120));

    return _chatMessagesTable
        .where((item) => item['chat_room_id'] == roomId)
        .map(ChatMessageModel.fromJson)
        .toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  @override
  Future<ChatMessageEntity> sendMessage({
    required int roomId,
    required int userId,
    String? content,
    String? attachmentPath,
    bool isLocal = false,
  }) async {
    // Local path now; backend will later return uploaded URL in the same field.
    await Future.delayed(const Duration(milliseconds: 250));

    final nextId = _chatMessagesTable.isEmpty
        ? 1
        : (_chatMessagesTable.last['id'] as int) + 1;

    final record = {
      'id': nextId,
      'chat_room_id': roomId,
      'user_id': userId,
      'content': content,
      'sent_at': DateTime.now(),
      'attachment_path': attachmentPath,
      'is_local': isLocal,
    };

    _chatMessagesTable.add(record);
    return ChatMessageModel.fromJson(record);
  }
}
