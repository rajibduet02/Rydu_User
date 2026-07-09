import '../../domain/entities/call_support_info_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/lost_item_trip_entity.dart';
import '../../domain/entities/ride_trip_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_local_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/lost_item_trip_model.dart';
import '../models/ride_trip_model.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl(this._local);

  final SupportLocalDatasource _local;

  @override
  Future<List<ChatMessageEntity>> getLiveChatMessages() async {
    final models = await _local.fetchLiveChatMessages();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> sendLiveChatMessage(ChatMessageEntity message) =>
      _local.sendLiveChatMessage(
        ChatMessageModel(
          id: message.id,
          senderType: message.senderType,
          senderName: message.senderName,
          message: message.message,
          time: message.time,
          attachmentPath: message.attachmentPath,
          isMine: message.isMine,
        ),
      );

  @override
  Future<List<RideTripEntity>> getRideIssueTrips() async {
    final models = await _local.fetchRideIssueTrips();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> submitRideIssue({
    required RideTripEntity trip,
    required String issueType,
    required String details,
    String? photoPath,
  }) => _local.submitRideIssue(
    trip: RideTripModel(
      id: trip.id,
      title: trip.title,
      subtitle: trip.subtitle,
      vehicleName: trip.vehicleName,
      fare: trip.fare,
      status: trip.status,
    ),
    issueType: issueType,
    details: details,
    photoPath: photoPath,
  );

  @override
  Future<List<LostItemTripEntity>> getLostItemTrips() async {
    final models = await _local.fetchLostItemTrips();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> submitLostItemReport({
    required LostItemTripEntity trip,
    required String itemDescription,
    required String lastSeenLocation,
    required String contactPreference,
  }) => _local.submitLostItemReport(
    trip: LostItemTripModel(
      id: trip.id,
      vehicleName: trip.vehicleName,
      dateTime: trip.dateTime,
      subtitle: trip.subtitle,
    ),
    itemDescription: itemDescription,
    lastSeenLocation: lastSeenLocation,
    contactPreference: contactPreference,
  );

  @override
  Future<CallSupportInfoEntity> getCallSupportInfo() async {
    final model = await _local.fetchCallSupportInfo();
    return model.toEntity();
  }

  @override
  Future<void> initiateSupportCall() => _local.initiateSupportCall();

  @override
  Future<void> submitEmailSupport({
    required String subject,
    required String category,
    required String message,
    String? attachmentPath,
  }) => _local.submitEmailSupport(
    subject: subject,
    category: category,
    message: message,
    attachmentPath: attachmentPath,
  );
}
