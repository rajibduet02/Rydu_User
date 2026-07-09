class InboxMessageEntity {
  const InboxMessageEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
    required this.iconType,
    required this.iconColorArgb,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String category;
  final String iconType;
  final int iconColorArgb;
  final bool isUnread;

  InboxMessageEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    String? category,
    String? iconType,
    int? iconColorArgb,
    bool? isUnread,
  }) {
    return InboxMessageEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      category: category ?? this.category,
      iconType: iconType ?? this.iconType,
      iconColorArgb: iconColorArgb ?? this.iconColorArgb,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
