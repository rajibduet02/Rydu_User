import '../../domain/entities/offer_entity.dart';

class OfferModel {
  const OfferModel({
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

  OfferEntity toEntity() {
    return OfferEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      expiryText: expiryText,
      badgeText: badgeText,
      discountType: discountType,
      actionType: actionType,
      iconAccent: iconAccent,
    );
  }

  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      expiryText: entity.expiryText,
      badgeText: entity.badgeText,
      discountType: entity.discountType,
      actionType: entity.actionType,
      iconAccent: entity.iconAccent,
    );
  }
}
