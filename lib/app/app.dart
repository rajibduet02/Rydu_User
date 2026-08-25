import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/push/presentation/passenger_push_controller.dart';
import '../features/push/presentation/ride_push_actions.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_mode_provider.dart';

final appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class RyduUserApp extends ConsumerWidget {
  const RyduUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeState = ref.watch(appThemeModeProvider);
    ref.watch(passengerPushControllerProvider);

    ref.listen<String?>(pushUserMessageProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(next)),
        );
        ref.read(pushUserMessageProvider.notifier).state = null;
      });
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      routerConfig: router,
      themeMode: themeState.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
