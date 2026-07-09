import 'package:flutter/material.dart';

import '../theme/family_profile_tokens.dart';

class FamilyFeatureTile extends StatelessWidget {
  const FamilyFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.042).clamp(15.0, 17.0);
    final bodySize = (w * 0.036).clamp(13.0, 14.5);

    return Padding(
      padding: EdgeInsets.only(bottom: (w * 0.06).clamp(22.0, 28.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: FamilyProfileTokens.white,
            size: (w * 0.065).clamp(24.0, 28.0),
          ),
          SizedBox(width: (w * 0.045).clamp(16.0, 20.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: FamilyProfileTokens.white,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: (w * 0.02).clamp(6.0, 8.0)),
                Text(
                  description,
                  style: TextStyle(
                    color: FamilyProfileTokens.muted,
                    fontSize: bodySize,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
