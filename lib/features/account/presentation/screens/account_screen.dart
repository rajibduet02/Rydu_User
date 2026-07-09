import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/shell_scroll_padding.dart';
import '../providers/account_controller.dart';
import '../theme/account_screen_tokens.dart';
import '../widgets/account_feature_card.dart';
import '../widgets/account_header.dart';
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
      ref.read(accountControllerProvider.notifier).resetForAccountTab();
      ref.read(accountControllerProvider.notifier).loadAccountData();
    });
  }

  void _onLogoutPressed() {
    showLogoutConfirmationDialog(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(accountControllerProvider);
    final c = ref.read(accountControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final gap = (w * 0.04).clamp(14.0, 18.0);
    final scrollBottomPadding = ShellScrollPadding.accountTabScrollBottom(
      context,
    );
    return SafeArea(
      bottom: false,
      child: AbsorbPointer(
        absorbing: s.isLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, scrollBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccountHeader(
                userName: s.userName,
                membershipName: s.membershipName,
                rating: s.rating,
                rideCount: s.rideCount,
                onAvatarTap: c.openEditProfile,
                onMembershipTap: c.openMembership,
                onRatingTap: c.openRideHistory,
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
                      subtitle: s.walletBalance,
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
                      showUnreadDot: s.hasUnreadInbox,
                      onTap: c.openInbox,
                    ),
                  ),
                ],
              ),
              SizedBox(height: (w * 0.05).clamp(18.0, 22.0)),
              if (s.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    s.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              AccountFeatureCard(
                leadingIcon: Icons.history_rounded,
                title: 'Ride History',
                subtitle: 'View past trips, receipts, and download invoices',
                linkLabel: 'View ${s.rideCount} rides',
                trailingEmoji: '📋',
                onTap: c.openRideHistory,
              ),
              SizedBox(height: gap),
              AccountFeatureCard(
                leadingIcon: Icons.location_on_outlined,
                title: 'Saved Places',
                subtitle:
                    'Quick access to Home, Work, and favorite destinations',
                linkLabel: 'Manage ${s.savedPlacesCount} places',
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
              const Divider(color: AccountScreenTokens.border, height: 1),
              AccountMenuTile(
                icon: Icons.groups_outlined,
                title: 'Family',
                subtitle: 'Manage family accounts and shared rides',
                onTap: c.openFamily,
              ),
              const Divider(color: AccountScreenTokens.border, height: 1),
              AccountMenuTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Privacy, notifications, and preferences',
                onTap: c.openSettings,
              ),
              const Divider(color: AccountScreenTokens.border, height: 1),
              AccountMenuTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isLogout: true,
                onTap: _onLogoutPressed,
              ),
              SizedBox(height: (w * 0.04).clamp(14.0, 18.0)),
              Text(
                s.appVersion,
                style: TextStyle(
                  color: AccountScreenTokens.muted.withValues(alpha: 0.7),
                  fontSize: (w * 0.028).clamp(11.0, 12.0),
                ),
              ),
              SizedBox(height: (w * 0.12).clamp(40.0, 56.0)),
            ],
          ),
        ),
      ),
    );
  }
}
