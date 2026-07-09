import '../../domain/entities/service_catalog_entry_entity.dart';

class ServiceCatalogEntryModel extends ServiceCatalogEntryEntity {
  const ServiceCatalogEntryModel({
    required super.id,
    required super.label,
    required super.emoji,
    super.discountLabel,
    required super.iconAccentArgb,
    required super.dimmed,
  });
}
