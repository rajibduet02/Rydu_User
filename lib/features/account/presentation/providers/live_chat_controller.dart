import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import 'account_dependencies.dart';

class LiveChatState {
  const LiveChatState({
    this.messages = const [],
    this.inputText = '',
    this.selectedAttachmentPath,
    this.isSending = false,
    this.errorMessage,
    this.isSupportOnline = true,
    this.snackMessage,
  });

  final List<ChatMessage> messages;
  final String inputText;
  final String? selectedAttachmentPath;
  final bool isSending;
  final String? errorMessage;
  final bool isSupportOnline;
  final String? snackMessage;

  bool get canSend =>
      (inputText.trim().isNotEmpty || selectedAttachmentPath != null) &&
      !isSending;

  LiveChatState copyWith({
    List<ChatMessage>? messages,
    String? inputText,
    String? selectedAttachmentPath,
    bool clearAttachment = false,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    bool? isSupportOnline,
    String? snackMessage,
    bool clearSnack = false,
  }) {
    return LiveChatState(
      messages: messages ?? this.messages,
      inputText: inputText ?? this.inputText,
      selectedAttachmentPath: clearAttachment
          ? null
          : (selectedAttachmentPath ?? this.selectedAttachmentPath),
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSupportOnline: isSupportOnline ?? this.isSupportOnline,
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
    );
  }
}

class LiveChatController extends Notifier<LiveChatState> {
  int _idCounter = 100;

  @override
  LiveChatState build() => const LiveChatState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSnack() {
    state = state.copyWith(clearSnack: true);
  }

  Future<void> loadInitialMessages() async {
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final messages = await ref
          .read(getLiveChatMessagesUsecaseProvider)
          .call();
      state = state.copyWith(
        messages: messages,
        isSending: false,
        isSupportOnline: true,
      );
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Could not load chat.',
      );
    }
  }

  void updateInputText(String value) {
    state = state.copyWith(inputText: value, clearError: true);
  }

  String _formatTimeNow() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Future<void> sendMessage() async {
    if (!state.canSend) return;
    final text = state.inputText.trim();
    final attachment = state.selectedAttachmentPath;
    final body = text.isNotEmpty
        ? text
        : (attachment != null ? '[Attachment]' : '');
    if (body.isEmpty) return;

    _idCounter += 1;
    final newMessage = ChatMessageEntity(
      id: 'u$_idCounter',
      senderType: ChatSenderType.user,
      senderName: 'You',
      message: body,
      time: _formatTimeNow(),
      attachmentPath: attachment,
      isMine: true,
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
      inputText: '',
      clearAttachment: true,
      isSending: true,
      clearError: true,
    );

    try {
      await ref.read(sendLiveChatMessageUsecaseProvider).call(newMessage);
      state = state.copyWith(isSending: false);
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Could not send message.',
      );
    }
  }

  void pickImageFromCamera() {
    state = state.copyWith(
      selectedAttachmentPath: 'demo://camera-preview',
      snackMessage: 'Camera picker coming soon. (TODO: image_picker)',
      clearError: true,
    );
  }

  void pickAttachment() {
    state = state.copyWith(
      selectedAttachmentPath: 'demo://file-preview',
      snackMessage: 'Attachment picker coming soon. (TODO: file_picker)',
      clearError: true,
    );
  }

  void removeAttachment() {
    state = state.copyWith(clearAttachment: true, clearError: true);
  }
}
