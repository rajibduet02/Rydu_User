import 'package:flutter/material.dart';

import '../models/lost_item_trip.dart';
import '../theme/report_lost_item_tokens.dart';

class LostItemTripSelector extends StatelessWidget {
  const LostItemTripSelector({
    super.key,
    required this.trip,
    required this.onTap,
  });

  final LostItemTrip? trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final iconBox = (w * 0.11).clamp(42.0, 48.0);
    final radius = (w * 0.03).clamp(10.0, 12.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.all((w * 0.035).clamp(12.0, 14.0)),
          decoration: BoxDecoration(
            color: ReportLostItemTokens.field,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: ReportLostItemTokens.border),
          ),
          child: Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: ReportLostItemTokens.iconWell,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ReportLostItemTokens.border),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.directions_car_outlined,
                  color: ReportLostItemTokens.muted,
                  size: iconBox * 0.48,
                ),
              ),
              SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
              Expanded(
                child: trip == null
                    ? Text(
                        'Select a completed trip',
                        style: TextStyle(
                          color: ReportLostItemTokens.placeholder,
                          fontSize: (w * 0.04).clamp(15.0, 16.0),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip!.vehicleName,
                            style: TextStyle(
                              color: ReportLostItemTokens.white,
                              fontWeight: FontWeight.w700,
                              fontSize: (w * 0.04).clamp(15.0, 16.0),
                            ),
                          ),
                          SizedBox(height: (w * 0.01).clamp(4.0, 6.0)),
                          Text(
                            trip!.subtitle,
                            style: TextStyle(
                              color: ReportLostItemTokens.muted,
                              fontSize: (w * 0.035).clamp(13.0, 14.0),
                            ),
                          ),
                        ],
                      ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: ReportLostItemTokens.muted,
                size: (w * 0.065).clamp(24.0, 28.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
