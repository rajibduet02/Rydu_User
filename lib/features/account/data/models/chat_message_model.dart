import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.senderType,
    required super.senderName,
    required super.message,
    required super.time,
    super.attachmentPath,
    required super.isMine,
  });

  static List<ChatMessageModel> seed() => const [
    ChatMessageModel(
      id: 'm1',
      senderType: ChatSenderType.support,
      senderName: 'ALEX',
      message: 'Hi, how can we help you today?',
      time: '10:42 AM',
      isMine: false,
    ),
    ChatMessageModel(
      id: 'm2',
      senderType: ChatSenderType.user,
      senderName: 'You',
      message: 'I need help with my recent ride.',
      time: '10:43 AM',
      isMine: true,
    ),
    ChatMessageModel(
      id: 'm3',
      senderType: ChatSenderType.support,
      senderName: 'ALEX',
      message:
          'Sure, I can help you with that. Could you share a screenshot of the issue?',
      time: '10:44 AM',
      isMine: false,
    ),
  ];

  ChatMessageEntity toEntity() => this;
}
