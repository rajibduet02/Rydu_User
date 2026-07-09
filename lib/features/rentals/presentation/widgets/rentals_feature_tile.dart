import 'package:flutter/material.dart';

import '../theme/rentals_tokens.dart';

class RentalsFeatureTile extends StatelessWidget {
  const RentalsFeatureTile({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 26, color: RentalsTokens.iconOutline),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: const TextStyle(
                color: RentalsTokens.bodyText,
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
