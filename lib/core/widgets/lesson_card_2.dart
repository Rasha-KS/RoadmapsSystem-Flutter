import 'package:flutter/material.dart';
import 'package:see_more/see_more.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class LessonCard2 extends StatelessWidget {
  final dynamic course;
  final double widthMultiplier;
  final int trimLength;
  final VoidCallback? onEnroll;

  const LessonCard2({
    super.key,
    required this.course,
    required this.widthMultiplier,
    required this.trimLength,
    this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * widthMultiplier;

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 130),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.primary1,
        borderRadius: BorderRadius.circular(20),
         boxShadow: [
          BoxShadow(
          color: const Color.fromARGB(255, 160, 159, 159) ,//.withValues(alpha: 0.5), // رمادي غامق أفتح من الأسود
          blurRadius:3,
          spreadRadius: 0.5, // يخليه ينتشر من الجناب
          offset: Offset(0,3), // لتحت
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
              _buildBadge(course.level),
              Expanded(
                child: Text(
                  course.title,
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
          const SizedBox(height: 3),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.centerRight,
              child: SeeMoreWidget(
                course.description,
                trimLength: trimLength,
                seeMoreText: '...المزيد',
                seeLessText: 'أقل',
                textStyle: AppTextStyles.body.copyWith(
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
                minWidth: 0,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: () {
                  onEnroll?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'تم التسجيل بنجاح',
                          style: AppTextStyles.heading5.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      backgroundColor: AppColors.backGroundSuccess,
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
                  'تسجيل',
                  style: AppTextStyles.boldSmallText.copyWith(
                    color: AppColors.text_5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        text,
        style: AppTextStyles.smallText.copyWith(
          color: AppColors.text_3,
        ),
      ),
    );
  }
}
