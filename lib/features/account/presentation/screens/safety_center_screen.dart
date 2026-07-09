import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/safety_center_provider.dart';
import '../theme/safety_center_tokens.dart';
import '../widgets/safety_action_card.dart';
import '../widgets/safety_setup_card.dart';
import '../widgets/safety_tips_card.dart';

class SafetyCenterScreen extends ConsumerStatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  ConsumerState<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends ConsumerState<SafetyCenterScreen> {
  static const _tips = [
    "Always verify the driver's name, photo, and vehicle before getting in",
    'Share your trip details with friends or family',
    'Sit in the back seat and wear your seatbelt',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(safetyCenterControllerProvider.notifier).loadSafetyData();
    });
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  String _emergencyContactsSubtitle(int count) {
    if (count == 0) return 'No contacts yet';
    if (count == 1) return '1 contact added';
    return '$count contacts added';
  }

  String _trustedSubtitle(int count) {
    if (count > 0) {
      return count == 1 ? '1 trusted contact' : '$count trusted contacts';
    }
    return 'Add contacts who can track you';
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(safetyCenterControllerProvider);
    final c = ref.read(safetyCenterControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.075).clamp(26.0, 30.0);
    final subSize = (w * 0.038).clamp(14.0, 15.0);
    final backBtn = (w * 0.1).clamp(40.0, 44.0);
    final gap = (w * 0.035).clamp(14.0, 16.0);

    ref.listen(safetyCenterControllerProvider, (prev, next) {
      final msg = next.snackMessage;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        c.clearSnack();
      }
    });

    return Scaffold(
      backgroundColor: SafetyCenterTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        color: SafetyCenterTokens.iconWell,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _goBack(context),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SafetyCenterTokens.border,
                              ),
                            ),
                            child: SizedBox(
                              width: backBtn,
                              height: backBtn,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: SafetyCenterTokens.white,
                                size: backBtn * 0.55,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: (w * 0.03).clamp(12.0, 16.0)),
                      Expanded(
                        child: Text(
                          'Safety Center',
                          style: TextStyle(
                            color: SafetyCenterTokens.white,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: (w * 0.03).clamp(10.0, 14.0)),
                  Text(
                    'Your safety is our priority',
                    style: TextStyle(
                      color: SafetyCenterTokens.muted,
                      fontSize: subSize,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: SafetyCenterTokens.border,
            ),
            if (s.isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: SafetyCenterTokens.border,
                color: SafetyCenterTokens.accent,
              ),
            if (s.errorMessage != null)
              Material(
                color: SafetyCenterTokens.cardTop,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: c.clearError,
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  (w * 0.04).clamp(16.0, 20.0),
                  hPad,
                  (w * 0.08).clamp(28.0, 36.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SafetySetupCard(
                      configuredCount: s.configuredFeaturesCount,
                      totalCount: s.totalFeaturesCount,
                      progress: s.setupProgress,
                    ),
                    SizedBox(height: gap + 2),
                    SafetyActionCard(
                      title: 'Emergency SOS',
                      subtitle: 'Quick access to emergency services',
                      icon: Icons.error_outline_rounded,
                      iconColor: SafetyCenterTokens.sosRed,
                      actionLabel: 'Configure',
                      onAction: c.configureEmergencySos,
                    ),
                    SizedBox(height: gap),
                    SafetyActionCard(
                      title: 'Share Your Trip',
                      subtitle: s.isTripSharingEnabled
                          ? 'Trip sharing is enabled'
                          : 'Let friends & family track your ride',
                      icon: Icons.share_outlined,
                      iconColor: SafetyCenterTokens.accentDeep,
                      actionLabel: 'Enable',
                      onAction: c.enableTripSharing,
                    ),
                    SizedBox(height: gap),
                    SafetyActionCard(
                      title: 'Emergency Contacts',
                      subtitle: _emergencyContactsSubtitle(
                        s.emergencyContactsCount,
                      ),
                      icon: Icons.phone_in_talk_outlined,
                      iconColor: SafetyCenterTokens.phoneOrange,
                      actionLabel: 'Manage',
                      showConfiguredBadge: s.emergencyContactsCount > 0,
                      onAction: c.manageEmergencyContacts,
                    ),
                    SizedBox(height: gap),
                    SafetyActionCard(
                      title: 'Trusted Contacts',
                      subtitle: _trustedSubtitle(s.trustedContactsCount),
                      icon: Icons.groups_outlined,
                      iconColor: SafetyCenterTokens.trustedGreen,
                      actionLabel: 'Add Contacts',
                      onAction: c.addTrustedContacts,
                    ),
                    SizedBox(height: gap),
                    SafetyActionCard(
                      title: 'Ride Check',
                      subtitle: 'Get help if your trip goes off course',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: SafetyCenterTokens.ridePurple,
                      actionLabel: 'Learn More',
                      onAction: c.openRideCheck,
                    ),
                    SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                    const SafetyTipsCard(tips: _tips),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
