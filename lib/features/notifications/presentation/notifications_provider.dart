import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import '../domain/get_notifications_usecase.dart';
import '../domain/get_unread_count_usecase.dart';
import '../domain/read_all_notifications_usecase.dart';
import '../domain/notification_entity.dart';

enum NotificationsState { loading, loaded, connectionError }

class NotificationsProvider extends SafeChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final ReadAllNotificationsUseCase readAllNotificationsUseCase;

  NotificationsProvider(
    this.getNotificationsUseCase,
    this.getUnreadCountUseCase,
    this.readAllNotificationsUseCase,
  );

  List<NotificationEntity> notifications = [];
  NotificationsState state = NotificationsState.loading;
  String? error;
  int unreadCount = 0;
  bool _awaitingUnreadSync = false;

  bool get hasUnread => unreadCount > 0;

  Future<void> loadNotifications() async {
    state = NotificationsState.loading;
    error = null;
    notifyListeners();

    try {
      // Load notifications list and update the notifications UI.
      notifications = await getNotificationsUseCase();
      state = NotificationsState.loaded;
      notifyListeners();

      final markedAsRead = await markAllAsRead();
      if (!markedAsRead) {
        await loadUnreadCount();
      }
    } catch (error) {
      state = NotificationsState.connectionError;
      this.error = _friendlyError(error);
    }

    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    try {
      // Fetch unread count to update the bell red dot indicator.
      final fetchedUnreadCount = await getUnreadCountUseCase();
      if (_awaitingUnreadSync && fetchedUnreadCount > 0) {
        unreadCount = 0;
        notifyListeners();
        return;
      }

      unreadCount = fetchedUnreadCount;
      _awaitingUnreadSync = fetchedUnreadCount > 0 ? _awaitingUnreadSync : false;
    } catch (_) {
      // Keep the last known count to avoid flashing the UI.
    }
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تحميل الإشعارات وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'تعذر تحميل الإشعارات.';
  }

  Future<bool> markAllAsRead() async {
    try {
      await readAllNotificationsUseCase();
      unreadCount = 0;
      _awaitingUnreadSync = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
