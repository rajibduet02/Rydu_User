import '../../domain/entities/ride_planning_entities.dart';
import '../../domain/entities/ride_option_entity.dart';

/// User-facing airport surcharge copy. Uses backend code/name/tripType only.
abstract final class AirportFarePresentation {
  static const tripFareLabel = 'Trip Fare';
  static const totalLabel = 'Total';

  static bool shouldShow({required double airportFee}) => airportFee > 0;

  static String money(String? currency, double amount) {
    final code = currency?.trim();
    final prefix = (code == null || code.isEmpty) ? 'BDT' : code;
    return '$prefix ${amount.toStringAsFixed(2)}';
  }

  static String feeLabel(AirportQuoteEntity? airport) {
    final prefix = _airportPrefix(airport);
    final kind = tripKind(airport?.tripType);
    if (prefix != null) {
      return switch (kind) {
        AirportTripKind.pickup => '$prefix Airport Pickup Fee',
        AirportTripKind.dropoff => '$prefix Airport Drop-Off Fee',
        AirportTripKind.unknown => '$prefix Airport Fee',
      };
    }
    return switch (kind) {
      AirportTripKind.pickup => 'Airport Pickup Fee',
      AirportTripKind.dropoff => 'Airport Drop-Off Fee',
      AirportTripKind.unknown => 'Airport Fee',
    };
  }

  static AirportTripKind tripKind(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return AirportTripKind.unknown;
    final compact = value.replaceAll(RegExp(r'[-_\s]'), '');
    if (compact == 'pickup' || compact == 'airportpickup') {
      return AirportTripKind.pickup;
    }
    if (compact == 'dropoff' ||
        compact == 'airportdropoff' ||
        compact == 'dropofffee') {
      return AirportTripKind.dropoff;
    }
    return AirportTripKind.unknown;
  }

  static String? _airportPrefix(AirportQuoteEntity? airport) {
    final code = airport?.code?.trim();
    if (code != null && code.isNotEmpty) return code.toUpperCase();
    final name = airport?.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return null;
  }

  static AirportFareBreakdownData? fromOption(RideOptionEntity option) {
    final fee = option.airportFee ?? 0;
    if (!shouldShow(airportFee: fee) || option.finalFare == null) return null;
    final currency = option.currency;
    return AirportFareBreakdownData(
      tripFareLabel: tripFareLabel,
      tripFareAmount: money(currency, option.displayTripFare),
      airportFeeLabel: feeLabel(option.airport),
      airportFeeAmount: money(currency, fee),
      totalLabel: totalLabel,
      totalAmount: money(currency, option.finalFare!),
    );
  }

  static AirportFareBreakdownData? fromBooking(BookingEntity booking) {
    final fee = booking.airportFee ?? 0;
    if (!shouldShow(airportFee: fee) || booking.finalFare == null) return null;
    final currency = booking.currency;
    return AirportFareBreakdownData(
      tripFareLabel: tripFareLabel,
      tripFareAmount: money(currency, booking.displayTripFare),
      airportFeeLabel: feeLabel(booking.airport),
      airportFeeAmount: money(currency, fee),
      totalLabel: totalLabel,
      totalAmount: money(currency, booking.finalFare!),
    );
  }
}

enum AirportTripKind { pickup, dropoff, unknown }

class AirportFareBreakdownData {
  const AirportFareBreakdownData({
    required this.tripFareLabel,
    required this.tripFareAmount,
    required this.airportFeeLabel,
    required this.airportFeeAmount,
    required this.totalLabel,
    required this.totalAmount,
  });

  final String tripFareLabel;
  final String tripFareAmount;
  final String airportFeeLabel;
  final String airportFeeAmount;
  final String totalLabel;
  final String totalAmount;
}
