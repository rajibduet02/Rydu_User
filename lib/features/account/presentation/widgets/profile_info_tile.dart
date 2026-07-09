import 'package:flutter/material.dart';

import '../theme/profile_details_tokens.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.showVerified = false,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showVerified;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.032).clamp(12.0, 13.0);
    final valueSize = (w * 0.04).clamp(15.0, 16.0);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (w * 0.045).clamp(16.0, 18.0),
                vertical: (w * 0.04).clamp(14.0, 16.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: ProfileDetailsTokens.label,
                            fontSize: labelSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: (w * 0.012).clamp(4.0, 6.0)),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: ProfileDetailsTokens.white,
                                  fontSize: valueSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (showVerified) ...[
                              SizedBox(width: (w * 0.02).clamp(8.0, 10.0)),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ProfileDetailsTokens.verified,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: ProfileDetailsTokens.muted,
                    size: (w * 0.06).clamp(22.0, 24.0),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: ProfileDetailsTokens.border,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
