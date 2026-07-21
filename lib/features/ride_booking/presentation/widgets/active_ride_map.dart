import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/maps/encoded_polyline_decoder.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';

/// Shared Google Map for planning and post-booking active-ride phases.
class ActiveRideMap extends ConsumerStatefulWidget {
  const ActiveRideMap({
    super.key,
    this.showDriver = true,
    this.bottomPadding = 48,
  });

  final bool showDriver;
  final double bottomPadding;

  @override
  ConsumerState<ActiveRideMap> createState() => _ActiveRideMapState();
}

class _ActiveRideMapState extends ConsumerState<ActiveRideMap> {
  GoogleMapController? _controller;
  bool _didFit = false;
  static const _polylineId = PolylineId('active_route');

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _fit(RideBookingState state) async {
    final controller = _controller;
    if (controller == null) return;

    LatLngBounds? bounds;
    final rb = state.routePreview?.routeBounds;
    if (rb != null && rb.isValid) {
      bounds = LatLngBounds(
        southwest: LatLng(rb.southwest.latitude, rb.southwest.longitude),
        northeast: LatLng(rb.northeast.latitude, rb.northeast.longitude),
      );
    } else {
      final fromPoints = EncodedPolylineDecoder.boundsFromPoints(
        state.polylinePoints,
      );
      if (fromPoints != null) {
        bounds = LatLngBounds(
          southwest: LatLng(fromPoints.southwest.lat, fromPoints.southwest.lng),
          northeast: LatLng(fromPoints.northeast.lat, fromPoints.northeast.lng),
        );
      } else if (state.pickupPlace != null && state.dropoffPlace != null) {
        final p = state.pickupPlace!;
        final d = state.dropoffPlace!;
        bounds = LatLngBounds(
          southwest: LatLng(
            p.latitude < d.latitude ? p.latitude : d.latitude,
            p.longitude < d.longitude ? p.longitude : d.longitude,
          ),
          northeast: LatLng(
            p.latitude > d.latitude ? p.latitude : d.latitude,
            p.longitude > d.longitude ? p.longitude : d.longitude,
          ),
        );
      }
    }

    if (bounds == null) return;
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, widget.bottomPadding),
      );
      _didFit = true;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideBookingControllerProvider);

    ref.listen(rideBookingControllerProvider, (prev, next) {
      if (_controller == null) return;
      final routeChanged =
          prev?.routePreview?.encodedPolyline !=
          next.routePreview?.encodedPolyline;
      if (routeChanged || !_didFit) {
        _fit(next);
      }
    });

    final pickup = state.pickupPlace;
    final dropoff = state.dropoffPlace;
    final driver = state.driverLocation;

    LatLng? target;
    if (pickup != null) {
      target = LatLng(pickup.latitude, pickup.longitude);
    } else if (dropoff != null) {
      target = LatLng(dropoff.latitude, dropoff.longitude);
    } else if (driver != null && widget.showDriver) {
      target = LatLng(driver.latitude, driver.longitude);
    }

    if (target == null) {
      return const ColoredBox(
        color: RideBookingTokens.background,
        child: Center(
          child: CircularProgressIndicator(color: RideBookingTokens.accent),
        ),
      );
    }

    final markers = <Marker>{
      if (pickup != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pickup.latitude, pickup.longitude),
          infoWindow: InfoWindow(title: 'Pickup', snippet: pickup.label),
        ),
      if (dropoff != null)
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(dropoff.latitude, dropoff.longitude),
          infoWindow: InfoWindow(title: 'Destination', snippet: dropoff.label),
        ),
      if (widget.showDriver && driver != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(driver.latitude, driver.longitude),
          rotation: driver.heading ?? 0,
          flat: true,
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
    };

    final polylines = <Polyline>{
      if (state.polylinePoints.length >= 2)
        Polyline(
          polylineId: _polylineId,
          color: RideBookingTokens.accent,
          width: 5,
          points: state.polylinePoints
              .map((p) => LatLng(p.lat, p.lng))
              .toList(growable: false),
        ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: target, zoom: 13),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        _fit(state);
      },
    );
  }
}
