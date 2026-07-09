import '../../domain/entities/faq_item_entity.dart';

class FaqItemModel extends FaqItemEntity {
  const FaqItemModel({
    required super.id,
    required super.category,
    required super.question,
    required super.answer,
  });

  FaqItemEntity toEntity() => this;
}
