import '../models/call_support_info_model.dart';
import '../models/chat_message_model.dart';
import '../models/lost_item_trip_model.dart';
import '../models/ride_trip_model.dart';

abstract interface class SupportLocalDatasource {
  Future<List<ChatMessageModel>> fetchLiveChatMessages();
  Future<void> sendLiveChatMessage(ChatMessageModel message);

  Future<List<RideTripModel>> fetchRideIssueTrips();
  Future<void> submitRideIssue({
    required RideTripModel trip,
    required String issueType,
    required String details,
    String? photoPath,
  });

  Future<List<LostItemTripModel>> fetchLostItemTrips();
  Future<void> submitLostItemReport({
    required LostItemTripModel trip,
    required String itemDescription,
    required String lastSeenLocation,
    required String contactPreference,
  });

  Future<CallSupportInfoModel> fetchCallSupportInfo();
  Future<void> initiateSupportCall();

  Future<void> submitEmailSupport({
    required String subject,
    required String category,
    required String message,
    String? attachmentPath,
  });
}

class SupportLocalDatasourceImpl implements SupportLocalDatasource {
  List<ChatMessageModel> _chatMessages = ChatMessageModel.seed();

  @override
  Future<List<ChatMessageModel>> fetchLiveChatMessages() async {
    // TODO: Load chat history from support API / WebSocket when backend is ready.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<ChatMessageModel>.from(_chatMessages);
  }

  @override
  Future<void> sendLiveChatMessage(ChatMessageModel message) async {
    // TODO: Send message to support chat API / socket.
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _chatMessages = [..._chatMessages, message];
  }

  static const _rideIssueTrips = <RideTripModel>[
    RideTripModel(
      id: '1',
      title: 'Oct 24 · Toyota Camry',
      subtitle: '\$24.50 · Delivered',
      vehicleName: 'Toyota Camry',
      fare: '\$24.50',
      status: 'Delivered',
    ),
    RideTripModel(
      id: '2',
      title: 'Oct 18 · Honda City',
      subtitle: '\$18.20 · Delivered',
      vehicleName: 'Honda City',
      fare: '\$18.20',
      status: 'Delivered',
    ),
    RideTripModel(
      id: '3',
      title: 'Oct 12 · Nissan X-Trail',
      subtitle: '\$32.00 · Cancelled',
      vehicleName: 'Nissan X-Trail',
      fare: '\$32.00',
      status: 'Cancelled',
    ),
  ];

  @override
  Future<List<RideTripModel>> fetchRideIssueTrips() async {
    // TODO: Load recent trips from ride history API when backend is ready.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _rideIssueTrips;
  }

  @override
  Future<void> submitRideIssue({
    required RideTripModel trip,
    required String issueType,
    required String details,
    String? photoPath,
  }) async {
    // TODO: POST ride issue ticket to support API with photos.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  static const _lostItemTrips = <LostItemTripModel>[
    LostItemTripModel(
      id: '1',
      vehicleName: 'Toyota Camry',
      dateTime: 'Oct 24 • 8:45 PM',
      subtitle: 'Oct 24 • 8:45 PM',
    ),
    LostItemTripModel(
      id: '2',
      vehicleName: 'Honda City',
      dateTime: 'Oct 18 • 6:20 PM',
      subtitle: 'Oct 18 • 6:20 PM',
    ),
    LostItemTripModel(
      id: '3',
      vehicleName: 'Nissan X-Trail',
      dateTime: 'Oct 12 • 9:10 AM',
      subtitle: 'Oct 12 • 9:10 AM',
    ),
  ];

  @override
  Future<List<LostItemTripModel>> fetchLostItemTrips() async {
    // TODO: Load completed trips from ride history API when backend is ready.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _lostItemTrips;
  }

  @override
  Future<void> submitLostItemReport({
    required LostItemTripModel trip,
    required String itemDescription,
    required String lastSeenLocation,
    required String contactPreference,
  }) async {
    // TODO: POST lost item report to support API and notify driver.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<CallSupportInfoModel> fetchCallSupportInfo() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const CallSupportInfoModel(
      supportPhoneNumber: '+1 (800) 123-4567',
      isAvailable: true,
    );
  }

  @override
  Future<void> initiateSupportCall() async {
    // TODO: Launch `tel:` via url_launcher when support line is finalized.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> submitEmailSupport({
    required String subject,
    required String category,
    required String message,
    String? attachmentPath,
  }) async {
    // TODO: POST support ticket to backend / send email via API.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
