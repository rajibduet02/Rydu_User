import 'package:flutter/material.dart';

import '../theme/reserve_tokens.dart';

class ReserveBottomButton extends StatelessWidget {
  const ReserveBottomButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ReserveTokens.buttonFill,
        foregroundColor: ReserveTokens.buttonText,
        elevation: 4,
        shadowColor: Colors.black54,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReserveTokens.buttonRadius),
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
      child: const Text(
        'Reserve a ride',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }
}
