import '../data/profile_repository.dart';
import 'profile_user_entity.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<ProfileUserEntity> call() {
    return repository.getUserProfile();
  }
}

