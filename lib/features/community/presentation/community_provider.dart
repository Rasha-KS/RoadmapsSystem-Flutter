import 'package:flutter/material.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/domain/chat_room_entity.dart';
import 'package:roadmaps/features/community/domain/get_messages_by_room_usecase.dart';
import 'package:roadmaps/features/community/domain/get_user_community_rooms_usecase.dart';
import 'package:roadmaps/features/community/domain/send_image_message_usecase.dart';
import 'package:roadmaps/features/community/domain/send_message_usecase.dart';

class CommunityProvider extends ChangeNotifier {
  CommunityProvider({
    required this.getUserCommunityRoomsUseCase,
    required this.getMessagesByRoomUseCase,
    required this.sendMessageUseCase,
    required this.sendImageMessageUseCase,
    required this.currentUserProvider,
  }) {
    currentUserProvider.addListener(_onCurrentUserChanged);
  }

  final GetUserCommunityRoomsUseCase getUserCommunityRoomsUseCase;
  final GetMessagesByRoomUseCase getMessagesByRoomUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final SendImageMessageUseCase sendImageMessageUseCase;
  final CurrentUserProvider currentUserProvider;

  List<ChatRoomEntity> _rooms = [];
  bool loadingRooms = false;
  int? activeRoomId;

  final Map<int, List<ChatMessageEntity>> _messagesByRoom = {};
  final Set<int> _loadingMessagesRooms = {};

  List<ChatRoomEntity> get rooms => List.unmodifiable(_rooms);

  List<ChatMessageEntity> messagesForRoom(int roomId) {
    return List.unmodifiable(_messagesByRoom[roomId] ?? []);
  }

  bool isRoomMessagesLoading(int roomId) {
    return _loadingMessagesRooms.contains(roomId);
  }

  Future<void> loadRooms() async {
    loadingRooms = true;
    notifyListeners();

    _rooms = await getUserCommunityRoomsUseCase();
    _ensureActiveRoomStillValid();

    loadingRooms = false;
    notifyListeners();
  }

  Future<void> openRoom(int roomId) async {
    activeRoomId = roomId;
    notifyListeners();
    await loadMessages(roomId);
  }

  Future<void> loadMessages(int roomId) async {
    _loadingMessagesRooms.add(roomId);
    notifyListeners();

    final data = await getMessagesByRoomUseCase(roomId);
    _messagesByRoom[roomId] = data;

    _loadingMessagesRooms.remove(roomId);
    notifyListeners();
  }

  Future<void> sendTextMessage({
    required int roomId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final currentUserId = currentUserProvider.userId;
    if (currentUserId == null) return;

    final temporaryId = -DateTime.now().microsecondsSinceEpoch;
    final optimistic = ChatMessageEntity(
      id: temporaryId,
      chatRoomId: roomId,
      userId: currentUserId,
      content: trimmed,
      sentAt: DateTime.now(),
      isLocal: true,
    );

    final roomMessages = <ChatMessageEntity>[
      ...(_messagesByRoom[roomId] ?? <ChatMessageEntity>[]),
      optimistic,
    ];
    _messagesByRoom[roomId] = roomMessages;
    notifyListeners();

    final sent = await sendMessageUseCase(roomId: roomId, content: trimmed);
    _replaceOptimistic(roomId: roomId, temporaryId: temporaryId, sent: sent);
  }

  Future<void> sendImageMessage({
    required int roomId,
    required String attachmentPath,
  }) async {
    final currentUserId = currentUserProvider.userId;
    if (currentUserId == null) return;

    final temporaryId = -DateTime.now().microsecondsSinceEpoch;
    final optimistic = ChatMessageEntity(
      id: temporaryId,
      chatRoomId: roomId,
      userId: currentUserId,
      sentAt: DateTime.now(),
      attachmentPath: attachmentPath,
      isLocal: true,
    );

    final roomMessages = <ChatMessageEntity>[
      ...(_messagesByRoom[roomId] ?? <ChatMessageEntity>[]),
      optimistic,
    ];
    _messagesByRoom[roomId] = roomMessages;
    notifyListeners();

    final sent = await sendImageMessageUseCase(
      roomId: roomId,
      attachmentPath: attachmentPath,
    );

    _replaceOptimistic(roomId: roomId, temporaryId: temporaryId, sent: sent);
  }

  void _replaceOptimistic({
    required int roomId,
    required int temporaryId,
    required ChatMessageEntity sent,
  }) {
    final updated = (_messagesByRoom[roomId] ?? <ChatMessageEntity>[]).map((message) {
      if (message.id == temporaryId) {
        return sent;
      }
      return message;
    }).toList(growable: false);

    _messagesByRoom[roomId] = updated;
    notifyListeners();
  }

  void _ensureActiveRoomStillValid() {
    if (activeRoomId == null) return;
    final stillValid = _rooms.any((room) => room.id == activeRoomId);
    if (!stillValid) {
      activeRoomId = null;
    }
  }

  void _onCurrentUserChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    currentUserProvider.removeListener(_onCurrentUserChanged);
    super.dispose();
  }
}
