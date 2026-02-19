import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/data/community_repository.dart';

class SendMessageUseCase {
  final CommunityRepository repository;
  final UserRepository userRepository;

  SendMessageUseCase({required this.repository, required this.userRepository});

  Future<ChatMessageEntity> call({
    required int roomId,
    required String content,
  }) async {
    final user = await userRepository.getCurrentUser();

    return repository.sendMessage(
      roomId: roomId,
      userId: user.id,
      content: content,
      isLocal: true,
    );
  }
}
