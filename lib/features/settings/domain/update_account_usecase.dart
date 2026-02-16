import '../data/settings_repository.dart';
import 'settings_entity.dart';

class UpdateAccountUseCase {
  final SettingsRepository repository;

  UpdateAccountUseCase(this.repository);

  Future<SettingsEntity> call({
    String? username,
    String? email,
    String? password,
  }) {
    return repository.updateAccount(
      username: username,
      email: email,
      password: password,
    );
  }
}