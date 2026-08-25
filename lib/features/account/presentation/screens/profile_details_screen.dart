import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/account_deactivation_listener.dart';
import '../providers/passenger_profile_controller.dart';
import '../theme/profile_details_tokens.dart';
import '../widgets/passenger_avatar.dart';
import '../widgets/profile_avatar_actions.dart';
import '../widgets/profile_details_header.dart';
import '../widgets/profile_info_tile.dart';
import '../widgets/profile_tab_button.dart';

class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(passengerProfileControllerProvider.notifier).loadIfNeeded();
    });
  }

  void _popOrAccount(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    listenForAccountDeactivation(ref);
    final state = ref.watch(passengerProfileControllerProvider);
    final c = ref.read(passengerProfileControllerProvider.notifier);
    final profile = state.profile;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);
    final cardRadius = (w * 0.045).clamp(16.0, 18.0);
    final showInitialLoading = state.isLoading && profile == null;
    final showInitialError =
        profile == null && state.errorMessage != null && !state.isLoading;

    return Scaffold(
      backgroundColor: ProfileDetailsTokens.background,
      body: SafeArea(
        child: showInitialLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: ProfileDetailsTokens.accent,
                ),
              )
            : showInitialError
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(hPad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => c.refresh(initial: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                color: ProfileDetailsTokens.accent,
                backgroundColor: ProfileDetailsTokens.card,
                onRefresh: () => c.refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          hPad - 8,
                          (w * 0.02).clamp(8.0, 12.0),
                          hPad,
                          0,
                        ),
                        child: ProfileDetailsHeader(
                          onBack: () => _popOrAccount(context),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.05).clamp(18.0, 24.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          PassengerAvatar(
                            profile: profile,
                            size: (w * 0.34).clamp(120.0, 140.0),
                            isUploading: state.isUploadingAvatar,
                            onTap: () => showProfileAvatarActions(
                              context: context,
                              ref: ref,
                              hasAvatar: profile?.hasAvatar ?? false,
                            ),
                          ),
                          SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
                          Text(
                            profile?.displayName ?? 'Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ProfileDetailsTokens.white,
                              fontWeight: FontWeight.w700,
                              fontSize: (w * 0.055).clamp(20.0, 24.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Row(
                          children: [
                            ProfileTabButton(
                              label: 'Personal Info',
                              icon: Icons.person_outline_rounded,
                              isSelected: true,
                              onTap: () {},
                            ),
                            SizedBox(width: (w * 0.025).clamp(8.0, 10.0)),
                            ProfileTabButton(
                              label: 'Security',
                              icon: Icons.verified_user_outlined,
                              isSelected: false,
                              onTap: () => context.push(RouteNames.security),
                            ),
                            SizedBox(width: (w * 0.025).clamp(8.0, 10.0)),
                            ProfileTabButton(
                              label: 'Privacy',
                              icon: Icons.shield_outlined,
                              isSelected: false,
                              onTap: () =>
                                  context.push(RouteNames.privacyAndData),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Personal info',
                            style: TextStyle(
                              color: ProfileDetailsTokens.white,
                              fontWeight: FontWeight.w600,
                              fontSize: (w * 0.042).clamp(15.0, 17.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: (w * 0.03).clamp(12.0, 14.0)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: ProfileDetailsTokens.card,
                            borderRadius: BorderRadius.circular(cardRadius),
                            border: Border.all(
                              color: ProfileDetailsTokens.border,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(cardRadius),
                            child: Column(
                              children: [
                                ProfileInfoTile(
                                  label: 'Name',
                                  value: profile?.name.trim().isNotEmpty == true
                                      ? profile!.name
                                      : 'Add name',
                                  onTap: () =>
                                      context.push(RouteNames.editProfile),
                                ),
                                ProfileInfoTile(
                                  label: 'Phone number',
                                  value:
                                      profile?.phone != null &&
                                          profile!.phone!.trim().isNotEmpty
                                      ? profile.phone!
                                      : 'Add phone',
                                  onTap: () =>
                                      context.push(RouteNames.editProfile),
                                ),
                                ProfileInfoTile(
                                  label: 'Email',
                                  value: profile?.email.trim().isNotEmpty == true
                                      ? profile!.email
                                      : '—',
                                  showDivider: false,
                                  readOnly: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (state.errorMessage != null && profile != null)
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
