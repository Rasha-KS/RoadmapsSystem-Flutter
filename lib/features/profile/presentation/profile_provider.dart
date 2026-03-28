import 'dart:math' as math;
import 'dart:async';

import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/cache/lesson_content_cache.dart';
import 'package:roadmaps/core/cache/user_profile_cache.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import 'package:roadmaps/features/learning_path/domain/get_learning_path_usecase.dart';
import '../domain/delete_user_roadmap_usecase.dart';
import '../domain/get_user_roadmaps_usecase.dart';
import '../domain/reset_user_roadmap_usecase.dart';
import '../domain/user_roadmap_entity.dart';

class ProfileProvider extends SafeChangeNotifier {
  final GetUserRoadmapsUseCase getUserRoadmapsUseCase;
  final GetLearningPathUseCase getLearningPathUseCase;
  final DeleteUserRoadmapUseCase deleteUserRoadmapUseCase;
  final ResetUserRoadmapUseCase resetUserRoadmapUseCase;
  final CurrentUserProvider currentUserProvider;
  final LessonContentCache _lessonContentCache = LessonContentCache.instance;
  final UserProfileCache _userProfileCache = UserProfileCache.instance;

  ProfileProvider({
    required this.getUserRoadmapsUseCase,
    required this.getLearningPathUseCase,
    required this.deleteUserRoadmapUseCase,
    required this.resetUserRoadmapUseCase,
    required this.currentUserProvider,
  }) {
    currentUserProvider.addListener(_onCurrentUserChanged);
  }

  UserEntity? user;
  List<UserRoadmapEntity> roadmaps = [];
  bool loading = false;
  String? error;
  bool hasLoadedProfileData = false;
  bool lastLoadFailed = false;

  int getRoadmapXp(int roadmapId) {
    for (final roadmap in roadmaps) {
      if (roadmap.roadmapId == roadmapId) {
        return roadmap.xpPoints;
      }
    }
    return 0;
  }

  Future<void> loadProfileData() async {
    loading = true;
    error = null;
    lastLoadFailed = false;
    notifyListeners();

    try {
      final cachedUser = currentUserProvider.user ??
          await _userProfileCache.readCurrentUser();

      if (cachedUser != null) {
        user = cachedUser;
        currentUserProvider.setUser(cachedUser);
        hasLoadedProfileData = true;
      }

      await _syncProfileData();
    } catch (e) {
      error = _friendlyError(e);
      lastLoadFailed = true;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _syncProfileData() async {
    if (currentUserProvider.user == null) {
      await currentUserProvider.loadCurrentUser();
    }

    final loadedUser = currentUserProvider.user;
    final loadedRoadmaps = loadedUser == null
        ? <UserRoadmapEntity>[]
        : await getUserRoadmapsUseCase(loadedUser.id);
    final roadmapsLoadError =
        getUserRoadmapsUseCase.repository.lastRoadmapsLoadErrorMessage;

    user = loadedUser;
    final computedRoadmaps = await _applyComputedProgress(loadedRoadmaps);
    roadmaps = computedRoadmaps;
    hasLoadedProfileData = true;
    lastLoadFailed = roadmapsLoadError != null;
    error = roadmapsLoadError;
    notifyListeners();
  }

  Future<List<UserRoadmapEntity>> _applyComputedProgress(
    List<UserRoadmapEntity> loadedRoadmaps,
  ) async {
    if (loadedRoadmaps.isEmpty) return loadedRoadmaps;

    final updatedRoadmaps = await Future.wait(
      loadedRoadmaps.map((roadmap) async {
        try {
          final learningPath = await getLearningPathUseCase(
            roadmapId: roadmap.roadmapId,
          );
          final units = learningPath.units;
          final int completedCount =
              units.where((unit) => unit.isCompleted).length;
          final int computedProgress = units.isEmpty
              ? 0
              : ((completedCount / units.length) * 100).round();
          final cachedProgress = await _lessonContentCache.readRoadmapProgress(
            roadmap.roadmapId,
          );
          final effectiveProgress = cachedProgress == null
              ? computedProgress
              : math.max(computedProgress, cachedProgress);

          if (effectiveProgress == roadmap.progressPercentage) {
            return roadmap;
          }

          return roadmap.copyWith(progressPercentage: effectiveProgress);
        } catch (_) {
          final cachedProgress = await _lessonContentCache.readRoadmapProgress(
            roadmap.roadmapId,
          );
          if (cachedProgress != null &&
              cachedProgress != roadmap.progressPercentage) {
            return roadmap.copyWith(progressPercentage: cachedProgress);
          }
          return roadmap;
        }
      }),
    );

    return updatedRoadmaps;
  }

  String _friendlyError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تحميل الملف الشخصي وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'حدث خطأ أثناء تحميل بيانات الملف الشخصي.';
  }

  void updateRoadmapProgress({
    required int roadmapId,
    required int progressPercentage,
  }) {
    final currentIndex =
        roadmaps.indexWhere((roadmap) => roadmap.roadmapId == roadmapId);
    if (currentIndex == -1) {
      return;
    }

    final current = roadmaps[currentIndex];
    final updated = current.copyWith(
      progressPercentage: progressPercentage.clamp(0, 100),
    );

    if (updated.progressPercentage == current.progressPercentage) {
      return;
    }

    roadmaps = [
      ...roadmaps.sublist(0, currentIndex),
      updated,
      ...roadmaps.sublist(currentIndex + 1),
    ];
    unawaited(
      _lessonContentCache.writeRoadmapProgress(
        roadmapId,
        updated.progressPercentage,
      ),
    );
    notifyListeners();
  }

  Future<void> deleteRoadmap(
    int enrollmentId, {
    bool updateState = true,
  }) async {
    await deleteUserRoadmapUseCase(enrollmentId);
    await _lessonContentCache.clearAll();
    if (!updateState) return;
    roadmaps = roadmaps
        .where((roadmap) => roadmap.enrollmentId != enrollmentId)
        .toList();
    notifyListeners();
  }

  Future<void> resetRoadmap(
    int enrollmentId, {
    bool updateState = true,
  }) async {
    await resetUserRoadmapUseCase(enrollmentId);
    await _lessonContentCache.clearAll();
    if (!updateState) return;
    roadmaps = roadmaps.map((roadmap) {
      if (roadmap.enrollmentId != enrollmentId) {
        return roadmap;
      }
      return roadmap.copyWith(
        completedAt: null,
        xpPoints: 0,
        progressPercentage: 0,
        status: 'active',
      );
    }).toList();
    notifyListeners();
  }

  void removeRoadmapByRoadmapId(int roadmapId) {
    final updatedRoadmaps =
        roadmaps.where((roadmap) => roadmap.roadmapId != roadmapId).toList();

    if (updatedRoadmaps.length == roadmaps.length) {
      return;
    }
    roadmaps = updatedRoadmaps;
    notifyListeners();
  }

  void resetRoadmapByRoadmapId(int roadmapId) {
    roadmaps = roadmaps.map((roadmap) {
      if (roadmap.roadmapId != roadmapId) {
        return roadmap;
      }
      return roadmap.copyWith(
        completedAt: null,
        xpPoints: 0,
        progressPercentage: 0,
        status: 'active',
      );
    }).toList();
    notifyListeners();
  }

  void _onCurrentUserChanged() {
    user = currentUserProvider.user;
    notifyListeners();
  }

  @override
  void dispose() {
    currentUserProvider.removeListener(_onCurrentUserChanged);
    super.dispose();
  }
}
