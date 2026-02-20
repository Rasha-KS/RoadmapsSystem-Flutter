import 'package:roadmaps/features/smart_instructor/data/smart_instructor_intro_model.dart';
import 'package:roadmaps/features/smart_instructor/data/smart_instructor_message_model.dart';
import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_intro_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';

class MockSmartInstructorRepository implements SmartInstructorRepository {
  final Map<String, dynamic> _introTable = {
    'title': 'مرحبا بك في المساعد الذكي',
    'subtitle': 'كيف يمكنني مساعدتك؟',
    'cta_label': 'هيا لنبدأ',
  };

  final List<Map<String, dynamic>> _messagesTable = [
    {
      'id': 1,
      'text': 'كيف يمكنني مساعدتك؟',
      'attachment_path': null,
      'is_from_user': false,
      'sent_at': DateTime(2026, 2, 19, 11, 30),
    },
    {
      'id': 2,
      'text': 'أحتاج خطة لتعلم Flutter خلال شهرين',
      'attachment_path': null,
      'is_from_user': true,
      'sent_at': DateTime(2026, 2, 19, 11, 31),
    },
    {
      'id': 3,
      'text': 'ممتاز، ابدأ بدارت أسبوعين ثم بناء واجهات تطبيق خلال 3 أسابيع.',
      'attachment_path': null,
      'is_from_user': false,
      'sent_at': DateTime(2026, 2, 19, 11, 32),
    },
  ];

  @override
  Future<SmartInstructorIntroEntity> getIntro() async {
    await Future.delayed(const Duration(milliseconds: 180));
    return SmartInstructorIntroModel.fromJson(_introTable);
  }

  @override
  Future<List<SmartInstructorMessageEntity>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _messagesTable.map(SmartInstructorMessageModel.fromJson).toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  @override
  Future<SmartInstructorMessageEntity> sendUserMessage({
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 260));
    final nextId = _messagesTable.isEmpty
        ? 1
        : (_messagesTable.last['id'] as int) + 1;

    final assistantRecord = {
      'id': nextId,
      'text': 'فهمت رسالتك: "$content"\nسأقترح عليك خطوات قصيرة وعملية الآن.',
      'attachment_path': null,
      'is_from_user': false,
      'sent_at': DateTime.now(),
    };

    _messagesTable.add(assistantRecord);
    return SmartInstructorMessageModel.fromJson(assistantRecord);
  }

  @override
  Future<SmartInstructorMessageEntity> sendImageMessage({
    required String attachmentPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final nextId = _messagesTable.isEmpty
        ? 1
        : (_messagesTable.last['id'] as int) + 1;

    final userImageRecord = {
      'id': nextId,
      'text': null,
      'attachment_path': attachmentPath,
      'is_from_user': true,
      'sent_at': DateTime.now(),
    };

    _messagesTable.add(userImageRecord);
    return SmartInstructorMessageModel.fromJson(userImageRecord);
  }
}
