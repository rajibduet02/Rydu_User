import '../../domain/constants/inbox_categories.dart';
import '../../domain/entities/inbox_message_entity.dart';

class InboxMessageModel extends InboxMessageEntity {
  const InboxMessageModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.time,
    required super.category,
    required super.iconType,
    required super.iconColorArgb,
    required super.isUnread,
  });

  static List<InboxMessageModel> seed() => const [
    InboxMessageModel(
      id: '1',
      title: '30% Off Your Next Ride',
      subtitle: 'Use code SAVE30 on your next trip. Valid until May 15.',
      time: '2 hours ago',
      category: InboxCategories.promotion,
      iconType: 'gift',
      iconColorArgb: 0xFFF59E0B,
      isUnread: true,
    ),
    InboxMessageModel(
      id: '2',
      title: 'Trip Receipt',
      subtitle: 'Your ride to Gulshan cost BDT 125.50. View receipt.',
      time: '5 hours ago',
      category: InboxCategories.trip,
      iconType: 'bolt',
      iconColorArgb: 0xFF2F6BFF,
      isUnread: true,
    ),
    InboxMessageModel(
      id: '3',
      title: 'RYD U One Benefits',
      subtitle:
          "You've earned 50 credits this month! Keep riding to unlock more rewards.",
      time: 'Yesterday',
      category: InboxCategories.system,
      iconType: 'info',
      iconColorArgb: 0xFF8B5CF6,
      isUnread: false,
    ),
    InboxMessageModel(
      id: '4',
      title: 'Safety Feature Update',
      subtitle:
          'New: Share your trip with up to 5 trusted contacts simultaneously.',
      time: '2 days ago',
      category: InboxCategories.system,
      iconType: 'alert',
      iconColorArgb: 0xFF22C55E,
      isUnread: false,
    ),
    InboxMessageModel(
      id: '5',
      title: 'Refer & Earn',
      subtitle: 'Invite friends and earn BDT 200 for each referral!',
      time: '3 days ago',
      category: InboxCategories.promotion,
      iconType: 'gift',
      iconColorArgb: 0xFFEC4899,
      isUnread: false,
    ),
    InboxMessageModel(
      id: '6',
      title: 'Driver Feedback Request',
      subtitle: 'How was your ride with Mohammad? Rate your experience.',
      time: '4 days ago',
      category: InboxCategories.trip,
      iconType: 'bell',
      iconColorArgb: 0xFF2F6BFF,
      isUnread: false,
    ),
  ];

  InboxMessageEntity toEntity() => this;
}
