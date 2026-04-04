import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/navigation/app_navigator.dart';
import 'package:roadmaps/core/navigation/notification_navigation.dart';
import 'package:roadmaps/features/notifications/data/notifications_repository.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';

class PushNotificationService {
  PushNotificationService({
    required NotificationsRepository notificationsRepository,
    required CurrentUserProvider currentUserProvider,
  })  : _notificationsRepository = notificationsRepository,
        _currentUserProvider = currentUserProvider;

  final NotificationsRepository _notificationsRepository;
  final CurrentUserProvider _currentUserProvider;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _notificationTapSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  bool _initialized = false;
  bool _initialMessageHandled = false;
  bool _localNotificationsInitialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _ensureFirebaseInitialized();
    await _initializeLocalNotifications();
    final messaging = FirebaseMessaging.instance;
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      (message) async {
        await _handleForegroundMessage(message);
      },
    );
    _notificationTapSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        await _handleNotificationTap(message);
      },
    );
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((token) async {
      debugPrint('FCM token refreshed: $token');
      await _saveTokenIfNeeded(token);
    });

    _initialized = true;
  }

  Future<void> syncCurrentDeviceToken() async {
    try {
      await _ensureFirebaseInitialized();
      final messaging = FirebaseMessaging.instance;

      if (_currentUserProvider.user == null) return;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        return;
      }

      final token = await messaging.getToken();
      if (token == null || token.trim().isEmpty) {
        debugPrint('FCM token is null or empty.');
        return;
      }

      debugPrint('FCM token generated: $token');
      await _saveTokenIfNeeded(token);
    } catch (_) {
      return;
    }
  }

  Future<void> handleInitialMessage() async {
    if (_initialMessageHandled) return;
    _initialMessageHandled = true;

    await _ensureFirebaseInitialized();
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage == null) return;

    await _handleNotificationTap(initialMessage);
  }

  Future<void> dispose() async {
    await _foregroundMessageSubscription?.cancel();
    await _notificationTapSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      'FCM foreground message received: id=${message.messageId}, title=${message.notification?.title}, body=${message.notification?.body}, data=${message.data}',
    );
    await _refreshUnreadCount();
    await _showForegroundNotification(message);
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    await _refreshUnreadCount();
    await _openNotificationsScreen();
  }

  Future<void> _handleLocalNotificationTap(String? payload) async {
    debugPrint('Foreground local notification tapped. payload=$payload');
    await _refreshUnreadCount();
    await _openNotificationsScreen();
  }

  Future<void> _saveTokenIfNeeded(String token) async {
    try {
      await _ensureFirebaseInitialized();

      if (_currentUserProvider.user == null) return;

      final normalizedToken = token.trim();
      if (normalizedToken.isEmpty) return;

      debugPrint(
        'Saving FCM token for device type ${_deviceType()}: $normalizedToken',
      );
      await _notificationsRepository.saveDeviceToken(
        token: normalizedToken,
        deviceType: _deviceType(),
      );
    } catch (_) {
      return;
    }
  }

  Future<void> _refreshUnreadCount() async {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    final notificationsProvider = context.read<NotificationsProvider>();
    await notificationsProvider.loadUnreadCount();
  }

  Future<void> _openNotificationsScreen() async {
    openNotificationsPage();
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_supportsLocalNotifications) {
      return;
    }

    final notification = message.notification;
    final title = _resolveNotificationTitle(message, notification) ??
        'Roadmaps';
    final body = _resolveNotificationBody(message, notification) ??
        'لديك إشعار جديد';
    if (message.notification == null && message.data.isEmpty) {
      return;
    }

    debugPrint(
      'Showing foreground local notification: title=$title, body=$body, data=${message.data}',
    );

    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    try {
      await _localNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: message.messageId ?? message.data['notification_id']?.toString(),
      );
      debugPrint('Foreground local notification shown successfully.');
    } catch (error, stackTrace) {
      debugPrint('Failed to show foreground local notification: $error');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;
    if (!_supportsLocalNotifications) {
      _localNotificationsInitialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    try {
      await _localNotificationsPlugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (response) {
          unawaited(_handleLocalNotificationTap(response.payload));
        },
      );
    } on MissingPluginException catch (error) {
      debugPrint('Local notifications plugin is not available: $error');
      _localNotificationsInitialized = true;
      return;
    }

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('Android notification permission granted: $granted');
      const channel = AndroidNotificationChannel(
        _notificationChannelId,
        _notificationChannelName,
        description: _notificationChannelDescription,
        importance: Importance.high,
      );
      await androidPlugin.createNotificationChannel(channel);
    }

    final iosPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS notification permission granted: $granted');
    }

    final macosPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    if (macosPlugin != null) {
      final granted = await macosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('macOS notification permission granted: $granted');
    }

    _localNotificationsInitialized = true;
  }

  bool get _supportsLocalNotifications {
    if (kIsWeb) return false;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  String _deviceType() {
    if (kIsWeb) return 'web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp();
  }

  String? _resolveNotificationTitle(
    RemoteMessage message,
    RemoteNotification? notification,
  ) {
    final title =
        notification?.title ??
        message.data['title']?.toString() ??
        message.data['subject']?.toString() ??
        message.data['heading']?.toString();
    final trimmed = title?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _resolveNotificationBody(
    RemoteMessage message,
    RemoteNotification? notification,
  ) {
    final body =
        notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        message.data['description']?.toString() ??
        message.data['content']?.toString();
    final trimmed = body?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static const String _notificationChannelId = 'roadmaps_high_importance_v2';
  static const String _notificationChannelName = 'Roadmaps Notifications';
  static const String _notificationChannelDescription =
      'Notifications from the Roadmaps app';
}
