import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/maps/encoded_polyline_decoder.dart';
import '../models/ride_flow_extra.dart';
import '../models/ride_vehicle_option.dart';
import '../../../payment/presentation/widgets/payment_method_sheet.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';
import '../widgets/card_payment_status_panel.dart';
import '../widgets/payment_method_tile.dart';
import '../widgets/ride_option_card.dart';

class RideSelectionScreen extends ConsumerStatefulWidget {
  const RideSelectionScreen({super.key});

  @override
  ConsumerState<RideSelectionScreen> createState() =>
      _RideSelectionScreenState();
}

class _RideSelectionScreenState extends ConsumerState<RideSelectionScreen> {
  bool _initialized = false;
  GoogleMapController? _mapController;
  bool _didFitCamera = false;

  static const _categories = ['recommended', 'premier', 'popular', 'economy'];
  static const _polylineId = PolylineId('route_preview');

  String _categoryTitle(String category) {
    switch (category) {
      case 'recommended':
        return 'Rides we think you\'ll like';
      case 'premier':
        return 'Premier';
      case 'popular':
        return 'Popular';
      case 'economy':
        return 'Economy';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fitRouteCamera(RideBookingState state) async {
    final controller = _mapController;
    if (controller == null || !mounted) return;

    LatLngBounds? cameraBounds;
    final bounds = state.routePreview?.routeBounds;
    if (bounds != null && bounds.isValid) {
      cameraBounds = LatLngBounds(
        southwest: LatLng(
          bounds.southwest.latitude,
          bounds.southwest.longitude,
        ),
        northeast: LatLng(
          bounds.northeast.latitude,
          bounds.northeast.longitude,
        ),
      );
    } else {
      final fromPoints = EncodedPolylineDecoder.boundsFromPoints(
        state.polylinePoints,
      );
      if (fromPoints != null) {
        cameraBounds = LatLngBounds(
          southwest: LatLng(fromPoints.southwest.lat, fromPoints.southwest.lng),
          northeast: LatLng(fromPoints.northeast.lat, fromPoints.northeast.lng),
        );
      } else if (state.pickupPlace?.hasCoordinates == true &&
          state.dropoffPlace?.hasCoordinates == true) {
        final p = state.pickupPlace!;
        final d = state.dropoffPlace!;
        cameraBounds = LatLngBounds(
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

    if (cameraBounds == null) {
      final single = state.pickupPlace?.hasCoordinates == true
          ? state.pickupPlace!
          : state.dropoffPlace;
      if (single == null || !single.hasCoordinates) return;
      try {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(single.latitude, single.longitude),
            14,
          ),
        );
        _didFitCamera = true;
      } catch (_) {}
      return;
    }

    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted || _mapController == null) return;
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(cameraBounds, 56),
      );
      _didFitCamera = true;
      if (kDebugMode) debugPrint('RideSelectionMap: camera fit ok');
    } catch (e) {
      if (kDebugMode) debugPrint('RideSelectionMap: camera fit failed $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideBookingControllerProvider);
    final c = ref.read(rideBookingControllerProvider.notifier);
    final options = state.rideOptions;

    ref.listen(rideBookingControllerProvider, (prev, next) {
      if (_mapController == null) return;
      final routeChanged =
          prev?.routePreview?.encodedPolyline !=
          next.routePreview?.encodedPolyline;
      if (routeChanged || !_didFitCamera) {
        _fitRouteCamera(next);
      }
    });

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final extra = GoRouterState.of(context).extra;
        c.initializeFromExtra(RideFlowExtra.parseMap(extra));
      });
    }

    final grouped = <String, List<RideVehicleOption>>{};
    for (final o in options) {
      grouped.putIfAbsent(o.category, () => []).add(o);
    }

