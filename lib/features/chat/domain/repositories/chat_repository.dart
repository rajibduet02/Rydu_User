import '../entities/chat_message_entity.dart';

abstract interface class ChatRepository {
  Stream<List<ChatMessageEntity>> messages(String rideId);

  Future<void> sendMessage({required String rideId, required String text});
}
