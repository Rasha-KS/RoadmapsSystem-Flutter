import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/widgets/lesson_card_2.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_screen.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_screen.dart';
// Providers
import 'home_provider.dart';
import '../../announcements/presentation/announcements_provider.dart';
import '../../announcements/presentation/announcement_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final size = MediaQuery.of(context).size;
    final hasInitialLoading =
        homeProvider.state == HomeState.loading &&
        homeProvider.recommended.isEmpty &&
        homeProvider.myCourses.isEmpty;
    final hasInitialError =
        homeProvider.state == HomeState.connectionError &&
        homeProvider.recommended.isEmpty &&
        homeProvider.myCourses.isEmpty;

    if (hasInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (hasInitialError) {
      return _ErrorState(
        onRetry: () async {
          final announcementsProvider = context.read<AnnouncementsProvider>();
          await homeProvider.loadHome();
          await announcementsProvider.loadAnnouncements();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final messenger = ScaffoldMessenger.of(context);
        final announcementsProvider = context.read<AnnouncementsProvider>();
        await homeProvider.loadHome();
        await announcementsProvider.loadAnnouncements();
        if (homeProvider.state == HomeState.connectionError) {
          _showRefreshFailedSnackBar(messenger);
        }
      },
      color: AppColors.primary2,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 15),
            const AnnouncementWidget(),
            const SizedBox(height: 12),
            Divider(color: AppColors.secondary2, thickness: 1, height: 2),
            const SizedBox(height: 12),
            _sectionHeader(
              'المسارات المقترحة',
              context,

              onButtonPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoadmapsScreen()),
              ),
            ),
            const SizedBox(height: 3),
            _buildRecommendedSection(context, homeProvider),
            const SizedBox(height: 12),
            Divider(color: AppColors.secondary2, thickness: 1, height: 2),
            const SizedBox(height: 12),
            homeProvider.myCourses.isEmpty
                ? _buildEmptyState(size)
                : _sectionHeader('مساراتي', context),
            const SizedBox(height: 3),
            _buildMyCoursesList(context, homeProvider),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBetween = screenWidth * 0.10;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.01,
      ),
      child: Row(
        children: [
          if (onButtonPressed != null)
            MaterialButton(
              onPressed: onButtonPressed,
              elevation: 0,
              height: 30,
              minWidth: 88,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(23)),
              ),
              color: AppColors.accent_1,
              child: Text(
                'عرض الكل',
                style: AppTextStyles.boldSmallText.copyWith(
                  color: AppColors.text_4,
                ),
              ),
            ),
          if (onButtonPressed != null) SizedBox(width: spaceBetween),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading4.copyWith(color: AppColors.text_3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(
    BuildContext context,
    HomeProvider homeProvider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (final course in homeProvider.recommended)
            LessonCard2(
              course: course,
              widthMultiplier: 0.65,
              trimLength: 40,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LearningPathScreen(
                      roadmapId: course.id,
                      roadmapTitle: course.title,
                    ),
                  ),
                );
              },
              // onEnroll: () {
              //   homeProvider.enrollCourse(course.id);
              // },
            ),
        ],
      ),
    );
  }

  Widget _buildMyCoursesList(BuildContext context, HomeProvider homeProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (final course in homeProvider.myCourses)
            LessonCard1(
              course: course,
              widthMultiplier: 0.80,
              trimLength: 70,
              onDelete: () {
                showConfirmActionDialog(
                  context: context,
                  title: 'هل أنت متأكد من حذف المسار؟',
                  message: 'سوف يؤدي ذلك إلى إلغاء اشتراكك في المسار',
                  onConfirm: () async {
                    final learningPathProvider = context
                        .read<LearningPathProvider>();
                    await homeProvider.deleteCourse(course.id);
                    await learningPathProvider.resetProgress(
                      roadmapId: course.id,
                    );
                  },
                );
              },
              onRefresh: () {
                showConfirmActionDialog(
                  context: context,
                  title: 'هل أنت متأكد من إعادة المسار؟',
                  message: 'سوف يؤدي ذلك إلى إعادتك لنقطة البداية في المسار',
                  onConfirm: () async {
                    final learningPathProvider = context
                        .read<LearningPathProvider>();
                    await homeProvider.resetCourse(course.id);
                    await learningPathProvider.resetProgress(
                      roadmapId: course.id,
                    );
                  },
                );
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LearningPathScreen(
                      roadmapId: course.id,
                      roadmapTitle: course.title,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/roadmap_empty_homepage.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Text(
              'هل انت مستعد',
              textAlign: TextAlign.right,
              style: AppTextStyles.heading2_2.copyWith(color: AppColors.text_1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 35),
            child: Align(
              alignment: Alignment.centerRight,
              child: RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: AppTextStyles.heading2_2.copyWith(
                    color: AppColors.text_1,
                  ),
                  children: [
                    const TextSpan(text: 'لأن تسلك '),
                    TextSpan(
                      text: 'مسارك ',
                      style: TextStyle(color: AppColors.primary2),
                    ),
                    const TextSpan(text: 'الاول؟'),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                'تعذر تحميل الصفحة الرئيسية',
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
