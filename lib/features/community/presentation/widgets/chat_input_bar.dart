import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.hasPendingAttachment,
    required this.onPickAttachment,
    required this.onSendPressed,
  });

  final bool hasPendingAttachment;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary4,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent_1,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                await widget.onPickAttachment();
                if (!mounted) return;
                setState(() {});
              },
              icon: const Icon(
                Icons.image_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'شارك أفكارك',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_4),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Opacity(
            opacity: _canSend ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !_canSend,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async {
                    final text = _controller.text.trim();
                    await widget.onSendPressed(text);
                    if (!mounted) return;
                    _controller.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
