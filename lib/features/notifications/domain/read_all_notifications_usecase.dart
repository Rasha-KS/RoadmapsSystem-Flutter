import '../data/notifications_repository.dart';

class ReadAllNotificationsUseCase {
  final NotificationsRepository repository;

  ReadAllNotificationsUseCase(this.repository);

  Future<void> call() {
    return repository.readAllNotifications();
  }
}
