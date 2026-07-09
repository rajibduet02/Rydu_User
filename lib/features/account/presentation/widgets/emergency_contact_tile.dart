import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';
import '../theme/safety_resources_tokens.dart';

class EmergencyContactTile extends StatelessWidget {
  const EmergencyContactTile({
    super.key,
    required this.contact,
    required this.onCall,
    this.showDivider = true,
  });

  final EmergencyContact contact;
  final VoidCallback onCall;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.042).clamp(15.0, 16.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final callBtn = (w * 0.11).clamp(42.0, 46.0);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.045).clamp(16.0, 18.0),
            vertical: (w * 0.04).clamp(14.0, 16.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.title,
                      style: TextStyle(
                        color: SafetyResourcesTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize,
                      ),
                    ),
                    SizedBox(height: (w * 0.01).clamp(4.0, 6.0)),
                    Text(
                      contact.subtitle,
                      style: TextStyle(
                        color: SafetyResourcesTokens.muted,
                        fontSize: subSize,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: SafetyResourcesTokens.iconWell,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onCall,
                  child: SizedBox(
                    width: callBtn,
                    height: callBtn,
                    child: Icon(
                      Icons.phone_rounded,
                      color: SafetyResourcesTokens.white,
                      size: callBtn * 0.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: SafetyResourcesTokens.border,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
