import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepositoryImpl(NotificationsRemoteDatasourceImpl());
});
