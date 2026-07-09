import 'package:flutter/material.dart';

import '../theme/account_screen_tokens.dart';
import 'membership_badge.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({
    super.key,
    required this.userName,
    required this.membershipName,
    required this.rating,
    required this.rideCount,
    required this.onAvatarTap,
    required this.onMembershipTap,
    required this.onRatingTap,
  });

  final String userName;
  final String membershipName;
  final String rating;
  final int rideCount;
  final VoidCallback onAvatarTap;
  final VoidCallback onMembershipTap;
  final VoidCallback onRatingTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final nameSize = (w * 0.095).clamp(32.0, 40.0);
    final avatar = (w * 0.22).clamp(72.0, 84.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  color: AccountScreenTokens.white,
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              SizedBox(height: (w * 0.02).clamp(8.0, 12.0)),
              MembershipBadge(label: membershipName, onTap: onMembershipTap),
              SizedBox(height: (w * 0.025).clamp(10.0, 14.0)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRatingTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Ink(
                    padding: EdgeInsets.symmetric(
                      horizontal: (w * 0.03).clamp(10.0, 14.0),
                      vertical: (w * 0.018).clamp(6.0, 8.0),
                    ),
                    decoration: BoxDecoration(
                      color: AccountScreenTokens.card,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AccountScreenTokens.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AccountScreenTokens.gold,
                          size: (w * 0.045).clamp(16.0, 18.0),
                        ),
                        SizedBox(width: (w * 0.015).clamp(4.0, 6.0)),
                        Text(
                          rating,
                          style: TextStyle(
                            color: AccountScreenTokens.white,
                            fontSize: (w * 0.038).clamp(14.0, 15.0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: AccountScreenTokens.muted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '$rideCount rides',
                          style: TextStyle(
                            color: AccountScreenTokens.muted,
                            fontSize: (w * 0.035).clamp(13.0, 14.0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: (w * 0.01).clamp(4.0, 6.0)),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AccountScreenTokens.muted,
                          size: (w * 0.055).clamp(20.0, 22.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: (w * 0.03).clamp(10.0, 14.0)),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAvatarTap,
            child: Ink(
              width: avatar,
              height: avatar,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AccountScreenTokens.accent.withValues(alpha: 0.25),
                    AccountScreenTokens.accentSoft.withValues(alpha: 0.12),
                  ],
                ),
                border: Border.all(
                  color: AccountScreenTokens.accent.withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: avatar * 0.48,
                color: AccountScreenTokens.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
