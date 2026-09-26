import 'package:flutter/material.dart';

import '../models/rental_vehicle.dart';

/// Light rental vehicle cards on the dark rental selection sheet.
abstract final class RentalVehicleLightTokens {
  static const cardBg = Color(0xFFFFFFFF);
  static const cardBgSelected = Color(0xFFF4FBF7);
  static const title = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const selectedBorder = Color(0xFF0F6B4C);
  static const divider = Color(0xFFE5E7EB);
  static const iconWell = Color(0xFFF3F4F6);
  static const bolt = Color(0xFF0F6B4C);
  static const radius = 16.0;
}

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

  static String _bdt(double v) => 'BDT ${v.toStringAsFixed(2)}';

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
        borderRadius: BorderRadius.circular(RentalVehicleLightTokens.radius),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? RentalVehicleLightTokens.cardBgSelected
                : RentalVehicleLightTokens.cardBg,
            borderRadius: BorderRadius.circular(RentalVehicleLightTokens.radius),
            border: Border.all(
              color: selected
                  ? RentalVehicleLightTokens.selectedBorder
                  : RentalVehicleLightTokens.divider,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: (w * 0.14).clamp(52.0, 56.0),
                height: (w * 0.14).clamp(52.0, 56.0),
                decoration: BoxDecoration(
                  color: RentalVehicleLightTokens.iconWell,
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
                        color: RentalVehicleLightTokens.title,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.eta,
                      style: TextStyle(
                        color: RentalVehicleLightTokens.muted,
                        fontSize: subSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.includedKm} kilometers included',
                      style: TextStyle(
                        color: RentalVehicleLightTokens.muted,
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
                        const Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: RentalVehicleLightTokens.bolt,
                        ),
                        const SizedBox(width: 2),
                      ],
                      Text(
                        _bdt(vehicle.price),
                        style: TextStyle(
                          color: RentalVehicleLightTokens.title,
                          fontSize: priceSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_bdt(vehicle.oldPrice)}/hour',
                    style: TextStyle(
                      color: RentalVehicleLightTokens.muted,
                      fontSize: subSize - 1.5,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: RentalVehicleLightTokens.muted,
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
