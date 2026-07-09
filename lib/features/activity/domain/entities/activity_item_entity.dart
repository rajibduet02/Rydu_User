class ActivityItemEntity {
  const ActivityItemEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestampLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final String timestampLabel;
}
