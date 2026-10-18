import 'package:flutter/foundation.dart';

/// Debug-only timing for driver/vehicle card population.
///
/// Logs presence flags only. Never logs phone numbers, tokens, plates,
/// or photo URLs.
abstract final class RideIdentityDebug {
  static void log(
    String step, {
    String? bookingId,
    bool? hasDriver,
    bool? hasVehicle,
    bool? hasEta,
  }) {
    if (!kDebugMode) return;
    final id = bookingId == null || bookingId.isEmpty
        ? '-'
        : (bookingId.length <= 8 ? bookingId : bookingId.substring(0, 8));
    debugPrint(
      '[RideIdentity] $step '
      't=${DateTime.now().toIso8601String()} '
      'booking=$id '
      'driver=$hasDriver vehicle=$hasVehicle eta=$hasEta',
    );
  }
}