    final selectedName = state.selectedVehicle?.name ?? 'Ride';
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final pickup = state.pickupPlace;
    final dropoff = state.dropoffPlace;
    final hasMapTarget =
        (pickup != null && pickup.hasCoordinates) ||
        (dropoff != null && dropoff.hasCoordinates);
    final initialTarget = hasMapTarget
        ? LatLng(
            pickup?.hasCoordinates == true
                ? pickup!.latitude
                : dropoff!.latitude,
            pickup?.hasCoordinates == true
                ? pickup!.longitude
                : dropoff!.longitude,
          )
        : null;

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
      if (state.driverLocation != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(
            state.driverLocation!.latitude,
            state.driverLocation!.longitude,
          ),
          rotation: state.driverLocation!.heading ?? 0,
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

    return Scaffold(
      backgroundColor: RideBookingTokens.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.34,
                  child: Stack(
                    children: [
                      if (initialTarget != null)
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: initialTarget,
                            zoom: 13,
                          ),
                          markers: markers,
                          polylines: polylines,
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                          mapToolbarEnabled: false,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            if (kDebugMode) {
                              debugPrint('RideSelectionMap: created');
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              _fitRouteCamera(state);
                            });
                          },
                        )
                      else
                        const ColoredBox(
                          color: AppDarkSurfaces.surfaceContainerLow,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Map unavailable. Check pickup/destination '
                                'coordinates and GOOGLE_MAPS_API_KEY.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: RideBookingTokens.muted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 12,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            _CircleIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () {
                                if (context.canPop()) context.pop();
                              },
                            ),
                            const Spacer(),
                            if (state.promotionBanner != null)
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B2C),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.bolt_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          state.promotionBanner!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (state.isLoadingQuote || state.isLoadingRoute)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Color(0x33000000),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: RideBookingTokens.accent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: RideBookingTokens.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: options.isEmpty && !state.isLoadingQuote
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.errorMessage ??
                                          'No ride services available for this route.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: RideBookingTokens.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: c.loadQuotesForCurrentTrip,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                200 + bottomInset,
                              ),
                              children: [
                                if (state.errorMessage != null) ...[
                                  Text(
                                    state.errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                for (final category in _categories) ...[
                                  if (grouped[category]?.isNotEmpty ??
                                      false) ...[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        0,
                                        8,
                                        12,
                                      ),
                                      child: Text(
                                        _categoryTitle(category),
                                        style: const TextStyle(
                                          color: RideBookingTokens.muted,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    for (final option in grouped[category]!)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: RideOptionCard(
                                          option: option,
                                          isSelected:
                                              state.selectedVehicleId ==
                                              option.id,
                                          onTap: () =>
                                              c.selectVehicle(option.id),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
                decoration: const BoxDecoration(
                  color: RideBookingTokens.background,
                  border: Border(
                    top: BorderSide(color: RideBookingTokens.border),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.showsCardPaymentPanel) ...[
                      CardPaymentStatusPanel(
                        state: state,
                        onRetry: () {
                          c.retryCardPayment();
                        },
                        onCancel: () async {
                          final ok = await c.cancelActiveBooking();
                          if (!context.mounted) return;
                          if (ok && context.canPop()) context.pop();
                        },
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      PaymentMethodTile(
                        method: state.bookingPaymentLabel,
                        onTap: () async {
                          await PaymentMethodSheet.show(context);
                          if (!context.mounted) return;
                          c.syncPaymentFromProvider();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            state.hasSelectedVehicle &&
                                !state.isCreatingBooking &&
                                !state.isPaymentPending &&
                                !state.showsCardPaymentPanel
                            ? c.continueToConfirmPickup
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                              AppDarkSurfaces.surfaceContainerLow,
                          disabledForegroundColor: RideBookingTokens.muted,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: state.isCreatingBooking
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'Choose $selectedName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RideBookingTokens.headerButtonFill,
            border: Border.all(color: RideBookingTokens.border),
          ),
          child: Icon(icon, color: RideBookingTokens.titleWhite, size: 22),
        ),
      ),
    );
  }
}
