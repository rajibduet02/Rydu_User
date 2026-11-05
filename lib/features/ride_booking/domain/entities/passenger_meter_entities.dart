/// Server Soft Meter snapshot for an On-Demand passenger booking.
///
/// Fields are taken only from GET `/passenger/bookings/:id/meter` and
/// `meter:state` / `meter:fare` payloads. The app never computes fare or
/// distance locally and never treats this as a charge.
class PassengerMeterSnapshot {
  const PassengerMeterSnapshot({
    this.bookingId,
    this.sessionId,
    this.sessionType,
    this.status = SoftMeterStatus.none,
    this.stateVersion,
    this.fareFrozen,
    this.reviewRequired,
    this.provisionalFare,
    this.currency,
    this.traveledDistanceMiles,
    this.tripElapsedSeconds,
    this.chargeableElapsedSeconds,
    this.pauseDurationSeconds,
    this.quotedFareUnchanged,
    this.settlement,
    this.eligibleStoppedSeconds,
    this.waitingSeconds,
    this.excludedStopSeconds,
    this.stopStreak,
    this.stopPolicy,
    this.flagDropCents,
    this.distanceChargeCents,
    this.waitingChargeCents,
    this.totalCents,
    this.billedStoppedMinutes,
    this.unbilledStoppedRemainderSeconds,
    this.waitingPolicyApplied,
    this.distanceTimePolicyApplied,
  });

  final String? bookingId;
  final String? sessionId;
  final String? sessionType;
  final SoftMeterStatus status;
  final int? stateVersion;
  final bool? fareFrozen;
  final bool? reviewRequired;
  final double? provisionalFare;
  final String? currency;
  final double? traveledDistanceMiles;
  final int? tripElapsedSeconds;
  final int? chargeableElapsedSeconds;
  final int? pauseDurationSeconds;
  final bool? quotedFareUnchanged;
  final MeterSettlement? settlement;
  final int? eligibleStoppedSeconds;
  final int? waitingSeconds;
  final int? excludedStopSeconds;
  final int? stopStreak;
  final String? stopPolicy;
  final int? flagDropCents;
  final int? distanceChargeCents;
  final int? waitingChargeCents;
  final int? totalCents;
  final int? billedStoppedMinutes;
  final int? unbilledStoppedRemainderSeconds;
  final bool? waitingPolicyApplied;
  final bool? distanceTimePolicyApplied;

  static const empty = PassengerMeterSnapshot();

  bool get hasSession =>
      (sessionId != null && sessionId!.isNotEmpty) ||
      status != SoftMeterStatus.none ||
      provisionalFare != null ||
      fareFrozen != null ||
      flagDropCents != null ||
      distanceChargeCents != null ||
      waitingChargeCents != null ||
      totalCents != null ||
      eligibleStoppedSeconds != null ||
      waitingSeconds != null;

  /// Walk-Up hail sessions are driver/admin only.
  bool get isWalkUp {
    final raw = (sessionType ?? '').trim().toLowerCase();
    if (raw.isEmpty) return false;
    final normalized = raw.replaceAll('_', '-').replaceAll(' ', '-');
    return normalized == 'walk-up' ||
        normalized == 'walkup' ||
        normalized == 'walkup-session';
  }

  bool get isPausedDisplay =>
      status == SoftMeterStatus.paused || fareFrozen == true;

  bool get isReviewRequiredDisplay =>
      status == SoftMeterStatus.reviewRequired || reviewRequired == true;

  bool get isFinalizedNonBillable =>
      status == SoftMeterStatus.finalized &&
      (settlement?.billable == false || settlement?.charged == false);

  String get statusLabel {
    if (isPausedDisplay) return 'Paused';
    return switch (status) {
      SoftMeterStatus.running => 'Running',
      SoftMeterStatus.paused => 'Paused',
      SoftMeterStatus.stopped => 'Stopped',
      SoftMeterStatus.finalized => 'Finalized',
      SoftMeterStatus.reviewRequired => 'Review required',
      SoftMeterStatus.none => '',
    };
  }

  String get currencyCode {
    final code = currency?.trim() ?? '';
    return code.isEmpty ? 'USD' : code.toUpperCase();
  }

  String? get formattedProvisionalFare {
    if (totalCents != null) return formatCents(totalCents);
    if (provisionalFare == null) return null;
    return '$currencyCode ${provisionalFare!.toStringAsFixed(2)}';
  }

  /// Backend eligible stopped time; `waitingSeconds` only if eligible is absent.
  int? get displayedEligibleStoppedSeconds =>
      eligibleStoppedSeconds ?? waitingSeconds;

  String? get formattedFlagDrop => formatCents(flagDropCents);

