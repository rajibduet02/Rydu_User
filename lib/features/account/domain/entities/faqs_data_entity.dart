import 'faq_item_entity.dart';

class FaqsDataEntity {
  const FaqsDataEntity({required this.faqs, required this.defaultExpandedId});

  final List<FaqItemEntity> faqs;
  final String defaultExpandedId;
}
