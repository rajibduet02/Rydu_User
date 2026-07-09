import 'package:flutter/material.dart';

import '../theme/reserve_tokens.dart';

class ReserveFeatureTile extends StatelessWidget {
  const ReserveFeatureTile({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ReserveTokens.featureIconSize,
          height: ReserveTokens.featureIconSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ReserveTokens.iconWell,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: ReserveTokens.accentBlue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ReserveTokens.white,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
