import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/shared_chat_input_bar.dart';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.roomName,
  });

  final int chatRoomId;
  final String roomName;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastRenderedMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommunityProvider>().openRoom(widget.chatRoomId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final currentUser = context.watch<CurrentUserProvider>().user;
    final messages = provider.messagesForRoom(widget.chatRoomId);
    final messagesError = provider.roomMessagesError(widget.chatRoomId);

    _autoScrollOnMessageChange(messages.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ChatRoomHeader(roomName: widget.roomName),
            Expanded(
              child: _buildMessagesSection(
                provider: provider,
                currentUserId: currentUser?.id,
                currentUserName: currentUser?.username,
                currentUserAvatarUrl: currentUser?.profileImageUrl,
                messages: messages,
                messagesError: messagesError,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: SharedChatInputBar.community(
                hasPendingAttachment: false,
                pendingAttachmentName: null,
                onClearAttachment: () {},
                onPickAttachment: () async {},
                onSendPressed: _onSendPressed,
                isSending: provider.isSendingMessage(widget.chatRoomId),
                allowAttachment: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection({
    required CommunityProvider provider,
    required int? currentUserId,
    required String? currentUserName,
    required String? currentUserAvatarUrl,
    required List<ChatMessageEntity> messages,
    required String? messagesError,
  }) {
    final isInitialLoading =
        provider.isRoomMessagesLoading(widget.chatRoomId) && messages.isEmpty;

    if (isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (messagesError != null && messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshMessages,
        color: AppColors.primary2,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: _ChatMessagesErrorState(
                message: messagesError,
                onRetry: _refreshMessages,
              ),
            ),
          ],
        ),
      );
    }

    if (messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshMessages,
        color: AppColors.primary2,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: const _EmptyMessagesState(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMessages,
      color: AppColors.primary2,
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[messages.length - 1 - index];
          final isCurrentUser = message.userId == currentUserId;

          return MessageBubble(
            message: message,
            isCurrentUser: isCurrentUser,
            currentUserName: currentUserName,
            currentUserAvatarUrl: currentUserAvatarUrl,
            onRetry: () {
              context.read<CommunityProvider>().retryMessage(
                    roomId: widget.chatRoomId,
                    messageId: message.id,
                  );
            },
            onCancel: () {
              context.read<CommunityProvider>().cancelFailedMessage(
                    roomId: widget.chatRoomId,
                    messageId: message.id,
                  );
            },
          );
        },
      ),
    );
  }

  void _autoScrollOnMessageChange(int messagesCount) {
    if (_lastRenderedMessagesCount == messagesCount) return;
    _lastRenderedMessagesCount = messagesCount;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _onSendPressed(String text) async {
    if (text.trim().isEmpty) return;
    await context.read<CommunityProvider>().sendTextMessage(
          roomId: widget.chatRoomId,
          text: text,
        );
    _scrollToBottom();
  }

  Future<void> _refreshMessages() async {
    final provider = context.read<CommunityProvider>();
    await provider.loadMessages(widget.chatRoomId);
    if (!mounted) return;

    final error = provider.roomMessagesError(widget.chatRoomId);
    if (error != null && error.isNotEmpty) {
      showActionSnackBar(
        ScaffoldMessenger.of(context),
        message: error,
        isSuccess: false,
      );
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }
}

class _ChatRoomHeader extends StatelessWidget {
  const _ChatRoomHeader({required this.roomName});

  final String roomName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              roomName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.boldHeading5.copyWith(color: AppColors.text_3),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_right_alt_outlined,
              color: AppColors.text_5,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.currentUserName,
    required this.currentUserAvatarUrl,
    required this.onRetry,
    required this.onCancel,
  });

  final ChatMessageEntity message;
  final bool isCurrentUser;
  final String? currentUserName;
  final String? currentUserAvatarUrl;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.7;
    final bubbleColor = isCurrentUser
        ? AppColors.secondary3
        : AppColors.secondary4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
                    isCurrentUser
                        ? (currentUserName ?? 'أنت')
                        : (message.senderName ?? 'عضو المجتمع'),
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.primary1,
                    ),
                  ),
                  if (message.content != null &&
                      message.content!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        message.content!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text_3,
                        ),
                      ),
                    ),
                  if (message.attachmentPath != null &&
                      message.attachmentPath!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildAttachmentPreview(maxBubbleWidth * 0.9),
                    ),
                  if (isCurrentUser) ...[
                    const SizedBox(height: 8),
                    _MessageStatusRow(
                      status: message.status,
                      failureMessage: message.failureMessage,
                      onRetry: onRetry,
                      onCancel: onCancel,
                    ),
                  ],
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
    final avatarUrl = isCurrentUser
        ? currentUserAvatarUrl
        : message.senderAvatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return SizedBox(
        width: 40,
        height: 40,
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildAvatarFallback(),
          ),
        ),
      );
    }

    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    return const CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.secondary2,
      child: Icon(Icons.person, size: 20, color: AppColors.primary),
    );
  }

  Widget _buildAttachmentPreview(double width) {
    final path = message.attachmentPath;
    if (path == null || path.isEmpty) return const SizedBox.shrink();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: SizedBox(
            width: width,
            child: Image.network(
              path,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    final file = File(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: SizedBox(
          width: width,
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _MessageStatusRow extends StatelessWidget {
  const _MessageStatusRow({
    required this.status,
    required this.failureMessage,
    required this.onRetry,
    required this.onCancel,
  });

  final ChatMessageStatus status;
  final String? failureMessage;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChatMessageStatus.sending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'جارٍ الإرسال',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.text_1.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 6),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary2,
              ),
            ),
          ],
        );
      case ChatMessageStatus.sent:
        return const SizedBox.shrink();
      case ChatMessageStatus.failed:
        final showRetry =
            failureMessage != null && failureMessage!.trim().isNotEmpty;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRetry) ...[
              IconButton(
                onPressed: onRetry,
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(30, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 4),
            ],
            IconButton(
              onPressed: onCancel,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(30, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(
                Icons.cancel_rounded,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ],
        );
    }
  }
}

class _ChatMessagesErrorState extends StatelessWidget {
  const _ChatMessagesErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading5.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_1,
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.boldSmallText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessagesState extends StatelessWidget {
  const _EmptyMessagesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 72,
            color: AppColors.primary2,
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد رسائل بعد',
            style: AppTextStyles.heading5.copyWith(color: AppColors.text_3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
