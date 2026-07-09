import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../models/recent_place.dart';
import '../models/saved_place.dart';
import 'account_dependencies.dart';

class SavedPlacesState {
  const SavedPlacesState({
    this.savedPlaces = const [],
    this.recentPlaces = const [],
    this.selectedPlace,
    this.defaultPlaceId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<SavedPlace> savedPlaces;
  final List<RecentPlace> recentPlaces;
  final SavedPlace? selectedPlace;
  final String? defaultPlaceId;
  final bool isLoading;
  final String? errorMessage;

  SavedPlacesState copyWith({
    List<SavedPlace>? savedPlaces,
    List<RecentPlace>? recentPlaces,
    SavedPlace? selectedPlace,
    bool clearSelectedPlace = false,
    String? defaultPlaceId,
    bool resetDefaultPlaceId = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SavedPlacesState(
      savedPlaces: savedPlaces ?? this.savedPlaces,
      recentPlaces: recentPlaces ?? this.recentPlaces,
      selectedPlace: clearSelectedPlace
          ? null
          : (selectedPlace ?? this.selectedPlace),
      defaultPlaceId: resetDefaultPlaceId
          ? null
          : (defaultPlaceId ?? this.defaultPlaceId),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SavedPlacesController extends Notifier<SavedPlacesState> {
  @override
  SavedPlacesState build() => const SavedPlacesState();

  SavedPlace? _savedById(String id) {
    for (final e in state.savedPlaces) {
      if (e.id == id) return e;
    }
    return null;
  }

  RecentPlace? _recentById(String id) {
    for (final e in state.recentPlaces) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> loadSavedPlaces() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(getSavedPlacesUsecaseProvider).call();
      state = state.copyWith(
        savedPlaces: data.savedPlaces,
        recentPlaces: data.recentPlaces,
        defaultPlaceId: data.defaultPlaceId,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load saved places.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void selectPlace(String placeId) {
    final p = _savedById(placeId);
    if (p == null) return;
    state = state.copyWith(selectedPlace: p, clearError: true);
  }

  void openSavedPlace(String placeId) {
    final p = _savedById(placeId);
    if (p == null) return;
    state = state.copyWith(selectedPlace: p, clearError: true);
    ref.read(goRouterProvider).push(RouteNames.savedPlaceDetail, extra: p);
  }

  void addNewPlace() {
    ref.read(goRouterProvider).push(RouteNames.addSavedPlace);
  }

  void editPlace(String placeId) {
    final p = _savedById(placeId);
    if (p == null) return;
    ref.read(goRouterProvider).push(RouteNames.editSavedPlace, extra: p);
  }

  void deletePlace(String placeId) {
    final filtered = state.savedPlaces.where((e) => e.id != placeId).toList();
    if (filtered.length == state.savedPlaces.length) return;

    var newDefaultId = state.defaultPlaceId;
    var next = filtered;

    if (state.defaultPlaceId == placeId ||
        !next.any((e) => e.id == state.defaultPlaceId)) {
      newDefaultId = next.isNotEmpty ? next.first.id : null;
      next = next
          .map(
            (e) => e.copyWith(
              isDefault: newDefaultId != null && e.id == newDefaultId,
            ),
          )
          .toList();
    }

    state = state.copyWith(
      savedPlaces: next,
      defaultPlaceId: newDefaultId,
      resetDefaultPlaceId: newDefaultId == null,
      clearSelectedPlace: state.selectedPlace?.id == placeId,
      clearError: true,
    );
  }

  void setDefaultPlace(String placeId) {
    if (_savedById(placeId) == null) return;
    final next = state.savedPlaces
        .map((e) => e.copyWith(isDefault: e.id == placeId))
        .toList();
    state = state.copyWith(
      savedPlaces: next,
      defaultPlaceId: placeId,
      clearError: true,
    );
  }

  void selectRecentPlace(String placeId) {
    if (_recentById(placeId) == null) return;
    state = state.copyWith(clearSelectedPlace: true, clearError: true);
    ref.read(goRouterProvider).push(RouteNames.searchDestination);
  }
}
