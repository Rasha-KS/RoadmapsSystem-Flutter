import 'package:roadmaps/features/checkpoints/data/checkpoint_repository.dart';

class SubmitCheckpointAttemptUseCase {
  final CheckpointRepository repository;

  SubmitCheckpointAttemptUseCase(this.repository);

  Future<QuizSubmissionResultModel> call({
    required int attemptId,
    required Map<String, String> answers,
    required int score,
    required bool passed,
  }) {
    return repository.submitAttempt(
      attemptId: attemptId,
      answers: answers,
      score: score,
      passed: passed,
    );
  }
}
