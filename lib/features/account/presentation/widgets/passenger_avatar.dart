import 'package:flutter/material.dart';

import '../../../../core/network/profile_image_url.dart';
import '../../domain/entities/passenger_profile.dart';
import '../theme/account_screen_tokens.dart';

class PassengerAvatar extends StatelessWidget {
  const PassengerAvatar({
    super.key,
    required this.profile,
    required this.size,
    this.isUploading = false,
    this.onTap,
  });

  final PassengerProfile? profile;
  final double size;
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = resolveProfileImageUrl(profile?.profileImageUrl);
    final initials = profile?.initials ?? 'A';

    Widget child;
    if (url != null) {
      child = ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(initials),
        ),
      );
    } else {
      child = _fallback(initials);
    }

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AccountScreenTokens.accent.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                child: child,
              ),
              if (isUploading)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x88000000),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback(String initials) {
    return DecoratedBox(
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
      ),
      child: Center(
        child: profile == null
            ? Icon(
                Icons.person_rounded,
                size: size * 0.48,
                color: AccountScreenTokens.accent,
              )
            : Text(
                initials,
                style: TextStyle(
                  color: AccountScreenTokens.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.32,
                ),
              ),
      ),
    );
  }
}
