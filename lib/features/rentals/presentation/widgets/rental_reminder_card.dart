import 'package:flutter/material.dart';

import '../theme/rental_driver_found_tokens.dart';

class RentalReminderCard extends StatelessWidget {
  const RentalReminderCard({
    super.key,
    required this.rentalHours,
    required this.includedKm,
  });

  final int rentalHours;
  final int includedKm;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.035).clamp(13.0, 14.0);
    final hourWord = rentalHours == 1 ? 'hour' : 'hours';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RentalDriverFoundTokens.reminderFill,
        borderRadius: BorderRadius.circular(RentalDriverFoundTokens.cardRadius),
        border: Border.all(
          color: RentalDriverFoundTokens.reminderBorder,
          width: 1,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: RentalDriverFoundTokens.white,
            fontSize: fontSize,
            height: 1.35,
          ),
          children: [
            const TextSpan(
              text: 'Rental reminder: ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text:
                  'Keep the car for $rentalHours $hourWord with ${includedKm}km included',
            ),
          ],
        ),
      ),
    );
  }
}
