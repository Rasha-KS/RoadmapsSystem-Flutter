import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/features/smart_instructor/data/smart_instructor_message_model.dart';
import 'package:roadmaps/features/smart_instructor/data/smart_instructor_repository.dart';
import 'package:roadmaps/features/smart_instructor/data/smart_instructor_session_model.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_intro_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_session_entity.dart';

class SmartInstructorApiRepository implements SmartInstructorRepository {
  SmartInstructorApiRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<SmartInstructorIntroEntity> getIntro() async {
    return const SmartInstructorIntroEntity(
      title: 'مرحبًا بك في المعلم الذكي',
      subtitle: 'ابدأ محادثة جديدة، وابقَ على تواصل مع جلساتك السابقة.',
      ctaLabel: 'هيا لنبدأ',
    );
  }

  @override
  Future<List<SmartInstructorSessionEntity>> getSessions() async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.chatbotSessions),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل المحادثات.');

    final items = _extractList(
      response['data'],
      keys: const ['sessions', 'items', 'data', 'results'],
    );

    return items.map(SmartInstructorSessionModel.fromJson).toList();
  }

  @override
  Future<SmartInstructorSessionEntity> createSession({
    required String title,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.chatbotSessions),
      body: {'title': title},
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر إنشاء المحادثة.');

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParsingException();
    }

    return SmartInstructorSessionModel.fromJson(data);
  }

  @override
  Future<List<SmartInstructorMessageEntity>> getMessages({
    required int sessionId,
  }) async {
    final messages = <SmartInstructorMessageEntity>[];
    var page = 1;
    var lastPage = 1;

    do {
      final response = await _apiClient.get(
        _buildMessagesUrl(sessionId: sessionId, page: page),
      );
      _ensureSuccess(response, fallbackMessage: 'تعذر تحميل الرسائل.');

      final items = _extractList(
        response['data'],
        keys: const ['messages', 'items', 'data', 'results'],
      );

      messages.addAll(items.map(SmartInstructorMessageModel.fromJson));
      lastPage = _extractLastPage(response['meta']) ?? page;
      page++;
    } while (page <= lastPage);

    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  @override
  Future<List<SmartInstructorMessageEntity>> sendMessage({
    required int sessionId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.chatbotSessionMessages(sessionId)),
      body: {'message': content},
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر إرسال الرسالة.');

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final userMessage = data['user_message'];
      final assistantMessage = data['assistant_message'];

      if (userMessage is Map<String, dynamic>) {
        final messages = <SmartInstructorMessageEntity>[
          SmartInstructorMessageModel.fromJson(userMessage),
        ];
        if (assistantMessage is Map<String, dynamic>) {
          messages.add(SmartInstructorMessageModel.fromJson(assistantMessage));
        }
        return messages;
      }
    }

    final message = response['message']?.toString().trim();
    if (message == 'Server Error') {
      // Temporary payment-gated behavior:
      // until the AI backend is enabled, this response means the user message
      // was accepted but no assistant reply is available yet.
      // Once billing is enabled, remove this special-case and treat responses
      // strictly by their real payload.
      return [
        SmartInstructorMessageModel(
          id: -DateTime.now().microsecondsSinceEpoch,
          text: content,
          isFromUser: true,
          sentAt: DateTime.now(),
        ),
      ];
    }

    throw const ParsingException();
  }

  @override
  Future<SmartInstructorMessageEntity> sendImageMessage({
    required String attachmentPath,
  }) {
    throw UnsupportedError(
      'Smart Instructor does not support image messages.',
    );
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    final response = await _apiClient.delete(
      ApiConstants.url(ApiConstants.chatbotSession(sessionId)),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر حذف المحادثة.');
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
      }
    }

    throw const ParsingException();
  }

  String _buildMessagesUrl({
    required int sessionId,
    required int page,
  }) {
    final uri = Uri.parse(ApiConstants.url(ApiConstants.chatbotSessionMessages(sessionId)))
        .replace(queryParameters: {'page': '$page'});
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
