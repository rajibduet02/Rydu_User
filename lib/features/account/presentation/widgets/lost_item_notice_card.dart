import 'package:flutter/material.dart';

import '../theme/report_lost_item_tokens.dart';

class LostItemNoticeCard extends StatelessWidget {
  const LostItemNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final bodySize = (w * 0.035).clamp(13.0, 14.0);
    final radius = (w * 0.03).clamp(10.0, 12.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.04).clamp(14.0, 16.0)),
      decoration: BoxDecoration(
        color: ReportLostItemTokens.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ReportLostItemTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: ReportLostItemTokens.orange,
            size: (w * 0.05).clamp(20.0, 22.0),
          ),
          SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
          Expanded(
            child: Text(
              'Your contact details will only be shared when needed for item recovery.',
              style: TextStyle(
                color: ReportLostItemTokens.muted,
                fontSize: bodySize,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
