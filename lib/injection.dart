import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/auth_interceptor.dart';
import 'package:roadmaps/core/auth/token_manager.dart';
import 'package:roadmaps/core/data/user/api_user_repository.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/features/announcements/data/announcements_repository.dart';
import 'package:roadmaps/features/announcements/domain/get_active_announcements_usecase.dart';
import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';
import 'package:roadmaps/features/auth/data/auth_repository.dart';
import 'package:roadmaps/features/auth/domain/forgot_password_usecase.dart';
import 'package:roadmaps/features/auth/domain/github_login_usecase.dart';
import 'package:roadmaps/features/auth/domain/login_usecase.dart';
import 'package:roadmaps/features/auth/domain/register_usecase.dart';
import 'package:roadmaps/features/auth/domain/reset_password_usecase.dart';
import 'package:roadmaps/features/auth/presentation/auth_provider.dart';
import 'package:roadmaps/features/community/data/community_api_repository.dart';
import 'package:roadmaps/features/community/domain/get_messages_by_room_usecase.dart';
import 'package:roadmaps/features/community/domain/get_user_community_rooms_usecase.dart';
import 'package:roadmaps/features/community/domain/send_image_message_usecase.dart';
import 'package:roadmaps/features/community/domain/send_message_usecase.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';
import 'package:roadmaps/features/challenge/data/challenge_repository.dart';
import 'package:roadmaps/features/challenge/domain/get_challenge_by_learning_unit_usecase.dart';
import 'package:roadmaps/features/challenge/domain/run_challenge_code_usecase.dart';
import 'package:roadmaps/features/challenge/presentation/challenge_provider.dart';
import 'package:roadmaps/features/checkpoints/data/checkpoint_repository.dart';
import 'package:roadmaps/features/checkpoints/domain/create_checkpoint_attempt_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/get_checkpoint_attempts_count_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/get_checkpoint_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/retake_checkpoint_attempt_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/submit_checkpoint_attempt_usecase.dart';
import 'package:roadmaps/features/checkpoints/presentation/checkpoints_provider.dart';
import 'package:roadmaps/features/homepage/data/home_repository.dart';
import 'package:roadmaps/features/homepage/domain/delete_my_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/domain/enroll_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/domain/get_home_data_usecase.dart';
import 'package:roadmaps/features/homepage/domain/get_roadmap_details_usecase.dart';
import 'package:roadmaps/features/homepage/domain/reset_my_roadmap_usecase.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/learning_path/data/learning_path_repository.dart';
import 'package:roadmaps/features/learning_path/domain/get_learning_path_usecase.dart';
import 'package:roadmaps/features/learning_path/domain/get_roadmap_xp_usecase.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/lessons/data/lesson_repository.dart';
import 'package:roadmaps/features/lessons/domain/get_sub_lessons_usecase.dart';
import 'package:roadmaps/features/lessons/domain/complete_lesson_usecase.dart';
import 'package:roadmaps/features/lessons/domain/prefetch_lesson_content_usecase.dart';
import 'package:roadmaps/features/lessons/presentation/lessons_provider.dart';
import 'package:roadmaps/features/notifications/data/notifications_repository.dart';
import 'package:roadmaps/features/notifications/domain/get_notifications_usecase.dart';
import 'package:roadmaps/features/notifications/domain/get_unread_count_usecase.dart';
import 'package:roadmaps/features/notifications/domain/read_all_notifications_usecase.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/core/services/push_notification_service.dart';
import 'package:roadmaps/features/profile/data/profile_repository.dart';
import 'package:roadmaps/features/profile/domain/delete_user_roadmap_usecase.dart';
import 'package:roadmaps/features/profile/domain/get_user_roadmaps_usecase.dart';
import 'package:roadmaps/features/profile/domain/reset_user_roadmap_usecase.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';
import 'package:roadmaps/features/roadmaps/data/roadmap_repository.dart';
import 'package:roadmaps/features/roadmaps/domain/get_roadmaps_usecase.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import 'package:roadmaps/features/settings/data/settings_repository.dart';
import 'package:roadmaps/features/settings/domain/change_password_usecase.dart';
import 'package:roadmaps/features/settings/domain/delete_account_usecase.dart';
import 'package:roadmaps/features/settings/domain/get_settings_data_usecase.dart';
import 'package:roadmaps/features/settings/domain/logout_usecase.dart';
import 'package:roadmaps/features/settings/domain/toggle_notifications_usecase.dart';
import 'package:roadmaps/features/settings/domain/upload_profile_image_usecase.dart';
import 'package:roadmaps/features/settings/domain/update_account_usecase.dart';
import 'package:roadmaps/features/settings/presentation/settings_provider.dart';
import 'package:roadmaps/features/smart_instructor/data/smart_instructor_api_repository.dart';
import 'package:roadmaps/features/smart_instructor/domain/get_smart_instructor_messages_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/create_smart_instructor_session_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/delete_smart_instructor_session_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/get_smart_instructor_sessions_usecase.dart';
import 'package:roadmaps/features/smart_instructor/domain/send_smart_instructor_message_usecase.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';

