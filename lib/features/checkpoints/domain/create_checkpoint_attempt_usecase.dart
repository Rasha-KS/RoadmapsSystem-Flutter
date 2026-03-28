import 'package:roadmaps/features/checkpoints/data/checkpoint_repository.dart';

class CreateCheckpointAttemptUseCase {
  final CheckpointRepository repository;

  CreateCheckpointAttemptUseCase(this.repository);

  Future<int> call({required int quizId}) {
    return repository.createAttempt(quizId: quizId);
  }
}
