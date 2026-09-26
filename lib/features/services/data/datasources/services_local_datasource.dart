import '../../../ride_booking/domain/constants/passenger_service_categories.dart';
import '../../../ride_booking/presentation/models/ride_vehicle_option.dart';
import '../../domain/constants/service_ids.dart';
import '../models/service_catalog_entry_model.dart';

abstract interface class ServicesLocalDatasource {
  List<ServiceCatalogEntryModel> getCatalog();
}

class ServicesLocalDatasourceImpl implements ServicesLocalDatasource {
  static const _accents = <String, int>{
    'ECONOMY': 0xFF2F6BFF,
    'EXECUTIVE': 0xFF4D7DFF,
    'SUV': 0xFF22C55E,
    'VAN': 0xFFF59E0B,
    'MINIVAN': 0xFF2F6BFF,
    'ADA': 0xFF0F6B4C,
  };

  @override
  List<ServiceCatalogEntryModel> getCatalog() {
    return [
      for (final item in PassengerServiceCategories.current)
        ServiceCatalogEntryModel(
          id: item.code,
          label: item.displayName,
          emoji: serviceCategoryIconEmoji(item.iconKey),
          iconAccentArgb: _accents[item.code] ?? 0xFF2F6BFF,
          dimmed: false,
        ),
      const ServiceCatalogEntryModel(
        id: ServiceIds.intercity,
        label: 'Intercity',
        emoji: '🚙',
        discountLabel: '30% OFF',
        iconAccentArgb: 0xFF2F6BFF,
        dimmed: true,
      ),
      const ServiceCatalogEntryModel(
        id: ServiceIds.reserve,
        label: 'Reserve',
        emoji: '🗓️',
        iconAccentArgb: 0xFF4D7DFF,
        dimmed: true,
      ),
      const ServiceCatalogEntryModel(
        id: ServiceIds.rentals,
        label: 'Rentals',
        emoji: '🔑',
        iconAccentArgb: 0xFF2F6BFF,
        dimmed: true,
      ),
    ];
  }
}
