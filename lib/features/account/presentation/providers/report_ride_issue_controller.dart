import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../models/ride_trip.dart';
import 'account_dependencies.dart';

const kIssueTypeDriver = 'driver_issue';
const kIssueTypePayment = 'payment';
const kIssueTypeRoute = 'route';
const kIssueTypeSafety = 'safety';
const kIssueTypeLostItem = 'lost_item';
const kIssueTypeOther = 'other';

const kIssueTypes = <String>[
  kIssueTypeDriver,
  kIssueTypePayment,
  kIssueTypeRoute,
  kIssueTypeSafety,
  kIssueTypeLostItem,
  kIssueTypeOther,
];

const Map<String, String> kIssueTypeLabels = {
  kIssueTypeDriver: 'Driver Issue',
  kIssueTypePayment: 'Payment',
  kIssueTypeRoute: 'Route',
  kIssueTypeSafety: 'Safety',
  kIssueTypeLostItem: 'Lost Item',
  kIssueTypeOther: 'Other',
};

class ReportRideIssueState {
  const ReportRideIssueState({
    this.selectedTrip,
    this.trips = const [],
    this.selectedIssueType = kIssueTypeDriver,
    this.details = '',
    this.uploadedPhotoPath,
    this.isFormValid = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.snackMessage,
    this.submitSucceeded = false,
  });

  final RideTrip? selectedTrip;
  final List<RideTrip> trips;
  final String selectedIssueType;
  final String details;
  final String? uploadedPhotoPath;
  final bool isFormValid;
  final bool isSubmitting;
  final String? errorMessage;
  final String? snackMessage;
  final bool submitSucceeded;

  ReportRideIssueState copyWith({
    RideTrip? selectedTrip,
    bool clearSelectedTrip = false,
    List<RideTrip>? trips,
    String? selectedIssueType,
    String? details,
    String? uploadedPhotoPath,
    bool clearPhoto = false,
    bool? isFormValid,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? snackMessage,
    bool clearSnack = false,
    bool? submitSucceeded,
    bool clearSubmitSucceeded = false,
  }) {
    return ReportRideIssueState(
      selectedTrip: clearSelectedTrip
          ? null
          : (selectedTrip ?? this.selectedTrip),
      trips: trips ?? this.trips,
      selectedIssueType: selectedIssueType ?? this.selectedIssueType,
      details: details ?? this.details,
      uploadedPhotoPath: clearPhoto
          ? null
          : (uploadedPhotoPath ?? this.uploadedPhotoPath),
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

class ReportRideIssueController extends Notifier<ReportRideIssueState> {
  @override
  ReportRideIssueState build() => const ReportRideIssueState();

  bool _computeValid(ReportRideIssueState s) {
    return s.selectedTrip != null &&
        s.selectedIssueType.isNotEmpty &&
        s.details.trim().length >= 10;
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
      final trips = await ref.read(getRideIssueTripsUsecaseProvider).call();
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
    RideTrip? trip;
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

  void selectIssueType(String issueType) {
    if (!kIssueTypes.contains(issueType)) return;
    state = state.copyWith(selectedIssueType: issueType);
    _syncValid();
  }

  void updateDetails(String value) {
    state = state.copyWith(details: value);
    _syncValid();
  }

  void pickFromCamera() {
    state = state.copyWith(
      uploadedPhotoPath: 'demo://camera-photo',
      snackMessage: 'Camera picker coming soon. (TODO: image_picker)',
    );
    _syncValid();
  }

  void pickFromGallery() {
    state = state.copyWith(
      uploadedPhotoPath: 'demo://gallery-photo',
      snackMessage: 'Gallery picker coming soon. (TODO: image_picker)',
    );
    _syncValid();
  }

  void removePhoto() {
    state = state.copyWith(clearPhoto: true);
    _syncValid();
  }

  void validateForm() {
    final valid = _computeValid(state);
    state = state.copyWith(
      isFormValid: valid,
      errorMessage: valid
          ? null
          : 'Select a trip, issue type, and enter at least 10 characters.',
      clearError: valid,
    );
  }

  Future<void> submitTicket() async {
    validateForm();
    if (!state.isFormValid || state.isSubmitting) return;
    final trip = state.selectedTrip;
    if (trip == null) return;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(submitRideIssueUsecaseProvider)
          .call(
            trip: trip,
            issueType: state.selectedIssueType,
            details: state.details,
            photoPath: state.uploadedPhotoPath,
          );
      state = state.copyWith(
        isSubmitting: false,
        snackMessage: 'Ride issue submitted',
        submitSucceeded: true,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not submit ticket. Please try again.',
      );
    }
  }

  void navigateAfterSuccess() {
    if (!state.submitSucceeded) return;
    state = state.copyWith(clearSubmitSucceeded: true);
    ref.read(goRouterProvider).go(RouteNames.helpCenter);
  }
}
