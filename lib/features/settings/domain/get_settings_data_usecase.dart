import '../data/settings_repository.dart';
import 'settings_entity.dart';

class GetSettingsDataUseCase {
  final SettingsRepository repository;

  GetSettingsDataUseCase(this.repository);

  Future<SettingsEntity> call() {
    return repository.getSettingsData();
  }
}