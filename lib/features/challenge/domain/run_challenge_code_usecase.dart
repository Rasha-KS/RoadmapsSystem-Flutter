import 'package:roadmaps/features/challenge/data/challenge_repository.dart';
import 'package:roadmaps/features/challenge/domain/challenge_entity.dart';

class RunChallengeCodeUseCase {
  final ChallengeRepository repository;

  RunChallengeCodeUseCase(this.repository);

  Future<ChallengeRunResultEntity> call({
    required int challengeId,
    required int userId,
    required String userCode,
  }) async {
    final result = await repository.runCode(
      challengeId: challengeId,
      userId: userId,
      userCode: userCode,
    );
    return result.toEntity();
  }
}
