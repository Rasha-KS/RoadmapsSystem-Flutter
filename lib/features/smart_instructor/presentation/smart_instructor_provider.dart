import 'dart:async';

import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import 'package:roadmaps/features/smart_instructor/domain/create_smart_instructor_session_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/delete_smart_instructor_session_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/get_smart_instructor_messages_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/get_smart_instructor_sessions_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/send_smart_instructor_message_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_session_entity.dart';

class SmartInstructorProvider extends SafeChangeNotifier {
  SmartInstructorProvider({
    required this.getSmartInstructorSessionsUseCase,
    required this.getSmartInstructorMessagesUseCase,
    required this.sendSmartInstructorMessageUseCase,
    required this.createSmartInstructorSessionUseCase,
    required this.deleteSmartInstructorSessionUseCase,
  });

  final GetSmartInstructorSessionsUseCase getSmartInstructorSessionsUseCase;
  final GetSmartInstructorMessagesUseCase getSmartInstructorMessagesUseCase;
  final SendSmartInstructorMessageUseCase sendSmartInstructorMessageUseCase;
  final CreateSmartInstructorSessionUseCase createSmartInstructorSessionUseCase;
  final DeleteSmartInstructorSessionUseCase deleteSmartInstructorSessionUseCase;

  final Map<int, List<SmartInstructorMessageEntity>> _messagesBySession = {};
  final Map<int, int> _messageResolutionTokens = {};
  List<SmartInstructorSessionEntity> _sessions = [];
  List<SmartInstructorMessageEntity> _messages = [];
  int _messagesRequestToken = 0;
  bool _isDisposed = false;

  int? currentSessionId;
  bool loadingSessions = false;
  bool loadingMessages = false;
  bool sendingMessage = false;
  int? deletingSessionId;
  String? sessionsError;
  String? messagesError;
  String? actionError;

  List<SmartInstructorSessionEntity> get sessions =>
      List.unmodifiable(_sessions);

  List<SmartInstructorMessageEntity> get messages =>
      List.unmodifiable(_messages);

  @override
  bool get isDisposed => _isDisposed;

  SmartInstructorSessionEntity? get currentSession {
    final sessionId = currentSessionId;
    if (sessionId == null) return null;
    for (final session in _sessions) {
      if (session.id == sessionId) return session;
    }
    return null;
  }

  Future<void> loadSessions({bool silent = false}) async {
    if (!silent) {
      loadingSessions = true;
    }
    sessionsError = null;
    _notifyIfAlive();

    try {
      final fetchedSessions = await getSmartInstructorSessionsUseCase();
      final repositoryError =
          getSmartInstructorSessionsUseCase.repository.lastSessionsLoadErrorMessage;
      if (repositoryError == null || fetchedSessions.isNotEmpty) {
        _sessions = fetchedSessions;
      }
      if (repositoryError != null) {
        sessionsError = repositoryError;
      }
      if (_isDisposed) return;
      _removeMissingCurrentSession();
    } catch (_) {
      sessionsError = 'تعذر تحميل الجلسات';
    }

    loadingSessions = false;
    _notifyIfAlive();
  }

  Future<void> openSession(int sessionId) async {
    discardFailedMessages();
    final requestToken = ++_messagesRequestToken;
    currentSessionId = sessionId;
    messagesError = null;
    loadingMessages = true;
    _messages = [];
    _notifyIfAlive();

    try {
      final loadedMessages = await getSmartInstructorMessagesUseCase(
        sessionId: sessionId,
      );
      final repositoryError =
          getSmartInstructorMessagesUseCase.repository.lastMessagesLoadErrorMessage;
      final normalizedMessages = _normalizeRetrievedMessages(loadedMessages);
      if (repositoryError == null || normalizedMessages.isNotEmpty) {
        _messagesBySession[sessionId] = normalizedMessages;
        _messages = normalizedMessages;
      }
      if (repositoryError != null) {
        messagesError = repositoryError;
      }
      if (_isDisposed) return;
      if (requestToken != _messagesRequestToken || currentSessionId != sessionId) {
        return;
      }
    } on ApiException catch (error) {
      if (requestToken != _messagesRequestToken || currentSessionId != sessionId) {
        return;
      }
      messagesError = error.message;
      _messages = _messagesBySession[sessionId] ?? <SmartInstructorMessageEntity>[];
    } catch (_) {
      if (requestToken != _messagesRequestToken || currentSessionId != sessionId) {
        return;
      }
      messagesError = 'تعذر تحميل الرسائل';
      _messages = _messagesBySession[sessionId] ?? <SmartInstructorMessageEntity>[];
    }

    if (requestToken != _messagesRequestToken || currentSessionId != sessionId) {
      return;
    }
    loadingMessages = false;
    _notifyIfAlive();
  }

