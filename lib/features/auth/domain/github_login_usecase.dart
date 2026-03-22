import 'package:roadmaps/core/entities/user_entity.dart';
import '../data/auth_repository.dart';

class GithubLoginUseCase {
  final AuthRepository repository;

  GithubLoginUseCase(this.repository);

  Future<UserEntity> call({required String code, String? state}) {
    return repository.loginWithGithub(code: code, state: state);
  }
}
