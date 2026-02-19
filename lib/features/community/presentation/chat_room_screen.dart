import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';
import 'dart:io';
import 'package:roadmaps/features/community/domain/chat_message_entity.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
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
                        horizontal: 14,
                        vertical: 6,
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
                          otherUserName: 'Abdo_A',
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: ChatInputBar(
                hasPendingAttachment: _pendingAttachmentPath != null,
                pendingAttachmentName:
                    _pendingAttachmentPath?.split(RegExp(r'[\\/]')).last,
                onClearAttachment: () {
                  setState(() {
                    _pendingAttachmentPath = null;
                  });
                },
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
      await provider.sendTextMessage(roomId: widget.chatRoomId, text: text);
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
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 10),
      child: Row(
        children: [
          Text(
            roomName,
            style: AppTextStyles.boldHeading5.copyWith(
              color: AppColors.text_3,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon:  const Icon(
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



class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.hasPendingAttachment,
    required this.pendingAttachmentName,
    required this.onClearAttachment,
    required this.onPickAttachment,
    required this.onSendPressed,
  });

  final bool hasPendingAttachment;
  final String? pendingAttachmentName;
  final VoidCallback onClearAttachment;
  final Future<void> Function() onPickAttachment;
  final Future<void> Function(String text) onSendPressed;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  bool get _canSend {
    return _controller.text.trim().isNotEmpty || widget.hasPendingAttachment;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.hasPendingAttachment && widget.pendingAttachmentName != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent_1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary2),
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onClearAttachment,
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تم اختيار صورة: ${widget.pendingAttachmentName}',
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),


        Padding(padding: EdgeInsets.fromLTRB(8,4,8,30),
        child:  Row(
          children: [
            Expanded(
              child: Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondary4,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.secondary1),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 1,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (value) async {
                    if (!_canSend) return;
                    await widget.onSendPressed(value.trim());
                    if (!mounted) return;
                    _controller.clear();
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'شاركنا أفكارك',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_1 , fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _canSend ? AppColors.primary1 : AppColors.secondary4,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary2),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  if (_canSend) {
                    final text = _controller.text.trim();
                    await widget.onSendPressed(text);
                    if (!mounted) return;
                    _controller.clear();
                    setState(() {});
                    return;
                  }

                  await widget.onPickAttachment();
                  if (!mounted) return;
                  setState(() {});
                },
                icon: Icon(
                  _canSend ? Icons.send : Icons.camera_alt_outlined,
                  color: _canSend ? Colors.white : AppColors.primary,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
        )
       


      ],
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
    final bubbleColor = isCurrentUser ? AppColors.secondary3 : AppColors.secondary4;

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
        radius: 20,
        backgroundImage: NetworkImage(currentUserAvatarUrl!),
      );
    }

    return const CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.secondary2,
      child: Icon(Icons.person, size: 20, color: AppColors.primary),
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




