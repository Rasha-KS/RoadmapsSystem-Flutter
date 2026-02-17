import '../data/settings_repository.dart';

class UploadProfileImageUseCase {
  final SettingsRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<String> call({required String localFilePath}) {
    return repository.uploadProfileImage(localFilePath: localFilePath);
  }
}
