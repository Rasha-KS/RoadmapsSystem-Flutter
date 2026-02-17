import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/domain/community_repository.dart';

class SendImageMessageUseCase {
  final CommunityRepository repository;
  final UserRepository userRepository;

  SendImageMessageUseCase({required this.repository, required this.userRepository});

  Future<ChatMessageEntity> call({
    required int roomId,
    required String attachmentPath,
  }) async {
    final user = await userRepository.getCurrentUser();

    return repository.sendMessage(
      roomId: roomId,
      userId: user.id,
      attachmentPath: attachmentPath,
      isLocal: true,
    );
  }
}
