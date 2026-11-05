/// Authoritative Soft Meter payment record from passenger meter-payment APIs
/// and `booking:meter_payment` socket events.
///
/// Flutter never calculates the payable fare and never infers Paid from a
/// browser return. Production charging is backend-controlled and stays off
/// in this client.
class MeterPaymentRecord {
  const MeterPaymentRecord({
    this.bookingId,
    this.rideStatus,
    this.paymentStatus = MeterPaymentStatus.unknown,
    this.paymentStatusRaw,
    this.paymentRequired,
    this.paymentMode,
    this.finalFareCents,
    this.currency,
    this.meterSessionId,
    this.completedAt,
    this.paidAt,
    this.receiptAvailable,
    this.receiptUrl,
    this.hostedUrl,
    this.testMode,
    this.fareClassification,
    this.paymentVersion,
    this.productionCharge,
    this.flagDropCents,
    this.distanceChargeCents,
    this.waitingChargeCents,
    this.totalCents,
  });

  final String? bookingId;
  final String? rideStatus;
  final MeterPaymentStatus paymentStatus;
  final String? paymentStatusRaw;
  final bool? paymentRequired;
  final String? paymentMode;
  final int? finalFareCents;
  final String? currency;
  final String? meterSessionId;
  final DateTime? completedAt;
  final DateTime? paidAt;
  final bool? receiptAvailable;
  final String? receiptUrl;
  final String? hostedUrl;
  final bool? testMode;
  final String? fareClassification;
  final int? paymentVersion;
  final bool? productionCharge;
  final int? flagDropCents;
  final int? distanceChargeCents;
  final int? waitingChargeCents;
  final int? totalCents;

  static const empty = MeterPaymentRecord();

  bool get hasRecord =>
      (bookingId != null && bookingId!.isNotEmpty) ||
      paymentStatus != MeterPaymentStatus.unknown ||
      paymentRequired != null ||
      finalFareCents != null ||
      meterSessionId != null ||
      paymentMode != null ||
      fareClassification != null ||
      hostedUrl != null ||
      receiptUrl != null;

  bool get isMetered {
    if (_looksLikeMeter(paymentMode) || _looksLikeMeter(fareClassification)) {
      return true;
    }
    if (meterSessionId != null && meterSessionId!.isNotEmpty) return true;
    if (finalFareCents != null) return true;
    if (paymentRequired != null) return true;
    return paymentStatus != MeterPaymentStatus.unknown;
  }

  bool get isPaid => paymentStatus == MeterPaymentStatus.paid;

  bool get isRefunded => paymentStatus == MeterPaymentStatus.refunded;

  bool get isFailed => paymentStatus == MeterPaymentStatus.paymentFailed;

  bool get isCheckoutOpen => paymentStatus == MeterPaymentStatus.checkoutOpen;

  bool get isPending =>
      paymentStatus == MeterPaymentStatus.paymentPending || isCheckoutOpen;

  bool get isMeterUnresolved =>
      paymentStatus == MeterPaymentStatus.meterUnresolved;

  bool get needsPayNow {
    if (isPaid || isRefunded || isMeterUnresolved) return false;
    if (!hasFinalFare && isMeterUnresolved) return false;
    if (paymentRequired == false) return false;
    if (paymentRequired == true && hasFinalFare) return true;
    if (paymentRequired == true && !hasFinalFare) return false;
    return (isPending || isFailed) && hasFinalFare;
  }

  bool get canShowPaidReceipt => isPaid && receiptAvailable == true;

  bool get isStripeTestMode => testMode == true || productionCharge != true;

  bool get hasFinalFare => finalFareCents != null || totalCents != null;

  String get currencyCode {
    final code = currency?.trim() ?? '';
    return code.isEmpty ? 'USD' : code.toUpperCase();
  }

  int? get payableCents => finalFareCents ?? totalCents;

  String? get formattedFinalFare => formatCents(payableCents);

  String? get formattedFlagDrop => formatCents(flagDropCents);

  String? get formattedDistanceCharge => formatCents(distanceChargeCents);

  String? get formattedStoppedTimeCharge => formatCents(waitingChargeCents);

  String get passengerStatusLabel {
    return switch (paymentStatus) {
      MeterPaymentStatus.paid => 'Paid',
      MeterPaymentStatus.refunded => 'Refunded',
      MeterPaymentStatus.paymentFailed => 'Payment Failed',
      MeterPaymentStatus.checkoutOpen => 'Checkout Open',
      MeterPaymentStatus.meterUnresolved => 'Fare under review',
      MeterPaymentStatus.paymentPending => 'Payment Pending',
      MeterPaymentStatus.unknown => paymentRequired == true
          ? 'Payment Pending'
          : 'Payment Pending',
    };
  }

