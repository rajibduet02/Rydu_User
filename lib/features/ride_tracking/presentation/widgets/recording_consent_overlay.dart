import 'package:flutter/material.dart';

import '../../../ride_booking/presentation/theme/ride_booking_tokens.dart';

/// Inline overlay explaining ride safety recording and collecting consent.
class RecordingConsentOverlay extends StatelessWidget {
  const RecordingConsentOverlay({
    super.key,
    required this.isSubmitting,
    required this.isFailed,
    this.errorMessage,
    required this.onAllow,
    required this.onDecline,
    this.onRetry,
  });

  final bool isSubmitting;
  final bool isFailed;
  final String? errorMessage;
  final VoidCallback onAllow;
  final VoidCallback onDecline;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final busy = isSubmitting;

    return Stack(
      children: [
        Container(color: Colors.black.withValues(alpha: 0.72)),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: BoxDecoration(
              color: RideBookingTokens.cardFill,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: RideBookingTokens.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ride safety recording',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RideBookingTokens.titleWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'For this trip, ride safety recording may begin after you '
                  'allow it. Recording is linked only to this ride.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RideBookingTokens.muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can allow or decline. Your booking stays active either way.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RideBookingTokens.muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (isFailed) ...[
                  const SizedBox(height: 14),
                  Text(
                    errorMessage?.trim().isNotEmpty == true
                        ? errorMessage!
                        : 'Could not save your choice. Please try again.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF87171),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  )
                else if (isFailed && onRetry != null) ...[
                  FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: RideBookingTokens.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Try again',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onDecline,
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: RideBookingTokens.muted),
                    ),
                  ),
                ] else ...[
                  FilledButton(
                    onPressed: busy ? null : onAllow,
                    style: FilledButton.styleFrom(
                      backgroundColor: RideBookingTokens.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Allow recording',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: busy ? null : onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RideBookingTokens.titleWhite,
                      side: const BorderSide(color: RideBookingTokens.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Subtle post-decision status line for the active ride sheet.
class RecordingConsentStatusBanner extends StatelessWidget {
  const RecordingConsentStatusBanner({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RideBookingTokens.plusFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RideBookingTokens.border),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: RideBookingTokens.muted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
