import 'package:flutter/material.dart';

import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../ride_history_presentation.dart';

class RideHistoryTile extends StatelessWidget {
  const RideHistoryTile({
    super.key,
    required this.booking,
    this.onTap,
  });

  final BookingEntity booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(RideHistoryPresentation.routeLabel(booking)),
      subtitle: Text(RideHistoryPresentation.statusLabel(booking.status)),
      onTap: onTap,
    );
  }
}
