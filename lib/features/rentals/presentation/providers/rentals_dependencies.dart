import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/rentals_local_datasource.dart';
import '../../data/repositories/rentals_repository_impl.dart';
import '../../domain/repositories/rentals_repository.dart';
import '../../domain/usecases/get_default_promotion_amount_usecase.dart';
import '../../domain/usecases/get_rental_pricing_usecase.dart';
import '../../domain/usecases/get_rental_time_config_usecase.dart';
import '../../domain/usecases/get_rental_vehicles_usecase.dart';

final rentalsLocalDatasourceProvider = Provider<RentalsLocalDatasource>((ref) {
  return RentalsLocalDatasourceImpl();
});

final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return RentalsRepositoryImpl(ref.watch(rentalsLocalDatasourceProvider));
});

final getRentalPricingUsecaseProvider = Provider<GetRentalPricingUsecase>((
  ref,
) {
  return GetRentalPricingUsecase(ref.watch(rentalsRepositoryProvider));
});

final getRentalVehiclesUsecaseProvider = Provider<GetRentalVehiclesUsecase>((
  ref,
) {
  return GetRentalVehiclesUsecase(ref.watch(rentalsRepositoryProvider));
});

final getRentalTimeConfigUsecaseProvider = Provider<GetRentalTimeConfigUsecase>(
  (ref) {
    return GetRentalTimeConfigUsecase(ref.watch(rentalsRepositoryProvider));
  },
);

final getDefaultPromotionAmountUsecaseProvider =
    Provider<GetDefaultPromotionAmountUsecase>((ref) {
      return GetDefaultPromotionAmountUsecase(
        ref.watch(rentalsRepositoryProvider),
      );
    });
