import 'package:flutter/material.dart';

import '../theme/report_ride_issue_tokens.dart';

class SupportNoticeCard extends StatelessWidget {
  const SupportNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final bodySize = (w * 0.035).clamp(13.0, 14.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: ReportRideIssueTokens.muted,
          size: (w * 0.05).clamp(20.0, 22.0),
        ),
        SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: ReportRideIssueTokens.muted,
                fontSize: bodySize,
                height: 1.45,
              ),
              children: const [
                TextSpan(text: 'Reports are typically reviewed within '),
                TextSpan(
                  text: '24 hours',
                  style: TextStyle(
                    color: ReportRideIssueTokens.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text:
                      '. Providing clear photos helps us resolve issues faster.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
