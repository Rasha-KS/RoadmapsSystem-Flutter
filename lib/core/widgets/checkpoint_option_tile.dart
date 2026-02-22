import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class CheckpointOptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CheckpointOptionTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background.withValues(alpha: 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              _OptionIndicator(isSelected: isSelected),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text_3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionIndicator extends StatelessWidget {
  final bool isSelected;

  const _OptionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary4,
        border: Border.all(
          color: isSelected ? AppColors.primary2 : AppColors.secondary2,
          width: 2,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary2 : AppColors.secondary4,
        ),
      ),
    );
  }
}
