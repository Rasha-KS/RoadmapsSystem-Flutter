
import 'package:flutter/material.dart';

import '../domain/get_roadmaps_usecase.dart';
import '../domain/roadmap_entity.dart';

enum PageState { loading, loaded, connectionError }

class RoadmapsProvider extends ChangeNotifier {
  final GetRoadmapsUseCase useCase;

  RoadmapsProvider(this.useCase);
  List<RoadmapEntity> myCourses = [];
  List<RoadmapEntity> roadmaps = [];
  final Set<int> _enrolledCourseIds = {};
  Set<int> get enrolledCourseIds => Set.unmodifiable(_enrolledCourseIds);
  PageState state = PageState.loading;

  bool isCourseEnrolled(int courseId) => _enrolledCourseIds.contains(courseId);

  void setCourseEnrollment(int courseId, bool enrolled) {
    final changed = enrolled
        ? _enrolledCourseIds.add(courseId)
        : _enrolledCourseIds.remove(courseId);

    if (!changed) {
      return;
    }

    RoadmapEntity? matchedCourse;
    roadmaps = roadmaps.map((course) {
      if (course.id == courseId) {
        final updatedCourse = course.copyWith(
          isEnrolled: enrolled,
          status: enrolled ? (course.status ?? 'مشترك') : null,
          clearStatus: !enrolled,
        );
        matchedCourse = updatedCourse;
        return updatedCourse;
      }
      return course;
    }).toList();

    if (enrolled) {
      final course = matchedCourse;
      if (course != null) {
        final alreadyExists = myCourses.any((item) => item.id == course.id);
        if (!alreadyExists) {
          myCourses = [...myCourses, course];
        }
      }
    } else {
      myCourses = myCourses.where((course) => course.id != courseId).toList();
    }

    notifyListeners();
  }

  Future<void> loadRoadmaps({Set<int>? enrolledCourseIds}) async {
    state = PageState.loading;
    notifyListeners();

    try {
      final loadedRoadmaps = await useCase.call();
      final persistedEnrollmentIds = <int>{
        ...loadedRoadmaps
            .where((course) => course.isEnrolled)
            .map((course) => course.id),
        if (enrolledCourseIds != null) ...enrolledCourseIds,
      };

      roadmaps = loadedRoadmaps.map((course) {
        final isEnrolled = persistedEnrollmentIds.contains(course.id);
        return course.copyWith(
          isEnrolled: isEnrolled,
          status: isEnrolled ? (course.status ?? 'مشترك') : null,
          clearStatus: !isEnrolled,
        );
      }).toList();

      myCourses = roadmaps.where((course) => course.isEnrolled).toList();
      _enrolledCourseIds
        ..clear()
        ..addAll(myCourses.map((course) => course.id));
      state = PageState.loaded;
    } catch (e) {
      state = PageState.connectionError;
    }

    notifyListeners();
  }
}
