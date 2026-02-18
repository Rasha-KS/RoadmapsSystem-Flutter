import '../data/notifications_repository.dart';
import 'notification_entity.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call() {
    return repository.getNotifications();
  }
}
