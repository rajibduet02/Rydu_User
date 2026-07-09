import 'package:flutter/material.dart';

import '../theme/profile_details_tokens.dart';

class ProfileDetailsHeader extends StatelessWidget {
  const ProfileDetailsHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ProfileDetailsTokens.white,
            size: (w * 0.05).clamp(20.0, 22.0),
          ),
        ),
        Container(
          width: (w * 0.055).clamp(20.0, 24.0),
          height: (w * 0.055).clamp(20.0, 24.0),
          decoration: BoxDecoration(
            color: ProfileDetailsTokens.accent,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
        Text(
          'RYD U Account',
          style: TextStyle(
            color: ProfileDetailsTokens.white,
            fontWeight: FontWeight.w600,
            fontSize: (w * 0.042).clamp(15.0, 17.0),
          ),
        ),
      ],
    );
  }
}
