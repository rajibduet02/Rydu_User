import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';

/// Legacy `/login` path — redirects to the main sign-in screen at `/auth`.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.go(RouteNames.auth);
    });
    return const Scaffold(
      backgroundColor: AppDarkSurfaces.scaffold,
      body: Center(
        child: CircularProgressIndicator(
          color: AppDarkText.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
