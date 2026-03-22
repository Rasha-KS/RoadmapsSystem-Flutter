import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';

class EnrollmentSync {
  static Future<void> refreshAll({
    required HomeProvider homeProvider,
    required RoadmapsProvider roadmapsProvider,
    ProfileProvider? profileProvider,
  }) async {
    await homeProvider.loadHome();

    final profileEnrollments = <int>{};
    if (profileProvider != null) {
      await profileProvider.loadProfileData();
      profileEnrollments.addAll(
        profileProvider.roadmaps.map((roadmap) => roadmap.roadmapId),
      );
    }

    final enrolledCourseIds = <int>{
      ...homeProvider.myCourses.map((course) => course.id),
      ...profileEnrollments,
    };
    await roadmapsProvider.loadRoadmaps(
      enrolledCourseIds: enrolledCourseIds,
    );
  }
}
