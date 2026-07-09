import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/privacy_and_data_provider.dart';
import '../theme/privacy_and_data_tokens.dart';
import '../widgets/privacy_large_card.dart';
import '../widgets/privacy_option_tile.dart';

class PrivacyAndDataScreen extends ConsumerWidget {
  const PrivacyAndDataScreen({super.key});

  void _popOrProfileDetails(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.profileDetails);
    }
  }

  Future<void> _onDownloadData(BuildContext context, WidgetRef ref) async {
    final c = ref.read(privacyAndDataControllerProvider.notifier);
    await c.requestDownloadData();
    if (!context.mounted) return;

    final state = ref.read(privacyAndDataControllerProvider);
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      return;
    }
    if (state.hasRequestedDataDownload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data archive request submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(privacyAndDataControllerProvider);
    final c = ref.read(privacyAndDataControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);
    final titleSize = (w * 0.07).clamp(26.0, 30.0);
    final sectionSize = (w * 0.042).clamp(15.0, 17.0);
    final headerTitleSize = (w * 0.042).clamp(15.0, 17.0);
    final cardRadius = (w * 0.04).clamp(14.0, 16.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _popOrProfileDetails(context);
      },
      child: Scaffold(
        backgroundColor: PrivacyAndDataTokens.background,
        body: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        hPad - 8,
                        (w * 0.02).clamp(8.0, 12.0),
                        hPad,
                        0,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _popOrProfileDetails(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: PrivacyAndDataTokens.white,
                              size: (w * 0.05).clamp(20.0, 22.0),
                            ),
                          ),
                          Text(
                            'Privacy & Data',
                            style: TextStyle(
                              color: PrivacyAndDataTokens.white,
                              fontWeight: FontWeight.w700,
                              fontSize: headerTitleSize,
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
                        (w * 0.04).clamp(14.0, 18.0),
                        hPad,
                        0,
                      ),
                      child: Text(
                        'Privacy & Data',
                        style: TextStyle(
                          color: PrivacyAndDataTokens.white,
                          fontWeight: FontWeight.w800,
                          fontSize: titleSize,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        (w * 0.045).clamp(16.0, 20.0),
                        hPad,
                        (w * 0.03).clamp(10.0, 12.0),
                      ),
                      child: Text(
                        'Privacy',
                        style: TextStyle(
                          color: PrivacyAndDataTokens.white,
                          fontWeight: FontWeight.w700,
                          fontSize: sectionSize,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: PrivacyAndDataTokens.card,
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(
                            color: PrivacyAndDataTokens.border,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(cardRadius),
                          child: Column(
                            children: [
                              PrivacyOptionTile(
                                title: 'Privacy Center',
                                subtitle:
                                    'Take control of your privacy and learn how we protect it.',
                                onTap: c.openPrivacyCenter,
                              ),
                              PrivacyOptionTile(
                                title: 'Communication Preferences',
                                subtitle: 'Manage how Velocity contacts you.',
                                showDivider: false,
                                onTap: c.openCommunicationPreferences,
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
                      child: PrivacyLargeCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Safety Checkup',
                        subtitle:
                            'Review your account security and activity logs.',
                        onTap: c.openSafetyCheckup,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: PrivacyLargeCard(
                        icon: Icons.download_outlined,
                        title: 'Download Data',
                        subtitle:
                            'Request a copy of your personal data archive.',
                        onTap: state.isLoading
                            ? () {}
                            : () => _onDownloadData(context, ref),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: (w * 0.08).clamp(28.0, 36.0)),
                  ),
                ],
              ),
              if (state.isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: PrivacyAndDataTokens.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
