import '../repositories/splash_repository.dart';

class ResolveInitialRouteUsecase {
  ResolveInitialRouteUsecase(this._repository);

  final SplashRepository _repository;

  Future<String> call() async {
    final first = await _repository.isFirstLaunch();
    return first ? '/onboarding' : '/home';
  }
}
