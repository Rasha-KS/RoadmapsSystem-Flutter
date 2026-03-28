import 'package:roadmaps/features/checkpoints/data/checkpoint_repository.dart';

class GetCheckpointAttemptsCountUseCase {
  final CheckpointRepository repository;

  GetCheckpointAttemptsCountUseCase(this.repository);

  Future<int> call({required int quizId}) {
    return repository.getAttemptsCount(quizId: quizId);
  }
}
