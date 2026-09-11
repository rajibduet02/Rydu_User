import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/payment_method_provider.dart';
import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';

/// Screenshot / design tokens for the Pay with sheet.
abstract final class PaymentMethodModalTokens {
  static const background = Color(0xFF060B14);
  static const card = Color(0xFF111827);
  static const tabUnselected = Color(0xFF182235);
  static const border = Color(0xFF2A3548);
  static const blue = Color(0xFF2962FF);
  static const blueAlt = Color(0xFF2F6BFF);
  static const muted = Color(0xFFB8C0D4);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF111827);
  static const logoBlack = Color(0xFF111827);
  static const switchOffTrack = border;
  static const switchOffThumb = white;
  static const switchOffOutline = border;
  static const switchOnTrack = Color(0x8C2F6BFF);
}

class PaymentMethodModal extends ConsumerWidget {
  const PaymentMethodModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(paymentMethodControllerProvider);
    final c = ref.read(paymentMethodControllerProvider.notifier);
    final booking = ref.watch(rideBookingControllerProvider);
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final sheetHeight = media.size.height * 0.92;

    void close() => Navigator.of(context).pop();

    Future<void> popThen(void Function() action) async {
      Navigator.of(context).pop();
      await Future<void>.delayed(Duration.zero);
      action();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: PaymentMethodModalTokens.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Pay with',
                          style: TextStyle(
                            color: PaymentMethodModalTokens.white,
                            fontSize: (w * 0.075).clamp(26.0, 30.0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: close,
                          customBorder: const CircleBorder(),
                          child: Ink(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PaymentMethodModalTokens.tabUnselected,
                              border: Border.all(
                                color: PaymentMethodModalTokens.border,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: PaymentMethodModalTokens.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: PaymentAccountTypeTabs(
                    selected: s.selectedAccountType,
                    onSelect: c.selectAccountType,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: PaymentMethodModalTokens.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      20,
                      hPad,
                      16 + media.padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              'RYD U balances',
                              style: TextStyle(
                                color: PaymentMethodModalTokens.white,
                                fontSize: (w * 0.048).clamp(18.0, 20.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: s.isRyduBalanceEnabled,
                              onChanged: (v) => c.toggleRyduBalance(v),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              thumbColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return PaymentMethodModalTokens.white;
                                }
                                return PaymentMethodModalTokens.switchOffThumb;
                              }),
                              trackColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return PaymentMethodModalTokens.switchOnTrack;
                                }
                                return PaymentMethodModalTokens.switchOffTrack;
                              }),
                              trackOutlineColor:
                                  WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return PaymentMethodModalTokens.blueAlt;
                                    }
                                    return PaymentMethodModalTokens
                                        .switchOffOutline;
                                  }),
                              trackOutlineWidth:
                                  WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return 1.0;
                                    }
                                    return 2.0;
                                  }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        RyduBalanceCard(
                          balanceLabel: PaymentMethodModal._formatRyduCash(
                            s.ryduCashBalance,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Payment methods',
                          style: TextStyle(
                            color: PaymentMethodModalTokens.white,
                            fontSize: (w * 0.048).clamp(18.0, 20.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ..._bookingPaymentOptions(
                          methods: booking.paymentMethods,
                          selectedLabel: s.selectedPaymentMethod,
                          selectedCode: booking.paymentMethodCode,
                          onSelect: (method) {
                            c.selectPaymentMethod(method.label);
                            ref
                                .read(rideBookingControllerProvider.notifier)
                                .updatePaymentMethod(method.label);
                            close();
                          },
                        ),
                        const SizedBox(height: 12),
                        PaymentOptionCard(
                          selected: false,
                          leading: Icon(
                            Icons.add_rounded,
                            color: PaymentMethodModalTokens.white,
                            size: 22,
                          ),
                          title: 'Add payment method',
                          showRadio: false,
                          outlined: true,
                          onTap: () => popThen(c.openAddPaymentMethod),
                        ),
                        const SizedBox(height: 28),
                        VoucherSectionHeader(
                          onSeeDetails: () => popThen(c.openVoucherDetails),
                        ),
                        const SizedBox(height: 14),
                        VoucherOptionCard(
                          onTap: () => popThen(c.openAddVoucher),
                        ),
                        if (s.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            s.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
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

  static String _formatRyduCash(double amount) {
    return 'BDT ${amount.toStringAsFixed(2)}';
  }
}

List<Widget> _bookingPaymentOptions({
  required List<PaymentMethodEntity> methods,
  required String selectedLabel,
  required String selectedCode,
  required void Function(PaymentMethodEntity method) onSelect,
}) {
  final visible = CardBookingPayment.visibleForBooking(methods);
  final children = <Widget>[];
  for (var i = 0; i < visible.length; i++) {
    final method = visible[i];
    final selected =
        selectedLabel == method.label ||
        selectedCode.toLowerCase() == method.code.toLowerCase() ||
        isCardPaymentMethodCode(selectedCode);
    children.add(
      PaymentOptionCard(
        selected: selected,
        leading: const Icon(
          Icons.credit_card_rounded,
          color: PaymentMethodModalTokens.white,
          size: 22,
        ),
        title: method.label,
        showRadio: true,
        onTap: () => onSelect(method),
      ),
    );
    if (i < visible.length - 1) {
      children.add(const SizedBox(height: 12));
    }
  }
  return children;
}

class PaymentAccountTypeTabs extends StatelessWidget {
  const PaymentAccountTypeTabs({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.038).clamp(14.0, 15.0);

    Widget tab(String id, String label, IconData icon) {
      final isSel = selected == id;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(id),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSel
                    ? PaymentMethodModalTokens.white
                    : PaymentMethodModalTokens.tabUnselected,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel
                      ? PaymentMethodModalTokens.white
                      : PaymentMethodModalTokens.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSel
                        ? PaymentMethodModalTokens.black
                        : PaymentMethodModalTokens.muted,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSel
                            ? PaymentMethodModalTokens.black
                            : PaymentMethodModalTokens.muted,
                        fontSize: fontSize,
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

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PaymentMethodModalTokens.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          tab(
            PaymentAccountTypes.personal,
            'Personal',
            Icons.person_outline_rounded,
          ),
          const SizedBox(width: 12),
          tab(
            PaymentAccountTypes.business,
            'Business',
            Icons.business_center_outlined,
          ),
        ],
      ),
    );
  }
}

class RyduBalanceCard extends StatelessWidget {
  const RyduBalanceCard({super.key, required this.balanceLabel});

  final String balanceLabel;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final textSize = (w * 0.04).clamp(15.0, 16.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PaymentMethodModalTokens.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PaymentMethodModalTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PaymentMethodModalTokens.logoBlack,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'RYD U',
              style: TextStyle(
                color: PaymentMethodModalTokens.white,
                fontSize: (w * 0.022).clamp(8.0, 9.0),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'RYD U Cash: $balanceLabel',
              style: TextStyle(
                color: PaymentMethodModalTokens.white,
                fontSize: textSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentOptionCard extends StatelessWidget {
  const PaymentOptionCard({
    super.key,
    required this.selected,
    required this.leading,
    required this.title,
    required this.showRadio,
    required this.onTap,
    this.outlined = false,
  });

  final bool selected;
  final Widget leading;
  final String title;
  final bool showRadio;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.042).clamp(15.5, 16.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: outlined
                ? Colors.transparent
                : PaymentMethodModalTokens.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected && !outlined
                  ? PaymentMethodModalTokens.blueAlt
                  : PaymentMethodModalTokens.border,
              width: selected && !outlined ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 40, height: 40, child: Center(child: leading)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: PaymentMethodModalTokens.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showRadio && selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: PaymentMethodModalTokens.blueAlt,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: PaymentMethodModalTokens.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoucherSectionHeader extends StatelessWidget {
  const VoucherSectionHeader({super.key, required this.onSeeDetails});

  final VoidCallback onSeeDetails;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.048).clamp(18.0, 20.0);
    final linkSize = (w * 0.035).clamp(13.0, 14.0);

    return Row(
      children: [
        Text(
          'Vouchers',
          style: TextStyle(
            color: PaymentMethodModalTokens.white,
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSeeDetails,
          style: TextButton.styleFrom(
            foregroundColor: PaymentMethodModalTokens.muted,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'See details',
            style: TextStyle(fontSize: linkSize, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class VoucherOptionCard extends StatelessWidget {
  const VoucherOptionCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.042).clamp(15.5, 16.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PaymentMethodModalTokens.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_rounded,
                color: PaymentMethodModalTokens.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Add voucher code',
                style: TextStyle(
                  color: PaymentMethodModalTokens.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
