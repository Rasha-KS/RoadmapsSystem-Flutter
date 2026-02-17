import 'package:roadmaps/core/entities/user_entity.dart';
import '../data/settings_repository.dart';

class UpdateAccountUseCase {
  final SettingsRepository repository;

  UpdateAccountUseCase(this.repository);

  Future<UserEntity> call({
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
