import '../../domain/entities/security_data_entity.dart';

class SecurityDataModel extends SecurityDataEntity {
  const SecurityDataModel({
    required super.securityStatus,
    required super.hasThreats,
  });

  SecurityDataEntity toEntity() => this;
}
