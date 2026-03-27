import 'package:flutter/material.dart';
import 'package:roadmaps/core/constants/ui_texts.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/utils/roadmap_display.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:see_more/see_more.dart';

class LessonCard1 extends StatefulWidget {
  final dynamic course;
  final double widthMultiplier;
  final int trimLength;
  final Future<void> Function() onDelete;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onTap;

  const LessonCard1({
    super.key,
    required this.course,
    required this.widthMultiplier,
    required this.trimLength,
    required this.onDelete,
    required this.onRefresh,
    required this.onTap,
  });

  @override
  State<LessonCard1> createState() => _LessonCard1State();
}

class _LessonCard1State extends State<LessonCard1> {
  bool _isBusy = false;

  Future<void> _runBusyAction(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    await showConfirmActionDialog(
      context: context,
      title: AppTexts.deleteConfirmTitle,
      message: AppTexts.deleteConfirmMessage,
      onConfirm: () async {
        await _runBusyAction(widget.onDelete);
      },
    );
  }

  Future<void> _showResetConfirmDialog() async {
    await showConfirmActionDialog(
      context: context,
      title: AppTexts.resetConfirmTitle,
      message: AppTexts.resetConfirmMessage,
      onConfirm: () async {
        await _runBusyAction(widget.onRefresh);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * widget.widthMultiplier;
    final statusText = RoadmapDisplay.status(widget.course.status?.toString());
    final titleText = (widget.course.title ?? '').toString();
    final descriptionText = (widget.course.description ?? '').toString();

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isBusy,
          child: Opacity(
            opacity: _isBusy ? 0.75 : 1,
            child: Container(
              width: width,
              constraints: const BoxConstraints(minHeight: 167),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary1,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(12, 32, 49, 0.25),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_sharp,
                          color: AppColors.text_2,
                          size: 22,
                        ),
                        onPressed: _isBusy ? null : _showDeleteConfirmDialog,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh_outlined,
                          color: AppColors.text_2,
                          size: 22,
                        ),
                        onPressed: _isBusy ? null : _showResetConfirmDialog,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              statusText,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.text_6,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Flexible(
                              child: Text(
                                titleText,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.heading4.copyWith(
                                  color: AppColors.text_2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      IconButton(
                        icon: Container(
                          height: 39,
                          width: 39,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary2,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        onPressed: _isBusy
                            ? null
                            : () async {
                                await widget.onTap();
                              },
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: SeeMoreWidget(
                            descriptionText,
                            trimLength: widget.trimLength,
                            seeMoreText: AppTexts.seeMore,
                            seeLessText: AppTexts.seeLess,
                            textStyle: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              color: AppColors.text_2,
                            ),
                            seeMoreStyle: AppTextStyles.smallText.copyWith(
                              color: AppColors.text_6,
                            ),
                            seeLessStyle: AppTextStyles.smallText.copyWith(
                              color: AppColors.text_6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isBusy)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
