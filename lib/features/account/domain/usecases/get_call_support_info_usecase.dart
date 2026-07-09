import '../entities/call_support_info_entity.dart';
import '../repositories/support_repository.dart';

class GetCallSupportInfoUsecase {
  GetCallSupportInfoUsecase(this._repository);

  final SupportRepository _repository;

  Future<CallSupportInfoEntity> call() => _repository.getCallSupportInfo();
}
