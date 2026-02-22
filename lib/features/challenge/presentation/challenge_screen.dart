import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/app_primary_button.dart';
import 'package:roadmaps/features/challenge/presentation/challenge_provider.dart';
import 'package:roadmaps/features/main_screen.dart';

enum ChallengeFinishAction { goHome, backToLearningPath }

class ChallengeScreen extends StatefulWidget {
  final int learningUnitId;
  final int userId;
  final String roadmapTitle;

  const ChallengeScreen({
    super.key,
    required this.learningUnitId,
    required this.userId,
    required this.roadmapTitle,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<ChallengeProvider>().loadChallenge(
        widget.learningUnitId,
        forceRefresh: true,
      );
      if (!mounted) return;

      final challenge = context.read<ChallengeProvider>().challenge;
      if (challenge != null) {
        _codeController.text = challenge.starterCode;
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final hasInitialLoading =
        provider.state == ChallengeScreenState.loading &&
        provider.challenge == null;
    final hasInitialError =
        provider.state == ChallengeScreenState.error &&
        provider.challenge == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.only(left: 15, top: 30, right: 14),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              elevation: 0,
              titleSpacing: 16,
              title: Text(
                provider.challenge?.language ?? widget.roadmapTitle,
                style: AppTextStyles.heading4.copyWith(color: AppColors.text_3),
              ),
              actions: [
                IconButton(
                  onPressed: _handleBackPressed,
                  icon: const Icon(
                    Icons.arrow_right_alt_outlined,
                    color: AppColors.text_3,
                    size: 35,
                  ),
                  padding: EdgeInsets.only(bottom: 5),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 20, 35, 25),
                child: hasInitialLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary2,
                        ),
                      )
                    : hasInitialError
                    ? _ErrorState(
                        onRetry: () async {
                          await context.read<ChallengeProvider>().loadChallenge(
                            widget.learningUnitId,
                            forceRefresh: true,
                          );
                        },
                      )
                    : _buildBody(provider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ChallengeProvider provider) {
    final challenge = provider.challenge;
    if (challenge == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double editorHeight = (constraints.maxHeight - 210).clamp(
          230.0,
          465.0,
        );

        return RefreshIndicator(
          color: AppColors.primary2,
          onRefresh: () async {
            final messenger = ScaffoldMessenger.of(context);
            await context.read<ChallengeProvider>().loadChallenge(
              widget.learningUnitId,
              forceRefresh: true,
              keepLocalData: true,
            );
            if (provider.state == ChallengeScreenState.error) {
              _showRefreshFailedSnackBar(messenger);
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              _ChallengeDescriptionCard(
                title: challenge.title,
                description: challenge.description,
                expanded: provider.isDescriptionExpanded,
                onToggle: () {
                  context.read<ChallengeProvider>().toggleDescription();
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: editorHeight,
                child: _CodeEditorCard(
                  controller: _codeController,
                  runState: provider.runState,
                  runOutput: provider.lastRunResult?.executionOutput,
                  onCodeChanged: (value) {
                    context.read<ChallengeProvider>().updateUserCode(value);
                  },
                  onRunPressed: provider.runState == ChallengeRunState.running
                      ? null
                      : () {
                          context.read<ChallengeProvider>().runCode(
                            challengeId: challenge.id,
                            userId: widget.userId,
                          );
                        },
                ),
              ),
              const SizedBox(height: 15),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 40),
                child: AppPrimaryButton(
                  text: 'إنتهاء',
                  onPressed: provider.canFinish
                      ? () => _onFinish(provider)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
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
          style: AppTextStyles.heading5.copyWith(color: AppColors.text_2),
        ),
        backgroundColor: AppColors.backGroundError,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _onFinish(ChallengeProvider provider) async {
    if (!provider.canFinish) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'نفذ الكود بنجاح قبل إنهاء التحدي',
            textAlign: TextAlign.right,
            style: AppTextStyles.heading5.copyWith(color: AppColors.text_2),
          ),
          backgroundColor: AppColors.backGroundError,
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    final ChallengeFinishAction? action =
        await showDialog<ChallengeFinishAction>(
          context: context,
          builder: (dialogContext) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Dialog(
                backgroundColor: AppColors.primary1.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 25,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تهانينا !',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لقد اكملت المسار',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.text_2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.secondary4,
                                side: BorderSide.none,
                              ),
                              onPressed: () => Navigator.of(
                                dialogContext,
                              ).pop(ChallengeFinishAction.goHome),
                              child: Text(
                                'الرئيسية',
                                style: AppTextStyles.boldSmallText.copyWith(
                                  color: AppColors.text_3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 22),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.secondary4,
                                side: BorderSide.none,
                              ),
                              onPressed: () => Navigator.of(
                                dialogContext,
                              ).pop(ChallengeFinishAction.backToLearningPath),
                              child: Text(
                                'المسار',
                                style: AppTextStyles.boldSmallText.copyWith(
                                  color: AppColors.text_3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );

    if (!mounted || action == null) return;
    _closeChallengeScreen(action: action);
  }

  void _handleBackPressed() {
    _closeChallengeScreen();
  }

  void _closeChallengeScreen({ChallengeFinishAction? action}) {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop(action);
        return;
      }

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    });
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
                'تعذر تحميل التحدي',
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

class _ChallengeDescriptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool expanded;
  final VoidCallback onToggle;

  const _ChallengeDescriptionCard({
    required this.title,
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accent_3,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading4.copyWith(color: AppColors.text_1),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.code, color: AppColors.text_1, size: 25),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.right,
            maxLines: expanded ? null : 3,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(color: AppColors.text_3),
          ),
          const SizedBox(height: 3),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              expanded ? 'اقل' : 'المزيد...',
              style: AppTextStyles.boldSmallText.copyWith(
                color: AppColors.primary2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeEditorCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback? onRunPressed;
  final ChallengeRunState runState;
  final String? runOutput;

  const _CodeEditorCard({
    required this.controller,
    required this.onCodeChanged,
    required this.onRunPressed,
    required this.runState,
    required this.runOutput,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFailure = runState == ChallengeRunState.failure;
    final bool isSuccess = runState == ChallengeRunState.success;
    final String? errorHeader = isFailure && (runOutput?.isNotEmpty ?? false)
        ? runOutput!.split('\n').first
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(color: AppColors.primary2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: TextField(
              controller: controller,
              onChanged: onCodeChanged,
              expands: true,
              maxLines: null,
              minLines: null,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text_2,
                height: 1.4,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                  16,
                  isFailure ? 44 : 14,
                  16,
                  54,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (errorHeader != null)
            Positioned(
              left: 16,
              top: 20,
              child: Text(
                errorHeader,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Positioned(
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 35,
              width: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary4,
                  foregroundColor: AppColors.text_3,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: onRunPressed,
                child: Text(
                  runState == ChallengeRunState.running
                      ? 'جاري التنفيذ'
                      : 'تنفيذ',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          if (runState == ChallengeRunState.success ||
              runState == ChallengeRunState.failure)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: runState == ChallengeRunState.success
                      ? AppColors.backGroundSuccess
                      : AppColors.backGroundError,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isSuccess ? 'تم التنفيذ بنجاح' : 'هناك خطأ في الكود',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading5.copyWith(
                          color: isSuccess
                              ? AppColors.text_3
                              : AppColors.text_2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSuccess
                          ? Icons.check_circle_outline_rounded
                          : Icons.highlight_off_rounded,
                      color: isSuccess ? AppColors.text_3 : AppColors.text_2,
                      size: 35,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
