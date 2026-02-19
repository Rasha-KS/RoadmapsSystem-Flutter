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

  Future<void> loadProfileData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (currentUserProvider.user == null) {
        await currentUserProvider.loadCurrentUser();
      }

      user = currentUserProvider.user;
      if (user == null) {
        roadmaps = [];
      } else {
        roadmaps = await getUserRoadmapsUseCase(user!.id);
      }
    } catch (_) {
      error = 'حدث خطأ أثناء تحميل بيانات الملف الشخصي';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> deleteRoadmap(int enrollmentId) async {
    await deleteUserRoadmapUseCase(enrollmentId);
    roadmaps = roadmaps
        .where((item) => item.enrollmentId != enrollmentId)
        .toList();
    notifyListeners();
  }

  Future<void> resetRoadmap(int enrollmentId) async {
    await resetUserRoadmapUseCase(enrollmentId);
    if (user != null) {
      roadmaps = await getUserRoadmapsUseCase(user!.id);
    }
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
