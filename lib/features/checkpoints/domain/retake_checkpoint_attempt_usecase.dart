import 'package:roadmaps/features/checkpoints/data/checkpoint_repository.dart';

class RetakeCheckpointAttemptUseCase {
  final CheckpointRepository repository;

  RetakeCheckpointAttemptUseCase(this.repository);

  Future<int> call({required int quizId}) {
    return repository.retakeAttempt(quizId: quizId);
  }
}
