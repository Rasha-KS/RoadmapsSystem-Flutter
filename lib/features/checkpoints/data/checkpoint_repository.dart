import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';

import 'checkpoint_model.dart';

class CheckpointRepository {
  CheckpointRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CheckpointModel> getCheckpoint({
    required String learningPathId,
    required String checkpointId,
  }) async {
    final quizId = _asInt(checkpointId);
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.quizDetails(quizId)),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل بيانات الاختبار.');

    final data = _extractMap(response['data']) ?? response;
    return CheckpointModel.fromJson(data);
  }

  Future<int> createAttempt({required int quizId}) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.quizAttempts(quizId)),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر بدء محاولة الاختبار.');
    final attemptId =
        _extractAttemptId(response['data']) ?? _extractAttemptId(response);
    if (attemptId == null) {
      throw const ParsingException();
    }
    return attemptId;
  }

  Future<int> retakeAttempt({required int quizId}) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.quizRetake(quizId)),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر بدء محاولة جديدة للاختبار.');
    final attemptId =
        _extractAttemptId(response['data']) ?? _extractAttemptId(response);
    if (attemptId == null) {
      throw const ParsingException();
    }
    return attemptId;
  }

  Future<QuizSubmissionResultModel> submitAttempt({
    required int attemptId,
    required Map<String, String> answers,
    required int score,
    required bool passed,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.url(ApiConstants.quizSubmitAttempt(attemptId)),
      body: <String, dynamic>{
        'answers': answers,
        'score': score,
        'passed': passed,
      },
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر إرسال إجابات الاختبار.');

    final data = _extractMap(response['data']) ?? response;
    return QuizSubmissionResultModel.fromJson(data);
  }

  Future<int> getAttemptsCount({required int quizId}) async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.quizAttemptsCount(quizId)),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل عدد المحاولات.');

    final data = _extractMap(response['data']) ?? response;
    return _asInt(data['attempts_count'] ?? data['attemptsCount']);
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

  Map<String, dynamic>? _extractMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return null;
  }

  int? _extractAttemptId(dynamic value) {
    final map = _extractMap(value);
    if (map == null) return null;

    final attempt = _extractMap(map['attempt']);
    if (attempt != null) {
      final id = attempt['id'] ?? attempt['attempt_id'];
      final parsed = _asIntOrNull(id);
      if (parsed != null) {
        return parsed;
      }
    }

    final direct = map['attempt_id'] ?? map['attemptId'] ?? map['id'];
    return _asIntOrNull(direct);
  }

  int _asInt(dynamic value) {
    final parsed = _asIntOrNull(value);
    return parsed ?? 0;
  }

  int? _asIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class QuizSubmissionResultModel {
  final int? attemptId;
  final bool passed;
  final int score;
  final int earnedPoints;

  const QuizSubmissionResultModel({
    required this.attemptId,
    required this.passed,
    required this.score,
    required this.earnedPoints,
  });

  factory QuizSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    final attempt = json['attempt'];
    final attemptMap = attempt is Map<String, dynamic>
        ? attempt
        : attempt is Map
            ? attempt.cast<String, dynamic>()
            : <String, dynamic>{};

    return QuizSubmissionResultModel(
      attemptId: _asIntOrNull(
        attemptMap['id'] ?? attemptMap['attempt_id'] ?? json['attempt_id'],
      ),
      passed: _asBool(json['passed']),
      score: _asInt(json['score']),
      earnedPoints: _asInt(
        json['earned_points'] ?? json['earnedPoints'] ?? json['points'],
      ),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asIntOrNull(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase();
  switch (text) {
    case '1':
    case 'true':
    case 'yes':
      return true;
    default:
      return false;
  }
}
