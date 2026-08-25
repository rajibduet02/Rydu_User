import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../../domain/ride_history_filter.dart';
import 'ride_history_dependencies.dart';

class RideHistoryState {
  const RideHistoryState({
    this.items = const [],
    this.selectedFilter = RideHistoryFilter.all,
    this.page = 0,
    this.totalPages = 1,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasFetched = false,
    this.errorMessage,
    this.detail,
    this.isLoadingDetail = false,
    this.detailError,
  });

  final List<BookingEntity> items;
  final RideHistoryFilter selectedFilter;
  final int page;
  final int totalPages;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasFetched;
  final String? errorMessage;
  final BookingEntity? detail;
  final bool isLoadingDetail;
  final String? detailError;

  bool get canLoadMore =>
      hasFetched &&
      !isInitialLoading &&
      !isRefreshing &&
      !isLoadingMore &&
      page > 0 &&
      page < totalPages;

  List<BookingEntity> previousRides({String? activeBookingId}) {
    if (activeBookingId == null || activeBookingId.isEmpty) return items;
    return items.where((item) => item.id != activeBookingId).toList();
  }

  RideHistoryState copyWith({
    List<BookingEntity>? items,
    RideHistoryFilter? selectedFilter,
    int? page,
    int? totalPages,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasFetched,
    String? errorMessage,
    bool clearError = false,
    BookingEntity? detail,
    bool clearDetail = false,
    bool? isLoadingDetail,
    String? detailError,
    bool clearDetailError = false,
  }) {
    return RideHistoryState(
      items: items ?? this.items,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasFetched: hasFetched ?? this.hasFetched,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      detail: clearDetail ? null : (detail ?? this.detail),
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      detailError: clearDetailError
          ? null
          : (detailError ?? this.detailError),
    );
  }
}

class RideHistoryController extends Notifier<RideHistoryState> {
  static const pageLimit = 20;

  String? _lastTerminalRefreshKey;
  int _requestId = 0;

  @override
  RideHistoryState build() {
    ref.listen<RideBookingState>(rideBookingControllerProvider, (prev, next) {
      if (prev == null) return;
      if (!prev.hasActiveBooking || next.hasActiveBooking) return;
      final key = '${prev.bookingId ?? ''}:${next.phase.name}';
      if (_lastTerminalRefreshKey == key) return;
      _lastTerminalRefreshKey = key;
      unawaited(refresh());
    });
    return const RideHistoryState();
  }

  @visibleForTesting
  void debugSeedState(RideHistoryState next) {
    state = next;
  }

  Future<void> loadInitial() async {
    if (state.isInitialLoading) return;
    if (state.hasFetched) {
      await refresh();
      return;
    }
    await _fetchPage(
      page: 1,
      replace: true,
      markInitial: true,
      refreshActive: true,
    );
  }

  Future<void> refresh() async {
    await _fetchPage(
      page: 1,
      replace: true,
      markRefreshing: true,
      refreshActive: true,
    );
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    await _fetchPage(
      page: state.page + 1,
      replace: false,
      markLoadingMore: true,
    );
  }

  Future<void> setFilter(RideHistoryFilter filter) async {
    if (state.selectedFilter == filter && state.hasFetched) {
      await refresh();
      return;
    }
    state = state.copyWith(
      selectedFilter: filter,
      items: const [],
      page: 0,
      hasFetched: false,
      clearError: true,
    );
    await _fetchPage(page: 1, replace: true, markInitial: true);
  }

  Future<BookingEntity?> loadDetail(String id) async {
    state = state.copyWith(
      isLoadingDetail: true,
      clearDetailError: true,
      clearDetail: true,
    );
    try {
      final booking = await ref.read(getRideDetailsUsecaseProvider).call(id);
      state = state.copyWith(
        detail: booking,
        isLoadingDetail: false,
        detailError: booking == null ? 'Ride not found.' : null,
        clearDetailError: booking != null,
      );
      return booking;
    } catch (e) {
      state = state.copyWith(
        isLoadingDetail: false,
        detailError: _messageFor(e),
      );
      return null;
    }
  }

  Future<void> _fetchPage({
    required int page,
    required bool replace,
    bool markInitial = false,
    bool markRefreshing = false,
    bool markLoadingMore = false,
    bool refreshActive = false,
  }) async {
    if (markLoadingMore && state.isRefreshing) return;
    final requestId = ++_requestId;
    state = state.copyWith(
      isInitialLoading: markInitial ? true : state.isInitialLoading,
      isRefreshing: markRefreshing ? true : state.isRefreshing,
      isLoadingMore: markLoadingMore ? true : state.isLoadingMore,
      clearError: true,
    );
    if (refreshActive) {
      await _refreshActiveQuietly();
    }
    try {
      final result = await ref
          .read(listRideHistoryUsecaseProvider)
          .call(
            page: page,
            limit: pageLimit,
            filter: state.selectedFilter,
          );
      if (requestId != _requestId) return;
      final merged = replace
          ? result.items
          : _mergeById(state.items, result.items);
      state = state.copyWith(
        items: merged,
        page: result.pagination.page,
        totalPages: result.pagination.totalPages,
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        hasFetched: true,
        clearError: true,
      );
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: _messageFor(e),
      );
    }
  }

  Future<void> _refreshActiveQuietly() async {
    try {
      await ref
          .read(rideBookingControllerProvider.notifier)
          .restoreActiveBooking(navigate: false);
    } catch (_) {}
  }

  List<BookingEntity> _mergeById(
    List<BookingEntity> existing,
    List<BookingEntity> incoming,
  ) {
    final seen = {for (final item in existing) item.id};
    final out = [...existing];
    for (final item in incoming) {
      if (seen.add(item.id)) out.add(item);
    }
    return out;
  }

  String _messageFor(Object error) {
    if (error is PassengerApiException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Could not load ride history. Try again.';
    }
    return 'Could not load ride history. Try again.';
  }
}
