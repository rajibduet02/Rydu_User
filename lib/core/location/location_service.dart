import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum AppLocationPermissionStatus {
  notDetermined,
  denied,
  deniedForever,
  granted,
  serviceDisabled,
}

class AppPosition {
  const AppPosition({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}

/// GPS / permission helper using geolocator.
class LocationService {
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<AppLocationPermissionStatus> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return AppLocationPermissionStatus.serviceDisabled;

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  Future<AppLocationPermissionStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return AppLocationPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _mapPermission(permission);
  }

  Future<AppPosition?> getCurrentPosition({
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    final status = await checkPermission();
    if (status != AppLocationPermissionStatus.granted) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
      return AppPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
    } on LocationServiceDisabledException {
      return null;
    } on PermissionDeniedException {
      return null;
    } on TimeoutException {
      return null;
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  AppLocationPermissionStatus _mapPermission(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.denied => AppLocationPermissionStatus.denied,
      LocationPermission.deniedForever =>
        AppLocationPermissionStatus.deniedForever,
      LocationPermission.whileInUse ||
      LocationPermission.always => AppLocationPermissionStatus.granted,
      LocationPermission.unableToDetermine =>
        AppLocationPermissionStatus.notDetermined,
    };
  }
}
