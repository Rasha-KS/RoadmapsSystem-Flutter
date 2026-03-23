class ApiConstants {
  static const String baseUrl = "https://roadmap.nixway.dev/api/v1";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String githubLogin = "/auth/github";
  static const String githubCallback = "/auth/github/callback";
  static const String forgotPassword = "/auth/forgot-password";
  static const String resetPassword = "/auth/reset-password";
  static const String resetAttempts = "/auth/reset-attempts";
  static const String logout = "/logout";

  // Profile
  static const String profile = "/profile";

  // Home
  static const String suggestedRoadmaps = "/home/suggested-roadmaps";
  static const String enrollments = "/me/enrollments";

  // Announcements
  static const String announcements = "/announcements";

  // Notifications
  static const String notifications = "/notifications";
  static const String notificationsUnreadCount = "/notifications/unread-count";
  static const String notificationsReadAll = "/notifications/read-all";
  static const String myNotifications = "/me/notifications";

  // Settings
  static const String updateAccount = "/update-account";
  static const String changePassword = "/change-password";
  static const String updateProfilePicture = "/update-profile-picture";

  // Smart Instructor
  static const String chatbotSessions = "/chatbot/sessions";
  static String chatbotSessionMessages(int sessionId) =>"/chatbot/sessions/$sessionId/messages";
  static String chatbotSession(int sessionId) => "/chatbot/sessions/$sessionId";

  // Roadmaps
  static const String roadmaps = "/roadmaps";
  static String roadmapDetails(int roadmapId) => "/roadmaps/$roadmapId";
  static String enrollRoadmap(int roadmapId) => "/roadmaps/$roadmapId/enroll";
  static String unenrollRoadmap(int roadmapId) =>
      "/roadmaps/$roadmapId/unenroll";

  static String url(String path) => "$baseUrl$path";
}