  void clearCurrentSession() {
    currentSessionId = null;
    _messages = [];
    messagesError = null;
    _notifyIfAlive();
  }

  void discardFailedMessages() {
    _messages = _messages
        .where((message) => message.status != SmartInstructorMessageStatus.failed)
        .toList(growable: false);

    final updatedCache = <int, List<SmartInstructorMessageEntity>>{};
    for (final entry in _messagesBySession.entries) {
      final filtered = entry.value
          .where((message) => message.status != SmartInstructorMessageStatus.failed)
          .toList(growable: false);
      if (filtered.isNotEmpty) {
        updatedCache[entry.key] = filtered;
      }
    }
    _messagesBySession
      ..clear()
      ..addAll(updatedCache);

    final sessionId = currentSessionId;
    if (sessionId != null) {
      _messages = _messagesBySession[sessionId] ?? _messages;
    }

    _notifyIfAlive();
  }

  Future<void> sendTextMessage({required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || sendingMessage) return;
    await _submitTextMessage(trimmed);
  }

  Future<void> retryMessage(int messageId) async {
    final message = _messages.firstWhere(
      (item) => item.id == messageId,
      orElse: () => throw StateError('Message not found'),
    );
    final text = message.text?.trim();
    if (text == null || text.isEmpty) return;
    if (sendingMessage) return;

    final sessionId = currentSessionId;
    if (sessionId != null) {
      final resolutionToken = _beginResolutionAttempt(messageId);
      final reconciled = await _tryReconcilePendingMessage(
        sessionId: sessionId,
        messageText: text,
        localMessageId: messageId,
        sentAt: message.sentAt,
        resolutionToken: resolutionToken,
      );
      if (reconciled) {
        sendingMessage = false;
        _notifyIfAlive();
        return;
      }
    }

    await _submitTextMessage(text, retryMessageId: messageId);
  }

  Future<void> deleteSession(int sessionId) async {
    if (deletingSessionId == sessionId) return;

    deletingSessionId = sessionId;
    actionError = null;
    _notifyIfAlive();

    try {
      await deleteSmartInstructorSessionUseCase(sessionId);
      _sessions.removeWhere((session) => session.id == sessionId);
      _messagesBySession.remove(sessionId);

      if (currentSessionId == sessionId) {
        currentSessionId = null;
        _messages = [];
        messagesError = null;
      }
    } catch (_) {
      actionError = 'تعذر حذف المحادثة. حاول مرة أخرى';
    }

    deletingSessionId = null;
    _notifyIfAlive();
  }

  Future<SmartInstructorSessionEntity> _createSessionFromFirstMessage(
    String firstMessage,
  ) async {
    final title = _deriveSessionTitle(firstMessage);
    final session = await createSmartInstructorSessionUseCase(title: title);
    currentSessionId = session.id;
    _upsertSession(session);
    return session;
  }

