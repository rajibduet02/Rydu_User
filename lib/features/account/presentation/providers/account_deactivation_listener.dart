import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../auth/presentation/providers/auth_dependencies.dart';
import '../../domain/passenger_profile_error_codes.dart';
import 'account_controller.dart';
import 'passenger_profile_controller.dart';

void listenForAccountDeactivation(WidgetRef ref) {
  ref.listen<PassengerProfileState>(passengerProfileControllerProvider, (
    previous,
    next,
  ) {
    if (next.isAccountDeactivated && previous?.isAccountDeactivated != true) {
      Future<void>(() async {
        await ref.read(accountControllerProvider.notifier).logout();
        ref.read(authFlashMessageProvider.notifier).state =
            PassengerProfileErrorCodes.deactivatedMessage;
        ref.read(goRouterProvider).go(RouteNames.auth);
      });
    }
  });
}
