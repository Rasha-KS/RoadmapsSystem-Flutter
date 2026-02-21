import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/roadmap_node.dart';
import 'package:roadmaps/core/widgets/roadmap_progress.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/features/challenge/presentation/challenge_provider.dart';
import 'package:roadmaps/features/challenge/presentation/challenge_screen.dart';
import 'package:roadmaps/features/main_screen.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/lessons/presentation/lessons_screen.dart';

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
                    title: widget.roadmapTitle,
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
                                  .loadPath(widget.roadmapId);
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
          'لا توجد دروس.',
          style: AppTextStyles.body.copyWith(color: AppColors.text_1),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary2,
      onRefresh: () async {
        final messenger = ScaffoldMessenger.of(context);
        await provider.loadPath(widget.roadmapId, showLoader: false);
        if (provider.state == LearningPathState.connectionError) {
          _showRefreshFailedSnackBar(messenger);
        }
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: provider.units.length,
        itemBuilder: (context, index) {
          final unit = provider.units[index];
          final bool alignLeft = index.isEven;

          return Column(
            children: [
              Align(
                alignment: alignLeft
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: RoadmapNode(
                  unit: unit,
                  onTap: () => _onUnitTap(provider, unit),
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

  void _showRefreshFailedSnackBar(ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        content: Text(
          'تعذر التحديث بسبب انقطاع الاتصال بالشبكة',
          textAlign: TextAlign.right,
          style: AppTextStyles.body.copyWith(color: AppColors.text_2),
        ),
        backgroundColor: AppColors.backGroundError,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _onUnitTap(
    LearningPathProvider provider,
    LearningUnitEntity unit,
  ) async {
    if (unit.status == LearningUnitStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          content: Text(
            textAlign: TextAlign.right,
            'هدا الدرس مقفل اكمل الدرس السابق',
            style: AppTextStyles.body,
          ),
          backgroundColor: AppColors.backGroundError,
          duration: Duration(milliseconds: 1000),
        ),
      );
      return;
    }

    if (unit.type == LearningUnitType.challenge) {
      final challengeProvider = context.read<ChallengeProvider>();
      final challenge = await challengeProvider.getChallengeByLearningUnitId(
        unit.id,
      );

      if (!mounted) return;

      if (challenge == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            content: Text(
              textAlign: TextAlign.right,
              'لا يوجد تحدي مرتبط بهذه الوحدة حاليا',
              style: AppTextStyles.body,
            ),
            backgroundColor: AppColors.backGroundError,
            duration: Duration(milliseconds: 1200),
          ),
        );
        return;
      }

      if (provider.userXp < challenge.minXp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            content: Directionality(textDirection: TextDirection.rtl, 
            child: Text(
              textAlign: TextAlign.right,
              'XP الحالي: ${provider.userXp}, '
              'لفتح هذا التحدي يلزم ${challenge.minXp}',
              style: AppTextStyles.body,
            ),),
            backgroundColor: AppColors.backGroundError,
            duration: const Duration(milliseconds: 1500),
          ),
        );
        return;
      }

      final userId = context.read<CurrentUserProvider>().userId ?? 1;
      final ChallengeFinishAction? finishAction = await Navigator.of(context)
          .push<ChallengeFinishAction>(
            MaterialPageRoute(
              builder: (_) => ChallengeScreen(
                learningUnitId: unit.id,
                userId: userId,
                roadmapTitle: widget.roadmapTitle,
              ),
            ),
          );

      if (finishAction == null) return;

      await provider.completeUnit(unitId: unit.id, earnedXp: 0);
      if (!mounted) return;

      if (finishAction == ChallengeFinishAction.goHome) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
      return;
    }

    if (unit.type == LearningUnitType.lesson) {
      final bool? shouldComplete = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => LessonsScreen(
            learningUnitId: unit.id.toString(),
            roadmapTitle: widget.roadmapTitle,
          ),
        ),
      );

      if (shouldComplete != true) return;

      final int earnedXp = _earnedXpForUnit(unit.type);
      await provider.completeUnit(unitId: unit.id, earnedXp: earnedXp);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          content: Text(
            '${unit.title} completed. +$earnedXp XP',
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.text_5),
          ),
          backgroundColor: AppColors.backGroundSuccess,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    if (unit.status == LearningUnitStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          content: Text(
            textAlign: TextAlign.right,
            '.هدا الدرس مكتمل',
            style: AppTextStyles.body.copyWith(color: AppColors.text_5),
          ),
          duration: Duration(milliseconds: 1000),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final bool? shouldComplete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(unit.title),
          content: Text(
            'Open ${_unitTypeText(unit.type)} and mark it as completed?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('الغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary1,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('مكتمل'),
            ),
          ],
        );
      },
    );

    if (shouldComplete != true) return;

    final int earnedXp = _earnedXpForUnit(unit.type);
    await provider.completeUnit(unitId: unit.id, earnedXp: earnedXp);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        content: Text(
          textAlign: TextAlign.right,
          '${unit.title} مكتمل. +$earnedXp نقاط خبرة',
          style: AppTextStyles.body.copyWith(color: AppColors.text_5),
        ),
        backgroundColor: AppColors.backGroundSuccess,
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  String _unitTypeText(LearningUnitType type) {
    switch (type) {
      case LearningUnitType.lesson:
        return 'lesson';
      case LearningUnitType.quiz:
        return 'quiz';
      case LearningUnitType.challenge:
        return 'challenge';
    }
  }

  int _earnedXpForUnit(LearningUnitType type) {
    switch (type) {
      case LearningUnitType.lesson:
        return 20;
      case LearningUnitType.quiz:
        return 30;
      case LearningUnitType.challenge:
        return 50;
    }
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
                'تعذر تحميل المسار التعليمي',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.heading4.copyWith(color: AppColors.text_5),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.text_5,
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
