import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';
import 'package:roadmaps/features/community/presentation/widgets/chat_input_bar.dart';
import 'package:roadmaps/features/community/presentation/widgets/message_bubble.dart';

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
  String? _pendingAttachmentPath;
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
    _autoScrollOnMessageChange(messages.length);

    return SafeArea(
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          children: [
            _ChatRoomHeader(roomName: widget.roomName),
            Expanded(
              child: provider.isRoomMessagesLoading(widget.chatRoomId) &&
                      messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary2),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        final isCurrentUser = message.userId == currentUser?.id;

                        return MessageBubble(
                          message: message,
                          isCurrentUser: isCurrentUser,
                          currentUserName: currentUser?.username,
                          currentUserAvatarUrl: currentUser?.profileImageUrl,
                          otherUserName: 'مستخدم',
                        );
                      },
                    ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              child: ChatInputBar(
                hasPendingAttachment: _pendingAttachmentPath != null,
                onPickAttachment: _onPickAttachment,
                onSendPressed: _onSendPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _autoScrollOnMessageChange(int messagesCount) {
    if (_lastRenderedMessagesCount == messagesCount) return;
    _lastRenderedMessagesCount = messagesCount;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _onPickAttachment() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _pendingAttachmentPath = picked.path;
    });
  }

  Future<void> _onSendPressed(String text) async {
    final provider = context.read<CommunityProvider>();

    if (text.trim().isNotEmpty) {
      await provider.sendTextMessage(
        roomId: widget.chatRoomId,
        text: text,
      );
    }

    final pendingPath = _pendingAttachmentPath;
    if (pendingPath != null) {
      await provider.sendImageMessage(
        roomId: widget.chatRoomId,
        attachmentPath: pendingPath,
      );
      if (!mounted) return;
      setState(() {
        _pendingAttachmentPath = null;
      });
    }

    _scrollToBottom();
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.text_5,
            ),
          ),
          const Spacer(),
          Text(
            roomName,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.heading5.copyWith(
              color: AppColors.text_1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
