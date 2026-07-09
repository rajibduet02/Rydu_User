import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../models/ride_vehicle_option.dart';
import '../theme/ride_booking_tokens.dart';

class RideOptionCard extends StatelessWidget {
  const RideOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final RideVehicleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: EdgeInsets.all((w * 0.04).clamp(14.0, 16.0)),
          decoration: BoxDecoration(
            color: isSelected
                ? RideBookingTokens.cardFill
                : AppDarkSurfaces.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? RideBookingTokens.accent
                  : RideBookingTokens.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: RideBookingTokens.accent.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: RideBookingTokens.plusFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  option.iconEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            option.name,
                            style: const TextStyle(
                              color: RideBookingTokens.titleWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (option.capacity != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_outline_rounded,
                            size: 14,
                            color: RideBookingTokens.muted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            option.capacity!,
                            style: const TextStyle(
                              color: RideBookingTokens.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (option.discount) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B2C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '30%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.time,
                      style: const TextStyle(
                        color: RideBookingTokens.muted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: const TextStyle(
                        color: RideBookingTokens.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: Color(0xFFFF6B2C),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        option.price,
                        style: const TextStyle(
                          color: RideBookingTokens.titleWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  if (option.originalPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.originalPrice!,
                      style: const TextStyle(
                        color: RideBookingTokens.muted,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
