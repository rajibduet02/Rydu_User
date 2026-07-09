import 'package:flutter/material.dart';

import '../models/inbox_message.dart';
import '../theme/inbox_tokens.dart';

class InboxMessageCard extends StatelessWidget {
  const InboxMessageCard({
    super.key,
    required this.message,
    required this.onTap,
  });

  final InboxMessage message;
  final VoidCallback onTap;

  static IconData _iconFor(String type) {
    switch (type) {
      case 'bolt':
        return Icons.bolt_rounded;
      case 'info':
        return Icons.info_outline_rounded;
      case 'alert':
        return Icons.error_outline_rounded;
      case 'bell':
        return Icons.notifications_none_rounded;
      case 'gift':
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.05).clamp(18.0, 20.0);
    final pad = (w * 0.04).clamp(14.0, 16.0);
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final timeSize = (w * 0.028).clamp(11.0, 12.0);
    final iconBox = (w * 0.12).clamp(44.0, 48.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [InboxTokens.cardTop, InboxTokens.cardBottom],
            ),
            border: Border.all(
              color: message.isUnread
                  ? InboxTokens.borderUnread
                  : InboxTokens.border,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: message.iconColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: iconBox,
                    height: iconBox,
                    child: Icon(
                      _iconFor(message.iconType),
                      color: message.iconColor,
                      size: iconBox * 0.42,
                    ),
                  ),
                ),
                SizedBox(width: (w * 0.035).clamp(14.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              message.title,
                              style: TextStyle(
                                color: InboxTokens.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (message.isUnread) ...[
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: InboxTokens.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: (w * 0.015).clamp(6.0, 8.0)),
                      Text(
                        message.subtitle,
                        style: TextStyle(
                          color: InboxTokens.muted,
                          fontSize: subSize,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
                      Text(
                        message.time,
                        style: TextStyle(
                          color: InboxTokens.muted,
                          fontSize: timeSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
