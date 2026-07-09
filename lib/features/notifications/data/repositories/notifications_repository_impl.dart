import '../../domain/entities/notification_item_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDatasource _remote;

  @override
  Future<List<NotificationItemEntity>> listNotifications() async {
    final models = await _remote.fetch();
    return models
        .map(
          (m) => NotificationItemEntity(id: m.id, title: m.title, body: m.body),
        )
        .toList();
  }
}
