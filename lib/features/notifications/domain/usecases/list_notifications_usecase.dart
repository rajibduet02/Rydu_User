import '../entities/notification_item_entity.dart';
import '../repositories/notifications_repository.dart';

class ListNotificationsUsecase {
  ListNotificationsUsecase(this._repository);

  final NotificationsRepository _repository;

  Future<List<NotificationItemEntity>> call() =>
      _repository.listNotifications();
}
