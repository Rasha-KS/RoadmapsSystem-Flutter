import 'package:flutter/material.dart';
import '../domain/delete_user_roadmap_usecase.dart';
import '../domain/get_user_profile_usecase.dart';
import '../domain/get_user_roadmaps_usecase.dart';
import '../domain/profile_user_entity.dart';
import '../domain/reset_user_roadmap_usecase.dart';
import '../domain/user_roadmap_entity.dart';

class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetUserRoadmapsUseCase getUserRoadmapsUseCase;
  final DeleteUserRoadmapUseCase deleteUserRoadmapUseCase;
  final ResetUserRoadmapUseCase resetUserRoadmapUseCase;

  ProfileProvider({
    required this.getUserProfileUseCase,
    required this.getUserRoadmapsUseCase,
    required this.deleteUserRoadmapUseCase,
    required this.resetUserRoadmapUseCase,
  });

  ProfileUserEntity? user;
  List<UserRoadmapEntity> roadmaps = [];
  bool loading = false;
  String? error;

  Future<void> loadProfileData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      user = await getUserProfileUseCase();
      roadmaps = await getUserRoadmapsUseCase();
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
    roadmaps = await getUserRoadmapsUseCase();
    notifyListeners();
  }
}
