import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/shell_scroll_padding.dart';
import '../providers/account_controller.dart';
import '../providers/account_deactivation_listener.dart';
import '../providers/passenger_profile_controller.dart';
import '../theme/account_screen_tokens.dart';
import '../widgets/account_feature_card.dart';
import '../widgets/account_header.dart';
import '../widgets/deactivate_account_dialog.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/account_menu_tile.dart';
import '../widgets/account_quick_action_card.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(passengerProfileControllerProvider.notifier).loadIfNeeded();
    });
  }

  void _onLogoutPressed() {
    showLogoutConfirmationDialog(context, ref);
  }

  void _onDeactivatePressed() {
    showDeactivateAccountDialog(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    listenForAccountDeactivation(ref);
    final s = ref.watch(accountControllerProvider);
    final profileState = ref.watch(passengerProfileControllerProvider);
    final c = ref.read(accountControllerProvider.notifier);
    final profileController = ref.read(
      passengerProfileControllerProvider.notifier,
    );
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final gap = (w * 0.04).clamp(14.0, 18.0);
    final scrollBottomPadding = ShellScrollPadding.accountTabScrollBottom(
      context,
    );
    final profileError = profileState.errorMessage;
    final showInitialLoading =
        profileState.isLoading && profileState.profile == null;
    final showInitialError =
        profileState.profile == null &&
        profileError != null &&
        !profileState.isLoading;

    return SafeArea(
      bottom: false,
      child: AbsorbPointer(
        absorbing: s.isLoading,
        child: RefreshIndicator(
          color: AccountScreenTokens.accent,
          backgroundColor: AccountScreenTokens.card,
          onRefresh: () => profileController.refresh(),
          child: showInitialLoading
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 160),
                    Center(
                      child: CircularProgressIndicator(
                        color: AccountScreenTokens.accent,
                      ),
                    ),
                  ],
                )
              : showInitialError
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    48,
                    hPad,
                    scrollBottomPadding,
                  ),
                  children: [
                    Text(
                      profileError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => profileController.refresh(initial: true),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    16,
                    hPad,
                    scrollBottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccountHeader(
                        profile: profileState.profile,
                        isUploadingAvatar: profileState.isUploadingAvatar,
                        onAvatarTap: c.openProfileDetails,
                        onEditProfile: c.openEditProfile,
                      ),
                      if (profileError != null && profileState.profile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            profileError,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      if (s.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            s.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                      Row(
                        children: [
                          Expanded(
                            child: AccountQuickActionCard(
                              icon: Icons.help_outline_rounded,
                              label: 'Help',
                              onTap: c.openHelp,
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: AccountQuickActionCard(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Wallet',
                              onTap: c.openWallet,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          Expanded(
                            child: AccountQuickActionCard(
                              icon: Icons.shield_outlined,
                              label: 'Safety',
                              onTap: c.openSafety,
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: AccountQuickActionCard(
                              icon: Icons.mail_outline_rounded,
                              label: 'Inbox',
                              onTap: c.openInbox,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (w * 0.05).clamp(18.0, 22.0)),
                      AccountFeatureCard(
                        leadingIcon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        subtitle: 'Update your name, phone, and photo',
                        linkLabel: 'Edit',
                        trailingEmoji: '✏️',
                        onTap: c.openEditProfile,
                      ),
                      SizedBox(height: gap),
                      AccountFeatureCard(
                        leadingIcon: Icons.history_rounded,
                        title: 'Ride History',
                        subtitle:
                            'View past trips, receipts, and download invoices',
                        linkLabel: 'View rides',
                        trailingEmoji: '📋',
                        onTap: c.openRideHistory,
                      ),
                      SizedBox(height: gap),
                      AccountFeatureCard(
                        leadingIcon: Icons.location_on_outlined,
                        title: 'Saved Places',
                        subtitle:
                            'Quick access to Home, Work, and favorite destinations',
                        linkLabel: 'Manage places',
                        trailingEmoji: '📍',
                        onTap: c.openSavedPlaces,
                      ),
                      SizedBox(height: gap),
                      AccountFeatureCard(
                        leadingIcon: Icons.business_center_outlined,
                        title: 'Business Travel',
                        subtitle:
                            'Company rides, expense reports, and travel management',
                        linkLabel: 'Manage Business',
                        trailingEmoji: '💼',
                        onTap: c.openBusinessTravel,
                      ),
                      SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                      const Divider(
                        color: AccountScreenTokens.border,
                        height: 1,
                      ),
                      AccountMenuTile(
                        icon: Icons.groups_outlined,
                        title: 'Family',
                        subtitle: 'Manage family accounts and shared rides',
                        onTap: c.openFamily,
                      ),
                      const Divider(
                        color: AccountScreenTokens.border,
                        height: 1,
                      ),
                      AccountMenuTile(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'Privacy, notifications, and preferences',
                        onTap: c.openSettings,
                      ),
                      const Divider(
                        color: AccountScreenTokens.border,
                        height: 1,
                      ),
                      AccountMenuTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        isLogout: true,
                        onTap: _onLogoutPressed,
                      ),
                      const Divider(
                        color: AccountScreenTokens.border,
                        height: 1,
                      ),
                      AccountMenuTile(
                        icon: Icons.person_off_outlined,
                        title: 'Deactivate Account',
                        subtitle:
                            'Deactivate this passenger account. History is retained.',
                        isLogout: true,
                        onTap: _onDeactivatePressed,
                      ),
                      SizedBox(height: (w * 0.12).clamp(40.0, 56.0)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
