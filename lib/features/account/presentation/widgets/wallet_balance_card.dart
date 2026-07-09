import 'package:flutter/material.dart';

import '../theme/wallet_tokens.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balanceLabel,
    required this.balanceText,
    required this.onAddMoney,
    required this.onSendMoney,
  });

  final String balanceLabel;
  final String balanceText;
  final VoidCallback onAddMoney;
  final VoidCallback onSendMoney;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.07).clamp(22.0, 28.0);
    final pad = (w * 0.045).clamp(18.0, 24.0);
    final labelSize = (w * 0.035).clamp(13.0, 14.0);
    final amountSize = (w * 0.1).clamp(30.0, 36.0);
    final iconBox = (w * 0.14).clamp(52.0, 56.0);
    final btnText = (w * 0.038).clamp(14.0, 15.0);
    final narrow = w < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [WalletTokens.accent, WalletTokens.accentSoft],
        ),
        boxShadow: [
          BoxShadow(
            color: WalletTokens.accent.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balanceLabel,
                      style: TextStyle(
                        color: WalletTokens.white.withValues(alpha: 0.85),
                        fontSize: labelSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: (w * 0.01).clamp(4.0, 6.0)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        balanceText,
                        style: TextStyle(
                          color: WalletTokens.white,
                          fontSize: amountSize,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: WalletTokens.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: iconBox,
                  height: iconBox,
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: WalletTokens.white,
                    size: iconBox * 0.45,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (w * 0.045).clamp(18.0, 22.0)),
          if (narrow) ...[
            FilledButton(
              onPressed: onAddMoney,
              style: FilledButton.styleFrom(
                backgroundColor: WalletTokens.white,
                foregroundColor: WalletTokens.accent,
                padding: EdgeInsets.symmetric(
                  vertical: (w * 0.035).clamp(12.0, 14.0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Add Money',
                style: TextStyle(
                  fontSize: btnText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
            FilledButton(
              onPressed: onSendMoney,
              style: FilledButton.styleFrom(
                backgroundColor: WalletTokens.white.withValues(alpha: 0.2),
                foregroundColor: WalletTokens.white,
                padding: EdgeInsets.symmetric(
                  vertical: (w * 0.035).clamp(12.0, 14.0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Send Money',
                style: TextStyle(
                  fontSize: btnText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onAddMoney,
                    style: FilledButton.styleFrom(
                      backgroundColor: WalletTokens.white,
                      foregroundColor: WalletTokens.accent,
                      padding: EdgeInsets.symmetric(
                        vertical: (w * 0.035).clamp(12.0, 14.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Add Money',
                      style: TextStyle(
                        fontSize: btnText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
                Expanded(
                  child: FilledButton(
                    onPressed: onSendMoney,
                    style: FilledButton.styleFrom(
                      backgroundColor: WalletTokens.white.withValues(
                        alpha: 0.2,
                      ),
                      foregroundColor: WalletTokens.white,
                      padding: EdgeInsets.symmetric(
                        vertical: (w * 0.035).clamp(12.0, 14.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Send Money',
                      style: TextStyle(
                        fontSize: btnText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
