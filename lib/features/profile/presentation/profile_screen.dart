import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/constants/ui_texts.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/lesson_card_1.dart';
import 'package:roadmaps/core/utils/enrollment_sync.dart';
import 'package:roadmaps/core/utils/page_refresh.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await refreshProfilePageData(context);
      if (!mounted) return;

      final provider = context.read<ProfileProvider>();
      if (provider.lastLoadFailed) {
        showAppSnackBar(
          ScaffoldMessenger.of(context),
          message: provider.error ?? AppTexts.profileRefreshError,
          variant: SnackBarVariant.error,
          duration: const Duration(milliseconds: 1000),
        );
      }
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
    final currentUserProvider = context.watch<CurrentUserProvider>();
    final effectiveUser = currentUserProvider.user ?? provider.user;
    final hasInitialLoading =
        !provider.hasLoadedProfileData &&
        !provider.lastLoadFailed &&
        effectiveUser == null;
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
            username: effectiveUser?.username ?? '',
            profileImageUrl: effectiveUser?.profileImageUrl,
            profileImageUpdatedAt: effectiveUser?.updatedAt,
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
    required DateTime? profileImageUpdatedAt,
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

          _ProfileAvatar(
            imageUrl: profileImageUrl,
            updatedAt: profileImageUpdatedAt,
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

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar({required this.imageUrl, required this.updatedAt});

  final String? imageUrl;
  final DateTime? updatedAt;

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  static const double _avatarSize = 80;

  late List<String> _candidateUrls;
  var _activeCandidateIndex = 0;
  bool _switchScheduled = false;

  @override
  void initState() {
    super.initState();
    _resetCandidates();
  }

  @override
  void didUpdateWidget(covariant _ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.updatedAt != widget.updatedAt) {
      _resetCandidates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: const BoxDecoration(
        color: AppColors.accent_3,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: _candidateUrls.isEmpty
            ? _buildFallback()
            : Image.network(
                _candidateUrls[_activeCandidateIndex],
                key: ValueKey(_candidateUrls[_activeCandidateIndex]),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  _tryNextCandidate();
                  return _buildFallback();
                },
              ),
      ),
    );
  }

  Widget _buildFallback() {
    return const Center(
      child: Icon(Icons.person, color: AppColors.primary, size: 30),
    );
  }

  void _resetCandidates() {
    _candidateUrls = _buildCandidateUrls(
      widget.imageUrl,
      updatedAt: widget.updatedAt,
    );
    _activeCandidateIndex = 0;
    _switchScheduled = false;
  }

  void _tryNextCandidate() {
    if (_switchScheduled ||
        _activeCandidateIndex >= _candidateUrls.length - 1) {
      return;
    }

    _switchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _activeCandidateIndex++;
        _switchScheduled = false;
      });
    });
  }

  List<String> _buildCandidateUrls(
    String? imageUrl, {
    required DateTime? updatedAt,
  }) {
    final normalizedUrl = _appendCacheVersion(imageUrl, updatedAt: updatedAt);
    if (normalizedUrl == null) {
      return const <String>[];
    }

    final candidates = <String>[normalizedUrl];
    final parsed = Uri.tryParse(normalizedUrl);
    if (parsed == null) {
      return candidates;
    }

    final path = parsed.path;
    final isProfilePicturePath = path.contains('/profile_pictures/');
    final alreadyStoragePath = path.startsWith('/storage/');
    if (!isProfilePicturePath || alreadyStoragePath) {
      return candidates;
    }

    final alternateUri = parsed.replace(path: '/storage$path');
    final alternateUrl = alternateUri.toString();
    if (!candidates.contains(alternateUrl)) {
      candidates.add(alternateUrl);
    }
    return candidates;
  }

  String? _appendCacheVersion(
    String? imageUrl, {
    required DateTime? updatedAt,
  }) {
    final trimmedUrl = imageUrl?.trim();
    if (trimmedUrl == null || trimmedUrl.isEmpty) {
      return null;
    }

    if (updatedAt == null) {
      return trimmedUrl;
    }

    final parsed = Uri.tryParse(trimmedUrl);
    if (parsed == null) {
      return trimmedUrl;
    }

    final queryParameters = <String, String>{
      ...parsed.queryParameters,
      'v': updatedAt.toUtc().millisecondsSinceEpoch.toString(),
    };
    return parsed.replace(queryParameters: queryParameters).toString();
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
          onDelete: () async {
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
          onRefresh: () async {
            try {
              final homeProvider = context.read<HomeProvider>();
              final roadmapsProvider = context.read<RoadmapsProvider>();
              final profileProvider = context.read<ProfileProvider>();
              final learningPathProvider = context.read<LearningPathProvider>();
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
                retryUntilSuccess(() async {
                  await learningPathProvider.resetProgress(
                    roadmapId: roadmap.roadmapId,
                    updateState: true,
                  );
                  await EnrollmentSync.refreshAll(
                    homeProvider: homeProvider,
                    roadmapsProvider: roadmapsProvider,
                    profileProvider: profileProvider,
                  );
                }, label: 'ProfileScreen reset sync'),
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
                  label: 'نقاط الخبرة',
                  text: roadmap.xpPoints.toString(),
                  icon: Icons.local_fire_department_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _StatContainer(
                  backgroundColor: AppColors.accent_3,
                  label: 'نسبة التقدم',
                  icon: Icons.av_timer_rounded,
                  text: '${roadmap.progressPercentage}%',
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
  final String label;
  final String text;
  final IconData icon;

  const _StatContainer({
    required this.backgroundColor,
    required this.label,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary2, size: 21),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text_1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.text_1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

