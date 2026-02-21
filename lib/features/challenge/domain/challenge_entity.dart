class ChallengeEntity {
  final int id;
  final int learningUnitId;
  final String title;
  final String description;
  final String language;
  final List<ChallengeTestCaseEntity> testCases;
  final String starterCode;
  final int minXp;
  final bool isActive;

  const ChallengeEntity({
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
}

class ChallengeTestCaseEntity {
  final String input;
  final String expectedOutput;

  const ChallengeTestCaseEntity({
    required this.input,
    required this.expectedOutput,
  });
}

class ChallengeRunResultEntity {
  final bool passed;
  final String executionOutput;

  const ChallengeRunResultEntity({
    required this.passed,
    required this.executionOutput,
  });
}
