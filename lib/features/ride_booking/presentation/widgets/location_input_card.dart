import 'package:flutter/material.dart';

import '../theme/ride_booking_tokens.dart';

class LocationInputCard extends StatelessWidget {
  const LocationInputCard({
    super.key,
    required this.pickupController,
    required this.destinationController,
    required this.destinationFocusNode,
    required this.onPickupChanged,
    required this.onDestinationChanged,
    required this.onDestinationTap,
    required this.onPlusTap,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final FocusNode destinationFocusNode;
  final ValueChanged<String> onPickupChanged;
  final ValueChanged<String> onDestinationChanged;
  final VoidCallback onDestinationTap;
  final VoidCallback onPlusTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 56, 20),
          decoration: BoxDecoration(
            color: RideBookingTokens.cardFill,
            borderRadius: BorderRadius.circular(RideBookingTokens.cardRadius),
            border: Border.all(color: RideBookingTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _PickupDot(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: pickupController,
                      onChanged: onPickupChanged,
                      style: const TextStyle(
                        color: RideBookingTokens.titleWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                      cursorColor: RideBookingTokens.accent,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: RideBookingTokens.border,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _DestinationDot(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: destinationController,
                      focusNode: destinationFocusNode,
                      onChanged: onDestinationChanged,
                      onTap: onDestinationTap,
                      style: const TextStyle(
                        color: RideBookingTokens.titleWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                      cursorColor: RideBookingTokens.accent,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Where to?',
                        hintStyle: TextStyle(
                          color: RideBookingTokens.muted,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
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
                    color: RideBookingTokens.plusFill,
                    border: Border.all(color: RideBookingTokens.border),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: RideBookingTokens.muted,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickupDot extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: RideBookingTokens.border,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: RideBookingTokens.muted,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
