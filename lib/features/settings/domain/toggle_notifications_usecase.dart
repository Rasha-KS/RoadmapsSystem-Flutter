import '../data/settings_repository.dart';
import 'settings_entity.dart';

class ToggleNotificationsUseCase {
  final SettingsRepository repository;

  ToggleNotificationsUseCase(this.repository);

  Future<SettingsEntity> call(bool enabled) {
    return repository.toggleNotifications(enabled);
  }
}