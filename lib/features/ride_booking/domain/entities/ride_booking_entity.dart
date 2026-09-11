import 'ride_destination_entity.dart';
import 'ride_option_entity.dart';

class RideBookingEntity {
  const RideBookingEntity({
    required this.rideType,
    required this.pickupLocation,
    this.destination,
    this.selectedOption,
    this.estimatedFare,
    this.paymentMethod = 'Card',
    this.pickupSpotIndex = 0,
    this.pickupConfirmed = false,
  });

  final String rideType;
  final String pickupLocation;
  final RideDestinationEntity? destination;
  final RideOptionEntity? selectedOption;
  final String? estimatedFare;
  final String paymentMethod;
  final int pickupSpotIndex;
  final bool pickupConfirmed;
}
