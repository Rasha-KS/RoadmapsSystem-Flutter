import '../data/profile_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.getUserProfile();
  }
}


