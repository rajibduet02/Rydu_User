import '../../domain/entities/faqs_data_entity.dart';
import 'faq_item_model.dart';

class FaqsDataModel extends FaqsDataEntity {
  const FaqsDataModel({required super.faqs, required super.defaultExpandedId});

  factory FaqsDataModel.fromSeed() {
    return const FaqsDataModel(
      defaultExpandedId: 'rides-contact-driver',
      faqs: [
        FaqItemModel(
          id: 'account-reset-password',
          category: 'Account',
          question: 'How do I reset my password?',
          answer:
              'Go to Settings > Security, tap Change Password, and follow the steps sent to your email or phone.',
        ),
        FaqItemModel(
          id: 'booking-cancel-ride',
          category: 'Booking',
          question: 'How do I cancel a ride?',
          answer:
              'Open your active trip, tap Cancel Ride, and confirm. Cancellation fees may apply depending on driver arrival status.',
        ),
        FaqItemModel(
          id: 'payment-extra-charge',
          category: 'Payment',
          question: 'Why was I charged extra?',
          answer:
              'Extra charges can include tolls, waiting time, route changes, or tips. Check your receipt breakdown in Ride History.',
        ),
        FaqItemModel(
          id: 'rides-contact-driver',
          category: 'Rides',
          question: 'How do I contact my driver?',
          answer:
              'Once a driver is assigned to your trip, a "Call" and "Message" button will appear on the bottom of the trip screen. All communication is routed through our secure system to protect your privacy. Your driver will also receive a notification if you send a message while they are en route.',
        ),
      ],
    );
  }

  FaqsDataEntity toEntity() => this;
}
