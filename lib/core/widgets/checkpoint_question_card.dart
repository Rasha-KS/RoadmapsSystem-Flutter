import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/checkpoint_option_tile.dart';
import 'package:roadmaps/features/checkpoints/domain/option_entity.dart';

class CheckpointQuestionCard extends StatelessWidget {
  final int questionNumber;
  final String questionText;
  final List<OptionEntity> options;
  final String? selectedOptionId;
  final ValueChanged<String> onOptionSelected;

  const CheckpointQuestionCard({
    super.key,
    required this.questionNumber,
    required this.questionText,
    required this.options,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.secondary4,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textAlign: TextAlign.right,
            'السؤال $questionNumber  :',
            style: AppTextStyles.heading5.copyWith(
              color: AppColors.text_3,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            questionText,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.text_5),
          ),
          const SizedBox(height: 10),
          ...options.map(
            (option) => CheckpointOptionTile(
              text: option.text,
              isSelected: selectedOptionId == option.id,
              onTap: () => onOptionSelected(option.id),
            ),
          ),
        ],
      ),
    );
  }
}
