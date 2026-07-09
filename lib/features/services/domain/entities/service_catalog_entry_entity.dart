class ServiceCatalogEntryEntity {
  const ServiceCatalogEntryEntity({
    required this.id,
    required this.label,
    required this.emoji,
    this.discountLabel,
    required this.iconAccentArgb,
    required this.dimmed,
  });

  final String id;
  final String label;
  final String emoji;
  final String? discountLabel;
  final int iconAccentArgb;
  final bool dimmed;
}
