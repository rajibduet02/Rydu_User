enum ChatSenderType { support, user }

class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.senderType,
    required this.senderName,
    required this.message,
    required this.time,
    this.attachmentPath,
    required this.isMine,
  });

  final String id;
  final ChatSenderType senderType;
  final String senderName;
  final String message;
  final String time;
  final String? attachmentPath;
  final bool isMine;
}
