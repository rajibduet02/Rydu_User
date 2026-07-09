import 'package:go_router/go_router.dart';

import '../../../features/payment/presentation/screens/add_card_screen.dart';
import '../../../features/payment/presentation/screens/payment_methods_screen.dart';
import '../route_names.dart';

/// Payment method routes.
List<RouteBase> get paymentRoutes => [
  GoRoute(
    path: RouteNames.paymentMethods,
    builder: (context, state) => const PaymentMethodsScreen(),
  ),
  GoRoute(
    path: RouteNames.addCard,
    builder: (context, state) => const AddCardScreen(),
  ),
];
