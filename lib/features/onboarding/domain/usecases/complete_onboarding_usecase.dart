import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUsecase {
  CompleteOnboardingUsecase(this._repository);

  final OnboardingRepository _repository;

  Future<void> call() => _repository.completeOnboarding();
}
