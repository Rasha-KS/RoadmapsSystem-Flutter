import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';

class RoadmapProgress extends StatelessWidget {
  final List<LearningUnitEntity> units;
  final int userXp;
  final String levelLabel;

  const RoadmapProgress({
    super.key,
    required this.units,
    required this.userXp,
    this.levelLabel = 'Level',
  });

  @override
  Widget build(BuildContext context) {
    final int completedCount = units
        .where((unit) => unit.status == LearningUnitStatus.completed)
        .length;
    final double progress = units.isEmpty ? 0 : completedCount / units.length;
    final int percentage = (progress * 100).round();

    return Column(
      children: [
        SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.secondary4,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.primary1),
                ),
              ),
              
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    widthFactor: progress.clamp(0, 1),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary2,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$percentage%',
                        style: AppTextStyles.boldSmallText.copyWith(
                          color: AppColors.text_5,
                        ),
                      ),
                      Text(
                        levelLabel,
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.text_1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedCount/${units.length} مكتمل',
              style: AppTextStyles.smallText.copyWith(color: AppColors.text_1),
            ),
            Text(
              'نقاط الخبرة: $userXp',
              style: AppTextStyles.smallText.copyWith(color: AppColors.text_1),
            ),
          ],
        ),
      ],
    );
  }
}
