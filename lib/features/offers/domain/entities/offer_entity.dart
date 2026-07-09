/// Visual accent for the offer list icon.
enum OfferIconAccent { gold, red }

/// Navigation target when the user taps Book now.
enum OfferActionType { premium, intercity, ride }

class OfferEntity {
  const OfferEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.expiryText,
    required this.discountType,
    required this.actionType,
    this.badgeText,
    this.iconAccent = OfferIconAccent.gold,
  });

  final String id;
  final String title;
  final String subtitle;
  final String expiryText;
  final String? badgeText;
  final String discountType;
  final OfferActionType actionType;
  final OfferIconAccent iconAccent;
}
