import '../../domain/entities/call_support_info_entity.dart';

class CallSupportInfoModel extends CallSupportInfoEntity {
  const CallSupportInfoModel({
    required super.supportPhoneNumber,
    required super.isAvailable,
  });

  CallSupportInfoEntity toEntity() => this;
}
