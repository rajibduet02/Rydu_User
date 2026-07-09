import '../entities/call_support_info_entity.dart';
import '../entities/chat_message_entity.dart';
import '../entities/lost_item_trip_entity.dart';
import '../entities/ride_trip_entity.dart';

abstract interface class SupportRepository {
  Future<List<ChatMessageEntity>> getLiveChatMessages();
  Future<void> sendLiveChatMessage(ChatMessageEntity message);

  Future<List<RideTripEntity>> getRideIssueTrips();
  Future<void> submitRideIssue({
    required RideTripEntity trip,
    required String issueType,
    required String details,
    String? photoPath,
  });

  Future<List<LostItemTripEntity>> getLostItemTrips();
  Future<void> submitLostItemReport({
    required LostItemTripEntity trip,
    required String itemDescription,
    required String lastSeenLocation,
    required String contactPreference,
  });

  Future<CallSupportInfoEntity> getCallSupportInfo();
  Future<void> initiateSupportCall();

  Future<void> submitEmailSupport({
    required String subject,
    required String category,
    required String message,
    String? attachmentPath,
  });
}
