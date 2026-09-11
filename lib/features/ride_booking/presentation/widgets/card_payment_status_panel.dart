import 'package:flutter/material.dart';

import '../../domain/entities/ride_planning_entities.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';

class CardPaymentStatusPanel extends StatelessWidget {
  const CardPaymentStatusPanel({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onCancel,
  });

  final RideBookingState state;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  bool get _busy =>
      state.isResolvingPayment ||
      state.cardPaymentUiState == CardPaymentUiState.preparing ||
      state.cardPaymentUiState == CardPaymentUiState.presentingSheet ||
      state.cardPaymentUiState == CardPaymentUiState.authorizing;

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
          Text(
            state.cardPaymentStatusTitle,
            style: const TextStyle(
              color: RideBookingTokens.titleWhite,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.cardPaymentStatusSubtitle,
            style: const TextStyle(
              color: RideBookingTokens.muted,
              fontSize: 13,
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              color: RideBookingTokens.accent,
              minHeight: 2,
            ),
          ] else ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.canRetryCardPayment ||
                        state.cardPaymentUiState ==
                            CardPaymentUiState.failed ||
                        state.cardPaymentUiState ==
                            CardPaymentUiState.requiresAction
                    ? onRetry
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Retry Payment',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: state.isCancelling ? null : onCancel,
                child: state.isCancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Cancel ride',
                        style: TextStyle(
                          color: RideBookingTokens.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
