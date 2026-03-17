import 'package:flutter/material.dart';
import '../domain/get_notifications_usecase.dart';
import '../domain/get_unread_count_usecase.dart';
import '../domain/notification_entity.dart';

enum NotificationsState { loading, loaded, connectionError }

class NotificationsProvider extends ChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;

  NotificationsProvider(
    this.getNotificationsUseCase,
    this.getUnreadCountUseCase,
  );

  List<NotificationEntity> notifications = [];
  NotificationsState state = NotificationsState.loading;
  int unreadCount = 0;

  bool get hasUnread => unreadCount > 0;

  Future<void> loadNotifications() async {
    state = NotificationsState.loading;
    notifyListeners();

    try {
      // Load notifications list and update the notifications UI.
      notifications = await getNotificationsUseCase();
      state = NotificationsState.loaded;
    } catch (_) {
      state = NotificationsState.connectionError;
    }

    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    try {
      // Fetch unread count to update the bell red dot indicator.
      unreadCount = await getUnreadCountUseCase();
    } catch (_) {
      // Keep the last known count to avoid flashing the UI.
    }
    notifyListeners();
  }
}
