import '../../domain/entities/inbox_message_entity.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../datasources/inbox_local_datasource.dart';

class InboxRepositoryImpl implements InboxRepository {
  InboxRepositoryImpl(this._local);

  final InboxLocalDatasource _local;

  @override
  Future<List<InboxMessageEntity>> getMessages() async {
    final models = await _local.fetchMessages();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<InboxMessageEntity>> markMessageRead(String messageId) async {
    final models = await _local.markMessageRead(messageId);
    return models.map((m) => m.toEntity()).toList();
  }
}
