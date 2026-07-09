import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/live_chat_provider.dart';
import '../theme/live_chat_tokens.dart';
import '../widgets/chat_attachment_preview.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';

class LiveChatSupportScreen extends ConsumerStatefulWidget {
  const LiveChatSupportScreen({super.key});

  @override
  ConsumerState<LiveChatSupportScreen> createState() =>
      _LiveChatSupportScreenState();
}

class _LiveChatSupportScreenState extends ConsumerState<LiveChatSupportScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(liveChatControllerProvider.notifier).loadInitialMessages();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _popOrHelpCenter(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.helpCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(liveChatControllerProvider);
    final c = ref.read(liveChatControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.04).clamp(16.0, 16.0);
    final titleSize = (w * 0.048).clamp(17.0, 19.0);
    final statusSize = (w * 0.032).clamp(12.0, 13.0);
    final logoSize = (w * 0.09).clamp(34.0, 38.0);

    ref.listen(liveChatControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
      if (prev?.inputText != next.inputText &&
          next.inputText.isEmpty &&
          _textController.text.isNotEmpty) {
        _textController.clear();
      }
      final snack = next.snackMessage;
      if (snack != null && snack.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snack),
            backgroundColor: LiveChatTokens.inputBar,
          ),
        );
        c.clearSnack();
      }
    });

    return Scaffold(
      backgroundColor: LiveChatTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => _popOrHelpCenter(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: LiveChatTokens.accent,
                          size: (w * 0.05).clamp(20.0, 22.0),
                        ),
                      ),
                      SizedBox(width: (w * 0.02).clamp(6.0, 8.0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Chat Support',
                              style: TextStyle(
                                color: LiveChatTokens.white,
                                fontWeight: FontWeight.w800,
                                fontSize: titleSize,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: (w * 0.015).clamp(4.0, 6.0)),
                            Row(
                              children: [
                                if (s.isSupportOnline) ...[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: LiveChatTokens.online,
                                    ),
                                  ),
                                  SizedBox(width: (w * 0.02).clamp(6.0, 8.0)),
                                ],
                                Text(
                                  s.isSupportOnline
                                      ? 'Support team is online'
                                      : 'Support team is offline',
                                  style: TextStyle(
                                    color: LiveChatTokens.muted,
                                    fontSize: statusSize,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: LiveChatTokens.white,
                          border: Border.all(color: LiveChatTokens.border),
                        ),
                        alignment: Alignment.center,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF2F6BFF),
                              Color(0xFF9B59FF),
                              Color(0xFFFF6BB3),
                            ],
                          ).createShader(bounds),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: logoSize * 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: LiveChatTokens.border,
            ),
            if (s.errorMessage != null)
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                child: Text(
                  s.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                itemCount: s.messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageBubble(message: s.messages[index]);
                },
              ),
            ),
            ChatAttachmentPreview(
              attachmentPath: s.selectedAttachmentPath,
              onRemove: c.removeAttachment,
            ),
            ChatInputBar(
              controller: _textController,
              onChanged: c.updateInputText,
              onSend: () async {
                await c.sendMessage();
                _scrollToBottom();
              },
              onCamera: c.pickImageFromCamera,
              onAttachment: c.pickAttachment,
              canSend: s.canSend,
              isSending: s.isSending,
            ),
          ],
        ),
      ),
    );
  }
}
