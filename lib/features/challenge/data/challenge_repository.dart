import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/features/challenge/data/challenge_model.dart';

class ChallengeRepository {
  ChallengeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ChallengeModel?> getChallengeById(int challengeId) async {
    final response = await _apiClient.get(
      ApiConstants.url(ApiConstants.challengeDetails(challengeId)),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحميل بيانات التحدي.');

    final data =
        _extractChallengePayload(response['data']) ??
        _extractChallengePayload(response);
    if (data == null || data.isEmpty) {
      throw const ParsingException();
    }

    return ChallengeModel.fromJson(data);
  }

  Future<ChallengeRunResultModel> runCode({
    required int challengeId,
    required String userCode,
  }) async {
    final attemptId = await _createAttempt(challengeId: challengeId);
    final response = await _apiClient.put(
      ApiConstants.url(ApiConstants.challengeSubmitAttempt(attemptId)),
      body: <String, dynamic>{'code': userCode},
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر إرسال حل التحدي.');
    _logSubmitResponse(response);

    final data =
        _extractRunResultPayload(response['data']) ??
        _extractRunResultPayload(response);
    if (data == null || data.isEmpty) {
      throw const ParsingException();
    }

    final result = ChallengeRunResultModel.fromJson(data);
    debugPrint(
      'Challenge submit interpreted result: http_ok=true, execution_passed=${result.passed}, execution_output=${result.executionOutput}',
    );
    return result;
  }

  Future<int> _createAttempt({required int challengeId}) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.challengeAttempts(challengeId)),
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر بدء محاولة جديدة للتحدي.');

    final attemptId =
        _extractAttemptId(response['data']) ?? _extractAttemptId(response);
    if (attemptId == null) {
      throw const ParsingException();
    }
    return attemptId;
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

  Map<String, dynamic>? _extractChallengePayload(dynamic value) {
    final map = _extractMap(value);
    if (map == null) {
      return null;
    }

    final nestedChallenge = _extractMap(map['challenge']);
    if (nestedChallenge != null && nestedChallenge.isNotEmpty) {
      return nestedChallenge;
    }

    return map;
  }

  Map<String, dynamic>? _extractRunResultPayload(dynamic value) {
    final map = _extractMap(value);
    if (map == null) {
      return null;
    }

    final nestedResult =
        _extractMap(map['result']) ??
        _extractMap(map['submission']) ??
        _extractMap(map['challenge_result']);
    if (nestedResult != null && nestedResult.isNotEmpty) {
      return nestedResult;
    }

    return map;
  }

  int? _extractAttemptId(dynamic value) {
    final map = _extractMap(value);
    if (map == null) {
      return null;
    }

    final attempt = _extractMap(map['attempt']);
    if (attempt != null) {
      final nestedId = _asIntOrNull(attempt['id'] ?? attempt['attempt_id']);
      if (nestedId != null) {
        return nestedId;
      }
    }

    return _asIntOrNull(map['id'] ?? map['attempt_id'] ?? map['attemptId']);
  }

  int? _asIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  void _logSubmitResponse(Map<String, dynamic> response) {
    try {
      debugPrint('Challenge submit response.data: ${jsonEncode(response['data'])}');
      debugPrint('Challenge submit full response: ${jsonEncode(response)}');
    } catch (_) {
      debugPrint('Challenge submit response.data: ${response['data']}');
      debugPrint('Challenge submit full response: $response');
    }
  }
}
