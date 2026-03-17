import 'package:roadmaps/core/entities/user_entity.dart';
import '../data/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return repository.register(
      username: username,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
