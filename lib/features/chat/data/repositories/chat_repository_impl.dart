import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteDatasource _remote;

  @override
  Stream<List<ChatMessageEntity>> messages(String rideId) {
    return _remote
        .listen(rideId)
        .map(
          (list) => list
              .map(
                (m) =>
                    ChatMessageEntity(id: m.id, body: m.body, isMine: m.isMine),
              )
              .toList(),
        );
  }

  @override
  Future<void> sendMessage({required String rideId, required String text}) {
    return _remote.send(rideId, text);
  }
}
