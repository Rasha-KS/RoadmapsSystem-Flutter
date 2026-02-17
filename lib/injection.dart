import 'package:roadmaps/core/data/user/mock_user_repository.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/features/announcements/data/announcements_repository.dart';
import 'package:roadmaps/features/announcements/domain/get_active_announcements_usecase.dart';
import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';
import 'package:roadmaps/features/community/data/mock_community_repository.dart';
import 'package:roadmaps/features/community/domain/get_messages_by_room_usecase.dart';
import 'package:roadmaps/features/community/domain/get_user_community_rooms_usecase.dart';
import 'package:roadmaps/features/community/domain/send_image_message_usecase.dart';
import 'package:roadmaps/features/community/domain/send_message_usecase.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';
import 'package:roadmaps/features/homepage/data/home_repository.dart';
import 'package:roadmaps/features/homepage/domain/delete_my_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/domain/enroll_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/domain/get_home_data_usecase.dart';
import 'package:roadmaps/features/homepage/domain/reset_my_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/profile/data/profile_repository.dart';
import 'package:roadmaps/features/profile/domain/delete_user_roadmap_usecase.dart';
import 'package:roadmaps/features/profile/domain/get_user_roadmaps_usecase.dart';
import 'package:roadmaps/features/profile/domain/reset_user_roadmap_usecase.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';
import 'package:roadmaps/features/roadmaps/data/roadmap_repository.dart';
import 'package:roadmaps/features/roadmaps/domain/get_roadmaps_usecase.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import 'package:roadmaps/features/settings/data/settings_repository.dart';
import 'package:roadmaps/features/settings/domain/delete_account_usecase.dart';
import 'package:roadmaps/features/settings/domain/get_settings_data_usecase.dart';
import 'package:roadmaps/features/settings/domain/logout_usecase.dart';
import 'package:roadmaps/features/settings/domain/toggle_notifications_usecase.dart';
import 'package:roadmaps/features/settings/domain/upload_profile_image_usecase.dart';
import 'package:roadmaps/features/settings/domain/update_account_usecase.dart';
import 'package:roadmaps/features/settings/presentation/settings_provider.dart';

class Injection {
  static final UserRepository _userRepository = MockUserRepository();
  static final CurrentUserProvider _currentUserProvider =
      CurrentUserProvider(userRepository: _userRepository);

  static CurrentUserProvider provideCurrentUserProvider() {
    return _currentUserProvider;
  }

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

  static ProfileProvider provideProfileProvider() {
    final repository = ProfileRepository(userRepository: _userRepository);
    return ProfileProvider(
      getUserRoadmapsUseCase: GetUserRoadmapsUseCase(repository),
      deleteUserRoadmapUseCase: DeleteUserRoadmapUseCase(repository),
      resetUserRoadmapUseCase: ResetUserRoadmapUseCase(repository),
      currentUserProvider: _currentUserProvider,
    );
  }

  static RoadmapsProvider provideRoadmapsProvider() {
    final roadmapsRepository = RoadmapRepository();
    final useCase = GetRoadmapsUseCase(roadmapsRepository);
    return RoadmapsProvider(useCase);
  }

  static AnnouncementsProvider provideAnnouncementsProvider() {
    final announcementsRepository = AnnouncementsRepository();
    final useCase = GetActiveAnnouncementsUseCase(announcementsRepository);
    return AnnouncementsProvider(useCase);
  }

  static SettingsProvider provideSettingsProvider() {
    final repository = SettingsRepository(userRepository: _userRepository);
    return SettingsProvider(
      getSettingsDataUseCase: GetSettingsDataUseCase(repository),
      toggleNotificationsUseCase: ToggleNotificationsUseCase(repository),
      updateAccountUseCase: UpdateAccountUseCase(repository),
      uploadProfileImageUseCase: UploadProfileImageUseCase(repository),
      deleteAccountUseCase: DeleteAccountUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      currentUserProvider: _currentUserProvider,
    );
  }

  static CommunityProvider provideCommunityProvider() {
    final repository = MockCommunityRepository();

    return CommunityProvider(
      getUserCommunityRoomsUseCase: GetUserCommunityRoomsUseCase(
        communityRepository: repository,
        userRepository: _userRepository,
      ),
      getMessagesByRoomUseCase: GetMessagesByRoomUseCase(repository),
      sendMessageUseCase: SendMessageUseCase(
        repository: repository,
        userRepository: _userRepository,
      ),
      sendImageMessageUseCase: SendImageMessageUseCase(
        repository: repository,
        userRepository: _userRepository,
      ),
      currentUserProvider: _currentUserProvider,
    );
  }
}
