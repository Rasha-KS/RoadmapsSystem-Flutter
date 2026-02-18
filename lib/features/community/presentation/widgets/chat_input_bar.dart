import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

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
            padding: const EdgeInsets.only(bottom: 8),
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
                      size: 16,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary4,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.secondary1),
          ),
          child: Row(
            children: [
              Expanded(
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
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_4),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _canSend ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary1),
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
        ),
      ],
    );
  }
}
