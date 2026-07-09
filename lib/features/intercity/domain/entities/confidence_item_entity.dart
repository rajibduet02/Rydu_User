enum ConfidenceIconType { award, shield, calendar, mapPin }

class ConfidenceItemEntity {
  const ConfidenceItemEntity({
    required this.id,
    required this.title,
    required this.iconType,
  });

  final String id;
  final String title;
  final ConfidenceIconType iconType;
}
