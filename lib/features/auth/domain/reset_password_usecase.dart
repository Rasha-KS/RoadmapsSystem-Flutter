import '../data/auth_repository.dart';

class ResetPasswordUseCase {
  ResetPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    return repository.resetPassword(
      email: email,
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
