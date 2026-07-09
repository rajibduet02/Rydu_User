import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/help_center_provider.dart';
import '../theme/help_center_tokens.dart';
import '../widgets/help_center_option_tile.dart';
import '../widgets/immediate_help_card.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(helpCenterControllerProvider.notifier).reset();
    });
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.075).clamp(26.0, 30.0);
    final subSize = (w * 0.038).clamp(14.0, 15.0);
    final backBtn = (w * 0.1).clamp(40.0, 44.0);
    final c = ref.read(helpCenterControllerProvider.notifier);

    ref.listen(helpCenterControllerProvider, (prev, next) {
      final msg = next.snackMessage;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        c.clearSnack();
      }
    });

    return Scaffold(
      backgroundColor: HelpCenterTokens.background,
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
                        color: HelpCenterTokens.iconWell,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _goBack(context),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: HelpCenterTokens.border,
                              ),
                            ),
                            child: SizedBox(
                              width: backBtn,
                              height: backBtn,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: HelpCenterTokens.white,
                                size: backBtn * 0.55,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: (w * 0.03).clamp(12.0, 16.0)),
                      Expanded(
                        child: Text(
                          'Help Center',
                          style: TextStyle(
                            color: HelpCenterTokens.white,
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
                    'How can we help you today?',
                    style: TextStyle(
                      color: HelpCenterTokens.muted,
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
              color: HelpCenterTokens.border,
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
                    HelpCenterOptionTile(
                      title: 'Live Chat Support',
                      subtitle: 'Chat with our support team',
                      accentColor: HelpCenterTokens.liveChat,
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: c.startLiveChat,
                    ),
                    SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                    HelpCenterOptionTile(
                      title: 'Call Support',
                      subtitle: 'Speak with a representative',
                      accentColor: HelpCenterTokens.call,
                      icon: Icons.phone_outlined,
                      onTap: c.callSupport,
                    ),
                    SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                    HelpCenterOptionTile(
                      title: 'Email Support',
                      subtitle: 'Send us an email',
                      accentColor: HelpCenterTokens.email,
                      icon: Icons.mail_outline_rounded,
                      onTap: c.emailSupport,
                    ),
                    SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                    HelpCenterOptionTile(
                      title: 'FAQs',
                      subtitle: 'Common questions answered',
                      accentColor: HelpCenterTokens.faq,
                      icon: Icons.help_outline_rounded,
                      onTap: c.openFaqs,
                    ),
                    SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                    HelpCenterOptionTile(
                      title: 'Ride Issues',
                      subtitle: 'Report problems with a trip',
                      accentColor: HelpCenterTokens.rideIssue,
                      icon: Icons.error_outline_rounded,
                      onTap: c.reportRideIssue,
                    ),
                    SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                    HelpCenterOptionTile(
                      title: 'Lost Items',
                      subtitle: 'Report lost belongings',
                      accentColor: HelpCenterTokens.lostItem,
                      icon: Icons.inventory_2_outlined,
                      onTap: c.reportLostItem,
                    ),
                    SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                    HelpCenterOptionTile(
                      title: 'Safety Resources',
                      subtitle: 'Emergency and safety guides',
                      accentColor: HelpCenterTokens.safety,
                      icon: Icons.description_outlined,
                      onTap: c.openSafetyResources,
                    ),
                    SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                    ImmediateHelpCard(
                      onStartLiveChat: c.startLiveChat,
                      onCallNow: c.callSupport,
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
