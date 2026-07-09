import 'package:flutter/material.dart';

import '../theme/activity_screen_tokens.dart';

class ActivityEmptyState extends StatelessWidget {
  const ActivityEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = (w * 0.048).clamp(17.0, 20.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: (w * 0.06).clamp(20.0, 28.0)),
      child: Center(
        child: Text(
          "You don't have any recent activity",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ActivityScreenTokens.muted,
            fontSize: size,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
