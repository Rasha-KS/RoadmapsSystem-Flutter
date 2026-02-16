import 'package:flutter/material.dart';
import '../domain/delete_my_roadmap_usecase.dart';
import '../domain/enroll_roadmap_usecase.dart';
import '../domain/get_home_data_usecase.dart';
import '../domain/home_entity.dart';
import '../domain/reset_my_roadmap_usecase.dart';

enum HomeState { loading, loaded, connectionError }

class HomeProvider extends ChangeNotifier {
  final GetHomeDataUseCase getHomeDataUseCase;
  final DeleteMyCourseUseCase deleteMyCourseUseCase;
  final ResetMyCourseUseCase resetMyCourseUseCase;
  final EnrollCourseUseCase enrollCourseUseCase;

  HomeProvider({
    required this.getHomeDataUseCase,
    required this.deleteMyCourseUseCase,
    required this.resetMyCourseUseCase,
    required this.enrollCourseUseCase,
  });

  List<HomeCourseEntity> recommended = [];
  List<HomeCourseEntity> myCourses = [];
  HomeState state = HomeState.loading;

  Future<void> loadHome() async {
    state = HomeState.loading;
    notifyListeners();

    try {
      recommended = await getHomeDataUseCase.callRecommended();
      myCourses = await getHomeDataUseCase.callMyCourses();
      state = HomeState.loaded;
    } catch (_) {
      state = HomeState.connectionError;
    }

    notifyListeners();
  }

  Future<void> deleteCourse(int courseId) async {
    await deleteMyCourseUseCase(courseId);
    myCourses = myCourses.where((course) => course.id != courseId).toList();
    notifyListeners();
  }

  Future<void> resetCourse(int courseId) async {
    await resetMyCourseUseCase(courseId);
    myCourses = myCourses.map((course) {
      if (course.id != courseId) return course;
      return HomeCourseEntity(
        id: course.id,
        title: course.title,
        level: course.level,
        description: course.description,
        status: course.status,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> enrollCourse(int courseId) async {
    await enrollCourseUseCase(courseId);

    final index = recommended.indexWhere((course) => course.id == courseId);
    if (index == -1) return;

    final course = recommended.removeAt(index);
    final alreadyExists = myCourses.any((item) => item.id == course.id);
    if (!alreadyExists) {
      myCourses = [
        ...myCourses,
        HomeCourseEntity(
          id: course.id,
          title: course.title,
          level: course.level,
          description: course.description,
          status: course.status,
        ),
      ];
    }

    notifyListeners();
  }
}

