class CheckpointSubmissionResult {
  final int? attemptId;
  final bool passed;
  final int earnedXp;
  final int minimumRequiredXp;
  final int maximumPossibleXp;
  final int totalQuestions;
  final int? correctCount;
  final double scorePercent;

  const CheckpointSubmissionResult({
    required this.attemptId,
    required this.passed,
    required this.earnedXp,
    required this.minimumRequiredXp,
    required this.maximumPossibleXp,
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercent,
  });
}
