class RideTripEntity {
  const RideTripEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.vehicleName,
    required this.fare,
    required this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final String vehicleName;
  final String fare;
  final String status;
}
