import '../models/ride_location_update_model.dart';

abstract interface class RideTrackingRemoteDatasource {
  Stream<RideLocationUpdateModel> driverLocation(String rideId);
}

class RideTrackingRemoteDatasourceImpl implements RideTrackingRemoteDatasource {
  RideTrackingRemoteDatasourceImpl();

  @override
  Stream<RideLocationUpdateModel> driverLocation(String rideId) async* {
    yield const RideLocationUpdateModel(lat: 0, lng: 0);
  }
}
