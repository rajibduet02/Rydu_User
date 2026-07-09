class RideHistoryItemEntity {
  const RideHistoryItemEntity({
    required this.id,
    required this.summary,
    required this.completedAt,
  });

  final String id;
  final String summary;
  final DateTime? completedAt;
}