  String? formatCents(int? cents) {
    if (cents == null) return null;
    return '$currencyCode ${(cents / 100).toStringAsFixed(2)}';
  }

  bool belongsToBooking(String? activeBookingId) {
    if (activeBookingId == null || activeBookingId.isEmpty) return true;
    if (bookingId == null || bookingId!.isEmpty) return true;
    return bookingId == activeBookingId;
  }

  /// REST snapshots are authoritative. Socket events use [paymentVersion].
  MeterPaymentRecord? mergeIncoming(
    MeterPaymentRecord incoming, {
    required bool authoritative,
  }) {
    if (!incoming.hasRecord) return this;
    if (!_bookingMatches(incoming)) return this;
    if (!authoritative && _isStale(incoming)) return this;
    if (!authoritative && !_mayReplaceStatus(incoming)) return this;
    if (authoritative) return incoming;
    return copyWith(
      bookingId: incoming.bookingId ?? bookingId,
      rideStatus: incoming.rideStatus ?? rideStatus,
      paymentStatus: incoming.paymentStatus == MeterPaymentStatus.unknown
          ? paymentStatus
          : incoming.paymentStatus,
      paymentStatusRaw: incoming.paymentStatusRaw ?? paymentStatusRaw,
      paymentRequired: incoming.paymentRequired ?? paymentRequired,
      paymentMode: incoming.paymentMode ?? paymentMode,
      finalFareCents: incoming.finalFareCents ?? finalFareCents,
      currency: incoming.currency ?? currency,
      meterSessionId: incoming.meterSessionId ?? meterSessionId,
      completedAt: incoming.completedAt ?? completedAt,
      paidAt: incoming.paidAt ?? paidAt,
      receiptAvailable: incoming.receiptAvailable ?? receiptAvailable,
      receiptUrl: incoming.receiptUrl ?? receiptUrl,
      hostedUrl: incoming.hostedUrl ?? hostedUrl,
      testMode: incoming.testMode ?? testMode,
      fareClassification: incoming.fareClassification ?? fareClassification,
      paymentVersion: incoming.paymentVersion ?? paymentVersion,
      productionCharge: incoming.productionCharge ?? productionCharge,
      flagDropCents: incoming.flagDropCents ?? flagDropCents,
      distanceChargeCents: incoming.distanceChargeCents ?? distanceChargeCents,
      waitingChargeCents: incoming.waitingChargeCents ?? waitingChargeCents,
      totalCents: incoming.totalCents ?? totalCents,
    );
  }

  bool _bookingMatches(MeterPaymentRecord incoming) {
    if (bookingId == null || bookingId!.isEmpty) return true;
    if (incoming.bookingId == null || incoming.bookingId!.isEmpty) return true;
    return incoming.bookingId == bookingId;
  }

  bool _isStale(MeterPaymentRecord incoming) {
    final incomingVersion = incoming.paymentVersion;
    final currentVersion = paymentVersion;
    if (incomingVersion == null || currentVersion == null) return false;
    return incomingVersion < currentVersion;
  }

  bool _mayReplaceStatus(MeterPaymentRecord incoming) {
    if (incoming.paymentStatus == MeterPaymentStatus.unknown) return true;
    if (isPaid || isRefunded) {
      if (incoming.isPaid || incoming.isRefunded) return true;
      final incomingVersion = incoming.paymentVersion;
      final currentVersion = paymentVersion;
      if (incomingVersion != null &&
          currentVersion != null &&
          incomingVersion > currentVersion) {
        return true;
      }
      return false;
    }
    return true;
  }

  static bool _looksLikeMeter(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return false;
    return value.contains('meter') || value.contains('soft');
  }

