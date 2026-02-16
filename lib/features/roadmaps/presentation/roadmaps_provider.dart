

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
  PageState state = PageState.loading;

  bool isCourseEnrolled(int courseId) => _enrolledCourseIds.contains(courseId);

  void setCourseEnrollment(int courseId, bool enrolled) {
    final changed = enrolled
        ? _enrolledCourseIds.add(courseId)
        : _enrolledCourseIds.remove(courseId);
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> loadRoadmaps() async {
    state = PageState.loading;
    notifyListeners();

    try {
      roadmaps = await useCase.call();
      myCourses = await useCase.callMyCourses();
      _enrolledCourseIds.addAll(myCourses.map((course) => course.id));
      state = PageState.loaded;
    } catch (e) {
      state = PageState.connectionError;
    }


    notifyListeners();
  }
}
