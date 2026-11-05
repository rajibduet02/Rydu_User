import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';
import '../widgets/meter_payment_card.dart';

class MeterPaymentScreen extends ConsumerStatefulWidget {
  const MeterPaymentScreen({super.key, this.bookingId});

  final String? bookingId;

  @override
  ConsumerState<MeterPaymentScreen> createState() => _MeterPaymentScreenState();
}

class _MeterPaymentScreenState extends ConsumerState<MeterPaymentScreen>
    with WidgetsBindingObserver {
  bool _receiptOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaitedRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaitedRefresh();
    }
  }

  void unawaitedRefresh() {
    final id = widget.bookingId;
    ref
        .read(rideBookingControllerProvider.notifier)
        .refreshMeterPayment(bookingId: id);
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideBookingControllerProvider);
    final c = ref.read(rideBookingControllerProvider.notifier);
    final payment = ride.meterPayment ?? ride.unpaidMeterPayment;
    final receipt = ride.meterReceipt;

    return Scaffold(
      backgroundColor: RideBookingTokens.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: c.deferMeterPaymentToHistory,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: RideBookingTokens.titleWhite,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Metered fare',
                    style: TextStyle(
                      color: RideBookingTokens.titleWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MeterPaymentCard(
              payment: payment,
              preparing: ride.meterPaymentPreparing &&
                  (payment == null || !payment.hasFinalFare),
              errorMessage: ride.meterPaymentError,
              isStartingCheckout: ride.isStartingMeterCheckout,
              confirming: ride.meterPaymentConfirming,
              onPayNow: ride.canOfferMeterPayNow
                  ? () => c.startMeterCheckout(bookingId: widget.bookingId)
                  : null,
              onViewHistory: c.deferMeterPaymentToHistory,
              onViewReceipt: payment?.canShowPaidReceipt == true
                  ? () async {
                      await c.fetchMeterReceipt(bookingId: widget.bookingId);
                      if (!mounted) return;
                      setState(() => _receiptOpen = true);
                    }
                  : null,
              onRetry: () =>
                  c.refreshMeterPayment(bookingId: widget.bookingId),
            ),
            if (_receiptOpen && receipt != null) ...[
              const SizedBox(height: 16),
              MeterReceiptCard(receipt: receipt),
            ],
            if (payment?.isPaid == true) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(goRouterProvider).go(RouteNames.home),
                child: const Text('Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
