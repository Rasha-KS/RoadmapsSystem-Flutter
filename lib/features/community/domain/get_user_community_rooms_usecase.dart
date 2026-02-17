import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/features/community/domain/chat_room_entity.dart';
import 'package:roadmaps/features/community/domain/community_repository.dart';

class GetUserCommunityRoomsUseCase {
  final CommunityRepository communityRepository;
  final UserRepository userRepository;

  GetUserCommunityRoomsUseCase({
    required this.communityRepository,
    required this.userRepository,
  });

  Future<List<ChatRoomEntity>> call() async {
    final user = await userRepository.getCurrentUser();
    final roadmapIds = await communityRepository.getUserEnrolledRoadmapIds(user.id);

    if (roadmapIds.isEmpty) {
      return [];
    }

    return communityRepository.getChatRoomsByRoadmapIds(roadmapIds);
  }
}
