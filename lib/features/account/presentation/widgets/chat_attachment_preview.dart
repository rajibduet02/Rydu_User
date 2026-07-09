import 'package:flutter/material.dart';

import '../theme/live_chat_tokens.dart';

class ChatAttachmentPreview extends StatelessWidget {
  const ChatAttachmentPreview({
    super.key,
    required this.attachmentPath,
    required this.onRemove,
  });

  final String? attachmentPath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachmentPath == null || attachmentPath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final w = MediaQuery.sizeOf(context).width;
    final thumb = (w * 0.18).clamp(64.0, 72.0);
    final hPad = (w * 0.04).clamp(16.0, 16.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: thumb,
              height: thumb,
              decoration: BoxDecoration(
                color: LiveChatTokens.iconWell,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LiveChatTokens.border),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.image_outlined,
                color: LiveChatTokens.muted,
                size: thumb * 0.4,
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: LiveChatTokens.supportBubble,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: LiveChatTokens.white,
                    ),
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
