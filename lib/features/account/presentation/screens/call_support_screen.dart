import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/call_support_provider.dart';
import '../theme/call_support_tokens.dart';
import '../widgets/support_action_button.dart';
import '../widgets/support_info_card.dart';

class CallSupportScreen extends ConsumerWidget {
  const CallSupportScreen({super.key});

  void _popOrHelpCenter(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.helpCenter);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(callSupportControllerProvider);
    final c = ref.read(callSupportControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.048).clamp(17.0, 19.0);
    final heroSize = (w * 0.38).clamp(140.0, 160.0);
    final headingSize = (w * 0.055).clamp(20.0, 22.0);
    final phoneSize = (w * 0.075).clamp(28.0, 32.0);
    final gap = (w * 0.035).clamp(14.0, 16.0);

    ref.listen(callSupportControllerProvider, (prev, next) {
      final snack = next.snackMessage;
      if (snack != null && snack.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snack),
            backgroundColor: CallSupportTokens.card,
          ),
        );
        c.clearSnack();
      }
    });

    return Scaffold(
      backgroundColor: CallSupportTokens.background,
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
                      color: CallSupportTokens.accentSolid,
                      size: (w * 0.05).clamp(20.0, 22.0),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Live Chat Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CallSupportTokens.white,
                        fontWeight: FontWeight.w800,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.12).clamp(44.0, 48.0)),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: (w * 0.04).clamp(12.0, 20.0)),
                    SizedBox(
                      width: heroSize,
                      height: heroSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: heroSize,
                            height: heroSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CallSupportTokens.border,
                                width: 2,
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: -0.35,
                            child: Icon(
                              Icons.phone_in_talk_rounded,
                              color: CallSupportTokens.accentSolid,
                              size: heroSize * 0.32,
                            ),
                          ),
                          if (s.isAvailable)
                            Positioned(
                              right: heroSize * 0.14,
                              bottom: heroSize * 0.14,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CallSupportTokens.online,
                                  border: Border.all(
                                    color: CallSupportTokens.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap + 4),
                    Text(
                      'Speak with our support team',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CallSupportTokens.white,
                        fontWeight: FontWeight.w800,
                        fontSize: headingSize,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: (w * 0.025).clamp(10.0, 12.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (s.isAvailable) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: CallSupportTokens.online,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          s.isAvailable ? 'AVAILABLE NOW' : 'UNAVAILABLE',
                          style: TextStyle(
                            color: s.isAvailable
                                ? CallSupportTokens.online
                                : CallSupportTokens.muted,
                            fontSize: (w * 0.03).clamp(11.0, 12.0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (w * 0.08).clamp(28.0, 36.0)),
                    Text(
                      'DIRECT LINE',
                      style: TextStyle(
                        color: CallSupportTokens.muted,
                        fontSize: (w * 0.03).clamp(11.0, 12.0),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
                    Text(
                      s.supportPhoneNumber,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CallSupportTokens.white,
                        fontWeight: FontWeight.w800,
                        fontSize: phoneSize,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                    SupportActionButton(
                      label: 'Call Now',
                      icon: Icons.wifi_calling_3_rounded,
                      isLoading: s.isCalling,
                      onPressed: c.callNow,
                    ),
                    SizedBox(height: gap),
                    SupportActionButton(
                      label: 'Request a Callback',
                      variant: SupportActionButtonVariant.secondary,
                      onPressed: c.requestCallback,
                    ),
                    SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                    SupportInfoCard(
                      title: '24/7 Support Available',
                      description:
                          'Our dedicated team of professionals is standing by to assist you at any hour, day or night.',
                      icon: Icons.schedule_rounded,
                    ),
                    SizedBox(height: gap),
                    SupportInfoCard(
                      title: 'Emergency Protocol',
                      description:
                          'For urgent safety issues, please contact local emergency services first before reaching out to support.',
                      icon: Icons.emergency_outlined,
                      variant: SupportInfoCardVariant.emergency,
                    ),
                    SizedBox(height: gap),
                    SupportInfoCard(
                      title: 'End-to-end encrypted support',
                      description: '',
                      variant: SupportInfoCardVariant.secureLine,
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