  String? get formattedDistanceCharge => formatCents(distanceChargeCents);

  String? get formattedWaitingCharge => formatCents(waitingChargeCents);

  String? get formattedEligibleStoppedTime =>
      formatElapsed(displayedEligibleStoppedSeconds);

  String? get formattedBilledStoppedMinutes {
    final minutes = billedStoppedMinutes;
    if (minutes == null) return null;
    return '$minutes min';
  }

  String? get formattedUnbilledRemainder =>
      formatElapsed(unbilledStoppedRemainderSeconds);

  String? formatCents(int? cents) {
    if (cents == null) return null;
    return '$currencyCode ${(cents / 100).toStringAsFixed(2)}';
  }

  String? get formattedDistanceMiles {
    final miles = traveledDistanceMiles;
    if (miles == null) return null;
    final digits = miles.abs() >= 10 ? 1 : 2;
    return '${miles.toStringAsFixed(digits)} mi';
  }

  String? get formattedTripElapsed => formatElapsed(tripElapsedSeconds);

  String? get formattedChargeableElapsed =>
      formatElapsed(chargeableElapsedSeconds);

  String? get formattedPauseDuration => formatElapsed(pauseDurationSeconds);

  static String? formatElapsed(int? seconds) {
    if (seconds == null) return null;
    final total = seconds.abs();
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final secs = total % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// REST snapshots are authoritative. Socket events use [stateVersion].
  PassengerMeterSnapshot? mergeIncoming(
    PassengerMeterSnapshot incoming, {
    required bool authoritative,
  }) {
    if (authoritative) {
      return incoming.hasSession ? incoming : null;
    }
    if (!incoming.hasSession && incoming.status == SoftMeterStatus.none) {
      return this;
    }
    if (!_bookingMatches(incoming)) return this;
    if (_isStale(incoming)) return this;
    return copyWith(
      bookingId: incoming.bookingId ?? bookingId,
      sessionId: incoming.sessionId ?? sessionId,
      sessionType: incoming.sessionType ?? sessionType,
      status: incoming.status == SoftMeterStatus.none
          ? status
          : incoming.status,
      stateVersion: incoming.stateVersion ?? stateVersion,
      fareFrozen: incoming.fareFrozen ?? fareFrozen,
      reviewRequired: incoming.reviewRequired ?? reviewRequired,
      provisionalFare: incoming.provisionalFare ?? provisionalFare,
      currency: incoming.currency ?? currency,
      traveledDistanceMiles:
          incoming.traveledDistanceMiles ?? traveledDistanceMiles,
      tripElapsedSeconds: incoming.tripElapsedSeconds ?? tripElapsedSeconds,
      chargeableElapsedSeconds:
          incoming.chargeableElapsedSeconds ?? chargeableElapsedSeconds,
      pauseDurationSeconds:
          incoming.pauseDurationSeconds ?? pauseDurationSeconds,
      quotedFareUnchanged:
          incoming.quotedFareUnchanged ?? quotedFareUnchanged,
      settlement: incoming.settlement ?? settlement,
      eligibleStoppedSeconds:
          incoming.eligibleStoppedSeconds ?? eligibleStoppedSeconds,
      waitingSeconds: incoming.waitingSeconds ?? waitingSeconds,
      excludedStopSeconds:
          incoming.excludedStopSeconds ?? excludedStopSeconds,
      stopStreak: incoming.stopStreak ?? stopStreak,
      stopPolicy: incoming.stopPolicy ?? stopPolicy,
      flagDropCents: incoming.flagDropCents ?? flagDropCents,
      distanceChargeCents:
          incoming.distanceChargeCents ?? distanceChargeCents,
      waitingChargeCents: incoming.waitingChargeCents ?? waitingChargeCents,
      totalCents: incoming.totalCents ?? totalCents,
      billedStoppedMinutes:
          incoming.billedStoppedMinutes ?? billedStoppedMinutes,
      unbilledStoppedRemainderSeconds:
          incoming.unbilledStoppedRemainderSeconds ??
          unbilledStoppedRemainderSeconds,
      waitingPolicyApplied:
          incoming.waitingPolicyApplied ?? waitingPolicyApplied,
      distanceTimePolicyApplied:
          incoming.distanceTimePolicyApplied ?? distanceTimePolicyApplied,
    );
  }

  bool belongsToBooking(String? activeBookingId) {
    if (activeBookingId == null || activeBookingId.isEmpty) return false;
    if (bookingId == null || bookingId!.isEmpty) return true;
    return bookingId == activeBookingId;
  }

  bool _bookingMatches(PassengerMeterSnapshot incoming) {
    if (bookingId == null || bookingId!.isEmpty) return true;
    if (incoming.bookingId == null || incoming.bookingId!.isEmpty) return true;
    return incoming.bookingId == bookingId;
  }

  bool _isStale(PassengerMeterSnapshot incoming) {
    final incomingVersion = incoming.stateVersion;
    final currentVersion = stateVersion;
    if (incomingVersion == null || currentVersion == null) return false;
    return incomingVersion < currentVersion;
  }

  PassengerMeterSnapshot copyWith({
    String? bookingId,
    String? sessionId,
    String? sessionType,
    SoftMeterStatus? status,
    int? stateVersion,
    bool? fareFrozen,
    bool? reviewRequired,
    double? provisionalFare,
    String? currency,
    double? traveledDistanceMiles,
    int? tripElapsedSeconds,
    int? chargeableElapsedSeconds,
    int? pauseDurationSeconds,
    bool? quotedFareUnchanged,
    MeterSettlement? settlement,
    int? eligibleStoppedSeconds,
    int? waitingSeconds,
    int? excludedStopSeconds,
    int? stopStreak,
    String? stopPolicy,
    int? flagDropCents,
    int? distanceChargeCents,
    int? waitingChargeCents,
    int? totalCents,
    int? billedStoppedMinutes,
    int? unbilledStoppedRemainderSeconds,
    bool? waitingPolicyApplied,
    bool? distanceTimePolicyApplied,
  }) {
    return PassengerMeterSnapshot(
      bookingId: bookingId ?? this.bookingId,
      sessionId: sessionId ?? this.sessionId,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      stateVersion: stateVersion ?? this.stateVersion,
      fareFrozen: fareFrozen ?? this.fareFrozen,
      reviewRequired: reviewRequired ?? this.reviewRequired,
      provisionalFare: provisionalFare ?? this.provisionalFare,
      currency: currency ?? this.currency,
      traveledDistanceMiles:
          traveledDistanceMiles ?? this.traveledDistanceMiles,
      tripElapsedSeconds: tripElapsedSeconds ?? this.tripElapsedSeconds,
      chargeableElapsedSeconds:
          chargeableElapsedSeconds ?? this.chargeableElapsedSeconds,
      pauseDurationSeconds:
          pauseDurationSeconds ?? this.pauseDurationSeconds,
      quotedFareUnchanged: quotedFareUnchanged ?? this.quotedFareUnchanged,
      settlement: settlement ?? this.settlement,
      eligibleStoppedSeconds:
          eligibleStoppedSeconds ?? this.eligibleStoppedSeconds,
      waitingSeconds: waitingSeconds ?? this.waitingSeconds,
      excludedStopSeconds: excludedStopSeconds ?? this.excludedStopSeconds,
      stopStreak: stopStreak ?? this.stopStreak,
      stopPolicy: stopPolicy ?? this.stopPolicy,
      flagDropCents: flagDropCents ?? this.flagDropCents,
      distanceChargeCents: distanceChargeCents ?? this.distanceChargeCents,
      waitingChargeCents: waitingChargeCents ?? this.waitingChargeCents,
      totalCents: totalCents ?? this.totalCents,
      billedStoppedMinutes:
          billedStoppedMinutes ?? this.billedStoppedMinutes,
      unbilledStoppedRemainderSeconds:
          unbilledStoppedRemainderSeconds ??
          this.unbilledStoppedRemainderSeconds,
      waitingPolicyApplied:
          waitingPolicyApplied ?? this.waitingPolicyApplied,
      distanceTimePolicyApplied:
          distanceTimePolicyApplied ?? this.distanceTimePolicyApplied,
    );
  }
}

enum SoftMeterStatus {
  none,
  running,
  paused,
  stopped,
  finalized,
  reviewRequired,
}

extension SoftMeterStatusParsing on SoftMeterStatus {
  static SoftMeterStatus fromRaw(String? raw) {
    if (raw == null) return SoftMeterStatus.none;
    final value = raw.trim().toLowerCase().replaceAll('-', '_');
    return switch (value) {
      'running' || 'in_progress' || 'started' => SoftMeterStatus.running,
      'paused' || 'pause' => SoftMeterStatus.paused,
      'stopped' || 'stop' => SoftMeterStatus.stopped,
      'finalized' || 'final' || 'complete' || 'completed' =>
        SoftMeterStatus.finalized,
      'review_required' ||
      'reviewrequired' ||
      'review' => SoftMeterStatus.reviewRequired,
      _ => SoftMeterStatus.none,
    };
  }
}

/// Settlement flags from the meter endpoint. Not a passenger payment.
class MeterSettlement {
  const MeterSettlement({
    this.billable,
    this.charged,
    this.status,
  });

  final bool? billable;
  final bool? charged;
  final String? status;
}