class Injection {
  static ProfileProvider? _profileProvider;
  static HomeProvider? _homeProvider;
  static RoadmapsProvider? _roadmapsProvider;
  static final TokenManager _tokenManager = TokenManager();
  static final AuthInterceptor _authInterceptor = AuthInterceptor(
    tokenManager: _tokenManager,
  );
  static final ApiClient _publicApiClient = ApiClient();
  static final ApiClient _apiClient = ApiClient(client: _authInterceptor);
  static final UserRepository _userRepository = ApiUserRepository(
    apiClient: _apiClient,
    tokenManager: _tokenManager,
  );
  static final AuthRepository _authRepository = AuthRepository(
    apiClient: _publicApiClient,
    tokenManager: _tokenManager,
  );
  static final NotificationsRepository _notificationsRepository =
      NotificationsRepository(apiClient: _apiClient);
  static final CurrentUserProvider _currentUserProvider = CurrentUserProvider(
    userRepository: _userRepository,
  );
  static final PushNotificationService _pushNotificationService =
      PushNotificationService(
        notificationsRepository: _notificationsRepository,
        currentUserProvider: _currentUserProvider,
      );

  static CurrentUserProvider provideCurrentUserProvider() {
    return _currentUserProvider;
  }

  static TokenManager provideTokenManager() {
    return _tokenManager;
  }

  static AuthProvider provideAuthProvider() {
    return AuthProvider(
      loginUseCase: LoginUseCase(_authRepository),
      registerUseCase: RegisterUseCase(_authRepository),
      githubLoginUseCase: GithubLoginUseCase(_authRepository),
      forgotPasswordUseCase: ForgotPasswordUseCase(_authRepository),
      resetPasswordUseCase: ResetPasswordUseCase(_authRepository),
      currentUserProvider: _currentUserProvider,
      pushNotificationService: _pushNotificationService,
    );
  }

  static HomeProvider provideHomeProvider() {
    final existing = _homeProvider;
    if (existing != null) {
      return existing;
    }

    final repository = HomeRepository(apiClient: _apiClient);
    final getHomeDataUseCase = GetHomeDataUseCase(repository);
    final getRoadmapDetailsUseCase = GetRoadmapDetailsUseCase(repository);
    final deleteMyCourseUseCase = DeleteMyCourseUseCase(repository);
    final resetMyCourseUseCase = ResetMyCourseUseCase(repository);
    final enrollCourseUseCase = EnrollCourseUseCase(repository);

    final homeProvider = HomeProvider(
      getHomeDataUseCase: getHomeDataUseCase,
      getRoadmapDetailsUseCase: getRoadmapDetailsUseCase,
      deleteMyCourseUseCase: deleteMyCourseUseCase,
      resetMyCourseUseCase: resetMyCourseUseCase,
      enrollCourseUseCase: enrollCourseUseCase,
    );
    _homeProvider = homeProvider;
    return homeProvider;
  }

  static ProfileProvider provideProfileProvider() {
    final existing = _profileProvider;
    if (existing != null) {
      return existing;
    }

    final repository = ProfileRepository(
      userRepository: _userRepository,
      apiClient: _apiClient,
    );
    final profileProvider = ProfileProvider(
      getUserRoadmapsUseCase: GetUserRoadmapsUseCase(repository),
      getLearningPathUseCase: GetLearningPathUseCase(
        LearningPathRepository(apiClient: _apiClient),
      ),
      deleteUserRoadmapUseCase: DeleteUserRoadmapUseCase(repository),
      resetUserRoadmapUseCase: ResetUserRoadmapUseCase(repository),
      currentUserProvider: _currentUserProvider,
    );
    _profileProvider = profileProvider;
    return profileProvider;
  }

  static RoadmapsProvider provideRoadmapsProvider() {
    final existing = _roadmapsProvider;
    if (existing != null) {
      return existing;
    }

    final roadmapsRepository = RoadmapRepository(apiClient: _apiClient);
    final useCase = GetRoadmapsUseCase(roadmapsRepository);
    final roadmapsProvider = RoadmapsProvider(useCase);
    _roadmapsProvider = roadmapsProvider;
    return roadmapsProvider;
  }

