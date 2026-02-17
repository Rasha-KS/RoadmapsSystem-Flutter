import 'package:roadmaps/core/entities/user_entity.dart';
import '../data/settings_repository.dart';

class ToggleNotificationsUseCase {
  final SettingsRepository repository;

  ToggleNotificationsUseCase(this.repository);

  Future<UserEntity> call(bool enabled) {
    return repository.toggleNotifications(enabled);
  }
}
