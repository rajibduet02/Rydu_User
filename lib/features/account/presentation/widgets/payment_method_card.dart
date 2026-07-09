import 'package:flutter/material.dart';

import '../models/wallet_payment_method.dart';
import '../theme/wallet_tokens.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final WalletPaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.05).clamp(18.0, 20.0);
    final pad = (w * 0.04).clamp(14.0, 16.0);
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final iconBox = (w * 0.12).clamp(44.0, 48.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [WalletTokens.cardTop, WalletTokens.cardBottom],
            ),
            border: Border.all(
              color: isSelected
                  ? WalletTokens.accent.withValues(alpha: 0.65)
                  : WalletTokens.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: WalletTokens.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: iconBox,
                    height: iconBox,
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: WalletTokens.accent,
                      size: iconBox * 0.42,
                    ),
                  ),
                ),
                SizedBox(width: (w * 0.035).clamp(14.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        method.name,
                        style: TextStyle(
                          color: WalletTokens.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: (w * 0.008).clamp(4.0, 6.0)),
                      Text(
                        '•••• ${method.last4}',
                        style: TextStyle(
                          color: WalletTokens.muted,
                          fontSize: subSize,
                        ),
                      ),
                    ],
                  ),
                ),
                if (method.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: (w * 0.025).clamp(10.0, 12.0),
                      vertical: (w * 0.015).clamp(5.0, 6.0),
                    ),
                    decoration: BoxDecoration(
                      color: WalletTokens.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: WalletTokens.accent,
                        fontSize: (w * 0.028).clamp(11.0, 12.0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
