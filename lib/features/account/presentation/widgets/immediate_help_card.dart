import 'package:flutter/material.dart';

import '../theme/help_center_tokens.dart';

class ImmediateHelpCard extends StatelessWidget {
  const ImmediateHelpCard({
    super.key,
    required this.onStartLiveChat,
    required this.onCallNow,
  });

  final VoidCallback onStartLiveChat;
  final VoidCallback onCallNow;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.055).clamp(18.0, 22.0);
    final pad = (w * 0.045).clamp(18.0, 24.0);
    final titleSize = (w * 0.045).clamp(16.0, 18.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final btnText = (w * 0.038).clamp(13.0, 15.0);
    final narrow = w < 380;

    final chatBtn = FilledButton(
      onPressed: onStartLiveChat,
      style: FilledButton.styleFrom(
        backgroundColor: HelpCenterTokens.accent,
        foregroundColor: HelpCenterTokens.white,
        padding: EdgeInsets.symmetric(vertical: (w * 0.035).clamp(12.0, 14.0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        'Start Live Chat',
        style: TextStyle(fontSize: btnText, fontWeight: FontWeight.w600),
      ),
    );

    final callBtn = FilledButton(
      onPressed: onCallNow,
      style: FilledButton.styleFrom(
        backgroundColor: HelpCenterTokens.iconWell,
        foregroundColor: HelpCenterTokens.white,
        padding: EdgeInsets.symmetric(vertical: (w * 0.035).clamp(12.0, 14.0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: HelpCenterTokens.border),
        ),
      ),
      child: Text(
        'Call Now',
        style: TextStyle(fontSize: btnText, fontWeight: FontWeight.w600),
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HelpCenterTokens.accent.withValues(alpha: 0.10),
            HelpCenterTokens.accentSoft.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: HelpCenterTokens.accent.withValues(alpha: 0.40),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Need Immediate Help?',
            style: TextStyle(
              color: HelpCenterTokens.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
          Text(
            'Our support team is available 24/7 to assist you',
            style: TextStyle(
              color: HelpCenterTokens.muted,
              fontSize: subSize,
              height: 1.4,
            ),
          ),
          SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
          if (narrow) ...[
            chatBtn,
            SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
            callBtn,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: chatBtn),
                SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
                Expanded(child: callBtn),
              ],
            ),
        ],
      ),
    );
  }
}
