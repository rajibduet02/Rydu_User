import '../repositories/chat_repository.dart';

class SendChatMessageUsecase {
  SendChatMessageUsecase(this._repository);

  final ChatRepository _repository;

  Future<void> call({required String rideId, required String text}) {
    return _repository.sendMessage(rideId: rideId, text: text);
  }
}
