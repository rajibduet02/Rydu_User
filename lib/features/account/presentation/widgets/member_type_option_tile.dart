import 'package:flutter/material.dart';

import '../theme/family_add_member_tokens.dart';

class MemberTypeOptionTile extends StatelessWidget {
  const MemberTypeOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.042).clamp(15.0, 17.0);
    final subtitleSize = (w * 0.034).clamp(13.0, 14.0);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: FamilyAddMemberTokens.white,
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
                            color: FamilyAddMemberTokens.white,
                            fontWeight: FontWeight.w700,
                            fontSize: titleSize,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: FamilyAddMemberTokens.muted,
                            fontSize: subtitleSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RadioIndicator(isSelected: isSelected),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: FamilyAddMemberTokens.divider,
          ),
      ],
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: FamilyAddMemberTokens.white, width: 2),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: FamilyAddMemberTokens.white,
              ),
            )
          : null,
    );
  }
}
