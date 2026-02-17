import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';

class RoadmapNode extends StatelessWidget {
  final LearningUnitEntity unit;
  final VoidCallback onTap;

  const RoadmapNode({super.key, required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = unit.status == LearningUnitStatus.locked;
    final Color backgroundColor = _backgroundForStatus(unit.status);
    final Color textColor = isLocked ? AppColors.text_3 : AppColors.text_2;

    return TweenAnimationBuilder<double>(
      key: ValueKey('${unit.id}-${unit.status.name}'),
      tween: Tween<double>(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: isLocked ? 0.8 : value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 190,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _UnitIcon(status: unit.status, type: unit.type),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        unit.title,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel(unit.status),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.smallText.copyWith(
                          color: textColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundForStatus(LearningUnitStatus status) {
    switch (status) {
      case LearningUnitStatus.completed:
        return AppColors.primary1;
      case LearningUnitStatus.unlocked:
        return AppColors.primary1;
      case LearningUnitStatus.locked:
        return AppColors.secondary1;
    }
  }

  String _statusLabel(LearningUnitStatus status) {
    switch (status) {
      case LearningUnitStatus.completed:
        return 'مكتمل';
      case LearningUnitStatus.unlocked:
        return 'متاح';
      case LearningUnitStatus.locked:
        return 'مقفل';
    }
  }
}

class _UnitIcon extends StatelessWidget {
  final LearningUnitStatus status;
  final LearningUnitType type;

  const _UnitIcon({required this.status, required this.type});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == LearningUnitStatus.completed;
    final bool isLocked = status == LearningUnitStatus.locked;

    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success
            : AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted
            ? Icons.check_rounded
            : (isLocked ? Icons.lock : _iconByType(type)),
        size: 15,
        color: isCompleted
            ? const Color.fromRGBO(72, 140, 92, 1)
            : AppColors.primary,
      ),
    );
  }

  IconData _iconByType(LearningUnitType type) {
    switch (type) {
      case LearningUnitType.lesson:
        return Icons.menu_book_rounded;
      case LearningUnitType.quiz:
        return Icons.quiz_outlined;
      case LearningUnitType.challenge:
        return Icons.emoji_events_outlined;
    }
  }
}
