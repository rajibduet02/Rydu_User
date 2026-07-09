import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._local);

  final OnboardingLocalDatasource _local;

  @override
  Future<void> completeOnboarding() => _local.setCompleted(true);
}
