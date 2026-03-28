import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/app_primary_button.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/checkpoint_header_card.dart';
import 'package:roadmaps/core/widgets/checkpoint_question_card.dart';
import 'package:roadmaps/features/checkpoints/domain/checkpoint_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/question_entity.dart';
import 'package:roadmaps/features/checkpoints/presentation/checkpoints_provider.dart';

class CheckpointScreen extends StatefulWidget {
  final String learningPathId;
  final String checkpointId;
  final String roadmapTitle;
  final bool isRetake;

  const CheckpointScreen({
    super.key,
    required this.learningPathId,
    required this.checkpointId,
    this.roadmapTitle = '',
    this.isRetake = false,
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
        useRetakeAttempt: widget.isRetake,
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
                        isLoading: provider.isSubmitting,
                        onPressed:
                            checkpoint != null &&
                                provider.isAllAnswered &&
                                !provider.isLoading &&
                                !provider.isSubmitting
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
                context.read<CheckpointsProvider>().retryCurrentCheckpoint(
                  learningPathId: widget.learningPathId,
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
              subtitle: checkpoint.subtitle,
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

    final result = await provider.submitAnswers();
    if (result == null) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      showAppSnackBar(
        messenger,
        message: provider.errorMessage ?? 'تعذر إرسال إجابات الاختبار.',
        variant: SnackBarVariant.error,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    if (!mounted) return;

    provider.resetAnswers();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final bool passed = result.passed;
        final bool hasFullScore =
            result.maximumPossibleXp > 0 && result.earnedXp >= result.maximumPossibleXp;

        return Dialog(
          alignment: Alignment.topCenter,
          backgroundColor: AppColors.primary1.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.only(
            left: 50,
            right: 50,
            top: 250,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    passed ? 'assets/images/happy.png' : 'assets/images/sad.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'النتيجة',
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.text_2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.correctCount != null
                        ? '${result.correctCount}/${result.totalQuestions}'
                        : '${result.earnedXp}/${result.maximumPossibleXp}',
                    style: AppTextStyles.heading2.copyWith(
                      color: passed ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'نقاط الخبرة: ${result.maximumPossibleXp}/${result.earnedXp}',
                    style: AppTextStyles.body.copyWith(color: AppColors.text_2),
                    textAlign: TextAlign.center,
                  ),
                  if (!passed) ...[
                    const SizedBox(height: 8),
                    Text(
                      'لم تنجح. يمكنك إعادة المحاولة لاحقًا.',
                      style: AppTextStyles.body.copyWith(color: AppColors.text_2),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (passed && hasFullScore)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary4,
                        foregroundColor: AppColors.text_3,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        if (!mounted) return;
                        Navigator.of(context).pop(result);
                      },
                      child: Text(
                        'المسار',
                        style: AppTextStyles.boldSmallText.copyWith(
                          color: AppColors.text_3,
                        ),
                      ),
                    ),
                  if (passed && !hasFullScore)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
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
                                Navigator.of(context).pop(result);
                              },
                              child: Text(
                                'المسار',
                                style: AppTextStyles.boldSmallText.copyWith(
                                  color: AppColors.text_3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary4,
                                foregroundColor: AppColors.text_3,
                                elevation: 0,
                              ),
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                if (!mounted) return;
                                final shouldRetake =
                                    await _showRetakeCheckpointDialogWithMessage(
                                      previousAttemptPassed: result.passed,
                                    );
                                if (!shouldRetake) {
                                  if (!mounted) return;
                                  Navigator.of(context).maybePop();
                                  return;
                                }
                                if (!mounted) return;
                                await context
                                    .read<CheckpointsProvider>()
                                    .retakeCurrentCheckpoint(
                                      learningPathId: widget.learningPathId,
                                    );
                              },
                              child: Text(
                                'إعادة المحاولة',
                                style: AppTextStyles.boldSmallText.copyWith(
                                  color: AppColors.text_3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!passed)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                if (!mounted) return;
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'إغلاق',
                                style: AppTextStyles.boldSmallText.copyWith(
                                  color: AppColors.text_2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary4,
                                foregroundColor: AppColors.text_3,
                                elevation: 0,
                              ),
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                if (!mounted) return;
                                final shouldRetake =
                                    await _showRetakeCheckpointDialogWithMessage(
                                      previousAttemptPassed: false,
                                    );
                                if (!shouldRetake) {
                                  if (!mounted) return;
                                  Navigator.of(context).maybePop();
                                  return;
                                }
                                if (!mounted) return;
                                await context
                                    .read<CheckpointsProvider>()
                                    .retakeCurrentCheckpoint(
                                      learningPathId: widget.learningPathId,
                                    );
                              },
                              child: Text(
                                'إعادة المحاولة',
                                style: AppTextStyles.boldSmallText.copyWith(
                                  color: AppColors.text_3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Future<bool> _showRetakeCheckpointDialog() async {
    bool confirmed = false;
    await showConfirmActionDialog(
      context: context,
      title: 'إعادة الاختبار',
      message:
          'سيتم بدء محاولة جديدة وإعادة ضبط نتيجة الاختبار الحالية. هل تريد المتابعة؟',
      cancelText: 'إلغاء',
      confirmText: 'إعادة',
      onConfirm: () async {
        confirmed = true;
      },
    );
    return confirmed;
  }

  Future<bool> _showRetakeCheckpointDialogWithMessage({
    required bool previousAttemptPassed,
  }) async {
    bool confirmed = false;
    await showConfirmActionDialog(
      context: context,
      title: 'إعادة الاختبار',
      message: previousAttemptPassed
          ? 'المحاولة السابقة ناجحة بالفعل. هل تريد إعادة الاختبار وبدء محاولة جديدة؟'
          : 'لم تنجح المحاولة السابقة. هل تريد إعادة الاختبار مباشرة؟',
      cancelText: 'إلغاء',
      confirmText: 'إعادة',
      onConfirm: () async {
        confirmed = true;
      },
    );
    return confirmed;
  }
}
