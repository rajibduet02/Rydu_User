import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/profile_details_provider.dart';
import '../theme/profile_details_tokens.dart';
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
      ref.read(profileDetailsControllerProvider.notifier).loadProfile();
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
    final state = ref.watch(profileDetailsControllerProvider);
    final c = ref.read(profileDetailsControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);
    final cardRadius = (w * 0.045).clamp(16.0, 18.0);

    return Scaffold(
      backgroundColor: ProfileDetailsTokens.background,
      body: SafeArea(
        child: state.isLoading && state.userName.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: ProfileDetailsTokens.accent,
                ),
              )
            : CustomScrollView(
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
                    child: _ProfileHero(
                      userName: state.userName,
                      rating: state.rating,
                      membershipName: state.membershipName,
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
                            isSelected:
                                state.selectedTab == kProfileTabPersonal,
                            onTap: () => c.selectTab(kProfileTabPersonal),
                          ),
                          SizedBox(width: (w * 0.025).clamp(8.0, 10.0)),
                          ProfileTabButton(
                            label: 'Security',
                            icon: Icons.verified_user_outlined,
                            isSelected: false,
                            onTap: () => c.selectTab(kProfileTabSecurity),
                          ),
                          SizedBox(width: (w * 0.025).clamp(8.0, 10.0)),
                          ProfileTabButton(
                            label: 'Privacy',
                            icon: Icons.shield_outlined,
                            isSelected: false,
                            onTap: () => c.selectTab(kProfileTabPrivacy),
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
                                value: state.userName,
                                onTap: c.openNameEdit,
                              ),
                              ProfileInfoTile(
                                label: 'Phone number',
                                value: state.phoneNumber,
                                showVerified: state.isPhoneVerified,
                                onTap: c.openPhoneEdit,
                              ),
                              ProfileInfoTile(
                                label: 'Email',
                                value: state.email,
                                showDivider: false,
                                onTap: c.openEmailEdit,
                              ),
                            ],
                          ),
                        ),
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
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.userName,
    required this.rating,
    required this.membershipName,
  });

  final String userName;
  final String rating;
  final String membershipName;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final avatarSize = (w * 0.34).clamp(120.0, 140.0);
    final nameSize = (w * 0.055).clamp(20.0, 24.0);

    return Column(
      children: [
        SizedBox(
          width: avatarSize + 24,
          height: avatarSize + 12,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ProfileDetailsTokens.iconWell,
                  border: Border.all(
                    color: ProfileDetailsTokens.border,
                    width: 2,
                  ),
                ),
                // TODO: Show network profile photo when user profile API is ready.
                child: Icon(
                  Icons.person_rounded,
                  size: avatarSize * 0.45,
                  color: ProfileDetailsTokens.muted,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (w * 0.025).clamp(8.0, 10.0),
                    vertical: (w * 0.012).clamp(4.0, 5.0),
                  ),
                  decoration: BoxDecoration(
                    color: ProfileDetailsTokens.gold,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: (w * 0.035).clamp(13.0, 15.0),
                        color: Colors.black,
                      ),
                      SizedBox(width: (w * 0.01).clamp(3.0, 4.0)),
                      Text(
                        rating,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: (w * 0.03).clamp(11.0, 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ProfileDetailsTokens.white,
            fontWeight: FontWeight.w700,
            fontSize: nameSize,
          ),
        ),
        SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.04).clamp(14.0, 16.0),
            vertical: (w * 0.018).clamp(6.0, 8.0),
          ),
          decoration: BoxDecoration(
            color: ProfileDetailsTokens.tabWell,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ProfileDetailsTokens.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: (w * 0.04).clamp(14.0, 16.0),
                color: ProfileDetailsTokens.gold,
              ),
              SizedBox(width: (w * 0.02).clamp(6.0, 8.0)),
              Text(
                membershipName,
                style: TextStyle(
                  color: ProfileDetailsTokens.white,
                  fontWeight: FontWeight.w600,
                  fontSize: (w * 0.028).clamp(10.0, 11.0),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