  static AnnouncementsProvider provideAnnouncementsProvider() {
    final announcementsRepository = AnnouncementsRepository(
      apiClient: _apiClient,
    );
    final useCase = GetActiveAnnouncementsUseCase(announcementsRepository);
    return AnnouncementsProvider(useCase);
  }

  static SettingsProvider provideSettingsProvider() {
    final repository = SettingsRepository(
      userRepository: _userRepository,
      apiClient: _apiClient,
    );
    return SettingsProvider(
      getSettingsDataUseCase: GetSettingsDataUseCase(repository),
      toggleNotificationsUseCase: ToggleNotificationsUseCase(repository),
      updateAccountUseCase: UpdateAccountUseCase(repository),
      changePasswordUseCase: ChangePasswordUseCase(repository),
      uploadProfileImageUseCase: UploadProfileImageUseCase(repository),
      deleteAccountUseCase: DeleteAccountUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      currentUserProvider: _currentUserProvider,
    );
  }

  static CommunityProvider provideCommunityProvider() {
    final repository = CommunityApiRepository(apiClient: _apiClient);

    return CommunityProvider(
      getUserCommunityRoomsUseCase: GetUserCommunityRoomsUseCase(
        communityRepository: repository,
      ),
      getMessagesByRoomUseCase: GetMessagesByRoomUseCase(repository),
      sendMessageUseCase: SendMessageUseCase(repository: repository),
      sendImageMessageUseCase: SendImageMessageUseCase(repository: repository),
      currentUserProvider: _currentUserProvider,
    );
  }

  static LearningPathProvider provideLearningPathProvider() {
    final repository = LearningPathRepository(apiClient: _apiClient);
    final lessonRepository = LessonRepository(
      apiClient: _apiClient,
      tokenManager: _tokenManager,
    );
    return LearningPathProvider(
      GetLearningPathUseCase(repository),
      GetRoadmapXpUseCase(repository),
      PrefetchLessonContentUseCase(lessonRepository),
      profileProvider: provideProfileProvider(),
      homeProvider: provideHomeProvider(),
      roadmapsProvider: provideRoadmapsProvider(),
    );
  }

  static LessonsProvider provideLessonsProvider() {
    final repository = LessonRepository(
      apiClient: _apiClient,
      tokenManager: _tokenManager,
    );
    return LessonsProvider(
      GetSubLessonsUseCase(repository),
      CompleteLessonUseCase(repository),
      PrefetchLessonContentUseCase(repository),
    );
  }

  static CheckpointsProvider provideCheckpointsProvider() {
    final repository = CheckpointRepository(apiClient: _apiClient);
    return CheckpointsProvider(
      getCheckpointUseCase: GetCheckpointUseCase(repository),
      createAttemptUseCase: CreateCheckpointAttemptUseCase(repository),
      getAttemptsCountUseCase: GetCheckpointAttemptsCountUseCase(repository),
      retakeAttemptUseCase: RetakeCheckpointAttemptUseCase(repository),
      submitAttemptUseCase: SubmitCheckpointAttemptUseCase(repository),
    );
  }

  static NotificationsProvider provideNotificationsProvider() {
    return NotificationsProvider(
      GetNotificationsUseCase(_notificationsRepository),
      GetUnreadCountUseCase(_notificationsRepository),
      ReadAllNotificationsUseCase(_notificationsRepository),
    );
  }

  static PushNotificationService providePushNotificationService() {
    return _pushNotificationService;
  }

  static SmartInstructorProvider provideSmartInstructorProvider() {
    final repository = SmartInstructorApiRepository(apiClient: _apiClient);
    return SmartInstructorProvider(
      getSmartInstructorSessionsUseCase: GetSmartInstructorSessionsUseCase(
        repository,
      ),
      getSmartInstructorMessagesUseCase: GetSmartInstructorMessagesUseCase(
        repository,
      ),
      sendSmartInstructorMessageUseCase: SendSmartInstructorMessageUseCase(
        repository,
      ),
      createSmartInstructorSessionUseCase: CreateSmartInstructorSessionUseCase(
        repository,
      ),
      deleteSmartInstructorSessionUseCase: DeleteSmartInstructorSessionUseCase(
        repository,
      ),
    );
  }

  static ChallengeProvider provideChallengeProvider() {
    final repository = ChallengeRepository(apiClient: _apiClient);
    return ChallengeProvider(
      getChallengeByLearningUnitUseCase: GetChallengeByLearningUnitUseCase(
        repository,
      ),
      runChallengeCodeUseCase: RunChallengeCodeUseCase(repository),
    );
  }
}
