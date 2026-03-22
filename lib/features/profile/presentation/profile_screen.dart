import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/constants/ui_texts.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/confirm_action_dialog.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/utils/enrollment_sync.dart';
import 'package:roadmaps/core/utils/page_refresh.dart';
import 'package:roadmaps/features/homepage/domain/home_entity.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_screen.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import '../domain/user_roadmap_entity.dart';
import 'profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      refreshProfilePageData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _ProfileScreenBody();
  }
}

class _ProfileScreenBody extends StatelessWidget {
  const _ProfileScreenBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final hasInitialLoading =
        !provider.hasLoadedProfileData && !provider.lastLoadFailed;
    final hasInitialError =
        provider.lastLoadFailed && !provider.hasLoadedProfileData;

    if (hasInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (hasInitialError) {
      return _ErrorState(
        onRetry: () {
          refreshProfilePageData(context);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final messenger = ScaffoldMessenger.of(context);
        await refreshProfilePageData(context);
        if (provider.lastLoadFailed) {
          _showRefreshFailedSnackBar(
            messenger,
            message: provider.error ?? AppTexts.profileRefreshError,
          );
        }
      },
      color: AppColors.primary2,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          _buildHeader(
            username: provider.user?.username ?? '',
            profileImageUrl: provider.user?.profileImageUrl,
          ),
          const SizedBox(height: 10),
          Divider(color: AppColors.secondary1, thickness: 1),
          const SizedBox(height: 12),
          ...provider.roadmaps.map((roadmap) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _RoadmapSection(roadmap: roadmap),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required String username,
    required String? profileImageUrl,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 20, right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              username,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading4.copyWith(color: AppColors.text_1),
            ),
          ),

          const SizedBox(width: 30),

          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.accent_3,
            backgroundImage:
                (profileImageUrl != null && profileImageUrl.isNotEmpty)
                ? NetworkImage(profileImageUrl)
                : null,
            child: (profileImageUrl == null || profileImageUrl.isEmpty)
                ? Icon(Icons.person, color: AppColors.primary, size: 30)
                : null,
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
  final VoidCallback onRetry;

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
                AppTexts.profileLoadError,
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

class _RoadmapSection extends StatelessWidget {
  final UserRoadmapEntity roadmap;

  const _RoadmapSection({required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          LessonCard1(
          course: roadmap,
          widthMultiplier: 0.92,
          trimLength: 90,
          onDelete: () => showConfirmActionDialog(
            context: context,
            title: AppTexts.deleteConfirmTitle,
            message: AppTexts.deleteConfirmMessage,
              onConfirm: () async {
              try {
                final homeProvider = context.read<HomeProvider>();
                final roadmapsProvider = context.read<RoadmapsProvider>();
                final profileProvider = context.read<ProfileProvider>();
                await profileProvider.deleteRoadmap(
                  roadmap.enrollmentId,
                  updateState: false,
                );
                profileProvider.removeRoadmapByRoadmapId(roadmap.roadmapId);
                homeProvider.removeCourseById(
                  roadmap.roadmapId,
                  courseData: HomeCourseEntity(
                    id: roadmap.roadmapId,
                    title: roadmap.title,
                    level: roadmap.level,
                    description: roadmap.description,
                    status: roadmap.status,
                  ),
                );
                roadmapsProvider.setCourseEnrollment(roadmap.roadmapId, false);
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
                    label: 'ProfileScreen delete sync',
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                showActionSnackBar(
                  messenger,
                  message: AppTexts.deleteFailure,
                  isSuccess: false,
                );
              }
            },
          ),
          onRefresh: () => showConfirmActionDialog(
            context: context,
            title: AppTexts.resetConfirmTitle,
            message: AppTexts.resetConfirmMessage,
            onConfirm: () async {
              try {
                final homeProvider = context.read<HomeProvider>();
                final roadmapsProvider = context.read<RoadmapsProvider>();
                final profileProvider = context.read<ProfileProvider>();
                final learningPathProvider =
                    context.read<LearningPathProvider>();
                await profileProvider.resetRoadmap(
                  roadmap.enrollmentId,
                  updateState: false,
                );
                profileProvider.resetRoadmapByRoadmapId(roadmap.roadmapId);
                homeProvider.resetCourseById(roadmap.roadmapId);
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                showActionSnackBar(
                  messenger,
                  message: AppTexts.resetSuccess,
                  isSuccess: true,
                );

                unawaited(
                  retryUntilSuccess(
                    () async {
                      await learningPathProvider.resetProgress(
                        roadmapId: roadmap.roadmapId,
                        updateState: true,
                      );
                      await EnrollmentSync.refreshAll(
                        homeProvider: homeProvider,
                        roadmapsProvider: roadmapsProvider,
                        profileProvider: profileProvider,
                      );
                    },
                    label: 'ProfileScreen reset sync',
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                showActionSnackBar(
                  messenger,
                  message: AppTexts.resetFailure,
                  isSuccess: false,
                );
              }
            },
          ),
          onTap: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LearningPathScreen(
                  roadmapId: roadmap.roadmapId,
                  roadmapTitle: roadmap.title,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: _StatContainer(
                  backgroundColor: AppColors.accent_1,
                  text: 'نقاط الخبرة   ',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _StatContainer(
                  backgroundColor: AppColors.accent_3,
                  icon: Icons.av_timer_rounded,
                  text: '%نسبة التقدم  ',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: AppColors.secondary1, thickness: 1),
      ],
    );
  }
}

class _StatContainer extends StatelessWidget {
  final Color backgroundColor;
  final String text;
  final IconData icon;

  const _StatContainer({
    required this.backgroundColor,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary2, size: 21),

          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text_1,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
