import 'package:flutter/material.dart';

import '../theme/security_screen_tokens.dart';

class SecurityStatusCard extends StatelessWidget {
  const SecurityStatusCard({
    super.key,
    required this.status,
    required this.hasThreats,
  });

  final String status;
  final bool hasThreats;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final labelSize = (w * 0.028).clamp(10.0, 11.0);
    final statusSize = (w * 0.09).clamp(32.0, 38.0);
    final footerSize = (w * 0.032).clamp(12.0, 13.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.05).clamp(18.0, 20.0)),
      decoration: BoxDecoration(
        color: SecurityScreenTokens.accent,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SECURITY STATUS',
            style: TextStyle(
              color: SecurityScreenTokens.statusLabel,
              fontWeight: FontWeight.w700,
              fontSize: labelSize,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
          Text(
            status,
            style: TextStyle(
              color: SecurityScreenTokens.accentDark,
              fontWeight: FontWeight.w800,
              fontSize: statusSize,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: (w * 0.045).clamp(17.0, 18.0),
                color: SecurityScreenTokens.accentDark,
              ),
              SizedBox(width: (w * 0.02).clamp(6.0, 8.0)),
              Text(
                hasThreats ? 'Threats detected' : 'No threats detected',
                style: TextStyle(
                  color: SecurityScreenTokens.accentDark,
                  fontWeight: FontWeight.w600,
                  fontSize: footerSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
