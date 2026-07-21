import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../theme/ride_booking_tokens.dart';

/// Pickup + destination search card.
///
/// Uses an intentional light field surface with dark text so typed values stay
/// readable regardless of Material [InputDecorationTheme] fill defaults.
class LocationInputCard extends StatelessWidget {
  const LocationInputCard({
    super.key,
    required this.pickupController,
    required this.destinationController,
    required this.pickupFocusNode,
    required this.destinationFocusNode,
    required this.onPickupChanged,
    required this.onDestinationChanged,
    required this.onPickupTap,
    required this.onDestinationTap,
    required this.onPlusTap,
    this.pickupHint = 'Choose pickup location',
    this.destinationHint = 'Where to?',
    this.isPickupLoading = false,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final FocusNode pickupFocusNode;
  final FocusNode destinationFocusNode;
  final ValueChanged<String> onPickupChanged;
  final ValueChanged<String> onDestinationChanged;
  final VoidCallback onPickupTap;
  final VoidCallback onDestinationTap;
  final VoidCallback onPlusTap;
  final String pickupHint;
  final String destinationHint;
  final bool isPickupLoading;

  static const fieldTextStyle = TextStyle(
    color: Color(0xFF111827),
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const hintTextStyle = TextStyle(
    color: Color(0xFF6B7280),
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: RideBookingTokens.accent,
          selectionColor: RideBookingTokens.accent.withValues(alpha: 0.25),
          selectionHandleColor: RideBookingTokens.accent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 56, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(RideBookingTokens.cardRadius),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _PickupDot(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pickupController,
                        focusNode: pickupFocusNode,
                        onChanged: onPickupChanged,
                        onTap: onPickupTap,
                        style: fieldTextStyle,
                        cursorColor: RideBookingTokens.accent,
                        keyboardAppearance: Brightness.light,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          hintText: isPickupLoading
                              ? 'Locating pickup…'
                              : pickupHint,
                          hintStyle: hintTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _DestinationDot(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: destinationController,
                        focusNode: destinationFocusNode,
                        onChanged: onDestinationChanged,
                        onTap: onDestinationTap,
                        style: fieldTextStyle,
                        cursorColor: RideBookingTokens.accent,
                        keyboardAppearance: Brightness.light,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          hintText: destinationHint,
                          hintStyle: hintTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPlusTap,
                  customBorder: const CircleBorder(),
                  child: Ink(
                    width: RideBookingTokens.plusButtonSize,
                    height: RideBookingTokens.plusButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3F4F6),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF4B5563),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupDot extends StatelessWidget {
  const _PickupDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RideBookingTokens.accent, width: 2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: RideBookingTokens.accent,
        ),
      ),
    );
  }
}

class _DestinationDot extends StatelessWidget {
  const _DestinationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppDarkText.muted,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
