import '../models/chat_message_model.dart';

abstract interface class ChatRemoteDatasource {
  Stream<List<ChatMessageModel>> listen(String rideId);

  Future<void> send(String rideId, String text);
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  ChatRemoteDatasourceImpl();

  @override
  Stream<List<ChatMessageModel>> listen(String rideId) async* {
    yield const [];
  }

  @override
  Future<void> send(String rideId, String text) async {}
}
