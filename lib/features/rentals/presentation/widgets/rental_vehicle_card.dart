import 'package:flutter/material.dart';

import '../models/rental_vehicle.dart';
import '../theme/rental_ride_tokens.dart';

class RentalVehicleCard extends StatelessWidget {
  const RentalVehicleCard({
    super.key,
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final RentalVehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  static String _bdt(double v) => 'BDT${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subSize = (w * 0.033).clamp(12.5, 13.5);
    final priceSize = (w * 0.038).clamp(14.0, 15.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RentalRideTokens.cardRadius),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? RentalRideTokens.cardSelected
                : RentalRideTokens.cardUnselected,
            borderRadius: BorderRadius.circular(RentalRideTokens.cardRadius),
            border: Border.all(
              color: selected
                  ? RentalRideTokens.borderSelected
                  : RentalRideTokens.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: RentalRideTokens.borderSelected.withValues(
                        alpha: 0.18,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: (w * 0.14).clamp(52.0, 56.0),
                height: (w * 0.14).clamp(52.0, 56.0),
                decoration: BoxDecoration(
                  color: RentalRideTokens.iconWell,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  vehicle.emoji,
                  style: TextStyle(fontSize: (w * 0.07).clamp(26.0, 30.0)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TextStyle(
                        color: RentalRideTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.eta,
                      style: TextStyle(
                        color: RentalRideTokens.muted,
                        fontSize: subSize,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.includedKm} kilometers included',
                      style: TextStyle(
                        color: RentalRideTokens.muted,
                        fontSize: subSize - 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (vehicle.showDiscountBolt) ...[
                        Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: RentalRideTokens.bolt,
                        ),
                        const SizedBox(width: 2),
                      ],
                      Text(
                        _bdt(vehicle.price),
                        style: TextStyle(
                          color: RentalRideTokens.white,
                          fontSize: priceSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_bdt(vehicle.oldPrice)}/hour',
                    style: TextStyle(
                      color: RentalRideTokens.muted,
                      fontSize: subSize - 1.5,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: RentalRideTokens.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
