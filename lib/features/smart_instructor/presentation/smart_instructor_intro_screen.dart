import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';

class SmartInstructorIntroScreen extends StatelessWidget {
  const SmartInstructorIntroScreen({super.key, required this.onStartPressed});

  final Future<void> Function() onStartPressed;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartInstructorProvider>();
    final hasInitialLoading = provider.introLoading && provider.intro == null;
    final hasInitialError =
        provider.introError != null && provider.intro == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: hasInitialLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary2),
            )
          : hasInitialError
          ? _ErrorState(
              onRetry: () {
                context.read<SmartInstructorProvider>().loadIntro();
              },
            )
          : RefreshIndicator(
              onRefresh: () async {
                final messenger = ScaffoldMessenger.of(context);
                await context.read<SmartInstructorProvider>().loadIntro();
                if (provider.introError != null) {
                  _showRefreshFailedSnackBar(messenger);
                }
              },
              color: AppColors.primary2,
              child: _IntroContent(onStartPressed: onStartPressed),
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
}

class _IntroContent extends StatelessWidget {
  const _IntroContent({required this.onStartPressed});

  final Future<void> Function() onStartPressed;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartInstructorProvider>();
    final intro = provider.intro;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              Text(
                intro?.title ?? 'مرحبا بك في المساعد الذكي',
                style: AppTextStyles.heading3.copyWith(color: AppColors.text_3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                intro?.subtitle ?? 'كيف يمكنني مساعدتك؟',
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.text_1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage("assets/images/cat.jpg"),
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: 220 ,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.introLoading
                      ? null
                      : () async {
                          await onStartPressed();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary2,
                    foregroundColor: AppColors.text_1,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    intro?.ctaLabel ?? 'هيا لنبدأ',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.text_3                 ),
                  ),
                ),
              ),
              const SizedBox(height: 55),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تعذر تحميل شاشة المساعد الذكي',
              style: AppTextStyles.heading5.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
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
