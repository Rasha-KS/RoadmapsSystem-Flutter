import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/shared_chat_input_bar.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_message_entity.dart';
import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_session_entity.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';

class SmartInstructorConversationScreen extends StatefulWidget {
  const SmartInstructorConversationScreen({super.key});

  @override
  State<SmartInstructorConversationScreen> createState() =>
      _SmartInstructorConversationScreenState();
}

class _SmartInstructorConversationScreenState
    extends State<SmartInstructorConversationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late final SmartInstructorProvider _provider;
  int _lastMessageCount = 0;
  String? _lastSessionsError;
  String? _lastActionError;

  @override
  void initState() {
    super.initState();
    _provider = context.read<SmartInstructorProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      () async {
        await _provider.loadSessions();
        if (!mounted) return;
        final sessionId = _provider.currentSessionId;
        if (sessionId != null) {
          await _provider.openSession(sessionId);
        }
      }();
    });
  }

  @override
  void dispose() {
    _provider.discardFailedMessages();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartInstructorProvider>();
    _handleSideEffects(provider);
    _autoScroll(provider.messages.length);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Directionality(
        textDirection: TextDirection.ltr,
        child: _SessionsDrawer(
          provider: provider,
          onSessionSelected: (session) {
            Navigator.of(context).pop();
            unawaited(provider.openSession(session.id));
          },
          onDeleteSession: (session) async {
            await _confirmDeleteSession(session);
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SmartInstructorHeader(
              onOpenDrawer: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _buildChatArea(provider),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: SharedChatInputBar.smartInstructor(
                hasPendingAttachment: false,
                pendingAttachmentName: null,
                onClearAttachment: () {},
                onPickAttachment: () async {},
                onSendPressed: (text) async {
                  await provider.sendTextMessage(text: text);
                },
                isSending: provider.sendingMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(SmartInstructorProvider provider) {
    if (provider.loadingMessages && provider.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (provider.currentSessionId == null && provider.messages.isEmpty) {
      return const _InitialEmptyState();
    }

    if (provider.messagesError != null && provider.messages.isEmpty) {
      return _MessagesErrorState(
        message: provider.messagesError!,
        onRetry: () {
          final sessionId = provider.currentSessionId;
          if (sessionId == null) return;
          unawaited(provider.openSession(sessionId));
        },
      );
    }

    if (provider.messages.isEmpty) {
      return const _NoMessagesState();
    }

    return Stack(
      children: [
        ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          itemCount: provider.messages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final message = provider.messages[index];
            return _MessageBubble(
              message: message,
              onRetry: message.status == SmartInstructorMessageStatus.failed
                  ? () => context.read<SmartInstructorProvider>().retryMessage(
                        message.id,
                      )
                  : null,
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmDeleteSession(SmartInstructorSessionEntity session) async {
    await showConfirmActionDialog(
      context: context,
      title: 'حذف المحادثة',
      message: 'هل تريد حذف "${session.title}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      onConfirm: () async {
        await context.read<SmartInstructorProvider>().deleteSession(session.id);
      },
    );
  }

  void _autoScroll(int messageCount) {
    if (_lastMessageCount == messageCount) return;
    _lastMessageCount = messageCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSideEffects(SmartInstructorProvider provider) {
    _showSnackBarOnChange(
      provider.sessionsError,
      lastValue: _lastSessionsError,
      onUpdate: (value) => _lastSessionsError = value,
    );
    _showSnackBarOnChange(
      provider.actionError,
      lastValue: _lastActionError,
      onUpdate: (value) => _lastActionError = value,
    );
  }

  void _showSnackBarOnChange(
    String? nextValue, {
    required String? lastValue,
    required ValueChanged<String?> onUpdate,
  }) {
    if (nextValue == null) {
      onUpdate(null);
      return;
    }

    if (nextValue == lastValue) return;
    onUpdate(nextValue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextValue,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.text_2),
          ),
          backgroundColor: AppColors.backGroundError,
          duration: const Duration(milliseconds: 1400),
        ),
      );
    });
  }
}

class _SmartInstructorHeader extends StatelessWidget {
  const _SmartInstructorHeader({
    required this.onOpenDrawer,
    required this.onBack,
  });

  final VoidCallback onOpenDrawer;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onOpenDrawer,
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.text_5,
              size: 30,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onBack,
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

class _SessionsDrawer extends StatelessWidget {
  const _SessionsDrawer({
    required this.provider,
    required this.onSessionSelected,
    required this.onDeleteSession,
  });

  final SmartInstructorProvider provider;
  final ValueChanged<SmartInstructorSessionEntity> onSessionSelected;
  final ValueChanged<SmartInstructorSessionEntity> onDeleteSession;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'المحادثات السابقة',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.text_3,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Icon(Icons.history_rounded, color: AppColors.primary2),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    provider.clearCurrentSession();
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('جلسة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary2,
                    foregroundColor: AppColors.text_1,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                ),
              ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            Expanded(
              child: provider.loadingSessions && provider.sessions.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary2,
                      ),
                    )
                  : provider.sessionsError != null && provider.sessions.isEmpty
                      ? _DrawerErrorState(
                          message: provider.sessionsError!,
                          onRetry: () {
                            context.read<SmartInstructorProvider>().loadSessions();
                          },
                        )
                      : provider.sessions.isEmpty
                          ? const _DrawerEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              itemCount: provider.sessions.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final session = provider.sessions[index];
                                final isActive =
                                    session.id == provider.currentSessionId;
                                return _SessionTile(
                                  session: session,
                                  isActive: isActive,
                                  isDeleting:
                                      provider.deletingSessionId == session.id,
                                  onTap: () => onSessionSelected(session),
                                  onDelete: () => onDeleteSession(session),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
  });

  final SmartInstructorSessionEntity session;
  final bool isActive;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.accent_3 : AppColors.secondary4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      session.title,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text_3,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _buildSubtitle(session),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.text_1.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(SmartInstructorSessionEntity session) {
    final reference =
        session.lastActivityAt ?? session.updatedAt ?? session.createdAt;
    if (reference == null) {
      return 'محادثة محفوظة';
    }

    final now = DateTime.now();
    final difference = now.difference(reference);

    if (difference.inMinutes < 1) {
      return 'الآن';
    }
    if (difference.inHours < 1) {
      return 'قبل ${difference.inMinutes} دقيقة';
    }
    if (difference.inDays < 1) {
      return 'قبل ${difference.inHours} ساعة';
    }
    if (difference.inDays == 1) {
      return 'أمس';
    }
    if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} أيام';
    }

    final day = reference.day.toString().padLeft(2, '0');
    final month = reference.month.toString().padLeft(2, '0');
    return '$day/$month/${reference.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    this.onRetry,
  });

  final SmartInstructorMessageEntity message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isFromUser
        ? AppColors.accent_1
        : AppColors.accent_3;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.74;

    return Row(
      mainAxisAlignment: message.isFromUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isFromUser) ...[
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondary1,
            child: Icon(
              Icons.psychology_alt_outlined,
              color: AppColors.primary2,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
        ],
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isFromUser ? 16 : 4),
                bottomRight: Radius.circular(message.isFromUser ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message.text ?? '',
                  style: AppTextStyles.body.copyWith(color: AppColors.text_3),
                  textAlign: TextAlign.right,
                ),
                if (message.isFromUser) ...[
                  const SizedBox(height: 8),
                  _MessageStatusRow(
                    status: message.status,
                    failureMessage: message.failureMessage,
                    onRetry: onRetry,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageStatusRow extends StatelessWidget {
  const _MessageStatusRow({
    required this.status,
    required this.failureMessage,
    required this.onRetry,
  });

  final SmartInstructorMessageStatus status;
  final String? failureMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SmartInstructorMessageStatus.sending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'جار الإرسال',
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
      case SmartInstructorMessageStatus.sent:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
          ],
        );
      case SmartInstructorMessageStatus.failed:
        final showRetry =
            onRetry != null && failureMessage != null && failureMessage!.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showRetry) ...[
                  IconButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.error,
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _InitialEmptyState extends StatelessWidget {
  const _InitialEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 72,
              color: AppColors.primary2,
            ),
            const SizedBox(height: 16),
            Text(
              'ابدأ سؤالك الأول',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.text_3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إنشاء محادثة جديدة تلقائيًا عند إرسال أول رسالة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text_1,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMessagesState extends StatelessWidget {
  const _NoMessagesState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'لا توجد رسائل بعد',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.text_3,
          fontSize: 18,
          fontFamily: 'Tajawal_M',
        ),
      ),
    );
  }
}

class _MessagesErrorState extends StatelessWidget {
  const _MessagesErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _RetryState(message: message, onRetry: onRetry);
  }
}

class _DrawerEmptyState extends StatelessWidget {
  const _DrawerEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'لا توجد جلسات محفوظة حتى الآن',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.text_1,
          ),
        ),
      ),
    );
  }
}

class _DrawerErrorState extends StatelessWidget {
  const _DrawerErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _RetryState(message: message, onRetry: onRetry);
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                message,
                style: AppTextStyles.heading5.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
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

