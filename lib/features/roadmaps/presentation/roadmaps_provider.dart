
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';

import '../domain/get_roadmaps_usecase.dart';
import '../domain/roadmap_entity.dart';

enum PageState { loading, loaded, connectionError }

class RoadmapsProvider extends SafeChangeNotifier {
  final GetRoadmapsUseCase useCase;

  RoadmapsProvider(this.useCase);
  List<RoadmapEntity> myCourses = [];
  List<RoadmapEntity> roadmaps = [];
  final Set<int> _enrolledCourseIds = {};
  Set<int> get enrolledCourseIds => Set.unmodifiable(_enrolledCourseIds);
  PageState state = PageState.loading;
  String? errorMessage;

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
          status: enrolled ? 'active' : null,
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
        } else {
          myCourses = myCourses.map((item) {
            if (item.id != course.id) {
              return item;
            }
            return course;
          }).toList();
        }
      }
    } else {
      myCourses = myCourses.where((course) => course.id != courseId).toList();
    }

    notifyListeners();
  }

  void updateRoadmapStatus({
    required int roadmapId,
    required String? status,
  }) {
    var changed = false;

    roadmaps = roadmaps.map((course) {
      if (course.id != roadmapId) return course;
      changed = true;
      return course.copyWith(
        status: status,
        clearStatus: status == null,
      );
    }).toList();

    myCourses = myCourses.map((course) {
      if (course.id != roadmapId) return course;
      changed = true;
      return course.copyWith(
        status: status,
        clearStatus: status == null,
      );
    }).toList();

    if (changed) {
      notifyListeners();
    }
  }

  Future<void> loadRoadmaps({Set<int>? enrolledCourseIds}) async {
    state = PageState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final loadedRoadmaps = await useCase.call();
      final repositoryError = useCase.repository.lastLoadErrorMessage;
      final persistedEnrollmentIds = <int>{
        ...loadedRoadmaps
            .where((course) => course.isEnrolled)
            .map((course) => course.id),
        if (enrolledCourseIds != null) ...enrolledCourseIds,
      };

      if (repositoryError == null || loadedRoadmaps.isNotEmpty) {
        roadmaps = loadedRoadmaps.map((course) {
          final isEnrolled = persistedEnrollmentIds.contains(course.id);
          return course.copyWith(
            isEnrolled: isEnrolled,
            status: isEnrolled ? (course.status ?? 'active') : null,
            clearStatus: !isEnrolled,
          );
        }).toList();

        myCourses = roadmaps.where((course) => course.isEnrolled).toList();
        _enrolledCourseIds
          ..clear()
          ..addAll(myCourses.map((course) => course.id));
      }

      if (repositoryError != null) {
        errorMessage = repositoryError;
        state = roadmaps.isEmpty ? PageState.connectionError : PageState.loaded;
      } else {
        state = PageState.loaded;
      }
    } catch (e) {
      state = PageState.connectionError;
      errorMessage = _friendlyError(e);
    }

    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تحميل المسارات وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'تعذر تحميل المسارات.';
  }
}
