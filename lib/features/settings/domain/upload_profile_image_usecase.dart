import 'package:roadmaps/core/entities/user_entity.dart';

import '../data/settings_repository.dart';

class UploadProfileImageUseCase {
  final SettingsRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<UserEntity> call({required String localFilePath}) {
    return repository.uploadProfileImage(localFilePath: localFilePath);
  }
}
