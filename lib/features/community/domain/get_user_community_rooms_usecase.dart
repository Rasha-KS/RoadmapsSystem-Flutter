import 'package:roadmaps/features/community/data/community_repository.dart';
import 'package:roadmaps/features/community/domain/chat_room_entity.dart';

class GetUserCommunityRoomsUseCase {
  final CommunityRepository communityRepository;

  GetUserCommunityRoomsUseCase({
    required this.communityRepository,
  });

  Future<List<ChatRoomEntity>> call() {
    return communityRepository.getUserCommunityRooms();
  }
}
