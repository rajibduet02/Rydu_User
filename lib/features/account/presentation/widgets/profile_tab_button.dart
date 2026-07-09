import 'package:flutter/material.dart';

import '../theme/profile_details_tokens.dart';

class ProfileTabButton extends StatelessWidget {
  const ProfileTabButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = (w * 0.22).clamp(80.0, 96.0);
    final radius = (w * 0.035).clamp(12.0, 14.0);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            height: size,
            decoration: BoxDecoration(
              color: isSelected
                  ? ProfileDetailsTokens.tabActive
                  : ProfileDetailsTokens.tabWell,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: isSelected
                    ? ProfileDetailsTokens.border.withValues(alpha: 0.9)
                    : ProfileDetailsTokens.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? ProfileDetailsTokens.white
                      : ProfileDetailsTokens.muted,
                  size: (w * 0.06).clamp(24.0, 26.0),
                ),
                SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? ProfileDetailsTokens.white
                        : ProfileDetailsTokens.muted,
                    fontSize: (w * 0.028).clamp(10.0, 11.0),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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
