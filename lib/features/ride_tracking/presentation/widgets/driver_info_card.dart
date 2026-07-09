import 'package:flutter/material.dart';

import '../../../ride_booking/presentation/theme/ride_booking_tokens.dart';

class DriverInfoCard extends StatelessWidget {
  const DriverInfoCard({
    super.key,
    required this.plateNumber,
    required this.driverName,
    required this.onMessage,
    required this.onCall,
  });

  final String plateNumber;
  final String driverName;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RideBookingTokens.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RideBookingTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2F6BFF), Color(0xFF4D7DFF)],
              ),
            ),
            alignment: Alignment.center,
            child: const Text('👤', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plateNumber,
                  style: const TextStyle(
                    color: RideBookingTokens.titleWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  driverName,
                  style: const TextStyle(
                    color: RideBookingTokens.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _CircleAction(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onMessage,
          ),
          const SizedBox(width: 8),
          _CircleAction(icon: Icons.phone_outlined, onTap: onCall),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RideBookingTokens.plusFill,
            border: Border.all(color: RideBookingTokens.border),
          ),
          child: Icon(icon, color: RideBookingTokens.titleWhite, size: 20),
        ),
      ),
    );
  }
}
