import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../theme/live_chat_tokens.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth = w * 0.78;
    final bubbleRadius = (w * 0.04).clamp(14.0, 18.0);
    final nameSize = (w * 0.028).clamp(10.0, 11.0);
    final bodySize = (w * 0.038).clamp(14.0, 15.0);
    final timeSize = (w * 0.03).clamp(11.0, 12.0);
    final avatarSize = (w * 0.075).clamp(28.0, 32.0);

    if (message.isMine) {
      return Padding(
        padding: EdgeInsets.only(bottom: (w * 0.05).clamp(18.0, 22.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (w * 0.04).clamp(14.0, 16.0),
                  vertical: (w * 0.03).clamp(12.0, 14.0),
                ),
                decoration: BoxDecoration(
                  color: LiveChatTokens.userBubble,
                  borderRadius: BorderRadius.circular(bubbleRadius),
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: LiveChatTokens.white,
                    fontSize: bodySize,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: (w * 0.015).clamp(6.0, 8.0)),
            Text(
              message.time,
              style: TextStyle(color: LiveChatTokens.muted, fontSize: timeSize),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: (w * 0.05).clamp(18.0, 22.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.senderName.toUpperCase(),
            style: TextStyle(
              color: LiveChatTokens.white.withValues(alpha: 0.85),
              fontSize: nameSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: (w * 0.015).clamp(6.0, 8.0)),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: (w * 0.04).clamp(14.0, 16.0),
                vertical: (w * 0.03).clamp(12.0, 14.0),
              ),
              decoration: BoxDecoration(
                color: LiveChatTokens.supportBubble,
                borderRadius: BorderRadius.circular(bubbleRadius),
                border: Border.all(
                  color: LiveChatTokens.border.withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: LiveChatTokens.white,
                  fontSize: bodySize,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
          Row(
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: LiveChatTokens.iconWell,
                backgroundImage: null,
                child: Icon(
                  Icons.person_rounded,
                  color: LiveChatTokens.muted,
                  size: avatarSize * 0.55,
                ),
              ),
              SizedBox(width: (w * 0.025).clamp(8.0, 10.0)),
              Text(
                message.time,
                style: TextStyle(
                  color: LiveChatTokens.muted,
                  fontSize: timeSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
