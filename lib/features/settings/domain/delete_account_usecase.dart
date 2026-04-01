import '../data/settings_repository.dart';

class DeleteAccountUseCase {
  final SettingsRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call({required String password}) {
    return repository.deleteAccount(password: password);
  }
}
