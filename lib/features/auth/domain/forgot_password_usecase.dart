import '../data/auth_repository.dart';

class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call({required String email}) {
    return repository.forgotPassword(email: email);
  }
}
