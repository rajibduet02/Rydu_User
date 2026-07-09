import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/entities/activity_item_entity.dart';
import 'activity_dependencies.dart';

typedef ActivityItem = ActivityItemEntity;

abstract final class ActivityCategoryIds {
  static const myOrders = 'My orders';
  static const business = 'Business';
  static const family = 'Family';
}

abstract final class ActivityServiceIds {
  static const all = 'All';
  static const rides = 'Rides';
  static const eats = 'Eats';
  static const twoWheeler = '2-Wheeler';
  static const rentals = 'Rentals';
}

class ActivityState {
  const ActivityState({
    this.selectedCategory = ActivityCategoryIds.myOrders,
    this.selectedService = ActivityServiceIds.all,
    this.appliedCategory = ActivityCategoryIds.myOrders,
    this.appliedService = ActivityServiceIds.all,
    this.activities = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedBottomNavIndex = 2,
  });

  final String selectedCategory;
  final String selectedService;
  final String appliedCategory;
  final String appliedService;
  final List<ActivityItem> activities;
  final bool isLoading;
  final String? errorMessage;
  final int selectedBottomNavIndex;

  bool get isEmptyFeed => activities.isEmpty;

  ActivityState copyWith({
    String? selectedCategory,
    String? selectedService,
    String? appliedCategory,
    String? appliedService,
    List<ActivityItem>? activities,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? selectedBottomNavIndex,
  }) {
    return ActivityState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedService: selectedService ?? this.selectedService,
      appliedCategory: appliedCategory ?? this.appliedCategory,
      appliedService: appliedService ?? this.appliedService,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}

class ActivityController extends Notifier<ActivityState> {
  @override
  ActivityState build() => const ActivityState();

  void resetForActivityTab() {
    state = const ActivityState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Syncs sheet draft selections from currently applied filters before opening UI.
  void openFilter() {
    state = state.copyWith(
      selectedCategory: state.appliedCategory,
      selectedService: state.appliedService,
      clearError: true,
    );
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category, clearError: true);
  }

  void selectService(String service) {
    state = state.copyWith(selectedService: service, clearError: true);
  }

  /// Returns `true` when filters were applied and the sheet should close.
  Future<bool> applyFilters() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await ref
          .read(loadActivitiesUsecaseProvider)
          .call(
            category: state.selectedCategory,
            service: state.selectedService,
          );
      state = state.copyWith(
        appliedCategory: state.selectedCategory,
        appliedService: state.selectedService,
        activities: items,
        isLoading: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Could not apply filters. Try again.',
        isLoading: false,
      );
      return false;
    }
  }

  void clearFilters() {
    state = state.copyWith(
      selectedCategory: ActivityCategoryIds.myOrders,
      selectedService: ActivityServiceIds.all,
      appliedCategory: ActivityCategoryIds.myOrders,
      appliedService: ActivityServiceIds.all,
      activities: const [],
      clearError: true,
    );
  }

  void selectBottomNav(int index) {
    state = state.copyWith(selectedBottomNavIndex: index, clearError: true);
    final router = ref.read(goRouterProvider);
    switch (index) {
      case 0:
        router.go(RouteNames.home);
        break;
      case 1:
        router.go(RouteNames.services);
        break;
      case 2:
        router.go(RouteNames.activity);
        break;
      case 3:
        router.go(RouteNames.account);
        break;
    }
  }
}

final activityControllerProvider =
    NotifierProvider<ActivityController, ActivityState>(ActivityController.new);
