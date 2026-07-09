import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/wallet_provider.dart';
import '../theme/wallet_tokens.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_stat_card.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(walletControllerProvider.notifier).loadWalletData();
    });
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(walletControllerProvider);
    final c = ref.read(walletControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.075).clamp(26.0, 30.0);
    final backBtn = (w * 0.1).clamp(40.0, 44.0);
    final sectionTitle = (w * 0.045).clamp(16.0, 18.0);
    final gap = (w * 0.035).clamp(14.0, 16.0);

    return Scaffold(
      backgroundColor: WalletTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    color: WalletTokens.iconWell,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _goBack(context),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: WalletTokens.border),
                        ),
                        child: SizedBox(
                          width: backBtn,
                          height: backBtn,
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: WalletTokens.white,
                            size: backBtn * 0.55,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.03).clamp(12.0, 16.0)),
                  Expanded(
                    child: Text(
                      'Wallet',
                      style: TextStyle(
                        color: WalletTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: WalletTokens.border),
            if (s.isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: WalletTokens.border,
                color: WalletTokens.accent,
              ),
            if (s.errorMessage != null)
              Material(
                color: WalletTokens.cardTop,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: c.clearError,
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  (w * 0.04).clamp(16.0, 20.0),
                  hPad,
                  (w * 0.08).clamp(28.0, 36.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WalletBalanceCard(
                      balanceLabel: 'Available Balance',
                      balanceText: s.availableBalance,
                      onAddMoney: c.addMoney,
                      onSendMoney: c.sendMoney,
                    ),
                    SizedBox(height: (w * 0.045).clamp(18.0, 22.0)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: WalletStatCard(
                            icon: Icons.trending_up_rounded,
                            iconColor: WalletTokens.green,
                            label: 'This Month',
                            value: s.thisMonthAmount,
                          ),
                        ),
                        SizedBox(width: (w * 0.035).clamp(14.0, 16.0)),
                        Expanded(
                          child: WalletStatCard(
                            icon: Icons.bolt_rounded,
                            iconColor: WalletTokens.gold,
                            label: 'Promo Credits',
                            value: s.promoCredits,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap + 4),
                    Text(
                      'Payment Methods',
                      style: TextStyle(
                        color: WalletTokens.white,
                        fontSize: sectionTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: gap),
                    for (var i = 0; i < s.paymentMethods.length; i++) ...[
                      if (i > 0)
                        SizedBox(height: (w * 0.025).clamp(10.0, 12.0)),
                      PaymentMethodCard(
                        method: s.paymentMethods[i],
                        isSelected:
                            s.selectedPaymentMethod == s.paymentMethods[i].id,
                        onTap: () =>
                            c.selectPaymentMethod(s.paymentMethods[i].id),
                      ),
                    ],
                    SizedBox(height: (w * 0.025).clamp(10.0, 12.0)),
                    OutlinedButton.icon(
                      onPressed: c.addPaymentMethod,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WalletTokens.white,
                        side: const BorderSide(color: WalletTokens.border),
                        padding: EdgeInsets.symmetric(
                          vertical: (w * 0.04).clamp(14.0, 16.0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 22),
                      label: Text(
                        'Add Payment Method',
                        style: TextStyle(
                          fontSize: (w * 0.04).clamp(15.0, 16.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: gap + 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            'Recent Transactions',
                            style: TextStyle(
                              color: WalletTokens.white,
                              fontSize: sectionTitle,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: c.openAllTransactions,
                          style: TextButton.styleFrom(
                            foregroundColor: WalletTokens.accent,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: (w * 0.035).clamp(13.0, 14.0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    for (var i = 0; i < s.transactions.length; i++) ...[
                      if (i > 0)
                        SizedBox(height: (w * 0.025).clamp(10.0, 12.0)),
                      TransactionTile(
                        transaction: s.transactions[i],
                        onTap: () => c.openTransaction(s.transactions[i].id),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
