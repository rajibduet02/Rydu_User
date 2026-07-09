import '../repositories/reserve_repository.dart';

class StartReserveRideUsecase {
  const StartReserveRideUsecase(this._repository);

  final ReserveRepository _repository;

  bool call() => _repository.canStartReserveRide();
}
