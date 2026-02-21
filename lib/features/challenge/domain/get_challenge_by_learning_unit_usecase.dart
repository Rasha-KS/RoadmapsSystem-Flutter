import 'package:roadmaps/features/challenge/data/challenge_repository.dart';
import 'package:roadmaps/features/challenge/domain/challenge_entity.dart';

class GetChallengeByLearningUnitUseCase {
  final ChallengeRepository repository;

  GetChallengeByLearningUnitUseCase(this.repository);

  Future<ChallengeEntity?> call(int learningUnitId) async {
    final challenge = await repository.getChallengeByLearningUnitId(
      learningUnitId,
    );
    return challenge?.toEntity();
  }
}
