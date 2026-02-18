import 'package:flutter/material.dart';
import '../domain/get_notifications_usecase.dart';
import '../domain/notification_entity.dart';

enum NotificationsState { loading, loaded, connectionError }

class NotificationsProvider extends ChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationsProvider(this.getNotificationsUseCase);

  List<NotificationEntity> notifications = [];
  NotificationsState state = NotificationsState.loading;

  Future<void> loadNotifications() async {
    state = NotificationsState.loading;
    notifyListeners();

    try {
      notifications = await getNotificationsUseCase();
      state = NotificationsState.loaded;
    } catch (_) {
      state = NotificationsState.connectionError;
    }

    notifyListeners();
  }
}
