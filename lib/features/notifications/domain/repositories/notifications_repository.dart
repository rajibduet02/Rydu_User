import '../entities/notification_item_entity.dart';

abstract interface class NotificationsRepository {
  Future<List<NotificationItemEntity>> listNotifications();
}
