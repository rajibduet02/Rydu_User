import 'package:flutter/material.dart';

import '../theme/rental_driver_found_tokens.dart';

class RentalDriverCard extends StatelessWidget {
  const RentalDriverCard({
    super.key,
    required this.vehiclePlate,
    required this.driverName,
    required this.onChat,
    required this.onCall,
  });

  final String vehiclePlate;
  final String driverName;
  final VoidCallback onChat;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final plateSize = (w * 0.045).clamp(17.0, 18.0);
    final nameSize = (w * 0.032).clamp(12.0, 13.0);
    final parts = driverName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RentalDriverFoundTokens.card,
        borderRadius: BorderRadius.circular(
          RentalDriverFoundTokens.driverCardRadius,
        ),
        border: Border.all(color: RentalDriverFoundTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: (w * 0.17).clamp(60.0, 64.0),
            height: (w * 0.17).clamp(60.0, 64.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RentalDriverFoundTokens.iconWell,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.person_rounded,
              size: (w * 0.12).clamp(40.0, 44.0),
              color: const Color(0xFF9333EA),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehiclePlate,
                  style: TextStyle(
                    color: RentalDriverFoundTokens.white,
                    fontSize: plateSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ...parts.map(
                  (p) => Text(
                    p.toUpperCase(),
                    style: TextStyle(
                      color: RentalDriverFoundTokens.muted,
                      fontSize: nameSize,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleAction(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: onChat,
              ),
              const SizedBox(width: 8),
              _CircleAction(icon: Icons.phone_rounded, onTap: onCall),
            ],
          ),
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
            color: RentalDriverFoundTokens.iconWell,
            border: Border.all(color: RentalDriverFoundTokens.border),
          ),
          child: Icon(icon, color: RentalDriverFoundTokens.white, size: 20),
        ),
      ),
    );
  }
}
