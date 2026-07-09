import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/safety_resources_provider.dart';
import '../theme/safety_resources_tokens.dart';
import '../widgets/emergency_contact_tile.dart';
import '../widgets/safety_resource_card.dart';
import '../widgets/safety_tip_tile.dart';
import '../widgets/support_action_button.dart';

class SafetyResourcesScreen extends ConsumerWidget {
  const SafetyResourcesScreen({super.key});

  void _popOrHelpCenter(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.helpCenter);
    }
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.only(
        bottom: (w * 0.025).clamp(10.0, 12.0),
        top: (w * 0.02).clamp(6.0, 8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: SafetyResourcesTokens.label,
          fontSize: (w * 0.028).clamp(10.0, 11.0),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _ruleRow(BuildContext context, String text, {IconData? icon}) {
    final w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (w * 0.045).clamp(16.0, 18.0),
        vertical: (w * 0.035).clamp(12.0, 14.0),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle_rounded,
            color: icon == null
                ? SafetyResourcesTokens.checkGreen
                : SafetyResourcesTokens.accentSolid,
            size: (w * 0.05).clamp(20.0, 22.0),
          ),
          SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: SafetyResourcesTokens.white,
                fontWeight: FontWeight.w600,
                fontSize: (w * 0.04).clamp(15.0, 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(safetyResourcesControllerProvider);
    final c = ref.read(safetyResourcesControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.05).clamp(18.0, 20.0);
    final gap = (w * 0.04).clamp(14.0, 18.0);

    ref.listen(safetyResourcesControllerProvider, (prev, next) {
      final snack = next.snackMessage;
      if (snack != null && snack.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snack),
            backgroundColor: SafetyResourcesTokens.card,
          ),
        );
        c.clearSnack();
      }
    });

    return Scaffold(
      backgroundColor: SafetyResourcesTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4, 4, hPad, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _popOrHelpCenter(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: SafetyResourcesTokens.white,
                      size: (w * 0.05).clamp(20.0, 22.0),
                    ),
                  ),
                  Text(
                    'Safety Resources',
                    style: TextStyle(
                      color: SafetyResourcesTokens.white,
                      fontWeight: FontWeight.w800,
                      fontSize: titleSize,
                    ),
                  ),
                ],
              ),
            ),
            if (s.errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Text(
                  s.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SafetyResourceCard(
                      padding: EdgeInsets.all((w * 0.045).clamp(16.0, 18.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: (w * 0.11).clamp(42.0, 48.0),
                                height: (w * 0.11).clamp(42.0, 48.0),
                                decoration: BoxDecoration(
                                  color: SafetyResourcesTokens.emergencyIconBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.emergency_rounded,
                                  color: SafetyResourcesTokens.white,
                                  size: (w * 0.06).clamp(24.0, 26.0),
                                ),
                              ),
                              SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Need urgent help?',
                                      style: TextStyle(
                                        color: SafetyResourcesTokens.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: (w * 0.045).clamp(16.0, 18.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: (w * 0.015).clamp(6.0, 8.0),
                                    ),
                                    Text(
                                      'Contact local emergency services first if you are in immediate danger.',
                                      style: TextStyle(
                                        color: SafetyResourcesTokens.muted,
                                        fontSize: (w * 0.035).clamp(13.0, 14.0),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gap),
                          SizedBox(
                            width: double.infinity,
                            height: (w * 0.12).clamp(48.0, 52.0),
                            child: FilledButton(
                              onPressed: c.openSosGuide,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    SafetyResourcesTokens.emergencyRed,
                                foregroundColor: SafetyResourcesTokens.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    (w * 0.035).clamp(12.0, 14.0),
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'SOS Guide',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: (w * 0.04).clamp(15.0, 16.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _sectionLabel(context, 'EMERGENCY TIPS'),
                    SafetyResourceCard(
                      child: Column(
                        children: [
                          SafetyTipTile(
                            title: 'Share Live Location',
                            icon: Icons.location_on_outlined,
                            isExpanded:
                                s.expandedTip == kSafetyTipShareLocation,
                            onTap: () {
                              c.shareLiveLocation();
                              c.toggleEmergencyTip(kSafetyTipShareLocation);
                            },
                            expandedBody:
                                s.expandedTip == kSafetyTipShareLocation
                                ? 'Share your trip with trusted contacts so they can follow your ride in real time.'
                                : null,
                          ),
                          SafetyTipTile(
                            title: 'Lock Doors Manually',
                            icon: Icons.lock_outline_rounded,
                            isExpanded: s.expandedTip == kSafetyTipLockDoors,
                            onTap: () =>
                                c.toggleEmergencyTip(kSafetyTipLockDoors),
                            expandedBody: s.expandedTip == kSafetyTipLockDoors
                                ? 'Verify child locks and rear doors are secured before the vehicle departs.'
                                : null,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    _sectionLabel(context, 'PASSENGER RULES'),
                    SafetyResourceCard(
                      child: Column(
                        children: [
                          _ruleRow(context, 'Check License Plate'),
                          const Divider(
                            height: 1,
                            color: SafetyResourcesTokens.border,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _ruleRow(context, 'Verify Driver Identity'),
                          const Divider(
                            height: 1,
                            color: SafetyResourcesTokens.border,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _ruleRow(context, 'Share Trip Status'),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    _sectionLabel(context, 'DRIVER STANDARDS'),
                    SafetyResourceCard(
                      child: Column(
                        children: [
                          _ruleRow(
                            context,
                            'Background Checks',
                            icon: Icons.verified_user_outlined,
                          ),
                          const Divider(
                            height: 1,
                            color: SafetyResourcesTokens.border,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _ruleRow(
                            context,
                            'Vehicle Maintenance',
                            icon: Icons.build_outlined,
                          ),
                          const Divider(
                            height: 1,
                            color: SafetyResourcesTokens.border,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _ruleRow(
                            context,
                            'Driving Performance',
                            icon: Icons.speed_outlined,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    _sectionLabel(context, 'EMERGENCY CONTACTS'),
                    SafetyResourceCard(
                      child: Column(
                        children: [
                          EmergencyContactTile(
                            contact: s.emergencyContacts.first,
                            onCall: c.callPoliceDispatch,
                          ),
                          EmergencyContactTile(
                            contact: s.emergencyContacts.last,
                            onCall: c.callRoadsideAssistance,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap + 4),
                    SafetyResourceCard(
                      padding: EdgeInsets.all((w * 0.055).clamp(20.0, 24.0)),
                      child: Column(
                        children: [
                          Text(
                            'Still need help?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: SafetyResourcesTokens.white,
                              fontWeight: FontWeight.w800,
                              fontSize: (w * 0.05).clamp(18.0, 20.0),
                            ),
                          ),
                          SizedBox(height: (w * 0.025).clamp(10.0, 12.0)),
                          Text(
                            'Our Concierge Support team is available around the clock for any inquiries.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: SafetyResourcesTokens.muted,
                              fontSize: (w * 0.035).clamp(13.0, 14.0),
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: gap),
                          SupportActionButton(
                            label: 'Call Support',
                            icon: Icons.phone_in_talk_rounded,
                            onPressed: c.openCallSupport,
                          ),
                          SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
                          SupportActionButton(
                            label: 'Live Chat',
                            icon: Icons.chat_bubble_outline_rounded,
                            variant: SupportActionButtonVariant.secondary,
                            onPressed: c.openLiveChat,
                          ),
                        ],
                      ),
                    ),
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
