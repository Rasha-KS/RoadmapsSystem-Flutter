import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/app_primary_button.dart';
import 'package:roadmaps/core/widgets/checkpoint_header_card.dart';
import 'package:roadmaps/core/widgets/checkpoint_question_card.dart';
import 'package:roadmaps/features/checkpoints/domain/checkpoint_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/question_entity.dart';
import 'package:roadmaps/features/checkpoints/presentation/checkpoints_provider.dart';

class CheckpointResult {
  final bool passed;
  final int earnedXp;
  final int minimumRequiredXp;
  final int correctCount;
  final int totalQuestions;
  final double scorePercent;

  const CheckpointResult({
    required this.passed,
    required this.earnedXp,
    required this.minimumRequiredXp,
    required this.correctCount,
    required this.totalQuestions,
    required this.scorePercent,
  });
}

class CheckpointScreen extends StatefulWidget {
  final String learningPathId;
  final String checkpointId;
  final String roadmapTitle;

  const CheckpointScreen({
    super.key,
    required this.learningPathId,
    required this.checkpointId,
    this.roadmapTitle = '',
  });

  @override
  State<CheckpointScreen> createState() => _CheckpointScreenState();
}

class _CheckpointScreenState extends State<CheckpointScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CheckpointsProvider>().fetchCheckpoint(
        learningPathId: widget.learningPathId,
        checkpointId: widget.checkpointId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckpointsProvider>();
    final checkpoint = provider.checkpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildBody(
                        provider: provider,
                        checkpoint: checkpoint,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: AppPrimaryButton(
                        text: 'النتيجة',
                        onPressed:
                            checkpoint != null &&
                                provider.isAllAnswered &&
                                !provider.isLoading
                            ? () => _showResultDialog(provider)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required CheckpointsProvider provider,
    required CheckpointEntity? checkpoint,
  }) {
    if (provider.isLoading && checkpoint == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (checkpoint == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage ?? 'تعذر تحميل الاختبار',
              style: AppTextStyles.heading5.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<CheckpointsProvider>().fetchCheckpoint(
                  learningPathId: widget.learningPathId,
                  checkpointId: widget.checkpointId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_5,
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.boldSmallText.copyWith(
                  color: AppColors.text_5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: checkpoint.questions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final String titleToShow = widget.roadmapTitle.trim().isNotEmpty
              ? widget.roadmapTitle
              : checkpoint.title;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CheckpointHeaderCard(
              title: titleToShow,
              subtitle: "'اكمل الاختبار للحصول على نقاط خبرة'",
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          );
        }

        final QuestionEntity question = checkpoint.questions[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CheckpointQuestionCard(
            questionNumber: index,
            questionText: question.text,
            options: question.options,
            selectedOptionId: provider.selectedOptionByQuestionId[question.id],
            onOptionSelected: (optionId) {
              context.read<CheckpointsProvider>().selectOption(
                questionId: question.id,
                optionId: optionId,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showResultDialog(CheckpointsProvider provider) async {
    if (!provider.isAllAnswered || provider.checkpoint == null) return;

    final CheckpointResult result = CheckpointResult(
      passed: provider.isPassed,
      earnedXp: provider.earnedXp,
      minimumRequiredXp: provider.minimumRequiredXp,
      correctCount: provider.correctCount,
      totalQuestions: provider.totalQuestions,
      scorePercent: provider.scorePercent,
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final bool passed = result.passed;
        return Dialog(
          backgroundColor: AppColors.primary1.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'النتيجة',
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.text_2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${result.correctCount}/${result.totalQuestions}',
                    style: AppTextStyles.heading2.copyWith(
                      color: result.correctCount == result.totalQuestions
                          ? AppColors.success
                          : AppColors.text_2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  const SizedBox(height: 8),
                  Text(
                    'نقاط الخبرة: ${result.earnedXp}/${result.minimumRequiredXp}',
                    style: AppTextStyles.body.copyWith(color: AppColors.text_2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary4,
                            foregroundColor: AppColors.text_3,
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            if (!mounted) return;

                            if (passed) {
                              Navigator.of(context).pop(result);
                              return;
                            }

                            context.read<CheckpointsProvider>().resetAnswers();
                          },
                          child: Text(
                            passed ? 'الدرس التالي' : 'إعادة المحاولة',
                            style: AppTextStyles.boldSmallText.copyWith(
                              color: AppColors.text_3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
