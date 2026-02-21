import 'package:roadmaps/features/challenge/domain/challenge_entity.dart';

class ChallengeModel {
  final int id;
  final int learningUnitId;
  final String title;
  final String description;
  final String language;
  final List<ChallengeTestCaseModel> testCases;
  final String starterCode;
  final int minXp;
  final bool isActive;

  const ChallengeModel({
    required this.id,
    required this.learningUnitId,
    required this.title,
    required this.description,
    required this.language,
    required this.testCases,
    required this.starterCode,
    required this.minXp,
    required this.isActive,
  });

  ChallengeEntity toEntity() {
    return ChallengeEntity(
      id: id,
      learningUnitId: learningUnitId,
      title: title,
      description: description,
      language: language,
      testCases: testCases.map((testCase) => testCase.toEntity()).toList(),
      starterCode: starterCode,
      minXp: minXp,
      isActive: isActive,
    );
  }
}

class ChallengeTestCaseModel {
  final String input;
  final String expectedOutput;

  const ChallengeTestCaseModel({
    required this.input,
    required this.expectedOutput,
  });

  ChallengeTestCaseEntity toEntity() {
    return ChallengeTestCaseEntity(
      input: input,
      expectedOutput: expectedOutput,
    );
  }
}

class ChallengeRunResultModel {
  final bool passed;
  final String executionOutput;

  const ChallengeRunResultModel({
    required this.passed,
    required this.executionOutput,
  });

  ChallengeRunResultEntity toEntity() {
    return ChallengeRunResultEntity(
      passed: passed,
      executionOutput: executionOutput,
    );
  }
}

class ChallengeAttemptModel {
  final int id;
  final int challengeId;
  final int userId;
  final String userCode;
  final String executionOutput;
  final bool passed;

  const ChallengeAttemptModel({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.userCode,
    required this.executionOutput,
    required this.passed,
  });
}
