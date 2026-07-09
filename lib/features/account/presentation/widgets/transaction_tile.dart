import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';
import '../theme/wallet_tokens.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final WalletTransaction transaction;
  final VoidCallback onTap;

  static String _amountLabel(WalletTransaction t) {
    final abs = t.amountSigned.abs().toStringAsFixed(2);
    if (t.amountSigned > 0) {
      return '+BDT $abs';
    }
    return 'BDT $abs';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.05).clamp(18.0, 20.0);
    final pad = (w * 0.04).clamp(14.0, 16.0);
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final amountSize = (w * 0.038).clamp(14.0, 15.0);
    final iconBox = (w * 0.12).clamp(44.0, 48.0);
    final credit = transaction.isCredit;
    final iconColor = credit ? WalletTokens.green : WalletTokens.accent;
    final iconBg = credit
        ? WalletTokens.green.withValues(alpha: 0.2)
        : WalletTokens.accent.withValues(alpha: 0.2);

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
            border: Border.all(color: WalletTokens.border),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: iconBox,
                    height: iconBox,
                    child: Icon(
                      Icons.history_rounded,
                      color: iconColor,
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
                        transaction.description,
                        style: TextStyle(
                          color: WalletTokens.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: (w * 0.008).clamp(4.0, 6.0)),
                      Text(
                        transaction.dateLabel,
                        style: TextStyle(
                          color: WalletTokens.muted,
                          fontSize: subSize,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _amountLabel(transaction),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: credit ? WalletTokens.green : WalletTokens.white,
                      fontSize: amountSize,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
