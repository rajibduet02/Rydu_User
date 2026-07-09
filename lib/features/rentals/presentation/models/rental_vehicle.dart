import '../../domain/entities/rental_vehicle_entity.dart';

typedef RentalVehicle = RentalVehicleEntity;

extension RentalVehiclePresentation on RentalVehicleEntity {
  String get emoji {
    switch (iconType) {
      case RentalVehicleIconType.car:
        return '🚗';
      case RentalVehicleIconType.suv:
        return '🚙';
    }
  }
}
