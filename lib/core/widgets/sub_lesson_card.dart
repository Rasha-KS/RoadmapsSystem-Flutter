import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/resource_tile.dart';
import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';

class SubLessonCard extends StatelessWidget {
  final SubLessonEntity subLesson;
  final String? displayTitle;

  const SubLessonCard({
    super.key,
    required this.subLesson,
    this.displayTitle,
  });

  @override
  Widget build(BuildContext context) {
    final arabicResources = subLesson.resources
        .where((resource) => resource.language.trim().toLowerCase() == 'ar')
        .toList(growable: false);
    final englishResources = subLesson.resources
        .where((resource) => resource.language.trim().toLowerCase() != 'ar')
        .toList(growable: false);
    final hasArabicResources = arabicResources.isNotEmpty;
    final hasEnglishResources = englishResources.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.secondary4,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              displayTitle ?? 'الجزء ${subLesson.position}',
              textAlign: TextAlign.right,
              style: AppTextStyles.boldHeading5.copyWith(
                color: AppColors.text_4,
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (subLesson.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.secondary2),
            const SizedBox(height: 10),
            Text(
              'المقدمة',
              textAlign: TextAlign.right,
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.text_5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subLesson.description!.trim(),
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text_3,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.secondary2),
            const SizedBox(height: 10),
            Text(
              'المقدمة',
              textAlign: TextAlign.right,
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.text_5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لا يوجد وصف لهذا الجزء.',
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text_3,
              ),
            ),
          ],
          if (hasArabicResources || hasEnglishResources) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.secondary2),
            const SizedBox(height: 10),
            if (hasArabicResources) ...[
              Text(
                'المصادر العربية',
                textAlign: TextAlign.right,
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.text_5,
                ),
              ),
              const SizedBox(height: 8),
              ...arabicResources.map((resource) => ResourceTile(resource: resource)),
            ],
            if (hasArabicResources && hasEnglishResources) ...[
              const SizedBox(height: 4),
              const Divider(color: AppColors.secondary2),
              const SizedBox(height: 8),
            ],
            if (hasEnglishResources) ...[
              Text(
                'المصادر الإنجليزية',
                textAlign: TextAlign.right,
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.text_5,
                ),
              ),
              const SizedBox(height: 8),
              ...englishResources
                  .map((resource) => ResourceTile(resource: resource)),
            ],
          ],
        ],
      ),
    );
  }
}
