import '../entities/inbox_message_entity.dart';

abstract interface class InboxRepository {
  Future<List<InboxMessageEntity>> getMessages();
  Future<List<InboxMessageEntity>> markMessageRead(String messageId);
}
