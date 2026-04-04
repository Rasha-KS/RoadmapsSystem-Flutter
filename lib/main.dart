import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/errors/global_error_gate.dart';
import 'package:roadmaps/core/auth/token_manager.dart';
import 'package:roadmaps/core/navigation/app_navigator.dart';
import 'package:roadmaps/core/navigation/auth_guard.dart';
import 'package:roadmaps/core/navigation/app_route_observer.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  debugPrint(
    'FCM background message received: id=${message.messageId}, title=${message.notification?.title}, body=${message.notification?.body}',
  );

  if (message.notification == null && message.data.isEmpty) {
    return;
  }

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(const InitializationSettings());

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'roadmaps_high_importance',
      'Roadmaps Notifications',
      channelDescription: 'Notifications from the Roadmaps app',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    ),
  );

  final title =
      message.notification?.title ??
      message.data['title']?.toString() ??
      message.data['subject']?.toString() ??
      message.data['heading']?.toString() ??
      'Roadmaps';
  final body =
      message.notification?.body ??
      message.data['body']?.toString() ??
      message.data['message']?.toString() ??
      message.data['description']?.toString() ??
      message.data['content']?.toString() ??
      'لديك إشعار جديد';

  await plugin.show(
    message.hashCode,
    title,
    body,
    details,
    payload: message.messageId,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runZonedGuarded(
    () async {
      _installGlobalErrorHandlers();
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      final launchUri = _resolveLaunchUri();

      final currentUserProvider = Injection.provideCurrentUserProvider();
      await currentUserProvider.loadCurrentUser();

      final pushNotificationService = Injection.providePushNotificationService();
      await pushNotificationService.initialize();
      if (currentUserProvider.user != null) {
        await pushNotificationService.syncCurrentDeviceToken();
      }

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

            ChangeNotifierProvider(
              create: (_) => Injection.provideHomeProvider(),
            ),

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
    },
    (error, stackTrace) {
      _showGlobalError(error);
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialUri});

  final Uri? initialUri;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        Injection.providePushNotificationService().handleInitialMessage(),
      );
    });
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
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appMessengerKey,
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
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async {
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
    final navigator = appNavigatorKey.currentState;
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

void _installGlobalErrorHandlers() {
  ErrorWidget.builder = (details) {
    return const SizedBox.shrink();
  };

  FlutterError.onError = (details) {
    _showGlobalError(details.exception);
  };

  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    _showGlobalError(error);
    return true;
  };
}

void _showGlobalError(Object error) {
  if (GlobalErrorGate.suppressSnackbars) {
    debugPrint('Suppressed global error while gated: $error');
    return;
  }

  final messenger = appMessengerKey.currentState;
  if (messenger == null) {
    return;
  }

  final message = error is TimeoutApiException
      ? 'استغرق الطلب وقتًا أطول من المعتاد. حاول مرة أخرى.'
      : error is NetworkException
      ? 'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.'
      : error is ApiException
      ? error.message
      : 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  showAppSnackBar(
    messenger,
    message: message,
    variant: SnackBarVariant.error,
    duration: const Duration(seconds: 3),
  );
}

class _AppEntry extends StatelessWidget {
  const _AppEntry({required this.initialUri});

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
  final firstSegment = uri.pathSegments.isNotEmpty
      ? uri.pathSegments.first
      : null;
  return firstSegment == 'reset-password' ||
      uri.path == '/reset-password' ||
      uri.host == 'reset-password';
}
