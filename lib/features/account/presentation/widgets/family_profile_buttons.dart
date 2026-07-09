import 'package:flutter/material.dart';

import '../theme/family_profile_tokens.dart';

class FamilyProfileButtons extends StatelessWidget {
  const FamilyProfileButtons({
    super.key,
    required this.onAdultTap,
    required this.onTeenTap,
    this.isLoading = false,
  });

  final VoidCallback onAdultTap;
  final VoidCallback onTeenTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final buttonHeight = (w * 0.14).clamp(52.0, 56.0);
    final fontSize = (w * 0.042).clamp(15.0, 17.0);
    final radius = (w * 0.035).clamp(12.0, 16.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        hPad,
        16,
        hPad,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: FilledButton(
              onPressed: isLoading ? null : onAdultTap,
              style: FilledButton.styleFrom(
                backgroundColor: FamilyProfileTokens.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFF3A3A3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      "I'm an adult",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                      ),
                    ),
            ),
          ),
          SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: OutlinedButton(
              onPressed: isLoading ? null : onTeenTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: FamilyProfileTokens.white,
                backgroundColor: FamilyProfileTokens.outlineButton,
                side: const BorderSide(color: FamilyProfileTokens.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              child: Text(
                "I'm a teen",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
