import 'package:flutter/material.dart';

import '../../domain/entities/meter_payment_entities.dart';
import '../theme/ride_booking_tokens.dart';

class MeterPaymentCard extends StatelessWidget {
  const MeterPaymentCard({
    super.key,
    required this.payment,
    this.preparing = false,
    this.errorMessage,
    this.isStartingCheckout = false,
    this.confirming = false,
    this.onPayNow,
    this.onViewHistory,
    this.onViewReceipt,
    this.onOpenDetails,
    this.onRetry,
    this.compact = false,
  });

  final MeterPaymentRecord? payment;
  final bool preparing;
  final String? errorMessage;
  final bool isStartingCheckout;
  final bool confirming;
  final VoidCallback? onPayNow;
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final record = payment;
    final fare = record?.formattedFinalFare;
    final showTestMode = record?.isStripeTestMode != false;
    final paid = record?.isPaid == true;
    final refunded = record?.isRefunded == true;
    final unresolved = record?.isMeterUnresolved == true;
    final canPay = !confirming &&
        !unresolved &&
        record?.needsPayNow == true &&
        onPayNow != null;
    final canReceipt = record?.canShowPaidReceipt == true && onViewReceipt != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: RideBookingTokens.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RideBookingTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unresolved
                ? SoftMeterPaymentCopy.unresolved
                : paid || refunded
                ? SoftMeterPaymentCopy.afterTrip
                : preparing && fare == null
                ? SoftMeterPaymentCopy.preparing
                : SoftMeterPaymentCopy.afterTrip,
            style: const TextStyle(
              color: RideBookingTokens.titleWhite,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          if (!unresolved && fare != null) ...[
            const SizedBox(height: 8),
            Text(
              fare,
              style: const TextStyle(
                color: RideBookingTokens.titleWhite,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            confirming
                ? SoftMeterPaymentCopy.confirming
                : record?.passengerStatusLabel ?? 'Payment Pending',
            style: TextStyle(
              color: paid
                  ? const Color(0xFF22C55E)
                  : refunded || unresolved
                  ? RideBookingTokens.muted
                  : const Color(0xFFF59E0B),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          if (showTestMode) ...[
            const SizedBox(height: 8),
            const Text(
              SoftMeterPaymentCopy.testMode,
              style: TextStyle(
                color: RideBookingTokens.muted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          if (errorMessage != null && errorMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFFF87171),
                fontSize: 13,
              ),
            ),
          ],
          if (canPay) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isStartingCheckout ? null : onPayNow,
                style: FilledButton.styleFrom(
                  backgroundColor: RideBookingTokens.sheetCta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isStartingCheckout
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Pay Now',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
          if (preparing && onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
          if (canReceipt) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onViewReceipt,
              child: const Text('View Receipt'),
            ),
          ],
          if (onViewHistory != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: onViewHistory,
              child: const Text('View ride history'),
            ),
          ],
          if (onOpenDetails != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: onOpenDetails,
              child: const Text('Open ride details'),
            ),
          ],
        ],
      ),
    );
  }
}

class MeterReceiptCard extends StatelessWidget {
  const MeterReceiptCard({super.key, required this.receipt});

  final MeterPaymentRecord receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RideBookingTokens.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RideBookingTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metered fare receipt',
            style: TextStyle(
              color: RideBookingTokens.titleWhite,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (receipt.formattedFlagDrop != null)
            _row('Flag drop', receipt.formattedFlagDrop!),
          if (receipt.formattedDistanceCharge != null)
            _row('Distance charge', receipt.formattedDistanceCharge!),
          if (receipt.formattedStoppedTimeCharge != null)
            _row(
              'Eligible stopped-time charge',
              receipt.formattedStoppedTimeCharge!,
            ),
          if (receipt.formattedFinalFare != null)
            _row('Total', receipt.formattedFinalFare!),
          _row('Payment status', receipt.passengerStatusLabel),
          if (receipt.receiptUrl != null && receipt.receiptUrl!.isNotEmpty)
            _row('Receipt URL', receipt.receiptUrl!),
          if (receipt.isStripeTestMode) ...[
            const SizedBox(height: 8),
            const Text(
              SoftMeterPaymentCopy.testMode,
              style: TextStyle(
                color: RideBookingTokens.muted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: RideBookingTokens.muted,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: RideBookingTokens.titleWhite,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
