enum RideHistoryFilter {
  all,
  completed,
  cancelled;

  String get queryValue => name;

  String get label => switch (this) {
    RideHistoryFilter.all => 'All',
    RideHistoryFilter.completed => 'Completed',
    RideHistoryFilter.cancelled => 'Cancelled',
  };
}
