import '../models/ride_destination_model.dart';
import '../models/ride_option_model.dart';
import '../../domain/entities/pickup_spot_entity.dart';

abstract interface class RideBookingLocalDatasource {
  String getDefaultPickupLocation();

  Future<List<RideDestinationModel>> fetchSuggestedLocations();

  Future<List<RideOptionModel>> fetchRideOptions();

  List<PickupSpotEntity> getPickupSpots();

  Future<void> simulateConfirmPickupDelay();

  Future<String> simulateCreateRideRequest();
}

class RideBookingLocalDatasourceImpl implements RideBookingLocalDatasource {
  static const _defaultPickup = '35 Road No. 2';

  static const _suggestedLocations = <RideDestinationModel>[
    RideDestinationModel(
      id: 'bashundhara_city',
      name: 'Bashundhara City Shopping Complex',
      address: '3 No, West Panthapath, Dhaka',
      distance: '6.3 km',
    ),
    RideDestinationModel(
      id: 'square_hospital',
      name: 'Square Hospital',
      address: '18 Bir Uttam Qazi Nuruzzaman Sarak West, ...',
      distance: '7.6 km',
    ),
    RideDestinationModel(
      id: 'hsia_airport',
      name: 'Hazrat Shahjalal International Airport',
      address: 'Airport - Dakshinkhan Rd, Dhaka',
      distance: '14 km',
    ),
    RideDestinationModel(
      id: 'jamuna_future_park',
      name: 'Jamuna Future Park',
      address: 'KA-244, Kuril, Progoti Shoroni, Dhaka',
      distance: '8.1 km',
    ),
    RideDestinationModel(
      id: 'evercare_hospital',
      name: 'Evercare Hospital, Dhaka',
      address: 'Plot 81, Dhaka',
      distance: '7.6 km',
    ),
  ];

  static const _rideOptions = <RideOptionModel>[
    RideOptionModel(
      id: 'cng',
      name: 'CNG',
      category: 'recommended',
      time: '16:02 - 2 min',
      capacity: '4',
      description: 'Affordable, eco-friendly rides',
      price: 'BDT 155.84',
      originalPrice: 'BDT 259.73',
      iconEmoji: '⚡',
      discount: true,
    ),
    RideOptionModel(
      id: 'moto',
      name: 'Moto',
      category: 'recommended',
      time: '16:08 - 9 min',
      capacity: '1',
      description: 'Affordable motorcycle rides',
      price: 'BDT 326.38',
      iconEmoji: '🏍️',
      discount: true,
    ),
    RideOptionModel(
      id: 'bike-41',
      name: 'Bike 41',
      category: 'recommended',
      time: '16:02 - 3 min',
      capacity: '1',
      description: 'Affordable rides in a bike',
      price: 'BDT 96.10',
      originalPrice: 'BDT 160.17',
      iconEmoji: '🏍️',
      discount: true,
    ),
    RideOptionModel(
      id: 'premier',
      name: 'Premier',
      category: 'premier',
      time: '16:06 - 7 min',
      capacity: '4',
      description: 'Comfortable sedans, top-quality drivers',
      price: 'BDT 360.70',
      originalPrice: 'BDT 476.70',
      iconEmoji: '🚗',
    ),
    RideOptionModel(
      id: 'uberxl',
      name: 'UberXL 46',
      category: 'popular',
      time: '16:11 - 7 min',
      capacity: '6',
      description: 'Comfortable SUVs',
      price: 'BDT 560.10',
      originalPrice: 'BDT 626.10',
      iconEmoji: '🚙',
    ),
    RideOptionModel(
      id: 'uberx-non-ac',
      name: 'UberX Non AC 44',
      category: 'popular',
      time: '16:07 - 3 min',
      capacity: '4',
      description: 'Affordable everyday rides',
      price: 'BDT 235.51',
      originalPrice: 'BDT 391.51',
      iconEmoji: '🚗',
    ),
    RideOptionModel(
      id: 'bike-saver',
      name: 'Bike Saver 41',
      category: 'popular',
      time: '2 min',
      description: '1-way bike rides',
      price: 'BDT 76.30',
      originalPrice: 'BDT 109.00',
      iconEmoji: '🏍️',
    ),
    RideOptionModel(
      id: 'uberx-rentals',
      name: 'UberX Rentals',
      category: 'economy',
      time: 'Rent a car',
      description: 'Rent a car by the hour',
      price: 'BDT 389.25',
      iconEmoji: '🚗',
    ),
    RideOptionModel(
      id: 'xl-rentals',
      name: 'XL Rentals',
      category: 'economy',
      time: '12 min away',
      description: 'Rent an SUV by the hour',
      price: 'BDT 618.00',
      iconEmoji: '🚙',
    ),
  ];

  static const _pickupSpots = <PickupSpotEntity>[
    PickupSpotEntity(index: 0, label: 'Near 35 Road No. 2 - Spot 1'),
    PickupSpotEntity(index: 1, label: 'Near 35 Road No. 2 - Spot 2'),
  ];

  @override
  String getDefaultPickupLocation() => _defaultPickup;

  @override
  Future<List<RideDestinationModel>> fetchSuggestedLocations() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return _suggestedLocations;
  }

  @override
  Future<List<RideOptionModel>> fetchRideOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return _rideOptions;
  }

  @override
  List<PickupSpotEntity> getPickupSpots() => _pickupSpots;

  @override
  Future<void> simulateConfirmPickupDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<String> simulateCreateRideRequest() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return 'ride_req_local_${DateTime.now().millisecondsSinceEpoch}';
  }
}
