import '../entities/inbox_message_entity.dart';
import '../repositories/inbox_repository.dart';

class MarkInboxMessageReadUsecase {
  MarkInboxMessageReadUsecase(this._repository);

  final InboxRepository _repository;

  Future<List<InboxMessageEntity>> call(String messageId) =>
      _repository.markMessageRead(messageId);
}
