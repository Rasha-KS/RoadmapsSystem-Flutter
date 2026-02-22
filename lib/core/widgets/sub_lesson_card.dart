import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/resource_tile.dart';
import 'package:roadmaps/features/lessons/domain/resource_entity.dart';
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
    final List<ResourceEntity> youtubeResources = subLesson.resources
        .where((resource) => resource.type == ResourceType.youtube)
        .toList(growable: false);
    final List<ResourceEntity> bookResources = subLesson.resources
        .where((resource) => resource.type == ResourceType.book)
        .toList(growable: false);
    final bool hasResources =
        youtubeResources.isNotEmpty || bookResources.isNotEmpty;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              displayTitle ?? subLesson.title,
              textAlign: TextAlign.right,
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.text_4,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            subLesson.introductionTitle,
            textAlign: TextAlign.right,
            style: AppTextStyles.boldHeading5.copyWith(color: AppColors.text_5),
          ),
          const SizedBox(height: 6),
          Text(
            subLesson.introductionDescription,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text_3,
            ),
          ),
          if (hasResources) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.secondary2),
            const SizedBox(height: 10),
            Text(
              'المصادر',
              textAlign: TextAlign.right,
              style: AppTextStyles.boldHeading5.copyWith(
                color: AppColors.text_5,
              ),
            ),
            const SizedBox(height: 8),
            ...youtubeResources.map(
              (resource) => ResourceTile(resource: resource),
            ),
            ...bookResources.map(
              (resource) => ResourceTile(resource: resource),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
