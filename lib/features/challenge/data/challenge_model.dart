import 'dart:convert';

import 'package:roadmaps/features/challenge/domain/challenge_entity.dart';

class ChallengeModel {
  final int id;
  final int learningUnitId;
  final String title;
  final String description;
  final String language;
  final String starterCode;
  final int minXp;
  final bool isActive;
  final bool isLocked;
  final int requiredXp;
  final int userXp;
  final int missingXp;

  const ChallengeModel({
    required this.id,
    required this.learningUnitId,
    required this.title,
    required this.description,
    required this.language,
    required this.starterCode,
    required this.minXp,
    required this.isActive,
    required this.isLocked,
    required this.requiredXp,
    required this.userXp,
    required this.missingXp,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: _asInt(json['id']),
      learningUnitId: _asInt(json['learning_unit_id']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      language: _asString(json['language']),
      starterCode: _asString(json['starter_code']),
      minXp: _asInt(json['min_xp']),
      isActive: _asBool(json['is_active'], fallback: true),
      isLocked: _asBool(json['is_locked']),
      requiredXp: _asInt(json['required_xp'] ?? json['min_xp']),
      userXp: _asInt(json['user_xp']),
      missingXp: _asInt(json['missing_xp']),
    );
  }

  ChallengeEntity toEntity() {
    return ChallengeEntity(
      id: id,
      learningUnitId: learningUnitId,
      title: title,
      description: description,
      language: language,
      starterCode: starterCode,
      minXp: minXp,
      isActive: isActive,
      isLocked: isLocked,
      requiredXp: requiredXp,
      userXp: userXp,
      missingXp: missingXp,
    );
  }
}

class ChallengeRunResultModel {
  final int? attemptId;
  final bool passed;
  final String executionOutput;
  final List<ChallengeExecutionDetailModel> details;

  const ChallengeRunResultModel({
    required this.attemptId,
    required this.passed,
    required this.executionOutput,
    required this.details,
  });

  factory ChallengeRunResultModel.fromJson(Map<String, dynamic> json) {
    final attempt = _asMap(json['attempt']);
    final result = _asMap(json['result']);
    final submission = _asMap(json['submission']);
    final challengeResult = _asMap(json['challenge_result']);

    final rawDetails = _extractDetails(
      json['details'] ?? result['details'] ?? submission['details'],
    );
    final rawExecutionOutput = _firstNonEmptyString([
      attempt['execution_output'],
      json['execution_output'],
      result['execution_output'],
      submission['execution_output'],
      challengeResult['execution_output'],
    ]);
    final rawMessage = _firstNonEmptyString([
      json['message'],
      json['error'],
      result['message'],
      result['error'],
      submission['message'],
      submission['error'],
      challengeResult['message'],
      challengeResult['error'],
      attempt['message'],
      attempt['error'],
    ]);

    final details = rawDetails.isNotEmpty
        ? rawDetails
        : _extractDetailsFromExecutionOutput(rawExecutionOutput);
    final passed = _resolvePassed(
      candidates: [
        json['passed'],
        attempt['passed'],
        result['passed'],
        submission['passed'],
        challengeResult['passed'],
      ],
      details: details,
      rawMessage: rawMessage,
    );

    return ChallengeRunResultModel(
      attemptId: _asIntOrNull(
        attempt['id'] ??
            json['attempt_id'] ??
            json['id'] ??
            result['attempt_id'] ??
            submission['attempt_id'],
      ),
      passed: passed,
      executionOutput: _resolveExecutionOutput(
        passed: passed,
        details: details,
        rawExecutionOutput: rawExecutionOutput,
        rawMessage: rawMessage,
      ),
      details: details,
    );
  }

  ChallengeRunResultEntity toEntity() {
    return ChallengeRunResultEntity(
      attemptId: attemptId,
      passed: passed,
      executionOutput: executionOutput,
      details: details.map((detail) => detail.toEntity()).toList(),
    );
  }

  static String _resolveExecutionOutput({
    required bool passed,
    required List<ChallengeExecutionDetailModel> details,
    required String rawExecutionOutput,
    required String rawMessage,
  }) {
    if (passed) {
      return 'تم تنفيذ الكود بنجاح.';
    }

    return _normalizeFailureMessage(
      _resolveFailureOutput(
        details: details,
        rawExecutionOutput: rawExecutionOutput,
        rawMessage: rawMessage,
      ),
    );
  }

  static String _resolveFailureOutput({
    required List<ChallengeExecutionDetailModel> details,
    required String rawExecutionOutput,
    required String rawMessage,
  }) {
    for (final detail in details) {
      if (detail.error.trim().isNotEmpty) {
        return detail.error.trim();
      }
    }

    if (rawMessage.trim().isNotEmpty) {
      return rawMessage.trim();
    }

    for (final detail in details) {
      if (detail.output.trim().isNotEmpty) {
        return detail.output.trim();
      }
    }

    final normalizedRawOutput = rawExecutionOutput.trim();
    if (normalizedRawOutput.isNotEmpty) {
      return normalizedRawOutput;
    }

    return 'تعذر التحقق من نتيجة التنفيذ.';
  }

