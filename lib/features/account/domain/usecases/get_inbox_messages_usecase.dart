import '../entities/inbox_message_entity.dart';
import '../repositories/inbox_repository.dart';

class GetInboxMessagesUsecase {
  GetInboxMessagesUsecase(this._repository);

  final InboxRepository _repository;

  Future<List<InboxMessageEntity>> call() => _repository.getMessages();
}
