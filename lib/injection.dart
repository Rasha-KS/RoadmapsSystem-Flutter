import 'package:roadmaps/features/announcements/data/announcements_repository.dart';
import 'package:roadmaps/features/announcements/domain/get_active_announcements_usecase.dart';
import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';
import 'package:roadmaps/features/homepage/data/home_repository.dart';
import 'package:roadmaps/features/homepage/domain/delete_my_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/domain/enroll_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/domain/get_home_data_usecase.dart';
import 'package:roadmaps/features/homepage/domain/reset_my_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/profile/domain/delete_user_roadmap_usecase.dart';
import 'package:roadmaps/features/profile/domain/get_user_profile_usecase.dart';
import 'package:roadmaps/features/profile/domain/get_user_roadmaps_usecase.dart';
import 'package:roadmaps/features/profile/data/profile_repository.dart';
import 'package:roadmaps/features/profile/domain/reset_user_roadmap_usecase.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';

class Injection {
  static HomeProvider provideHomeProvider() {
    final repository = HomeRepository();
    final getHomeDataUseCase = GetHomeDataUseCase(repository);
    final deleteMyCourseUseCase = DeleteMyCourseUseCase(repository);
    final resetMyCourseUseCase = ResetMyCourseUseCase(repository);
    final enrollCourseUseCase = EnrollCourseUseCase(repository);

    return HomeProvider(
      getHomeDataUseCase: getHomeDataUseCase,
      deleteMyCourseUseCase: deleteMyCourseUseCase,
      resetMyCourseUseCase: resetMyCourseUseCase,
      enrollCourseUseCase: enrollCourseUseCase,
    );
  }

  static AnnouncementsProvider provideAnnouncementsProvider() {
    final repository = AnnouncementsRepository();
    final useCase = GetActiveAnnouncementsUseCase(repository);
    return AnnouncementsProvider(useCase);
  }

  static ProfileProvider provideProfileProvider() {
    final repository = ProfileRepository();
    return ProfileProvider(
      getUserProfileUseCase: GetUserProfileUseCase(repository),
      getUserRoadmapsUseCase: GetUserRoadmapsUseCase(repository),
      deleteUserRoadmapUseCase: DeleteUserRoadmapUseCase(repository),
      resetUserRoadmapUseCase: ResetUserRoadmapUseCase(repository),
    );
  }
}