  static bool _resolvePassed({
    required List<dynamic> candidates,
    required List<ChallengeExecutionDetailModel> details,
    required String rawMessage,
  }) {
    for (final candidate in candidates) {
      if (candidate != null) {
        return _asBool(candidate);
      }
    }

    if (rawMessage.trim().isNotEmpty) {
      return false;
    }

    return details.isNotEmpty && details.every((detail) => detail.passed);
  }

  static String _normalizeFailureMessage(String message) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      return 'تعذر إكمال تنفيذ التحدي. حاول مرة أخرى.';
    }

    final lowerMessage = normalizedMessage.toLowerCase();

    if (lowerMessage.contains('execution failed with status code')) {
      return 'تم إرسال الطلب بنجاح إلى الخادم، لكن تنفيذ الكود فشل داخل خدمة التشغيل. حاول مرة أخرى بعد قليل.';
    }

    if (lowerMessage.contains('method is not supported for route') ||
        (lowerMessage.contains('not supported') &&
            lowerMessage.contains('route'))) {
      return 'تعذر إرسال الكود إلى خدمة التنفيذ بسبب إعداد غير متوافق في الخادم.';
    }

    if (lowerMessage.contains('internal server error') ||
        lowerMessage.contains('server error') ||
        lowerMessage.contains('status code: 500')) {
      return 'حدثت مشكلة في خادم التنفيذ أثناء تشغيل الكود. حاول مرة أخرى بعد قليل.';
    }

    if (lowerMessage.contains('timeout') ||
        lowerMessage.contains('timed out')) {
      return 'استغرق تنفيذ الكود وقتًا أطول من المتوقع. حاول مرة أخرى.';
    }

    if (lowerMessage.contains('connection refused') ||
        lowerMessage.contains('failed to connect') ||
        lowerMessage.contains('failed to fetch') ||
        lowerMessage.contains('network error')) {
      return 'تعذر الاتصال بخدمة التنفيذ حاليًا. تحقق من الشبكة ثم حاول مرة أخرى.';
    }

    return normalizedMessage;
  }
}

class ChallengeExecutionDetailModel {
  final int caseNumber;
  final bool passed;
  final String output;
  final String expectedOutput;
  final String error;

  const ChallengeExecutionDetailModel({
    required this.caseNumber,
    required this.passed,
    required this.output,
    required this.expectedOutput,
    required this.error,
  });

  factory ChallengeExecutionDetailModel.fromJson(Map<String, dynamic> json) {
    return ChallengeExecutionDetailModel(
      caseNumber: _asInt(json['case']),
      passed: _asBool(json['passed']),
      output: _asString(json['output']),
      expectedOutput: _asString(json['expected_output']),
      error: _asString(json['error']),
    );
  }

  ChallengeExecutionDetailEntity toEntity() {
    return ChallengeExecutionDetailEntity(
      caseNumber: caseNumber,
      passed: passed,
      output: output,
      expectedOutput: expectedOutput,
      error: error,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, dynamic>();
  }
  return <String, dynamic>{};
}

List<ChallengeExecutionDetailModel> _extractDetails(dynamic value) {
  if (value is! List) {
    return const <ChallengeExecutionDetailModel>[];
  }

  return value
      .whereType<Map>()
      .map(
        (detail) => ChallengeExecutionDetailModel.fromJson(
          detail.cast<String, dynamic>(),
        ),
      )
      .toList(growable: false);
}

List<ChallengeExecutionDetailModel> _extractDetailsFromExecutionOutput(
  String executionOutput,
) {
  final raw = executionOutput.trim();
  if (raw.isEmpty || !raw.startsWith('[')) {
    return const <ChallengeExecutionDetailModel>[];
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <ChallengeExecutionDetailModel>[];
    }

    return decoded
        .whereType<Map>()
        .map(
          (detail) => ChallengeExecutionDetailModel.fromJson(
            detail.cast<String, dynamic>(),
          ),
        )
        .toList(growable: false);
  } catch (_) {
    return const <ChallengeExecutionDetailModel>[];
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _asIntOrNull(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String _asString(dynamic value, {String fallback = ''}) {
  final text = value?.toString();
  if (text == null) {
    return fallback;
  }
  final normalized = text.trim();
  return normalized.isEmpty ? fallback : normalized;
}

String _firstNonEmptyString(List<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    final normalized = _asString(value);
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  switch (value?.toString().trim().toLowerCase()) {
    case '1':
    case 'true':
    case 'yes':
      return true;
    case '0':
    case 'false':
    case 'no':
      return false;
    default:
      return fallback;
  }
}
