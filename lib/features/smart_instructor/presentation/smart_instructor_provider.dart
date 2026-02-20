import 'package:flutter/material.dart';
import 'package:roadmaps/features/smart_instructor/domain/get_smart_instructor_intro_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/get_smart_instructor_messages_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/send_smart_instructor_image_message_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/send_smart_instructor_message_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_intro_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

class SmartInstructorProvider extends ChangeNotifier {
  SmartInstructorProvider({
    required this.getSmartInstructorIntroUseCase,
    required this.getSmartInstructorMessagesUseCase,
    required this.sendSmartInstructorMessageUseCase,
    required this.sendSmartInstructorImageMessageUseCase,
  });

  final GetSmartInstructorIntroUseCase getSmartInstructorIntroUseCase;
  final GetSmartInstructorMessagesUseCase getSmartInstructorMessagesUseCase;
  final SendSmartInstructorMessageUseCase sendSmartInstructorMessageUseCase;
  final SendSmartInstructorImageMessageUseCase
  sendSmartInstructorImageMessageUseCase;

  SmartInstructorIntroEntity? intro;
  bool introLoading = false;
  String? introError;

  List<SmartInstructorMessageEntity> _messages = [];
  bool messagesLoading = false;
  String? messagesError;
  bool sendingMessage = false;
  String? sendError;

  List<SmartInstructorMessageEntity> get messages =>
      List.unmodifiable(_messages);

  Future<void> loadIntro() async {
    introLoading = true;
    introError = null;
    notifyListeners();

    try {
      intro = await getSmartInstructorIntroUseCase();
    } catch (_) {
      introError = 'تعذر تحميل شاشة الترحيب';
    }

    introLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages() async {
    messagesLoading = true;
    messagesError = null;
    notifyListeners();

    try {
      _messages = await getSmartInstructorMessagesUseCase();
    } catch (_) {
      messagesError = 'تعذر تحميل المحادثة';
    }

    messagesLoading = false;
    notifyListeners();
  }

  Future<void> sendTextMessage({required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || sendingMessage) return;

    sendError = null;
    sendingMessage = true;

    final temporaryId = -DateTime.now().microsecondsSinceEpoch;
    final optimisticUserMessage = SmartInstructorMessageEntity(
      id: temporaryId,
      text: trimmed,
      isFromUser: true,
      sentAt: DateTime.now(),
    );

    _messages = <SmartInstructorMessageEntity>[
      ..._messages,
      optimisticUserMessage,
    ];
    notifyListeners();

    try {
      final assistantReply = await sendSmartInstructorMessageUseCase(
        content: trimmed,
      );
      _messages = <SmartInstructorMessageEntity>[
        ..._messages.where((message) => message.id != temporaryId),
        optimisticUserMessage,
        assistantReply,
      ];
    } catch (_) {
      _messages = _messages
          .where((message) => message.id != temporaryId)
          .toList();
      sendError = 'تعذر إرسال الرسالة. حاول مرة أخرى';
    }

    sendingMessage = false;
    notifyListeners();
  }

  Future<void> sendImageMessage({required String attachmentPath}) async {
    if (attachmentPath.trim().isEmpty || sendingMessage) return;

    sendError = null;
    sendingMessage = true;

    final temporaryId = -DateTime.now().microsecondsSinceEpoch;
    final optimisticImage = SmartInstructorMessageEntity(
      id: temporaryId,
      attachmentPath: attachmentPath,
      isFromUser: true,
      sentAt: DateTime.now(),
    );

    _messages = <SmartInstructorMessageEntity>[..._messages, optimisticImage];
    notifyListeners();

    try {
      final sent = await sendSmartInstructorImageMessageUseCase(
        attachmentPath: attachmentPath,
      );
      _replaceOptimistic(temporaryId: temporaryId, sent: sent);
    } catch (_) {
      _messages = _messages
          .where((message) => message.id != temporaryId)
          .toList();
      sendError = 'تعذر إرسال الصورة. حاول مرة أخرى';
    }

    sendingMessage = false;
    notifyListeners();
  }

  void _replaceOptimistic({
    required int temporaryId,
    required SmartInstructorMessageEntity sent,
  }) {
    _messages = _messages
        .map((message) {
          if (message.id == temporaryId) {
            return sent;
          }
          return message;
        })
        .toList(growable: false);
  }
}
