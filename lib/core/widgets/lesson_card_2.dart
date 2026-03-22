import 'package:flutter/material.dart';
import 'package:see_more/see_more.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/ui_texts.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/utils/roadmap_display.dart';

class LessonCard2 extends StatefulWidget {
  final dynamic course;
  final double widthMultiplier;
  final int trimLength;
  final bool? isEnrolled;
  final ValueChanged<bool>? onEnrollmentChanged;
  final Future<void> Function()? onEnroll;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onTap;

  const LessonCard2({
    super.key,
    required this.course,
    required this.widthMultiplier,
    required this.trimLength,
    this.isEnrolled,
    this.onEnrollmentChanged,
    this.onEnroll,
    this.onDelete,
    this.onRefresh,
    this.onTap,
  });

  @override
  State<LessonCard2> createState() => _LessonCard2State();
}

class _LessonCard2State extends State<LessonCard2> {
  bool _isEnrolled = false;
  bool _isBusy = false;

  void _setEnrollment(bool enrolled) {
    if (widget.onEnrollmentChanged != null) {
      widget.onEnrollmentChanged!(enrolled);
      return;
    }

    if (!mounted) return;
    setState(() => _isEnrolled = enrolled);
  }

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
        await _runBusyAction(() async {
          try {
            if (widget.onDelete != null) {
              await widget.onDelete!();
            } else {
              _setEnrollment(false);
            }
            if (!mounted) return;
            _setEnrollment(false);
            final messenger = ScaffoldMessenger.of(context);
            showActionSnackBar(
              messenger,
              message: AppTexts.deleteSuccess,
              isSuccess: true,
            );
          } catch (e) {
            if (!mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            final message =
                e is ApiException ? e.message : AppTexts.deleteFailure;
            showActionSnackBar(
              messenger,
              message: message,
              isSuccess: false,
            );
          }
        });
      },
    );
  }

  Future<void> _showResetConfirmDialog() async {
    await showConfirmActionDialog(
      context: context,
      title: AppTexts.resetConfirmTitle,
      message: AppTexts.resetConfirmMessage,
      onConfirm: () async {
        await _runBusyAction(() async {
          try {
            if (widget.onRefresh != null) {
              await widget.onRefresh!();
            }
            if (!mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            showActionSnackBar(
              messenger,
              message: AppTexts.resetSuccess,
              isSuccess: true,
            );
          } catch (e) {
            if (!mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            final message = e is ApiException
                ? e.message
                : AppTexts.resetFailure;
            showActionSnackBar(
              messenger,
              message: message,
              isSuccess: false,
            );
          }
        });
      },
    );
  }

  Future<void> _showEnrollConfirmDialog() async {
    await showConfirmActionDialog(
      context: context,
      title: AppTexts.enrollConfirmTitle,
      message: AppTexts.enrollConfirmMessage,
      confirmText: AppTexts.enrollConfirmButton,
      onConfirm: () async {
        await _runBusyAction(() async {
          try {
            if (widget.onEnroll != null) {
              await widget.onEnroll!();
            } else if (widget.onEnrollmentChanged != null) {
              widget.onEnrollmentChanged!(true);
            }
            if (!mounted) return;
            _setEnrollment(true);
          } catch (e) {
            if (!mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            final message =
                e is ApiException ? e.message : AppTexts.enrollFailure;
            showActionSnackBar(
              messenger,
              message: message,
              isSuccess: false,
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnrolled = widget.isEnrolled ?? _isEnrolled;

    if (isEnrolled) {
      return LessonCard1(
        trimLength: 70,
        course: widget.course,
        widthMultiplier: 0.80,
        onDelete: () async {
          await _showDeleteConfirmDialog();
        },
        onRefresh: () async {
          await _showResetConfirmDialog();
        },
        onTap: widget.onTap ?? () async {},
      );
    }

    final width = MediaQuery.of(context).size.width * widget.widthMultiplier;

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isBusy,
          child: Opacity(
            opacity: _isBusy ? 0.75 : 1,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: width,
                constraints: const BoxConstraints(minHeight: 130),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 22,
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBadge(widget.course.level),
                        Expanded(
                          child: Text(
                            widget.course.title,
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
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SeeMoreWidget(
                          widget.course.description,
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        MaterialButton(
                          color: AppColors.primary2,
                          minWidth: 70,
                          height: 25,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: _isBusy
                              ? null
                              : () {
                                  if (widget.onEnroll != null) {
                                    _showEnrollConfirmDialog();
                                    return;
                                  }

                                  if (widget.onEnrollmentChanged != null) {
                                    widget.onEnrollmentChanged!(true);
                                  } else {
                                    setState(() => _isEnrolled = true);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          AppTexts.enrollSuccess,
                                          style: AppTextStyles.heading5.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      backgroundColor:
                                          AppColors.backGroundSuccess,
                                      duration: const Duration(seconds: 3),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(18),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          child: Text(
                            AppTexts.enrollConfirmButton,
                            style: AppTextStyles.boldSmallText.copyWith(
                              color: AppColors.text_5,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
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
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent_2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        RoadmapDisplay.level(text),
        style: AppTextStyles.smallText.copyWith(
          color: AppColors.text_3,
        ),
      ),
    );
  }
}
