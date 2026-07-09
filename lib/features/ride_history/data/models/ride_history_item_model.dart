class RideHistoryItemModel {
  const RideHistoryItemModel({
    required this.id,
    required this.summary,
    this.completedAt,
  });

  final String id;
  final String summary;
  final DateTime? completedAt;
}
