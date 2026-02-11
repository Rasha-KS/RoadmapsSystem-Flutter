import 'package:flutter/material.dart';
import 'package:see_more/see_more.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class LessonCard1 extends StatelessWidget {
  final dynamic course;
  final double widthMultiplier;
  final int trimLength;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback onTap;

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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * widthMultiplier;

    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: 167 ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary1,
        borderRadius: BorderRadius.circular(25),
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
                onPressed: onDelete,
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh_outlined,
                  color: AppColors.text_2,
                  size: 22,
                ),
                onPressed: onRefresh,
              ),
              const SizedBox(width:12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                     course.status,
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
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary2,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                onPressed: onTap,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                child: SeeMoreWidget(
                  course.description,
                  trimLength: trimLength,
                  seeMoreText: 'المزيد',
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
            ],
          ),
        ],
      ),
    );
  }
}
