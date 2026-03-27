import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/domain/chat_room_entity.dart';
import 'package:roadmaps/features/community/domain/get_messages_by_room_usecase.dart';
import 'package:roadmaps/features/community/domain/get_user_community_rooms_usecase.dart';
import 'package:roadmaps/features/community/domain/send_image_message_usecase.dart';
import 'package:roadmaps/features/community/domain/send_message_usecase.dart';

class CommunityProvider extends SafeChangeNotifier {
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
  String? roomsError;
  int? activeRoomId;

  final Map<int, List<ChatMessageEntity>> _messagesByRoom = {};
  final Map<int, String?> _messagesErrorsByRoom = {};
  final Set<int> _loadingMessagesRooms = {};
  final Set<int> _sendingRooms = {};

  List<ChatRoomEntity> get rooms => List.unmodifiable(_rooms);

  List<ChatMessageEntity> messagesForRoom(int roomId) {
    return List.unmodifiable(
      _messagesByRoom[roomId] ?? const <ChatMessageEntity>[],
    );
  }

  bool isRoomMessagesLoading(int roomId) {
    return _loadingMessagesRooms.contains(roomId);
  }

  bool isSendingMessage(int roomId) {
    return _sendingRooms.contains(roomId);
  }

  String? roomMessagesError(int roomId) {
    return _messagesErrorsByRoom[roomId];
  }

  Future<void> loadRooms() async {
    loadingRooms = true;
    roomsError = null;
    notifyListeners();

    try {
      _rooms = await getUserCommunityRoomsUseCase();
      _ensureActiveRoomStillValid();
    } catch (error) {
      roomsError = _resolveErrorMessage(
        error,
        fallback: 'تعذر تحميل المجتمعات.',
      );
    } finally {
      loadingRooms = false;
      notifyListeners();
    }
  }

  Future<void> openRoom(int roomId) async {
    activeRoomId = roomId;
    notifyListeners();
    await loadMessages(roomId);
  }

  Future<void> loadMessages(int roomId) async {
    _loadingMessagesRooms.add(roomId);
    _messagesErrorsByRoom.remove(roomId);
    notifyListeners();

    try {
      final data = await getMessagesByRoomUseCase(roomId);
      _messagesByRoom[roomId] = data;
    } catch (error) {
      _messagesErrorsByRoom[roomId] = _resolveErrorMessage(
        error,
        fallback: 'تعذر تحميل الرسائل.',
      );
    } finally {
      _loadingMessagesRooms.remove(roomId);
      notifyListeners();
    }
  }

