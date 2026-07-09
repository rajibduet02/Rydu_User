import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../ride_booking/presentation/models/ride_booking_route_args.dart';
import '../../domain/entities/offer_entity.dart';
import 'offers_dependencies.dart';

const kOfferIdPremier = 'premier';
const kOfferIdIntercity = 'intercity';
const kOfferIdSelectProduct = 'select-product';

class OffersState {
  const OffersState({
    this.offers = const [],
    this.selectedOfferId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<OfferEntity> offers;
  final String? selectedOfferId;
  final bool isLoading;
  final String? errorMessage;

  OffersState copyWith({
    List<OfferEntity>? offers,
    String? selectedOfferId,
    bool clearSelectedOffer = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OffersState(
      offers: offers ?? this.offers,
      selectedOfferId: clearSelectedOffer
          ? null
          : (selectedOfferId ?? this.selectedOfferId),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OffersController extends Notifier<OffersState> {
  @override
  OffersState build() => const OffersState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadOffers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final offers = await ref.read(getOffersUsecaseProvider).call();
      state = state.copyWith(offers: offers, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load offers. Try again.',
      );
    }
  }

  void selectOffer(String offerId) {
    final exists = state.offers.any((o) => o.id == offerId);
    if (!exists) return;
    state = state.copyWith(selectedOfferId: offerId, clearError: true);
  }

  void bookOffer(String offerId) {
    final index = state.offers.indexWhere((o) => o.id == offerId);
    if (index < 0) return;
    final offer = state.offers[index];

    selectOffer(offerId);
    final router = ref.read(goRouterProvider);

    switch (offer.actionType) {
      case OfferActionType.premium:
        router.push(
          RouteNames.rideBooking,
          extra: const RideBookingRouteArgs(selectedType: 'Premium'),
        );
      case OfferActionType.intercity:
        router.push(RouteNames.intercity);
      case OfferActionType.ride:
        router.push(
          RouteNames.rideBooking,
          extra: const RideBookingRouteArgs(selectedType: 'Ride'),
        );
    }
  }
}

final offersControllerProvider =
    NotifierProvider<OffersController, OffersState>(OffersController.new);
