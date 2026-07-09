import 'package:flutter/material.dart';

import '../theme/rental_time_tokens.dart';

class RentalLeaveOptionButton extends StatelessWidget {
  const RentalLeaveOptionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? RentalTimeTokens.white
                  : RentalTimeTokens.iconWell,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? RentalTimeTokens.white
                    : RentalTimeTokens.border,
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? RentalTimeTokens.black
                      : RentalTimeTokens.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
