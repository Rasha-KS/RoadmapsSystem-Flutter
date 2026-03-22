import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/auth/token_manager.dart';
import 'package:roadmaps/core/navigation/auth_guard.dart';
import 'package:roadmaps/core/navigation/app_route_observer.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/features/auth/presentation/confirm_new_password_screen.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';
import 'package:roadmaps/features/main_screen.dart';
import 'package:roadmaps/features/auth/presentation/auth_provider.dart';
import 'package:roadmaps/features/challenge/presentation/challenge_provider.dart';
import 'package:roadmaps/features/checkpoints/presentation/checkpoints_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/lessons/presentation/lessons_provider.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';
import 'package:roadmaps/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final launchUri = _resolveLaunchUri();

  final currentUserProvider = Injection.provideCurrentUserProvider();
  await currentUserProvider.loadCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenManager>.value(
          value: Injection.provideTokenManager(),
        ),
        ChangeNotifierProvider.value(value: currentUserProvider),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => Injection.provideAuthProvider(),
        ),

        ChangeNotifierProvider(create: (_) => Injection.provideHomeProvider()),

        ChangeNotifierProvider(
          create: (_) => Injection.provideRoadmapsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideAnnouncementsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideSettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideCommunityProvider(),
        ),
        ChangeNotifierProvider<LearningPathProvider>(
          create: (_) => Injection.provideLearningPathProvider(),
        ),
        ChangeNotifierProvider<LessonsProvider>(
          create: (_) => Injection.provideLessonsProvider(),
        ),
        ChangeNotifierProvider<CheckpointsProvider>(
          create: (_) => Injection.provideCheckpointsProvider(),
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => Injection.provideNotificationsProvider(),
        ),
        ChangeNotifierProvider<SmartInstructorProvider>(
          create: (_) => Injection.provideSmartInstructorProvider(),
        ),
        ChangeNotifierProvider<ChallengeProvider>(
          create: (_) => Injection.provideChallengeProvider(),
        ),
      ],
      child: MyApp(initialUri: launchUri),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.initialUri,
  });

  final Uri? initialUri;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      navigatorObservers: [appRouteObserver],
      title: 'Roadmaps App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal_R',
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: _AppEntry(initialUri: widget.initialUri),
    );
  }

  @override
  Future<bool> didPushRoute(String route) async {
    return _handleIncomingRoute(route);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    return _handleIncomingRoute(routeInformation.uri.toString());
  }

  Future<bool> _handleIncomingRoute(String? route) async {
    final uri = _parseUri(route ?? '');
    if (uri == null || !_isResetPasswordLink(uri)) {
      return false;
    }

    _openResetPasswordScreen(uri);
    return true;
  }

  void _openResetPasswordScreen(Uri uri) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openResetPasswordScreen(uri);
      });
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ConfirmNewPasswordScreen(
          email: uri.queryParameters['email'],
          token: uri.queryParameters['token'],
        ),
      ),
      (route) => false,
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry({
    required this.initialUri,
  });

  final Uri? initialUri;

  @override
  Widget build(BuildContext context) {
    final uri = initialUri ?? Uri.base;
    if (_isResetPasswordLink(uri)) {
      return ConfirmNewPasswordScreen(
        email: uri.queryParameters['email'],
        token: uri.queryParameters['token'],
      );
    }

    return AuthGuard(
      child: const MainScreen(),
      unauthenticatedBuilder: (_) => const SplashScreen(),
    );
  }
}

Uri? _resolveLaunchUri() {
  final routeName = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  final routeUri = _parseUri(routeName);
  if (routeUri != null && _isResetPasswordLink(routeUri)) {
    return routeUri;
  }

  if (_isResetPasswordLink(Uri.base)) {
    return Uri.base;
  }

  if (routeUri != null && routeUri.toString() != '/') {
    return routeUri;
  }

  return null;
}

Uri? _parseUri(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  try {
    return Uri.parse(trimmed);
  } catch (_) {
    return null;
  }
}

bool _isResetPasswordLink(Uri uri) {
  final firstSegment =
      uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  return firstSegment == 'reset-password' ||
      uri.path == '/reset-password' ||
      uri.host == 'reset-password';
}
