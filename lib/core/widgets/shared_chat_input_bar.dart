import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class SharedChatInputBar extends StatefulWidget {
  const SharedChatInputBar.community({
    super.key,
    required this.hasPendingAttachment,
    required this.pendingAttachmentName,
    required this.onClearAttachment,
    required this.onPickAttachment,
    required this.onSendPressed,
    this.hintText = 'شاركنا أفكارك',
    this.showInsideSendButton = false,
    this.showSeparateImageButton = false,
    this.isSending = false,
  });

  const SharedChatInputBar.smartInstructor({
    super.key,
    required this.hasPendingAttachment,
    required this.pendingAttachmentName,
    required this.onClearAttachment,
    required this.onPickAttachment,
    required this.onSendPressed,
    this.hintText = 'اسأل عن أي شيء',
    this.showInsideSendButton = true,
    this.showSeparateImageButton = true,
    this.isSending = false,
  });

  final bool hasPendingAttachment;
  final String? pendingAttachmentName;
  final VoidCallback onClearAttachment;
  final Future<void> Function() onPickAttachment;
  final Future<void> Function(String text) onSendPressed;
  final String hintText;
  final bool showInsideSendButton;
  final bool showSeparateImageButton;
  final bool isSending;

  @override
  State<SharedChatInputBar> createState() => _SharedChatInputBarState();
}

class _SharedChatInputBarState extends State<SharedChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  bool get _canSend {
    return _controller.text.trim().isNotEmpty || widget.hasPendingAttachment;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_canSend || widget.isSending) return;
    final text = _controller.text.trim();
    await widget.onSendPressed(text);
    if (!mounted) return;
    _controller.clear();
    setState(() {});
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 30),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary4,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.secondary1),
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 5,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) async {
                          await _send();
                        },
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.text_1,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: widget.showInsideSendButton ? 38 : 0,
                          ),
                        ),
                      ),
                      if (widget.showInsideSendButton)
                        Positioned(
                          left: 0,
                          top: 1,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _canSend
                                  ? AppColors.primary2
                                  : AppColors.secondary1,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: _canSend ? _send : null,
                              icon: const Icon(
                                Icons.arrow_upward,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: widget.showSeparateImageButton
                      ? AppColors.secondary4
                      : (_canSend ? AppColors.primary1 : AppColors.secondary4),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary2),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    if (widget.isSending) return;
                    if (widget.showSeparateImageButton) {
                      await widget.onPickAttachment();
                      if (!mounted) return;
                      setState(() {});
                      return;
                    }

                    if (_canSend) {
                      await _send();
                      return;
                    }

                    await widget.onPickAttachment();
                    if (!mounted) return;
                    setState(() {});
                  },
                  icon: Icon(
                    widget.showSeparateImageButton
                        ? Icons.photo_camera_outlined
                        : (_canSend ? Icons.send : Icons.camera_alt_outlined),
                    color: _canSend && !widget.showSeparateImageButton
                        ? Colors.white
                        : AppColors.primary,
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
