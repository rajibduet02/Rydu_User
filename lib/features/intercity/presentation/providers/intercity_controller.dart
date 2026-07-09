import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/entities/confidence_item_entity.dart';
import '../../domain/entities/destination_entity.dart';
import '../models/intercity_booking_route_args.dart';
import 'intercity_dependencies.dart';

abstract final class IntercityOfferIds {
  static const defaultPromo = 'intercity_30_bdt75';
}

class IntercityState {
  const IntercityState({
    this.selectedOffer,
    this.selectedDestination,
    this.popularDestinations = const [],
    this.confidenceItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String? selectedOffer;
  final DestinationEntity? selectedDestination;
  final List<DestinationEntity> popularDestinations;
  final List<ConfidenceItemEntity> confidenceItems;
  final bool isLoading;
  final String? errorMessage;

  IntercityState copyWith({
    String? selectedOffer,
    DestinationEntity? selectedDestination,
    bool clearSelectedDestination = false,
    List<DestinationEntity>? popularDestinations,
    List<ConfidenceItemEntity>? confidenceItems,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IntercityState(
      selectedOffer: selectedOffer ?? this.selectedOffer,
      selectedDestination: clearSelectedDestination
          ? null
          : (selectedDestination ?? this.selectedDestination),
      popularDestinations: popularDestinations ?? this.popularDestinations,
      confidenceItems: confidenceItems ?? this.confidenceItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class IntercityController extends Notifier<IntercityState> {
  @override
  IntercityState build() => const IntercityState();

  Future<void> loadIntercityData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final content = await ref
          .read(loadIntercityContentUsecaseProvider)
          .call();
      state = state.copyWith(
        isLoading: false,
        popularDestinations: content.popularDestinations,
        confidenceItems: content.confidenceItems,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load intercity content.',
      );
    }
  }

  void selectOffer(String offer) {
    state = state.copyWith(selectedOffer: offer, clearError: true);
    ref.read(goRouterProvider).push(RouteNames.offers);
  }

  void selectDestination(String destinationId) {
    DestinationEntity? found;
    for (final d in state.popularDestinations) {
      if (d.id == destinationId) {
        found = d;
        break;
      }
    }
    state = state.copyWith(selectedDestination: found, clearError: true);
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.intercityBooking,
          extra: IntercityBookingRouteArgs(
            destinationId: found?.id,
            cityName: found?.cityName,
            startingPrice: found?.startingPrice,
          ),
        );
  }

  void searchRides() {
    final d = state.selectedDestination;
    state = state.copyWith(clearError: true);
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.intercityBooking,
          extra: IntercityBookingRouteArgs(
            destinationId: d?.id,
            cityName: d?.cityName,
            startingPrice: d?.startingPrice,
          ),
        );
  }

  void openHelp() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.helpCenter);
  }

  void navigateBack() {
    final router = ref.read(goRouterProvider);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(RouteNames.services);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