  Future<void> _submitTextMessage(
    String text, {
    int? retryMessageId,
  }) async {
    actionError = null;
    sendingMessage = true;

    final localMessageId = retryMessageId ?? -DateTime.now().microsecondsSinceEpoch;
    final resolutionToken = _beginResolutionAttempt(localMessageId);
    final pendingMessage = SmartInstructorMessageEntity(
      id: localMessageId,
      text: text,
      isFromUser: true,
      sentAt: DateTime.now(),
      status: SmartInstructorMessageStatus.sending,
    );

    _replaceOrInsertLocalMessage(pendingMessage);
    _notifyIfAlive();

    var activeSessionId = currentSessionId;

    try {
      activeSessionId = currentSessionId ??
          (await _createSessionFromFirstMessage(text)).id;
      if (_isDisposed) return;

      final sentMessages = await sendSmartInstructorMessageUseCase(
        sessionId: activeSessionId,
        content: text,
      );
      if (_isDisposed) return;

      final sentUserMessage = sentMessages.first.copyWith(
        id: localMessageId,
        text: text,
        isFromUser: true,
        sentAt: sentMessages.first.sentAt,
        status: SmartInstructorMessageStatus.sent,
      );
      final assistantMessage = sentMessages.length > 1 ? sentMessages[1] : null;

      final updatedMessages = _messages
          .map((message) {
            if (message.id == localMessageId) {
              return sentUserMessage;
            }
            return message;
          })
          .toList(growable: true);

      if (assistantMessage != null) {
        updatedMessages.add(
          assistantMessage.copyWith(status: SmartInstructorMessageStatus.sent),
        );
      }

      _messages = updatedMessages;
      _messagesBySession[activeSessionId] = updatedMessages;

      try {
        final refreshedMessages = await getSmartInstructorMessagesUseCase(
          sessionId: activeSessionId,
        );
        if (_isDisposed) return;
        final normalizedMessages = _normalizeRetrievedMessages(refreshedMessages);
        if (normalizedMessages.isNotEmpty) {
          _messages = normalizedMessages;
          _messagesBySession[activeSessionId] = normalizedMessages;
        } else if (assistantMessage != null) {
          _messages = updatedMessages;
        }
      } catch (_) {
        // The send already succeeded, so keep the optimistic sent state.
        // A later screen reopen will resync from the backend.
      }

      try {
        await _refreshSessionsSilently();
      } catch (_) {
        // Keep the sent message even if the session list cannot refresh.
      }
    } on ApiException catch (error) {
      if (activeSessionId != null) {
        unawaited(
          _resolvePendingMessageEventually(
            sessionId: activeSessionId,
            messageText: text,
            localMessageId: localMessageId,
            sentAt: pendingMessage.sentAt,
            resolutionToken: resolutionToken,
            failureMessage: error.message,
          ),
        );
        sendingMessage = false;
        _notifyIfAlive();
        return;
      }

      _markMessageFailed(localMessageId, error.message);
    } catch (_) {
      if (activeSessionId != null) {
        unawaited(
          _resolvePendingMessageEventually(
            sessionId: activeSessionId,
            messageText: text,
            localMessageId: localMessageId,
            sentAt: pendingMessage.sentAt,
            resolutionToken: resolutionToken,
          ),
        );
        sendingMessage = false;
        _notifyIfAlive();
        return;
      }

      _markMessageFailed(localMessageId);
    }

    if (_isDisposed) return;
    sendingMessage = false;
    _notifyIfAlive();
  }

  int _beginResolutionAttempt(int messageId) {
    final nextToken = (_messageResolutionTokens[messageId] ?? 0) + 1;
    _messageResolutionTokens[messageId] = nextToken;
    return nextToken;
  }

  bool _isCurrentResolutionAttempt(int messageId, int token) {
    return _messageResolutionTokens[messageId] == token;
  }

  Future<void> _resolvePendingMessageEventually({
    required int sessionId,
    required String messageText,
    required int localMessageId,
    required DateTime sentAt,
    required int resolutionToken,
    String? failureMessage,
  }) async {
    final reconciled = await _tryReconcilePendingMessage(
      sessionId: sessionId,
      messageText: messageText,
      localMessageId: localMessageId,
      sentAt: sentAt,
      resolutionToken: resolutionToken,
    );
    if (reconciled) {
      return;
    }

    if (!_isCurrentResolutionAttempt(localMessageId, resolutionToken)) {
      return;
    }

    _markMessageFailed(localMessageId, failureMessage);
    if (currentSessionId == sessionId) {
      _notifyIfAlive();
    }
  }

  void _replaceOrInsertLocalMessage(SmartInstructorMessageEntity message) {
    final index = _messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      _messages = <SmartInstructorMessageEntity>[..._messages, message];
      return;
    }

