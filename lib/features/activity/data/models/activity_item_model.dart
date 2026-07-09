import '../../domain/entities/activity_item_entity.dart';

class ActivityItemModel {
  const ActivityItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestampLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final String timestampLabel;

  ActivityItemEntity toEntity() {
    return ActivityItemEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      timestampLabel: timestampLabel,
    );
  }
}