  Future<void> sendTextMessage({
    required int roomId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final currentUser = currentUserProvider.user;
    final currentUserId = currentUser?.id;
    if (currentUserId == null) {
      return;
    }

    final temporaryId = -DateTime.now().microsecondsSinceEpoch;
    final optimistic = ChatMessageEntity(
      id: temporaryId,
      chatRoomId: roomId,
      userId: currentUserId,
      content: trimmed,
      sentAt: DateTime.now(),
      senderName: currentUser?.username,
      senderAvatarUrl: currentUser?.profileImageUrl,
      status: ChatMessageStatus.sending,
      isLocal: true,
    );

    _messagesByRoom[roomId] = <ChatMessageEntity>[
      ...(_messagesByRoom[roomId] ?? const <ChatMessageEntity>[]),
      optimistic,
    ];
    _messagesErrorsByRoom.remove(roomId);
    _sendingRooms.add(roomId);
    notifyListeners();

    try {
      final sent = await sendMessageUseCase(
        roomId: roomId,
        userId: currentUserId,
        content: trimmed,
      );
      _replaceMessage(
        roomId: roomId,
        messageId: temporaryId,
        updatedMessage: sent.copyWith(
          chatRoomId: sent.chatRoomId == 0 ? roomId : sent.chatRoomId,
          userId: sent.userId == 0 ? currentUserId : sent.userId,
          content: (sent.content == null || sent.content!.trim().isEmpty)
              ? trimmed
              : sent.content,
          senderName: sent.senderName ?? currentUser?.username,
          senderAvatarUrl:
              sent.senderAvatarUrl ?? currentUser?.profileImageUrl,
          status: ChatMessageStatus.sent,
          failureMessage: null,
          isLocal: false,
        ),
      );
    } catch (error) {
      _replaceMessage(
        roomId: roomId,
        messageId: temporaryId,
        updatedMessage: optimistic.copyWith(
          status: ChatMessageStatus.failed,
          failureMessage: _resolveErrorMessage(
            error,
            fallback: 'تعذر إرسال الرسالة.',
          ),
        ),
      );
    } finally {
      _sendingRooms.remove(roomId);
      notifyListeners();
    }
  }

  Future<void> retryMessage({
    required int roomId,
    required int messageId,
  }) async {
    if (_sendingRooms.contains(roomId)) return;

    final target = _findMessage(roomId: roomId, messageId: messageId);
    final text = target?.content?.trim();
    if (target == null || text == null || text.isEmpty) {
      return;
    }

    final currentUser = currentUserProvider.user;
    final currentUserId = currentUser?.id ?? target.userId;
    final retrying = target.copyWith(
      status: ChatMessageStatus.sending,
      failureMessage: null,
      senderName: target.senderName ?? currentUser?.username,
      senderAvatarUrl:
          target.senderAvatarUrl ?? currentUser?.profileImageUrl,
    );

    _replaceMessage(
      roomId: roomId,
      messageId: messageId,
      updatedMessage: retrying,
    );
    _sendingRooms.add(roomId);
    notifyListeners();

    try {
      final sent = await sendMessageUseCase(
        roomId: roomId,
        userId: currentUserId,
        content: text,
      );
      _replaceMessage(
        roomId: roomId,
        messageId: messageId,
        updatedMessage: sent.copyWith(
          chatRoomId: sent.chatRoomId == 0 ? roomId : sent.chatRoomId,
          userId: sent.userId == 0 ? currentUserId : sent.userId,
          content: (sent.content == null || sent.content!.trim().isEmpty)
              ? text
              : sent.content,
          senderName: sent.senderName ?? currentUser?.username,
          senderAvatarUrl:
              sent.senderAvatarUrl ?? currentUser?.profileImageUrl,
          status: ChatMessageStatus.sent,
          failureMessage: null,
          isLocal: false,
        ),
      );
    } catch (error) {
      _replaceMessage(
        roomId: roomId,
        messageId: messageId,
        updatedMessage: retrying.copyWith(
          status: ChatMessageStatus.failed,
          failureMessage: _resolveErrorMessage(
            error,
            fallback: 'تعذر إرسال الرسالة.',
          ),
        ),
      );
    } finally {
      _sendingRooms.remove(roomId);
      notifyListeners();
    }
  }

  void cancelFailedMessage({
    required int roomId,
    required int messageId,
  }) {
    final target = _findMessage(roomId: roomId, messageId: messageId);
    if (target == null || target.status != ChatMessageStatus.failed) {
      return;
    }

    _removeMessage(roomId: roomId, messageId: messageId);
    notifyListeners();
  }

  Future<void> sendImageMessage({
    required int roomId,
    required String attachmentPath,
  }) async {
    final currentUser = currentUserProvider.user;
    final currentUserId = currentUser?.id;
    if (currentUserId == null) {
      throw const ApiException('تعذر تحديد المستخدم الحالي.');
    }

    final temporaryId = -DateTime.now().microsecondsSinceEpoch;
    final optimistic = ChatMessageEntity(
      id: temporaryId,
      chatRoomId: roomId,
      userId: currentUserId,
      sentAt: DateTime.now(),
      attachmentPath: attachmentPath,
      senderName: currentUser?.username,
      senderAvatarUrl: currentUser?.profileImageUrl,
      status: ChatMessageStatus.sending,
      isLocal: true,
    );

    _messagesByRoom[roomId] = <ChatMessageEntity>[
      ...(_messagesByRoom[roomId] ?? const <ChatMessageEntity>[]),
      optimistic,
    ];
    _messagesErrorsByRoom.remove(roomId);
    _sendingRooms.add(roomId);
    notifyListeners();

    try {
      final sent = await sendImageMessageUseCase(
        roomId: roomId,
        userId: currentUserId,
        attachmentPath: attachmentPath,
      );
      _replaceMessage(
        roomId: roomId,
        messageId: temporaryId,
        updatedMessage: sent.copyWith(
          chatRoomId: sent.chatRoomId == 0 ? roomId : sent.chatRoomId,
          userId: sent.userId == 0 ? currentUserId : sent.userId,
          attachmentPath: sent.attachmentPath ?? attachmentPath,
          senderName: sent.senderName ?? currentUser?.username,
          senderAvatarUrl:
              sent.senderAvatarUrl ?? currentUser?.profileImageUrl,
          status: ChatMessageStatus.sent,
          failureMessage: null,
        ),
      );
    } catch (error) {
      _replaceMessage(
        roomId: roomId,
        messageId: temporaryId,
        updatedMessage: optimistic.copyWith(
          status: ChatMessageStatus.failed,
          failureMessage: _resolveErrorMessage(
            error,
            fallback: 'تعذر إرسال الصورة.',
          ),
        ),
      );
      rethrow;
    } finally {
      _sendingRooms.remove(roomId);
      notifyListeners();
    }
  }

  void _replaceMessage({
    required int roomId,
    required int messageId,
    required ChatMessageEntity updatedMessage,
  }) {
    _messagesByRoom[roomId] = (_messagesByRoom[roomId] ??
            const <ChatMessageEntity>[])
        .map((message) => message.id == messageId ? updatedMessage : message)
        .toList(growable: false);
  }

  void _removeMessage({
    required int roomId,
    required int messageId,
  }) {
    _messagesByRoom[roomId] = (_messagesByRoom[roomId] ??
            const <ChatMessageEntity>[])
        .where((message) => message.id != messageId)
        .toList(growable: false);
  }

  ChatMessageEntity? _findMessage({
    required int roomId,
    required int messageId,
  }) {
    for (final message in _messagesByRoom[roomId] ?? const <ChatMessageEntity>[]) {
      if (message.id == messageId) {
        return message;
      }
    }
    return null;
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

  String _resolveErrorMessage(Object error, {required String fallback}) {
    if (error is TimeoutApiException) {
      return 'استغرق الاتصال بالمجتمع وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      final message = error.message.trim();
      if (message.isNotEmpty) {
        return message;
      }
    }

    final message = error.toString().trim();
    if (message.isNotEmpty && !message.startsWith('Exception')) {
      return message;
    }
    return fallback;
  }

  @override
  void dispose() {
    currentUserProvider.removeListener(_onCurrentUserChanged);
    super.dispose();
  }
}
