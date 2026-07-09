import '../entities/chat_message_entity.dart';
import '../repositories/support_repository.dart';

class GetLiveChatMessagesUsecase {
  GetLiveChatMessagesUsecase(this._repository);

  final SupportRepository _repository;

  Future<List<ChatMessageEntity>> call() => _repository.getLiveChatMessages();
}
