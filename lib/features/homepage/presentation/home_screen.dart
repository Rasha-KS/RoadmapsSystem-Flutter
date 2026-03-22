import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/ui_texts.dart';
import 'package:roadmaps/core/navigation/auth_guard.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/widgets/lesson_card_2.dart';
import 'package:roadmaps/core/utils/enrollment_sync.dart';
import 'package:roadmaps/core/utils/page_refresh.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_screen.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_screen.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';
// Providers
import '../domain/home_entity.dart';
import 'home_provider.dart';
import '../../announcements/presentation/announcement_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      refreshHomePageData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenBody();
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final size = MediaQuery.of(context).size;
    final hasInitialLoading =
        !homeProvider.hasLoadedHomeData && !homeProvider.lastLoadFailed;
    final hasInitialError =
        homeProvider.lastLoadFailed && !homeProvider.hasLoadedHomeData;

    if (hasInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }
    if (hasInitialError) {
      return _ErrorState(
        message: homeProvider.errorMessage ?? AppTexts.homeLoadError,
        onRetry: () async {
          await refreshHomePageData(context);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final messenger = ScaffoldMessenger.of(context);
        await refreshHomePageData(context);
        if (homeProvider.lastLoadFailed) {
          _showRefreshFailedSnackBar(
            messenger,
            message: homeProvider.errorMessage ?? AppTexts.homeRefreshError,
          );
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
              AppTexts.homeRecommended,
              context,

              onButtonPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthGuard(
                    child: const RoadmapsScreen(),
                    unauthenticatedBuilder: (_) => const LoginScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            _buildRecommendedSection(context, homeProvider),
            const SizedBox(height: 12),
            Divider(color: AppColors.secondary2, thickness: 1, height: 2),
            const SizedBox(height: 12),
            homeProvider.myCourses.isEmpty
                ? _buildEmptyState(size)
                : _sectionHeader(AppTexts.homeMyRoadmaps, context),
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
                AppTexts.showAll,
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
              onTap: () async {
                await _openRoadmap(context, homeProvider, course);
              },
              onEnroll: () async {
                final profileProvider = context.read<ProfileProvider>();
                final roadmapsProvider = context.read<RoadmapsProvider>();
                await homeProvider.enrollCourse(
                  course.id,
                  updateState: true,
                );
                roadmapsProvider.setCourseEnrollment(course.id, true);
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                showActionSnackBar(
                  messenger,
                  message: AppTexts.enrollSuccess,
                  isSuccess: true,
                );

                unawaited(
                  retryUntilSuccess(
                    () => EnrollmentSync.refreshAll(
                      homeProvider: homeProvider,
                      roadmapsProvider: roadmapsProvider,
                      profileProvider: profileProvider,
                    ),
                    label: 'HomeScreen enroll sync',
                  ),
                );
              },
             
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
              onDelete: () async {
                await showConfirmActionDialog(
                  context: context,
                  title: AppTexts.deleteConfirmTitle,
                  message: AppTexts.deleteConfirmMessage,
                  onConfirm: () async {
                    try {
                      final profileProvider = context.read<ProfileProvider>();
                      final roadmapsProvider = context.read<RoadmapsProvider>();
                      final learningPathProvider = context
                          .read<LearningPathProvider>();
                      await homeProvider.deleteCourse(
                        course.id,
                        courseData: course,
                        updateState: false,
                      );
                      await learningPathProvider.resetProgress(
                        roadmapId: course.id,
                        updateState: false,
                      );
                      homeProvider.removeCourseById(
                        course.id,
                        courseData: course,
                      );
                      roadmapsProvider.setCourseEnrollment(course.id, false);
                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      showActionSnackBar(
                        messenger,
                        message: AppTexts.deleteSuccess,
                        isSuccess: true,
                      );

                      unawaited(
                        retryUntilSuccess(
                          () => EnrollmentSync.refreshAll(
                            homeProvider: homeProvider,
                            roadmapsProvider: roadmapsProvider,
                            profileProvider: profileProvider,
                          ),
                          label: 'HomeScreen delete sync',
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      showActionSnackBar(
                        messenger,
                        message: e is ApiException
                            ? e.message
                            : AppTexts.deleteFailure,
                        isSuccess: false,
                      );
                    }
                  },
                );
              },
              onRefresh: () async {
                await showConfirmActionDialog(
                  context: context,
                  title: AppTexts.resetConfirmTitle,
                  message: AppTexts.resetConfirmMessage,
                  onConfirm: () async {
                    try {
                      final profileProvider = context.read<ProfileProvider>();
                      final roadmapsProvider = context.read<RoadmapsProvider>();
                      final learningPathProvider = context
                          .read<LearningPathProvider>();
                      await homeProvider.resetCourse(
                        course.id,
                        updateState: false,
                      );
                      await learningPathProvider.resetProgress(
                        roadmapId: course.id,
                        updateState: false,
                      );
                      homeProvider.resetCourseById(course.id);
                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      showActionSnackBar(
                        messenger,
                        message: AppTexts.resetSuccess,
                        isSuccess: true,
                      );

                      unawaited(
                        retryUntilSuccess(
                          () => EnrollmentSync.refreshAll(
                            homeProvider: homeProvider,
                            roadmapsProvider: roadmapsProvider,
                            profileProvider: profileProvider,
                          ),
                          label: 'HomeScreen reset sync',
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      showActionSnackBar(
                        messenger,
                        message: e is ApiException
                            ? e.message
                            : AppTexts.resetFailure,
                        isSuccess: false,
                      );
                    }
                  },
                );
              },
              onTap: () async {
                await _openRoadmap(context, homeProvider, course);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _openRoadmap(
    BuildContext context,
    HomeProvider homeProvider,
    HomeCourseEntity course,
  ) async {
    HomeCourseEntity details = course;
    try {
      details = await homeProvider.fetchRoadmapDetails(course.id);
    } catch (_) {}

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearningPathScreen(
          roadmapId: course.id,
          roadmapTitle: details.title,
        ),
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
              AppTexts.emptyHomeTitle,
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
                    const TextSpan(text: 'الأول؟'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefreshFailedSnackBar(
    ScaffoldMessengerState messenger, {
    required String message,
  }) {
    messenger.showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        content: Text(
          message,
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
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
                message,
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
                AppTexts.retry,
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
