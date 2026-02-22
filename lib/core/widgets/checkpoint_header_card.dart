import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class CheckpointHeaderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBackPressed;

  const CheckpointHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: IconButton(
                  onPressed: onBackPressed,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.text_5,
                  ),
                ),
              ),
              Text(
                title,
                style: AppTextStyles.heading4.copyWith(color: AppColors.text_5),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent_3,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
            
                children: [
                  Text(
                    subtitle!,
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.text_3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 20,
                    color: AppColors.primary2,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
