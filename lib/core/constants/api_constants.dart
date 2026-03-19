class ApiConstants {
  static const String baseUrl = "https://roadmap.nixway.dev/api/v1";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String githubLogin = "/auth/github";
  static const String githubCallback = "/auth/github/callback";
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

  // Roadmaps
  static const String roadmaps = "/roadmaps";
  static String roadmapDetails(int roadmapId) => "/roadmaps/$roadmapId";
  static String enrollRoadmap(int roadmapId) => "/roadmaps/$roadmapId/enroll";
  static String unenrollRoadmap(int roadmapId) =>
      "/roadmaps/$roadmapId/unenroll";

  static String url(String path) => "$baseUrl$path";
}
