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
    final bubbleColor = isCurrentUser ? AppColors.accent_1 : AppColors.secondary2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) _buildAvatar(),
          if (!isCurrentUser) const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isCurrentUser
                        ? (currentUserName ?? 'أنت')
                        : otherUserName,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.text_4,
                    ),
                  ),
                  if (message.content != null && message.content!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        message.content!,
                        textDirection: TextDirection.rtl,
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
        radius: 15,
        backgroundImage: NetworkImage(currentUserAvatarUrl!),
      );
    }

    return const CircleAvatar(
      radius: 15,
      backgroundColor: AppColors.secondary1,
      child: Icon(Icons.person, size: 16, color: AppColors.primary),
    );
  }

  Widget _buildAttachmentPreview(double width) {
    final path = message.attachmentPath;
    if (path == null || path.isEmpty) {
      return const SizedBox.shrink();
    }

    final file = File(path);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary4,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        path,
        style: AppTextStyles.smallText.copyWith(color: AppColors.text_3),
      ),
    );
  }
}
