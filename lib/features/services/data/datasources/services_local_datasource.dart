import '../../domain/constants/service_ids.dart';
import '../models/service_catalog_entry_model.dart';

abstract interface class ServicesLocalDatasource {
  List<ServiceCatalogEntryModel> getCatalog();
}

class ServicesLocalDatasourceImpl implements ServicesLocalDatasource {
  static const _catalog = <ServiceCatalogEntryModel>[
    ServiceCatalogEntryModel(
      id: ServiceIds.ride,
      label: 'Ride',
      emoji: '🚗',
      discountLabel: '30% OFF',
      iconAccentArgb: 0xFF2F6BFF,
      dimmed: false,
    ),
    ServiceCatalogEntryModel(
      id: ServiceIds.bike,
      label: 'Bike',
      emoji: '🏍️',
      discountLabel: '30% OFF',
      iconAccentArgb: 0xFF22C55E,
      dimmed: false,
    ),
    ServiceCatalogEntryModel(
      id: ServiceIds.cng,
      label: 'CNG',
      emoji: '⚡',
      discountLabel: '30% OFF',
      iconAccentArgb: 0xFFF59E0B,
      dimmed: false,
    ),
    ServiceCatalogEntryModel(
      id: ServiceIds.intercity,
      label: 'Intercity',
      emoji: '🚙',
      discountLabel: '30% OFF',
      iconAccentArgb: 0xFF2F6BFF,
      dimmed: true,
    ),
    ServiceCatalogEntryModel(
      id: ServiceIds.reserve,
      label: 'Reserve',
      emoji: '🗓️',
      iconAccentArgb: 0xFF4D7DFF,
      dimmed: true,
    ),
    ServiceCatalogEntryModel(
      id: ServiceIds.rentals,
      label: 'Rentals',
      emoji: '🔑',
      iconAccentArgb: 0xFF2F6BFF,
      dimmed: true,
    ),
  ];

  @override
  List<ServiceCatalogEntryModel> getCatalog() => _catalog;
}
