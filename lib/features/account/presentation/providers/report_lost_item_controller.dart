import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../models/lost_item_trip.dart';
import 'account_dependencies.dart';

const kContactPreferencePhone = 'phone';
const kContactPreferenceEmail = 'email';
const kContactPreferenceChat = 'chat';

const kContactPreferences = <String>[
  kContactPreferencePhone,
  kContactPreferenceEmail,
  kContactPreferenceChat,
];

class ReportLostItemState {
  const ReportLostItemState({
    this.selectedTrip,
    this.trips = const [],
    this.itemDescription = '',
    this.lastSeenLocation = '',
    this.contactPreference = kContactPreferencePhone,
    this.isFormValid = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.snackMessage,
    this.submitSucceeded = false,
  });

  final LostItemTrip? selectedTrip;
  final List<LostItemTrip> trips;
  final String itemDescription;
  final String lastSeenLocation;
  final String contactPreference;
  final bool isFormValid;
  final bool isSubmitting;
  final String? errorMessage;
  final String? snackMessage;
  final bool submitSucceeded;

  ReportLostItemState copyWith({
    LostItemTrip? selectedTrip,
    bool clearSelectedTrip = false,
    List<LostItemTrip>? trips,
    String? itemDescription,
    String? lastSeenLocation,
    String? contactPreference,
    bool? isFormValid,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? snackMessage,
    bool clearSnack = false,
    bool? submitSucceeded,
    bool clearSubmitSucceeded = false,
  }) {
    return ReportLostItemState(
      selectedTrip: clearSelectedTrip
          ? null
          : (selectedTrip ?? this.selectedTrip),
      trips: trips ?? this.trips,
      itemDescription: itemDescription ?? this.itemDescription,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      contactPreference: contactPreference ?? this.contactPreference,
      isFormValid: isFormValid ?? this.isFormValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
      submitSucceeded: clearSubmitSucceeded
          ? false
          : (submitSucceeded ?? this.submitSucceeded),
    );
  }
}

class ReportLostItemController extends Notifier<ReportLostItemState> {
  @override
  ReportLostItemState build() => const ReportLostItemState();

  bool _computeValid(ReportLostItemState s) {
    return s.selectedTrip != null &&
        s.itemDescription.trim().length >= 5 &&
        s.lastSeenLocation.trim().isNotEmpty &&
        kContactPreferences.contains(s.contactPreference);
  }

  void _syncValid() {
    state = state.copyWith(isFormValid: _computeValid(state), clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSnack() {
    state = state.copyWith(clearSnack: true);
  }

  void clearSubmitSucceeded() {
    state = state.copyWith(clearSubmitSucceeded: true);
  }

  Future<void> loadTrips() async {
    try {
      final trips = await ref.read(getLostItemTripsUsecaseProvider).call();
      state = state.copyWith(
        trips: trips,
        selectedTrip: trips.isNotEmpty ? trips.first : null,
      );
      _syncValid();
    } catch (_) {
      state = state.copyWith(errorMessage: 'Could not load trips.');
    }
  }

  void selectTrip(String tripId) {
    LostItemTrip? trip;
    for (final t in state.trips) {
      if (t.id == tripId) {
        trip = t;
        break;
      }
    }
    if (trip == null) return;
    state = state.copyWith(selectedTrip: trip);
    _syncValid();
  }

  void updateItemDescription(String value) {
    state = state.copyWith(itemDescription: value);
    _syncValid();
  }

  void updateLastSeenLocation(String value) {
    state = state.copyWith(lastSeenLocation: value);
    _syncValid();
  }

  void selectContactPreference(String preference) {
    if (!kContactPreferences.contains(preference)) return;
    state = state.copyWith(contactPreference: preference);
    _syncValid();
  }

  void validateForm() {
    final valid = _computeValid(state);
    state = state.copyWith(
      isFormValid: valid,
      errorMessage: valid
          ? null
          : 'Select a trip, describe the item (5+ chars), and enter last seen location.',
      clearError: valid,
    );
  }

  Future<void> submitReport() async {
    validateForm();
    if (!state.isFormValid || state.isSubmitting) return;
    final trip = state.selectedTrip;
    if (trip == null) return;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(submitLostItemReportUsecaseProvider)
          .call(
            trip: trip,
            itemDescription: state.itemDescription,
            lastSeenLocation: state.lastSeenLocation,
            contactPreference: state.contactPreference,
          );
      state = state.copyWith(
        isSubmitting: false,
        snackMessage: 'Lost item report submitted',
        submitSucceeded: true,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not submit report. Please try again.',
      );
    }
  }

  void navigateAfterSuccess() {
    if (!state.submitSucceeded) return;
    state = state.copyWith(clearSubmitSucceeded: true);
    ref.read(goRouterProvider).go(RouteNames.helpCenter);
  }
}
