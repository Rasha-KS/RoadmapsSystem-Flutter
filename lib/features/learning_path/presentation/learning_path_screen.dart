import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/roadmap_node.dart';
import 'package:roadmaps/core/widgets/roadmap_progress.dart';
import 'package:roadmaps/features/checkpoints/domain/checkpoint_submission_result.dart';
import 'package:roadmaps/features/checkpoints/presentation/checkpoints_provider.dart';
import 'package:roadmaps/features/checkpoints/presentation/checkpoint_screen.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/lessons/presentation/lessons_screen.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';

class LearningPathScreen extends StatefulWidget {
  final int roadmapId;
  final String roadmapTitle;

  const LearningPathScreen({
    super.key,
    required this.roadmapId,
    this.roadmapTitle = 'C++',
  });

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LearningPathProvider>().loadPath(widget.roadmapId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningPathProvider>();
    context.watch<ProfileProvider>();
    final hasInitialLoading =
        provider.state == LearningPathState.loading && provider.units.isEmpty;
    final hasInitialError =
        provider.state == LearningPathState.connectionError &&
        provider.units.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35, 40, 35, 40),
              child: Column(
                children: [
                  _HeaderCard(
                    title: provider.roadmapTitle.isNotEmpty
                        ? provider.roadmapTitle
                        : widget.roadmapTitle,
                    units: provider.units,
                    userXp: provider.userXp,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: hasInitialLoading
                      ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary2,
                            ),
                          )
                        : hasInitialError
                        ? _ErrorState(
                            onRetry: () async {
                              await context
                                  .read<LearningPathProvider>()
                                  .refreshPath();
                            },
                          )
                        : _buildRoadmapList(provider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapList(LearningPathProvider provider) {
    if (provider.units.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد محتوى للعرض',
          style: AppTextStyles.body.copyWith(color: AppColors.text_1),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary2,
      onRefresh: () async {
        final messenger = ScaffoldMessenger.of(context);
        await provider.refreshPath();
        if (provider.state == LearningPathState.connectionError) {
          _showRefreshFailedSnackBar(messenger);
        }
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: provider.units.length,
        itemBuilder: (context, index) {
          final unit = provider.units[index];
          final displayUnit = _effectiveUnitForDisplay(
            units: provider.units,
            index: index,
            unit: unit,
            userXp: provider.userXp,
          );
          final bool alignLeft = index.isEven;
          final lessonNumber = _lessonNumberForIndex(provider.units, index);
          final String? displayTitle = displayUnit.type == LearningUnitType.lesson
              ? 'درس $lessonNumber'
              : null;

          return Column(
            children: [
              Align(
                alignment:
                    alignLeft ? Alignment.centerLeft : Alignment.centerRight,
                child: RoadmapNode(
                  unit: displayUnit,
                  displayTitle: displayTitle,
                  onTap: () => _onUnitTap(provider, displayUnit, lessonNumber),
                ),
              ),
              if (index < provider.units.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: 150,
                    height: 58,
                    child: CustomPaint(
                      painter: _RoadmapConnectorPainter(
                        fromLeft: alignLeft,
                        color: AppColors.primary1,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  int _lessonNumberForIndex(List<LearningUnitEntity> units, int currentIndex) {
    var lessonCount = 0;
    for (var i = 0; i <= currentIndex && i < units.length; i++) {
      if (units[i].type == LearningUnitType.lesson) {
        lessonCount++;
      }
    }
    return lessonCount == 0 ? 1 : lessonCount;
  }

  void _showRefreshFailedSnackBar(ScaffoldMessengerState messenger) {
    showAppSnackBar(
      messenger,
      message: 'تعذر التحديث بسبب انقطاع الاتصال بالشبكة',
      variant: SnackBarVariant.error,
      duration: const Duration(milliseconds: 1000),
    );
  }

  Future<void> _onUnitTap(
    LearningPathProvider provider,
    LearningUnitEntity unit,
    int lessonNumber,
  ) async {
    if (unit.isLocked && unit.type != LearningUnitType.challenge) {
      final previousUnit = _previousUnit(provider.units, unit.id);
      final bool isLockedChallenge = unit.type == LearningUnitType.challenge;
      final bool isLockedCheckPonit = unit.type == LearningUnitType.quiz;
      final bool isLockedLesson = unit.type == LearningUnitType.lesson;
      showAppSnackBar(
        ScaffoldMessenger.of(context),
        message: isLockedChallenge
            ? 'هذا التحدي مقفل حاليًا.'
            : isLockedCheckPonit
            ? _lockedQuizMessage(previousUnit)
            : isLockedLesson
            ? _lockedLessonMessage(previousUnit)
            : 'التحدي مقفل، أكمل الدروس السابقة.',
        variant: SnackBarVariant.warning,
        duration: const Duration(milliseconds: 1200),
      );
      return;
    }

    if (unit.type == LearningUnitType.challenge) {
      final previousUnit = _previousUnit(provider.units, unit.id);
      final bool previousLessonCompleted = previousUnit?.isCompleted ?? false;
      final int requiredXp = unit.requiredXp;
      final bool hasEnoughXp = requiredXp <= 0 || provider.userXp >= requiredXp;
      if (!previousLessonCompleted || !hasEnoughXp) {
        showAppSnackBar(
          ScaffoldMessenger.of(context),
          message: _challengeLockMessage(
            previousLessonCompleted: previousLessonCompleted,
            hasEnoughXp: hasEnoughXp,
            currentXp: provider.userXp,
            requiredXp: requiredXp,
          ),
          variant: SnackBarVariant.warning,
          duration: const Duration(milliseconds: 1200),
        );
        return;
      }
      return;
    }

    if (unit.type == LearningUnitType.lesson) {
      final bool? shouldComplete = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => LessonsScreen(
            lessonId: unit.entityId,
            roadmapTitle: widget.roadmapTitle,
            lessonTitle: unit.title,
            lessonDescription: unit.description ?? '',
            lessonNumber: lessonNumber,
            isLessonCompleted: unit.status == LearningUnitStatus.completed,
          ),
        ),
      );

      if (shouldComplete != true) return;

      await provider.completeUnit(unitId: unit.id);
      if (!mounted) return;

      showAppSnackBar(
        ScaffoldMessenger.of(context),
        message: '${unit.title} مكتمل.',
        variant: SnackBarVariant.success,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    if (unit.type == LearningUnitType.quiz) {
      final navigator = Navigator.of(context);
      final checkpointsProvider = context.read<CheckpointsProvider>();
      final profileProvider = context.read<ProfileProvider>();
      final int attemptsCount;
      try {
        attemptsCount = await checkpointsProvider.getAttemptsCount(
          quizId: unit.entityId,
        );
      } catch (_) {
        if (!mounted) return;
        showAppSnackBar(
          ScaffoldMessenger.of(context),
          message: 'تعذر فتح الاختبار حاول مرة اخرى.',
          variant: SnackBarVariant.error,
          duration: const Duration(milliseconds: 1400),
        );
        return;
      }

      final bool isRetake = attemptsCount > 0;
      if (isRetake) {
        final bool shouldRetake = await _showRetakeCheckpointDialog(
          previousAttemptPassed:
              unit.isCompleted || provider.hasConfirmedRetake(unit.id),
        );
        if (!shouldRetake) return;
      }

      final CheckpointSubmissionResult? result = await navigator.push<
        CheckpointSubmissionResult
      >(
            MaterialPageRoute(
              builder: (_) => CheckpointScreen(
                learningPathId: widget.roadmapId.toString(),
                checkpointId: unit.entityId.toString(),
                roadmapTitle: widget.roadmapTitle,
                isRetake: isRetake,
              ),
            ),
          );

      if (!mounted || result == null) return;

      await provider.submitCheckpointAttempt(
        unitId: unit.id,
        passed: result.passed,
      );
      if (!mounted) return;

      if (!result.passed) {
        showAppSnackBar(
          ScaffoldMessenger.of(context),
          message: 'لم تحقق الحد الأدنى للنجاح في هذه المحاولة. يمكنك إعادة الاختبار.',
          variant: SnackBarVariant.error,
          duration: const Duration(milliseconds: 1700),
        );
        return;
      }

      await profileProvider.loadProfileData();
      if (!mounted) return;

      showAppSnackBar(
        ScaffoldMessenger.of(context),
        message: 'أحسنت! تم تسجيل نتيجة الاختبار. +${result.earnedXp} XP',
        variant: SnackBarVariant.success,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    final int earnedXp = _earnedXpForUnit(unit.type);
    await provider.completeUnit(unitId: unit.id);
    _syncProfileProgress(provider);
    if (!mounted) return;

    showAppSnackBar(
      ScaffoldMessenger.of(context),
      message: '${unit.title} مكتمل. +$earnedXp نقاط خبرة',
      variant: SnackBarVariant.success,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _syncProfileProgress(LearningPathProvider provider) {
    if (!mounted) return;
    final profileProvider = context.read<ProfileProvider>();
    profileProvider.updateRoadmapProgress(
      roadmapId: widget.roadmapId,
      progressPercentage: (provider.completionRatio * 100).round(),
    );
  }

  Future<bool> _showRetakeCheckpointDialog({
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

  int _earnedXpForUnit(LearningUnitType type) {
    switch (type) {
      case LearningUnitType.lesson:
        return 0;
      case LearningUnitType.quiz:
        return 0;
      case LearningUnitType.challenge:
        return 0;
    }
  }

  LearningUnitEntity _effectiveUnitForDisplay({
    required List<LearningUnitEntity> units,
    required int index,
    required LearningUnitEntity unit,
    required int userXp,
  }) {
    if (unit.type != LearningUnitType.challenge || unit.isCompleted) {
      return unit;
    }

    final previousUnit = index > 0 ? units[index - 1] : null;
    final bool previousLessonCompleted = previousUnit?.isCompleted ?? false;
    final int requiredXp = unit.requiredXp;
    final bool shouldUnlock =
        previousLessonCompleted && (requiredXp <= 0 || userXp >= requiredXp);

    return unit.copyWith(
      status: shouldUnlock
          ? LearningUnitStatus.unlocked
          : LearningUnitStatus.locked,
      isLocked: !shouldUnlock,
    );
  }

  LearningUnitEntity? _previousUnit(
    List<LearningUnitEntity> units,
    int currentUnitId,
  ) {
    final index = units.indexWhere((unit) => unit.id == currentUnitId);
    if (index <= 0) return null;
    return units[index - 1];
  }

  String _lockedLessonMessage(LearningUnitEntity? previousUnit) {
    if (previousUnit == null) {
      return 'هذا الدرس مقفل، أكمل الدرس السابق.';
    }

    switch (previousUnit.type) {
      case LearningUnitType.quiz:
        return 'هذا الدرس مقفل، أكمل الاختبار السابق.';
      case LearningUnitType.challenge:
        return 'هذا الدرس مقفل، أكمل التحدي السابق.';
      case LearningUnitType.lesson:
        return 'هذا الدرس مقفل، أكمل الدرس السابق.';
    }
  }

  String _lockedQuizMessage(LearningUnitEntity? previousUnit) {
    if (previousUnit == null) {
      return 'هذا الاختبار مقفل، أكمل الدرس السابق.';
    }

    switch (previousUnit.type) {
      case LearningUnitType.lesson:
        return 'هذا الاختبار مقفل، أكمل الدرس السابق.';
      case LearningUnitType.quiz:
        return 'هذا الاختبار مقفل، أكمل الاختبار السابق.';
      case LearningUnitType.challenge:
        return 'هذا الاختبار مقفل، أكمل التحدي السابق.';
    }
  }

  String _challengeLockMessage({
    required bool previousLessonCompleted,
    required bool hasEnoughXp,
    required int currentXp,
    required int requiredXp,
  }) {
    if (!previousLessonCompleted) {
      return 'هذا التحدي مقفل، أكمل الدرس السابق.';
    }

    if (requiredXp > 0 && !hasEnoughXp) {
      return 'نقاط الخبرة الحالية $currentXp من أصل $requiredXp غير كافية لفتح التحدي.';
    }

    return 'هذا التحدي مقفل حاليًا.';
  }

}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'انقطع الاتصال. أعد المحاولة لتحميل المسار.',
                style: AppTextStyles.heading5.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_1,
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.boldSmallText.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final List<LearningUnitEntity> units;
  final int userXp;

  const _HeaderCard({
    required this.title,
    required this.units,
    required this.userXp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(246, 248, 250, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.text_5,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_right_alt_outlined,
                  color: AppColors.text_5,
                  size: 35,
                ),
              ),
            ],
          ),
          RoadmapProgress(units: units, userXp: userXp, levelLabel: 'المستوى'),
        ],
      ),
    );
  }
}

class _RoadmapConnectorPainter extends CustomPainter {
  final bool fromLeft;
  final Color color;

  _RoadmapConnectorPainter({required this.fromLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final double startX = fromLeft ? 24 : size.width - 24;
    final double endX = fromLeft ? size.width - 24 : 24;
    const double startY = 6;
    final double endY = size.height - 8;
    final double controlX = size.width / 2;
    const double controlY = -10;

    final path = Path()
      ..moveTo(startX, startY)
      ..quadraticBezierTo(controlX, controlY, endX, endY);

    canvas.drawPath(path, paint);

    final double direction = fromLeft ? 0.75 : pi - 0.75;
    const double arrowSize = 7;
    final arrowPoint1 = Offset(
      endX - arrowSize * cos(direction - pi / 6),
      endY - arrowSize * sin(direction - pi / 6),
    );
    final arrowPoint2 = Offset(
      endX - arrowSize * cos(direction + pi / 6),
      endY - arrowSize * sin(direction + pi / 6),
    );

    canvas.drawLine(Offset(endX, endY), arrowPoint1, paint);
    canvas.drawLine(Offset(endX, endY), arrowPoint2, paint);
  }

  @override
  bool shouldRepaint(covariant _RoadmapConnectorPainter oldDelegate) {
    return oldDelegate.fromLeft != fromLeft || oldDelegate.color != color;
  }
}
