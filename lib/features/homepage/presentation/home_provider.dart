import 'package:flutter/material.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import '../domain/delete_my_roadmap_usecase.dart';
import '../domain/enroll_roadmap_usecase.dart';
import '../domain/get_home_data_usecase.dart';
import '../domain/get_roadmap_details_usecase.dart';
import '../domain/home_entity.dart';
import '../domain/reset_my_roadmap_usecase.dart';

enum HomeState { loading, loaded, connectionError }

class HomeProvider extends SafeChangeNotifier {
  final GetHomeDataUseCase getHomeDataUseCase;
  final GetRoadmapDetailsUseCase getRoadmapDetailsUseCase;
  final DeleteMyCourseUseCase deleteMyCourseUseCase;
  final ResetMyCourseUseCase resetMyCourseUseCase;
  final EnrollCourseUseCase enrollCourseUseCase;

  HomeProvider({
    required this.getHomeDataUseCase,
    required this.getRoadmapDetailsUseCase,
    required this.deleteMyCourseUseCase,
    required this.resetMyCourseUseCase,
    required this.enrollCourseUseCase,
  });

  List<HomeCourseEntity> recommended = [];
  List<HomeCourseEntity> myCourses = [];
  HomeState state = HomeState.loading;
  String? errorMessage;
  bool hasLoadedHomeData = false;
  bool lastLoadFailed = false;

  Future<void> loadHome() async {
    state = HomeState.loading;
    errorMessage = null;
    lastLoadFailed = false;
    notifyListeners();

    final hadCachedData = hasLoadedHomeData;
    var hadError = false;

    try {
      recommended = await getHomeDataUseCase.callRecommended();
    } catch (error, stackTrace) {
      hadError = true;
      debugPrint('HomeProvider.loadHome recommended failed: $error');
      debugPrint(stackTrace.toString());
      errorMessage ??= _friendlyLoadError(error);
    }

    try {
      myCourses = await getHomeDataUseCase.callMyCourses();
    } catch (error, stackTrace) {
      hadError = true;
      debugPrint('HomeProvider.loadHome myCourses failed: $error');
      debugPrint(stackTrace.toString());
      errorMessage ??= _friendlyLoadError(error);
    }

    if (hadError && !hadCachedData) {
      state = HomeState.connectionError;
      lastLoadFailed = true;
      errorMessage ??= 'تعذر تحميل بيانات الصفحة الرئيسية. حاول مرة أخرى.';
    } else {
      state = HomeState.loaded;
      if (!hadError) {
        hasLoadedHomeData = true;
      }
    }

    if (hadError) {
      lastLoadFailed = true;
    }

    notifyListeners();
  }

  Future<void> deleteCourse(
    int courseId, {
    HomeCourseEntity? courseData,
    bool updateState = true,
  }) async {
    await deleteMyCourseUseCase(courseId);
    if (!updateState) return;
    myCourses = myCourses.where((course) => course.id != courseId).toList();
    if (courseData != null &&
        !recommended.any((course) => course.id == courseData.id)) {
      recommended = [...recommended, courseData];
    }
    notifyListeners();
  }

  void removeCourseById(
    int courseId, {
    HomeCourseEntity? courseData,
  }) {
    myCourses = myCourses.where((course) => course.id != courseId).toList();
    if (courseData != null &&
        !recommended.any((course) => course.id == courseData.id)) {
      recommended = [...recommended, courseData];
    }
    notifyListeners();
  }

  void resetCourseById(int courseId) {
    myCourses = myCourses.map((course) {
      if (course.id != courseId) return course;
      return HomeCourseEntity(
        id: course.id,
        title: course.title,
        level: course.level,
        description: course.description,
        status: 'active',
      );
    }).toList();
    notifyListeners();
  }

  Future<void> resetCourse(
    int courseId, {
    bool updateState = true,
  }) async {
    await resetMyCourseUseCase(courseId);
    if (!updateState) return;
    myCourses = myCourses.map((course) {
      if (course.id != courseId) return course;
      return HomeCourseEntity(
        id: course.id,
        title: course.title,
        level: course.level,
        description: course.description,
        status: 'active',
      );
    }).toList();
    notifyListeners();
  }

  Future<void> enrollCourse(
    int courseId, {
    HomeCourseEntity? courseData,
    bool updateState = true,
  }) async {
    await enrollCourseUseCase(courseId);
    if (!updateState) return;

    final index = recommended.indexWhere((course) => course.id == courseId);
    HomeCourseEntity? enrolledCourse;
    if (index != -1) {
      enrolledCourse = recommended.removeAt(index);
    } else {
      enrolledCourse = courseData;
    }

    if (enrolledCourse == null) {
      notifyListeners();
      return;
    }

    final course = enrolledCourse;
    final alreadyExists = myCourses.any((item) => item.id == course.id);
    if (!alreadyExists) {
      myCourses = [
        ...myCourses,
        HomeCourseEntity(
          id: course.id,
          title: course.title,
          level: course.level,
          description: course.description,
          status: 'active',
        ),
      ];
    } else {
      myCourses = myCourses.map((item) {
        if (item.id != course.id) return item;
        return HomeCourseEntity(
          id: course.id,
          title: course.title,
          level: course.level,
          description: course.description,
          status: 'active',
        );
      }).toList();
    }

    notifyListeners();
  }

  Future<HomeCourseEntity> fetchRoadmapDetails(int roadmapId) {
    return getRoadmapDetailsUseCase(roadmapId);
  }

  String _friendlyLoadError(Object error) {
    if (error is NetworkException) {
      return 'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.';
    }
    if (error is UnauthorizedException) {
      return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }
    if (error is ParsingException) {
      return 'استلمنا بيانات غير متوقعة من الخادم. حاول مرة أخرى لاحقًا.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'تعذر تحميل بيانات الصفحة الرئيسية. حاول مرة أخرى.';
  }
}

