import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/features/community/data/chat_message_model.dart';
import 'package:roadmaps/features/community/data/chat_room_model.dart';
import 'package:roadmaps/features/community/data/community_repository.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/domain/chat_room_entity.dart';

class CommunityApiRepository implements CommunityRepository {
  CommunityApiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ChatRoomEntity>> getUserCommunityRooms() async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.myCommunity),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل المجتمعات.');

    final items = _extractList(
      response['data'] ?? response,
      keys: const [
        'communities',
        'community_rooms',
        'chat_rooms',
        'rooms',
        'items',
        'data',
        'results',
      ],
    );

    return items
        .map(ChatRoomModel.fromJson)
        .where((room) => room.isActive)
        .toList();
  }

  @override
  Future<List<ChatMessageEntity>> getMessagesByRoom(int roomId) async {
    final messages = <ChatMessageEntity>[];
    var page = 1;
    var lastPage = 1;

    do {
      final response = await _apiClient.get(
        _buildMessagesUrl(roomId: roomId, page: page),
      );
      _ensureSuccess(response, fallbackMessage: 'تعذر تحميل الرسائل.');

      final items = _extractList(
        response['data'] ?? response,
        keys: const ['messages', 'items', 'data', 'results'],
      );

      messages.addAll(
        items.map(
          (item) => ChatMessageModel.fromJson(
            item,
            fallbackRoomId: roomId,
          ),
        ),
      );

      lastPage =
          _extractLastPage(response['meta']) ??
          _extractLastPage(_extractMap(response['data'], const ['meta'])) ??
          page;
      page++;
    } while (page <= lastPage);

    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  @override
  Future<ChatMessageEntity> sendMessage({
    required int roomId,
    required int userId,
    String? content,
    String? attachmentPath,
    bool isLocal = false,
  }) async {
    if (attachmentPath != null && attachmentPath.trim().isNotEmpty) {
      return ChatMessageModel.fromJson(
        <String, dynamic>{
          'id': DateTime.now().microsecondsSinceEpoch,
          'chat_room_id': roomId,
          'user_id': userId,
          'attachment_path': attachmentPath,
          'sent_at': DateTime.now().toIso8601String(),
          'is_local': isLocal,
        },
        fallbackRoomId: roomId,
        fallbackUserId: userId,
        fallbackSentAt: DateTime.now(),
      );
    }

    final message = content?.trim() ?? '';
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.communityMessages(roomId)),
      body: {'content': message},
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر إرسال الرسالة.');

    final payload = _extractSentMessagePayload(
      response['data'] ?? response,
      roomId: roomId,
      fallbackContent: message,
    );

    return ChatMessageModel.fromJson(
      payload,
      fallbackRoomId: roomId,
      fallbackUserId: userId,
      fallbackContent: message,
      fallbackSentAt: DateTime.now(),
    );
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    if (response.containsKey('success') && response['success'] != true) {
      final message = response['message']?.toString().trim();
      throw ApiException(
        message == null || message.isEmpty ? fallbackMessage : message,
      );
    }
  }

  List<Map<String, dynamic>> _extractList(
    dynamic payload, {
    required List<String> keys,
  }) {
    if (payload == null) return [];

    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    if (payload is Map<String, dynamic>) {
      for (final key in keys) {
        final value = payload[key];
        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
        if (value is Map<String, dynamic>) {
          final nestedData = value['data'];
          if (nestedData is List) {
            return nestedData.whereType<Map<String, dynamic>>().toList();
          }
        }
      }
    }

    throw const ParsingException();
  }

  Map<String, dynamic> _extractSentMessagePayload(
    dynamic payload, {
    required int roomId,
    required String fallbackContent,
  }) {
    if (payload is Map<String, dynamic>) {
      for (final key in const ['message', 'chat_message', 'item', 'data']) {
        final value = payload[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
        if (value is Map) {
          return value.cast<String, dynamic>();
        }
        if (value is List) {
          final maps = value.whereType<Map<String, dynamic>>().toList();
          if (maps.isNotEmpty) {
            return maps.last;
          }
        }
      }

      return payload;
    }

    if (payload is List) {
      final maps = payload.whereType<Map<String, dynamic>>().toList();
      if (maps.isNotEmpty) {
        return maps.last;
      }
    }

    return <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch,
      'chat_room_id': roomId,
      'content': fallbackContent,
      'sent_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic>? _extractMap(dynamic payload, List<String> keys) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    for (final key in keys) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.cast<String, dynamic>();
      }
    }
    return null;
  }

  String _buildMessagesUrl({
    required int roomId,
    required int page,
  }) {
    final uri = Uri.parse(
      ApiConstants.url(ApiConstants.communityMessages(roomId)),
    ).replace(queryParameters: {'page': '$page'});
    return uri.toString();
  }

  int? _extractLastPage(dynamic meta) {
    if (meta is Map<String, dynamic>) {
      final value = meta['last_page'];
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '');
    }
    return null;
  }
}
