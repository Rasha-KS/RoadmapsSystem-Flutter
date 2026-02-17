import 'package:roadmaps/core/entities/user_entity.dart';
import '../data/settings_repository.dart';

class GetSettingsDataUseCase {
  final SettingsRepository repository;

  GetSettingsDataUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.getSettingsData();
  }
}
