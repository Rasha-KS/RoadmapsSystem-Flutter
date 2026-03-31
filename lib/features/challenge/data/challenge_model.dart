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
    final rawDetails = _extractDetails(json['details']);
    final rawExecutionOutput = _asString(
      attempt['execution_output'] ?? json['execution_output'],
    );
    final details = rawDetails.isNotEmpty
        ? rawDetails
        : _extractDetailsFromExecutionOutput(rawExecutionOutput);
    final passed = _asBool(json['passed'] ?? attempt['passed']);

    return ChallengeRunResultModel(
      attemptId: _asIntOrNull(
        attempt['id'] ?? json['attempt_id'] ?? json['id'],
      ),
      passed: passed,
      executionOutput: _resolveExecutionOutput(
        passed: passed,
        details: details,
        rawExecutionOutput: rawExecutionOutput,
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
  }) {
    if (passed) {
      return 'تم تنفيذ الكود بنجاح.';
    }

    for (final detail in details) {
      if (detail.error.trim().isNotEmpty) {
        return detail.error.trim();
      }
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