    final updated = List<SmartInstructorMessageEntity>.from(_messages);
    updated[index] = message;
    _messages = updated;
  }

  void _markMessageFailed(int messageId, [String? failureMessage]) {
    _messages = _messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(
          status: SmartInstructorMessageStatus.failed,
          failureMessage: failureMessage,
        );
      }
      return message;
    }).toList(growable: false);

    final sessionId = currentSessionId;
    if (sessionId != null) {
      _messagesBySession[sessionId] = _messages;
    }
  }

  Future<bool> _tryReconcilePendingMessage({
    required int sessionId,
    required String messageText,
    required int localMessageId,
    required DateTime sentAt,
    required int resolutionToken,
  }) async {
    const retryDelays = <Duration>[
      Duration.zero,
      Duration(milliseconds: 300),
      Duration(milliseconds: 700),
      Duration(milliseconds: 1500),
      Duration(milliseconds: 3000),
      Duration(milliseconds: 5000),
      Duration(milliseconds: 8000),
      Duration(milliseconds: 12000),
      Duration(milliseconds: 16000),
    ];

    try {
      for (final delay in retryDelays) {
        if (delay != Duration.zero) {
          await Future.delayed(delay);
        }
        if (_isDisposed || !_isCurrentResolutionAttempt(localMessageId, resolutionToken)) {
          return false;
        }

        final backendMessages = await getSmartInstructorMessagesUseCase(
          sessionId: sessionId,
        );
        if (_isDisposed || !_isCurrentResolutionAttempt(localMessageId, resolutionToken)) {
          return false;
        }

        final normalizedMessages = _normalizeRetrievedMessages(backendMessages);
        final backendMessage = normalizedMessages
            .where(
              (message) =>
                  message.isFromUser &&
                  message.text?.trim() == messageText.trim() &&
                  message.sentAt.isAfter(
                    sentAt.subtract(const Duration(seconds: 10)),
                  ),
            )
            .fold<SmartInstructorMessageEntity?>(null, (latest, current) {
          if (latest == null) return current;
          return current.sentAt.isAfter(latest.sentAt) ? current : latest;
        });

        if (backendMessage == null) {
          continue;
        }

        final reconciledMessage = backendMessage.copyWith(
          id: backendMessage.id,
          isFromUser: true,
          status: SmartInstructorMessageStatus.sent,
          failureMessage: null,
        );

        final updatedMessages = _messages.map((message) {
          if (message.id == localMessageId) {
            return reconciledMessage;
          }
          return message;
        }).toList(growable: true);

        if (!updatedMessages.any((message) => message.id == backendMessage.id)) {
          updatedMessages.add(reconciledMessage);
        }

        updatedMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
        _messages = updatedMessages;
        _messagesBySession[sessionId] = updatedMessages;
        _messageResolutionTokens.remove(localMessageId);
        return true;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  Future<void> _refreshSessionsSilently() async {
    try {
      _sessions = await getSmartInstructorSessionsUseCase();
      if (_isDisposed) return;
      _removeMissingCurrentSession();
      _notifyIfAlive();
    } catch (_) {
      // Keep the current view stable if a background refresh fails.
    }
  }

  void _upsertSession(SmartInstructorSessionEntity session) {
    final index = _sessions.indexWhere((item) => item.id == session.id);
    if (index == -1) {
      _sessions = <SmartInstructorSessionEntity>[session, ..._sessions];
    } else {
      final updated = List<SmartInstructorSessionEntity>.from(_sessions);
      updated[index] = session;
      _sessions = updated;
    }
    _notifyIfAlive();
  }

  void _removeMissingCurrentSession() {
    final sessionId = currentSessionId;
    if (sessionId == null) return;

    final exists = _sessions.any((session) => session.id == sessionId);
    if (exists) return;

    currentSessionId = null;
    _messages = [];
  }

  @override
  void dispose() {
    _isDisposed = true;
    _messagesRequestToken++;
    super.dispose();
  }

  void _notifyIfAlive() {
    if (_isDisposed) return;
    notifyListeners();
  }

  List<SmartInstructorMessageEntity> _normalizeRetrievedMessages(
    List<SmartInstructorMessageEntity> messages,
  ) {
    // Keep backend history as-is. We only discard local failed messages when
    // leaving the screen or switching sessions.
    return List<SmartInstructorMessageEntity>.from(messages);
  }

  String _deriveSessionTitle(String message) {
    final normalized = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return 'محادثة جديدة';

    final words = normalized.split(' ');
    final title = words.take(6).join(' ').trim();
    if (title.isNotEmpty && title.length <= 48) {
      return title;
    }

    return normalized.substring(0, normalized.length > 48 ? 48 : normalized.length).trim();
  }
}
