import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/shared_chat_input_bar.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';

class SmartInstructorConversationScreen extends StatefulWidget {
  const SmartInstructorConversationScreen({super.key});

  @override
  State<SmartInstructorConversationScreen> createState() =>
      _SmartInstructorConversationScreenState();
}

class _SmartInstructorConversationScreenState
    extends State<SmartInstructorConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _pendingAttachmentPath;
  int _lastRenderedMessagesCount = 0;
  String? _lastSendError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<SmartInstructorProvider>();
      if (provider.messages.isEmpty && !provider.messagesLoading) {
        provider.loadMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartInstructorProvider>();
    _showSendErrorIfChanged(provider.sendError);
    _autoScrollOnMessageChange(provider.messages.length);

    final hasInitialLoading =
        provider.messagesLoading && provider.messages.isEmpty;
    final hasInitialError =
        provider.messagesError != null && provider.messages.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Row(
                children: [
                  Text(
                    'المعلم الذكي',
                    style: AppTextStyles.boldHeading5.copyWith(
                      color: AppColors.text_3,
                      fontSize: 18
                    ),
                  ),
                  const Spacer(),
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
            ),
            Expanded(
              child: hasInitialLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary2,
                      ),
                    )
                  : hasInitialError
                  ? _ErrorState(
                      onRetry: () {
                        context.read<SmartInstructorProvider>().loadMessages();
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await context
                            .read<SmartInstructorProvider>()
                            .loadMessages();
                        if (provider.messagesError != null) {
                          _showRefreshFailedSnackBar(messenger);
                        }
                      },
                      color: AppColors.primary2,
                      child: provider.messages.isEmpty
                          ? const _RefreshableEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              itemCount: provider.messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    provider.messages[provider.messages.length -
                                        1 -
                                        index];
                                return _MessageBubble(message: message);
                              },
                            ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: SharedChatInputBar.smartInstructor(
                hasPendingAttachment: _pendingAttachmentPath != null,
                pendingAttachmentName: _pendingAttachmentPath
                    ?.split(RegExp(r'[\\/]'))
                    .last,
                onClearAttachment: () {
                  setState(() {
                    _pendingAttachmentPath = null;
                  });
                },
                onPickAttachment: _onPickAttachment,
                onSendPressed: _onSendPressed,
                isSending: provider.sendingMessage,
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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
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
    final provider = context.read<SmartInstructorProvider>();

    if (text.trim().isNotEmpty) {
      await provider.sendTextMessage(text: text);
    }

    final pendingPath = _pendingAttachmentPath;
    if (pendingPath != null) {
      await provider.sendImageMessage(attachmentPath: pendingPath);
      if (!mounted) return;
      setState(() {
        _pendingAttachmentPath = null;
      });
    }

    _scrollToBottom();
  }

  void _showSendErrorIfChanged(String? error) {
    if (error == null || error == _lastSendError) return;
    _lastSendError = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.text_2),
          ),
          backgroundColor: AppColors.backGroundError,
          duration: const Duration(milliseconds: 1200),
        ),
      );
    });
  }

  void _showRefreshFailedSnackBar(ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        content: Text(
          'تعذر التحديث بسبب انقطاع الاتصال بالشبكة',
          textAlign: TextAlign.right,
          style: AppTextStyles.body.copyWith(color: AppColors.text_2),
        ),
        backgroundColor: AppColors.backGroundError,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SmartInstructorMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isFromUser
        ? AppColors.accent_1
        : AppColors.accent_3;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.7;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7 , horizontal: 10),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.secondary1,
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(message.isFromUser ? 14 : 4),
                  bottomRight: Radius.circular(message.isFromUser ? 4 : 14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (message.text != null && message.text!.trim().isNotEmpty)
                    Text(
                      message.text!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text_3,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  if (message.attachmentPath != null &&
                      message.attachmentPath!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: (message.text?.isNotEmpty ?? false) ? 8 : 0,
                      ),
                      child: _buildAttachmentPreview(maxBubbleWidth * 0.9),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(double width) {
    final path = message.attachmentPath;
    if (path == null || path.isEmpty) return const SizedBox.shrink();

    final file = File(path);
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

class _RefreshableEmptyState extends StatelessWidget {
  const _RefreshableEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Text(
              'لا يوجد رسائل بعد',
              style: AppTextStyles.boldHeading5.copyWith(
                color: AppColors.text_3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تعذر تحميل المحادثة',
              style: AppTextStyles.boldHeading5.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_1,
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.boldSmallText.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
