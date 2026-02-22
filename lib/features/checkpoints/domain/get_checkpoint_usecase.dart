import 'package:roadmaps/features/checkpoints/data/checkpoint_repository.dart';
import 'package:roadmaps/features/checkpoints/domain/checkpoint_entity.dart';

class GetCheckpointUseCase {
  final CheckpointRepository repository;

  GetCheckpointUseCase(this.repository);

  Future<CheckpointEntity> call({
    required String learningPathId,
    required String checkpointId,
  }) async {
    final checkpoint = await repository.getCheckpoint(
      learningPathId: learningPathId,
      checkpointId: checkpointId,
    );
    return checkpoint.toEntity();
  }
}
