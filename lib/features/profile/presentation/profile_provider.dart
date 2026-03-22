import 'package:flutter/material.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import '../domain/delete_user_roadmap_usecase.dart';
import '../domain/get_user_roadmaps_usecase.dart';
import '../domain/reset_user_roadmap_usecase.dart';
import '../domain/user_roadmap_entity.dart';

class ProfileProvider extends ChangeNotifier {
  final GetUserRoadmapsUseCase getUserRoadmapsUseCase;
  final DeleteUserRoadmapUseCase deleteUserRoadmapUseCase;
  final ResetUserRoadmapUseCase resetUserRoadmapUseCase;
  final CurrentUserProvider currentUserProvider;

  ProfileProvider({
    required this.getUserRoadmapsUseCase,
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

  Future<void> loadProfileData() async {
    loading = true;
    error = null;
    lastLoadFailed = false;
    notifyListeners();

    try {
      UserEntity? loadedUser;
      List<UserRoadmapEntity> loadedRoadmaps = [];

      if (currentUserProvider.user == null) {
        await currentUserProvider.loadCurrentUser();
      }

      loadedUser = currentUserProvider.user;
      if (loadedUser == null) {
        loadedRoadmaps = [];
      } else {
        loadedRoadmaps = await getUserRoadmapsUseCase(loadedUser.id);
      }

      user = loadedUser;
      roadmaps = loadedRoadmaps;
      hasLoadedProfileData = true;
      lastLoadFailed = false;
    } catch (_) {
      error = 'حدث خطأ أثناء تحميل بيانات الملف الشخصي';
      lastLoadFailed = true;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> deleteRoadmap(
    int enrollmentId, {
    bool updateState = true,
  }) async {
    await deleteUserRoadmapUseCase(enrollmentId);
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
