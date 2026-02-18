import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.currentUserName,
    required this.currentUserAvatarUrl,
    required this.otherUserName,
  });

  final ChatMessageEntity message;
  final bool isCurrentUser;
  final String? currentUserName;
  final String? currentUserAvatarUrl;
  final String otherUserName;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.7;
    final bubbleColor = isCurrentUser ? const Color(0xFFEAD7CA) : AppColors.secondary4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) _buildAvatar(),
          if (!isCurrentUser) const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentUser ? (currentUserName ?? 'أنت') : otherUserName,
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.primary1,
                      fontSize: 12,
                    ),
                  ),
                  if (message.content != null && message.content!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        message.content!,
                        style: AppTextStyles.body.copyWith(color: AppColors.text_3),
                      ),
                    ),
                  if (message.attachmentPath != null &&
                      message.attachmentPath!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildAttachmentPreview(maxBubbleWidth * 0.9),
                    ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (isCurrentUser &&
        currentUserAvatarUrl != null &&
        currentUserAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(currentUserAvatarUrl!),
      );
    }

    return const CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.secondary2,
      child: Icon(Icons.person, size: 13, color: AppColors.primary),
    );
  }

  Widget _buildAttachmentPreview(double width) {
    final path = message.attachmentPath;
    if (path == null || path.isEmpty) return const SizedBox.shrink();

    final file = File(path);
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(path, fit: BoxFit.cover),
          ),
        ),
      );
    }

    {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }
  }
}
