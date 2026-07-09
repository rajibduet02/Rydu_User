import '../models/notification_item_model.dart';

abstract interface class NotificationsRemoteDatasource {
  Future<List<NotificationItemModel>> fetch();
}

class NotificationsRemoteDatasourceImpl
    implements NotificationsRemoteDatasource {
  NotificationsRemoteDatasourceImpl();

  @override
  Future<List<NotificationItemModel>> fetch() async => const [];
}
