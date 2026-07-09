import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder for analytics / onboarding help preference until backend exists.
class WelcomeInteraction {
  Future<void> recordChoice({required bool wantsHelp}) async {
    // TODO: POST user onboarding preference when API is ready.
  }
}

final welcomeInteractionProvider = Provider<WelcomeInteraction>((ref) {
  return WelcomeInteraction();
});
