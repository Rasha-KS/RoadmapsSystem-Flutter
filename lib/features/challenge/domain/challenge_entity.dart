class ChallengeEntity {
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

  const ChallengeEntity({
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
}

class ChallengeExecutionDetailEntity {
  final int caseNumber;
  final bool passed;
  final String output;
  final String expectedOutput;
  final String error;

  const ChallengeExecutionDetailEntity({
    required this.caseNumber,
    required this.passed,
    required this.output,
    required this.expectedOutput,
    required this.error,
  });
}

class ChallengeRunResultEntity {
  final int? attemptId;
  final bool passed;
  final String executionOutput;
  final List<ChallengeExecutionDetailEntity> details;

  const ChallengeRunResultEntity({
    required this.attemptId,
    required this.passed,
    required this.executionOutput,
    required this.details,
  });
}
