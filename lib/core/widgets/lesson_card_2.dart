import 'package:flutter/material.dart';
import 'package:see_more/see_more.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';

class LessonCard2 extends StatefulWidget {
  final dynamic course;
  final double widthMultiplier;
  final int trimLength;
  final VoidCallback? onDelete;
  final VoidCallback? onRefresh;
  final VoidCallback? onTap;

  const LessonCard2({
    super.key,
    required this.course,
    required this.widthMultiplier,
    this.trimLength = 45,
    this.onDelete,
    this.onRefresh,
    this.onTap,
  });

  @override
  State<LessonCard2> createState() => _LessonCard2State();
}

class _LessonCard2State extends State<LessonCard2>
    with SingleTickerProviderStateMixin {
  bool _isEnrolled = false;

  @override
  Widget build(BuildContext context) {
    if (_isEnrolled) {
      return LessonCard1(
        course: widget.course,
        widthMultiplier: widget.widthMultiplier,
        onDelete: () {
          setState(() => _isEnrolled = false);
          widget.onDelete?.call();
        },
        onRefresh: widget.onRefresh ?? () {},
        onTap: widget.onTap ?? () {},
      );
    }

    final width = MediaQuery.of(context).size.width * widget.widthMultiplier;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary1,
          borderRadius: BorderRadius.circular(25),
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
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.text_2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SeeMoreWidget(
                widget.course.description,
                trimLength: widget.trimLength,
                seeMoreText: 'المزيد',
                seeLessText: 'أقل',
                textStyle: const TextStyle(
                  fontFamily: 'Tajawal_R',
                  fontSize: 12,
                  color: AppColors.text_2,
                ),
                seeMoreStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Tajawal_R',
                  color: AppColors.primary2,
                ),
                seeLessStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Tajawal_R',
                  color: AppColors.primary2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    setState(() => _isEnrolled = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("تم التسجيل بنجاح"),
                        backgroundColor: AppColors.backGroundSuccess,
                        duration: const Duration(seconds: 2),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "تسجيل",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent_2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppTextStyles.smallText.copyWith(
          color: AppColors.text_3,
        ),
      ),
    );
  }
}