  MeterPaymentRecord copyWith({
    String? bookingId,
    String? rideStatus,
    MeterPaymentStatus? paymentStatus,
    String? paymentStatusRaw,
    bool? paymentRequired,
    String? paymentMode,
    int? finalFareCents,
    String? currency,
    String? meterSessionId,
    DateTime? completedAt,
    DateTime? paidAt,
    bool? receiptAvailable,
    String? receiptUrl,
    String? hostedUrl,
    bool? testMode,
    String? fareClassification,
    int? paymentVersion,
    bool? productionCharge,
    int? flagDropCents,
    int? distanceChargeCents,
    int? waitingChargeCents,
    int? totalCents,
  }) {
    return MeterPaymentRecord(
      bookingId: bookingId ?? this.bookingId,
      rideStatus: rideStatus ?? this.rideStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentStatusRaw: paymentStatusRaw ?? this.paymentStatusRaw,
      paymentRequired: paymentRequired ?? this.paymentRequired,
      paymentMode: paymentMode ?? this.paymentMode,
      finalFareCents: finalFareCents ?? this.finalFareCents,
      currency: currency ?? this.currency,
      meterSessionId: meterSessionId ?? this.meterSessionId,
      completedAt: completedAt ?? this.completedAt,
      paidAt: paidAt ?? this.paidAt,
      receiptAvailable: receiptAvailable ?? this.receiptAvailable,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      hostedUrl: hostedUrl ?? this.hostedUrl,
      testMode: testMode ?? this.testMode,
      fareClassification: fareClassification ?? this.fareClassification,
      paymentVersion: paymentVersion ?? this.paymentVersion,
      productionCharge: productionCharge ?? this.productionCharge,
      flagDropCents: flagDropCents ?? this.flagDropCents,
      distanceChargeCents: distanceChargeCents ?? this.distanceChargeCents,
      waitingChargeCents: waitingChargeCents ?? this.waitingChargeCents,
      totalCents: totalCents ?? this.totalCents,
    );
  }
}

/// Backend PaymentIntent for a completed Soft Meter ride.
///
/// [clientSecret] is used only to present PaymentSheet and must not be stored
/// on ride UI state or written to logs.
class MeterPaymentIntentResult {
  const MeterPaymentIntentResult({
    this.record,
    this.clientSecret,
    this.paymentIntentId,
    this.publishableKey,
  });

  final MeterPaymentRecord? record;
  final String? clientSecret;
  final String? paymentIntentId;

  /// Backend publishable key for this PaymentIntent. Never a secret key.
  final String? publishableKey;

  bool get hasClientSecret {
    final secret = clientSecret?.trim() ?? '';
    return secret.isNotEmpty;
  }
}

enum MeterPaymentStatus {
  unknown,
  paymentPending,
  checkoutOpen,
  paymentFailed,
  meterUnresolved,
  paid,
  refunded,
}

extension MeterPaymentStatusParsing on MeterPaymentStatus {
  static MeterPaymentStatus fromRaw(String? raw) {
    if (raw == null) return MeterPaymentStatus.unknown;
    final value = raw.trim().toLowerCase().replaceAll('-', '_');
    return switch (value) {
      'payment_pending' ||
      'pending' ||
      'unpaid' ||
      'requires_payment' ||
      'incomplete' => MeterPaymentStatus.paymentPending,
      'checkout_open' ||
      'checkout_opened' ||
      'open' ||
      'checkout' => MeterPaymentStatus.checkoutOpen,
      'payment_failed' ||
      'failed' ||
      'expired' ||
      'checkout_expired' => MeterPaymentStatus.paymentFailed,
      'meter_unresolved' ||
      'unresolved' ||
      'fare_unresolved' => MeterPaymentStatus.meterUnresolved,
      'paid' ||
      'succeeded' ||
      'success' ||
      'captured' => MeterPaymentStatus.paid,
      'refunded' ||
      'refund' ||
      'partially_refunded' => MeterPaymentStatus.refunded,
      _ => MeterPaymentStatus.unknown,
    };
  }
}

/// Hosted Checkout URLs must come from the backend and use HTTPS.
abstract final class MeterCheckoutUrls {
  static Uri? parseSafeHttps(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null) return null;
    if (uri.scheme.toLowerCase() != 'https') return null;
    if (uri.host.trim().isEmpty) return null;
    return uri;
  }
}

/// Copy shown on On-Demand Soft Meter booking surfaces.
abstract final class SoftMeterPaymentCopy {
  static const beforeTrip =
      'Your fare is calculated by the Soft Meter based on distance traveled and eligible stopped time. Payment is due after your ride.';
  static const duringTrip =
      'Live meter fare — final amount confirmed when your ride ends.';
  static const afterTrip = 'Final metered fare';
  static const testMode = 'Stripe Test Mode — no real money charged.';
  static const preparing = 'Final fare is being prepared.';
  static const confirming = 'Confirming payment...';
  static const confirmingUnavailable =
      'Payment is being verified. It will update when the bank confirms it.';
  static const unresolved =
      'The final metered fare needs review. No payable amount is available yet.';
}
