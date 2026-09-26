import 'package:flutter/material.dart';

import '../models/ride_vehicle_option.dart';

/// Light ride-option cards on the dark ride-selection bottom sheet.
abstract final class RideOptionLightTokens {
  static const cardBg = Color(0xFFFFFFFF);
  static const cardBgSelected = Color(0xFFF4FBF7);
  static const title = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const selectedBorder = Color(0xFF0F6B4C);
  static const badgeSolid = Color(0xFF0F6B4C);
  static const badgeSoftBg = Color(0xFFD1FAE5);
  static const badgeSoftText = Color(0xFF065F46);
  static const divider = Color(0xFFE5E7EB);
  static const iconWell = Color(0xFFF3F4F6);
  static const radius = 16.0;
}

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
        borderRadius: BorderRadius.circular(RideOptionLightTokens.radius),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.035).clamp(12.0, 16.0),
            vertical: (w * 0.03).clamp(12.0, 14.0),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? RideOptionLightTokens.cardBgSelected
                : RideOptionLightTokens.cardBg,
            borderRadius: BorderRadius.circular(RideOptionLightTokens.radius),
            border: Border.all(
              color: isSelected
                  ? RideOptionLightTokens.selectedBorder
                  : RideOptionLightTokens.divider,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: RideOptionLightTokens.iconWell,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  option.iconEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        color: RideOptionLightTokens.title,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (option.time.isNotEmpty)
                          Text(
                            option.time,
                            style: const TextStyle(
                              color: RideOptionLightTokens.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (option.capacity != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: RideOptionLightTokens.muted,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                option.capacity!,
                                style: const TextStyle(
                                  color: RideOptionLightTokens.muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        if (option.discount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? RideOptionLightTokens.badgeSolid
                                  : RideOptionLightTokens.badgeSoftBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '30% OFF',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : RideOptionLightTokens.badgeSoftText,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (option.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RideOptionLightTokens.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    option.price,
                    style: const TextStyle(
                      color: RideOptionLightTokens.title,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (option.originalPrice != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.originalPrice!,
                      style: const TextStyle(
                        color: RideOptionLightTokens.muted,
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
