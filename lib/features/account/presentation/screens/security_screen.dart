import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/security_provider.dart';
import '../theme/security_screen_tokens.dart';
import '../widgets/security_footer_card.dart';
import '../widgets/security_info_card.dart';
import '../widgets/security_option_tile.dart';
import '../widgets/security_status_card.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(securityControllerProvider.notifier).loadSecurityData();
    });
  }

  void _popOrProfileDetails(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.profileDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(securityControllerProvider);
    final c = ref.read(securityControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);
    final titleSize = (w * 0.07).clamp(26.0, 30.0);
    final subtitleSize = (w * 0.038).clamp(14.0, 15.0);
    final barTitleSize = (w * 0.042).clamp(15.0, 17.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _popOrProfileDetails(context);
      },
      child: Scaffold(
        backgroundColor: SecurityScreenTokens.background,
        body: SafeArea(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: SecurityScreenTokens.accent,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          hPad,
                          (w * 0.02).clamp(8.0, 12.0),
                          hPad,
                          0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: SecurityScreenTokens.white,
                              size: (w * 0.055).clamp(22.0, 24.0),
                            ),
                            SizedBox(width: (w * 0.025).clamp(8.0, 10.0)),
                            Text(
                              'Security',
                              style: TextStyle(
                                color: SecurityScreenTokens.white,
                                fontWeight: FontWeight.w600,
                                fontSize: barTitleSize,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: c.openNotifications,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: SecurityScreenTokens.white,
                                size: (w * 0.06).clamp(24.0, 26.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          hPad,
                          (w * 0.05).clamp(18.0, 22.0),
                          hPad,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Security',
                              style: TextStyle(
                                color: SecurityScreenTokens.white,
                                fontWeight: FontWeight.w800,
                                fontSize: titleSize,
                              ),
                            ),
                            SizedBox(height: (w * 0.015).clamp(6.0, 8.0)),
                            Text(
                              'Logging in to Velocity',
                              style: TextStyle(
                                color: SecurityScreenTokens.muted,
                                fontSize: subtitleSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.05).clamp(18.0, 22.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: const SecurityInfoCard(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: SecurityStatusCard(
                          status: state.securityStatus,
                          hasThreats: state.hasThreats,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: SecurityScreenTokens.card,
                            borderRadius: BorderRadius.circular(
                              (w * 0.04).clamp(14.0, 16.0),
                            ),
                            border: Border.all(
                              color: SecurityScreenTokens.border,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              (w * 0.04).clamp(14.0, 16.0),
                            ),
                            child: Column(
                              children: [
                                SecurityOptionTile(
                                  title: 'Password',
                                  onTap: c.openChangePassword,
                                ),
                                SecurityOptionTile(
                                  title: 'Authenticator app',
                                  subtitle:
                                      'Setup your authenticator app to add an extra layer of security.',
                                  onTap: c.openAuthenticatorApp,
                                ),
                                SecurityOptionTile(
                                  title: '2-step verification',
                                  subtitle:
                                      'Additional security to your account with 2-step verification.',
                                  onTap: c.openTwoStepVerification,
                                ),
                                SecurityOptionTile(
                                  title: 'Recovery phone',
                                  subtitle:
                                      'Add a backup phone number to access your account',
                                  showDivider: false,
                                  onTap: c.openRecoveryPhone,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: SecurityFooterCard(
                          onPrivacyPolicy: c.openPrivacyPolicy,
                        ),
                      ),
                    ),
                    if (state.errorMessage != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(hPad),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.08).clamp(28.0, 36.0)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
