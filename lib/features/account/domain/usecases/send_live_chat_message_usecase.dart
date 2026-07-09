import '../entities/chat_message_entity.dart';
import '../repositories/support_repository.dart';

class SendLiveChatMessageUsecase {
  SendLiveChatMessageUsecase(this._repository);

  final SupportRepository _repository;

  Future<void> call(ChatMessageEntity message) =>
      _repository.sendLiveChatMessage(message);
}
