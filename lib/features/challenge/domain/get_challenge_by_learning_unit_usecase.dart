import 'package:roadmaps/features/challenge/data/challenge_repository.dart';
import 'package:roadmaps/features/challenge/domain/challenge_entity.dart';

class GetChallengeByLearningUnitUseCase {
  final ChallengeRepository repository;

  GetChallengeByLearningUnitUseCase(this.repository);

  Future<ChallengeEntity?> call(int challengeId) async {
    final challenge = await repository.getChallengeById(challengeId);
    return challenge?.toEntity();
  }
}
