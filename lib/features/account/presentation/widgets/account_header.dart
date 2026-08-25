import 'package:flutter/material.dart';

import '../../domain/entities/passenger_profile.dart';
import '../theme/account_screen_tokens.dart';
import 'passenger_avatar.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({
    super.key,
    required this.profile,
    required this.isUploadingAvatar,
    required this.onAvatarTap,
    required this.onEditProfile,
  });

  final PassengerProfile? profile;
  final bool isUploadingAvatar;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final nameSize = (w * 0.07).clamp(24.0, 32.0);
    final avatar = (w * 0.22).clamp(72.0, 84.0);
    final name = profile?.displayName ?? 'Account';
    final email = profile?.email.trim() ?? '';
    final phone = profile?.phone?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: AccountScreenTokens.white,
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              if (email.isNotEmpty) ...[
                SizedBox(height: (w * 0.018).clamp(6.0, 10.0)),
                Text(
                  email,
                  style: TextStyle(
                    color: AccountScreenTokens.muted,
                    fontSize: (w * 0.038).clamp(13.0, 15.0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (phone != null && phone.isNotEmpty) ...[
                SizedBox(height: (w * 0.01).clamp(4.0, 6.0)),
                Text(
                  phone,
                  style: TextStyle(
                    color: AccountScreenTokens.muted,
                    fontSize: (w * 0.035).clamp(12.0, 14.0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: (w * 0.03).clamp(10.0, 14.0)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEditProfile,
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
                          Icons.edit_outlined,
                          color: AccountScreenTokens.accent,
                          size: (w * 0.045).clamp(16.0, 18.0),
                        ),
                        SizedBox(width: (w * 0.015).clamp(4.0, 6.0)),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: AccountScreenTokens.white,
                            fontSize: (w * 0.035).clamp(13.0, 14.0),
                            fontWeight: FontWeight.w700,
                          ),
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
        PassengerAvatar(
          profile: profile,
          size: avatar,
          isUploading: isUploadingAvatar,
          onTap: onAvatarTap,
        ),
      ],
    );
  }
}
