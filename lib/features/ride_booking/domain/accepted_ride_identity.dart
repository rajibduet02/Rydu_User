import 'entities/ride_planning_entities.dart';

/// Passenger-facing identity. Omits fields the backend did not send.
class AcceptedRideIdentity {
  const AcceptedRideIdentity({
    required this.driverName,
    this.profileImageUrl,
    this.rating,
    this.phone,
    this.make,
    this.model,
    this.color,
    this.year,
    this.plateNumber,
    this.etaLabel,
  });

  final String driverName;
  final String? profileImageUrl;
  final String? rating;
  final String? phone;
  final String? make;
  final String? model;
  final String? color;
  final int? year;
  final String? plateNumber;
  final String? etaLabel;

  bool get canCall => phone != null && phone!.trim().isNotEmpty;

  String? get makeModel {
    final parts = <String>[
      if (make != null && make!.trim().isNotEmpty) make!.trim(),
      if (model != null && model!.trim().isNotEmpty) model!.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  String? get colorYear {
    final parts = <String>[
      if (color != null && color!.trim().isNotEmpty) color!.trim(),
      if (year != null) '$year',
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  static AcceptedRideIdentity fromAssignment({
    AssignedDriverEntity? driver,
    BookingVehicleEntity? vehicle,
    int? etaMinutes,
  }) {
    final plate = _text(vehicle?.plateNumber) ?? _text(driver?.plateNumber);
    final eta = driver?.etaMinutes ?? etaMinutes;
    return AcceptedRideIdentity(
      driverName: _text(driver?.name) ?? 'Driver assigned',
      profileImageUrl: _text(driver?.profileImageUrl),
      rating: _text(driver?.rating),
      phone: _text(driver?.phone),
      make: _text(vehicle?.make),
      model: _text(vehicle?.model),
      color: _text(vehicle?.color),
      year: vehicle?.year,
      plateNumber: plate,
      etaLabel: eta != null ? '$eta min' : null,
    );
  }

  static String? _text(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}
