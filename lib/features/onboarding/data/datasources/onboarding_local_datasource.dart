abstract interface class OnboardingLocalDatasource {
  Future<void> setCompleted(bool value);
}

class OnboardingLocalDatasourceImpl implements OnboardingLocalDatasource {
  OnboardingLocalDatasourceImpl();

  @override
  Future<void> setCompleted(bool value) async {}
}
