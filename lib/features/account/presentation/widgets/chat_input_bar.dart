import 'package:flutter/material.dart';

import '../theme/live_chat_tokens.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.onCamera,
    required this.onAttachment,
    required this.canSend,
    this.isSending = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback onCamera;
  final VoidCallback onAttachment;
  final bool canSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.04).clamp(16.0, 16.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final barRadius = (w * 0.07).clamp(26.0, 30.0);
    final iconSize = (w * 0.055).clamp(22.0, 24.0);
    final sendSize = (w * 0.11).clamp(42.0, 46.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        hPad,
        8,
        hPad,
        bottomPad > 0 ? bottomPad : 12,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (w * 0.03).clamp(10.0, 12.0),
          vertical: (w * 0.015).clamp(6.0, 8.0),
        ),
        decoration: BoxDecoration(
          color: LiveChatTokens.inputBar,
          borderRadius: BorderRadius.circular(barRadius),
          border: Border.all(color: LiveChatTokens.border),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: isSending ? null : onCamera,
              icon: Icon(
                Icons.photo_camera_outlined,
                color: LiveChatTokens.muted,
                size: iconSize,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            IconButton(
              onPressed: isSending ? null : onAttachment,
              icon: Icon(
                Icons.attach_file_rounded,
                color: LiveChatTokens.muted,
                size: iconSize,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                enabled: !isSending,
                style: TextStyle(
                  color: LiveChatTokens.white,
                  fontSize: (w * 0.038).clamp(14.0, 15.0),
                ),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: LiveChatTokens.muted.withValues(alpha: 0.75),
                    fontSize: (w * 0.038).clamp(14.0, 15.0),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: canSend && !isSending ? (_) => onSend() : null,
                maxLines: 4,
                minLines: 1,
              ),
            ),
            SizedBox(width: (w * 0.02).clamp(6.0, 8.0)),
            Material(
              color: canSend && !isSending
                  ? LiveChatTokens.accent
                  : LiveChatTokens.accent.withValues(alpha: 0.35),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: canSend && !isSending ? onSend : null,
                child: SizedBox(
                  width: sendSize,
                  height: sendSize,
                  child: isSending
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LiveChatTokens.white,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: LiveChatTokens.white,
                          size: sendSize * 0.45,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
