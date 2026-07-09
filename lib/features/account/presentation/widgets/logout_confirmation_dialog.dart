import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../providers/account_controller.dart';
import '../theme/account_screen_tokens.dart';

/// Centered logout confirmation with blurred dimmed backdrop (Figma + React).
Future<void> showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) {
  ref.read(accountControllerProvider.notifier).clearError();
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (dialogContext) => const LogoutConfirmationDialog(),
  );
}

class LogoutConfirmationDialog extends ConsumerStatefulWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  ConsumerState<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState
    extends ConsumerState<LogoutConfirmationDialog> {
  bool _submitting = false;

  Future<void> _onConfirmLogout() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final c = ref.read(accountControllerProvider.notifier);
    await c.logout();
    if (!mounted) return;
    setState(() => _submitting = false);
    final s = ref.read(accountControllerProvider);
    if (s.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.errorMessage!),
          backgroundColor: AccountScreenTokens.card,
        ),
      );
      return;
    }
    Navigator.of(context).pop();
    ref.read(goRouterProvider).go(RouteNames.auth);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hMargin = (w * 0.06).clamp(20.0, 28.0);
    final pad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.05).clamp(18.0, 20.0);
    final bodySize = (w * 0.038).clamp(14.0, 15.0);
    final btnHeight = (w * 0.12).clamp(48.0, 52.0);
    final radius = (w * 0.06).clamp(22.0, 24.0);
    final btnRadius = (w * 0.075).clamp(26.0, 30.0);
    final gap = (w * 0.03).clamp(10.0, 12.0);
    final busy = _submitting;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: busy ? null : () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hMargin),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AccountScreenTokens.card,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: AccountScreenTokens.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Confirm Logout',
                        style: TextStyle(
                          color: AccountScreenTokens.white,
                          fontWeight: FontWeight.w800,
                          fontSize: titleSize,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: (w * 0.025).clamp(8.0, 12.0)),
                      Text(
                        'Are you sure you want to log out of your account?',
                        style: TextStyle(
                          color: AccountScreenTokens.muted,
                          fontSize: bodySize,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: btnHeight,
                              child: Material(
                                color: AccountScreenTokens.iconWell,
                                borderRadius: BorderRadius.circular(btnRadius),
                                child: InkWell(
                                  onTap: busy
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(
                                    btnRadius,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AccountScreenTokens.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: (w * 0.038).clamp(14.0, 16.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: SizedBox(
                              height: btnHeight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    btnRadius,
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AccountScreenTokens.accent,
                                      AccountScreenTokens.accentSoft,
                                    ],
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    btnRadius,
                                  ),
                                  child: InkWell(
                                    onTap: busy ? null : _onConfirmLogout,
                                    borderRadius: BorderRadius.circular(
                                      btnRadius,
                                    ),
                                    child: Center(
                                      child: busy
                                          ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color:
                                                    AccountScreenTokens.white,
                                              ),
                                            )
                                          : Text(
                                              'Logout',
                                              style: TextStyle(
                                                color:
                                                    AccountScreenTokens.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: (w * 0.038).clamp(
                                                  14.0,
                                                  16.0,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
