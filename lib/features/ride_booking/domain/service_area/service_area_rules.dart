import '../entities/ride_planning_entities.dart';
import 'service_area_geometry.dart';
import 'service_area_messages.dart';
import 'service_area_models.dart';

abstract final class ServiceAreaRules {
  /// Evaluates pickup, drop-off, and stops against the backend boundary.
  /// The passenger's physical device location is not an input.
  static ServiceAreaDecision evaluate({
    required ServiceAreaConfig? config,
    required PlaceEntity? pickup,
    PlaceEntity? dropoff,
    List<PlaceEntity> stops = const [],
  }) {
    if (config == null || !config.canApplyLocalRestriction) {
      return ServiceAreaDecision(
        config: config,
        allowsQuoteOrBooking: true,
        serviceUnavailable: false,
      );
    }

    final failed = <String>[];
    if (pickup != null &&
        pickup.hasCoordinates &&
        !ServiceAreaGeometry.contains(
          config,
          pickup.latitude,
          pickup.longitude,
        )) {
      failed.add('pickup');
    }
    if (dropoff != null &&
        dropoff.hasCoordinates &&
        !ServiceAreaGeometry.contains(
          config,
          dropoff.latitude,
          dropoff.longitude,
        )) {
      failed.add('dropoff');
    }
    for (final stop in stops) {
      if (!stop.hasCoordinates) continue;
      if (ServiceAreaGeometry.contains(config, stop.latitude, stop.longitude)) {
        continue;
      }
      if (!failed.contains('stop')) failed.add('stop');
    }

    if (failed.isEmpty) {
      return ServiceAreaDecision(
        config: config,
        allowsQuoteOrBooking: true,
        serviceUnavailable: false,
      );
    }

    return ServiceAreaDecision(
      config: config,
      allowsQuoteOrBooking: false,
      serviceUnavailable: false,
      message: ServiceAreaMessages.outOfServiceMessage(failed),
      failedPoints: failed,
    );
  }
}
