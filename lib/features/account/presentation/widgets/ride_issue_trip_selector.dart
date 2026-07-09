import 'package:flutter/material.dart';

import '../models/ride_trip.dart';
import '../theme/report_ride_issue_tokens.dart';

class RideIssueTripSelector extends StatelessWidget {
  const RideIssueTripSelector({
    super.key,
    required this.trip,
    required this.onTap,
  });

  final RideTrip? trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final iconBox = (w * 0.11).clamp(42.0, 48.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: (w * 0.01).clamp(4.0, 6.0)),
          child: Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: ReportRideIssueTokens.iconWell,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ReportRideIssueTokens.border),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.directions_car_outlined,
                  color: ReportRideIssueTokens.muted,
                  size: iconBox * 0.48,
                ),
              ),
              SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
              Expanded(
                child: trip == null
                    ? Text(
                        'Select a trip',
                        style: TextStyle(
                          color: ReportRideIssueTokens.placeholder,
                          fontSize: (w * 0.04).clamp(15.0, 16.0),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip!.title,
                            style: TextStyle(
                              color: ReportRideIssueTokens.white,
                              fontWeight: FontWeight.w700,
                              fontSize: (w * 0.04).clamp(15.0, 16.0),
                            ),
                          ),
                          SizedBox(height: (w * 0.01).clamp(4.0, 6.0)),
                          Text(
                            trip!.subtitle,
                            style: TextStyle(
                              color: ReportRideIssueTokens.muted,
                              fontSize: (w * 0.035).clamp(13.0, 14.0),
                            ),
                          ),
                        ],
                      ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ReportRideIssueTokens.white,
                size: (w * 0.065).clamp(24.0, 28.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
