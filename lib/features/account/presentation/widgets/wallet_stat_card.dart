import 'package:flutter/material.dart';

import '../theme/wallet_tokens.dart';

class WalletStatCard extends StatelessWidget {
  const WalletStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.05).clamp(18.0, 20.0);
    final pad = (w * 0.04).clamp(14.0, 16.0);
    final labelSize = (w * 0.028).clamp(11.0, 12.0);
    final valueSize = (w * 0.055).clamp(18.0, 22.0);
    final iconSize = (w * 0.06).clamp(22.0, 24.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [WalletTokens.cardTop, WalletTokens.cardBottom],
        ),
        border: Border.all(color: WalletTokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
            Text(
              label,
              style: TextStyle(
                color: WalletTokens.muted,
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: (w * 0.008).clamp(4.0, 6.0)),
            Text(
              value,
              style: TextStyle(
                color: WalletTokens.white,
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
