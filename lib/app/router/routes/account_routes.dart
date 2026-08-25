import 'package:go_router/go_router.dart';

import '../../../features/account/presentation/screens/account_hub_placeholder_screen.dart';
import '../../../features/account/presentation/screens/add_family_member_screen.dart';
import '../../../features/account/presentation/screens/add_parent_guardian_screen.dart';
import '../../../features/account/presentation/screens/add_saved_place_screen.dart';
import '../../../features/account/presentation/screens/call_support_screen.dart';
import '../../../features/account/presentation/screens/edit_saved_place_screen.dart';
import '../../../features/account/presentation/screens/email_support_screen.dart';
import '../../../features/account/presentation/screens/family_profile_screen.dart';
import '../../../features/account/presentation/screens/faqs_screen.dart';
import '../../../features/account/presentation/screens/help_center_screen.dart';
import '../../../features/account/presentation/screens/inbox_detail_screen.dart';
import '../../../features/account/presentation/screens/inbox_screen.dart';
import '../../../features/account/presentation/screens/invite_teen_screen.dart';
import '../../../features/account/presentation/screens/language_settings_screen.dart';
import '../../../features/account/presentation/screens/live_chat_support_screen.dart';
import '../../../features/account/presentation/screens/privacy_and_data_screen.dart';
import '../../../features/account/presentation/screens/privacy_settings_screen.dart';
import '../../../features/account/presentation/screens/profile_details_screen.dart';
import '../../../features/account/presentation/screens/edit_profile_screen.dart';
import '../../../features/account/presentation/screens/report_lost_item_screen.dart';
import '../../../features/account/presentation/screens/report_ride_issue_screen.dart';
import '../../../features/account/presentation/screens/request_callback_screen.dart';
import '../../../features/account/presentation/screens/safety_center_screen.dart';
import '../../../features/account/presentation/screens/safety_resources_screen.dart';
import '../../../features/account/presentation/screens/saved_place_detail_screen.dart';
import '../../../features/account/presentation/screens/saved_places_screen.dart';
import '../../../features/account/presentation/screens/security_screen.dart';
import '../../../features/account/presentation/screens/security_settings_screen.dart';
import '../../../features/account/presentation/screens/sos_guide_screen.dart';
import '../../../features/account/presentation/screens/support_flow_placeholder_screen.dart';
import '../../../features/account/presentation/screens/wallet_screen.dart';
import '../../../features/auth/presentation/screens/privacy_policy_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../route_names.dart';

/// Account hub routes: help/support, wallet, safety, inbox, saved places,
/// family, settings, privacy, and security.
List<RouteBase> get accountRoutes => [
  // Help & support
  GoRoute(
    path: RouteNames.help,
    redirect: (context, state) => RouteNames.helpCenter,
  ),
  GoRoute(
    path: RouteNames.helpCenter,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const HelpCenterScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.liveChat,
    builder: (context, state) => const LiveChatSupportScreen(),
  ),
  GoRoute(
    path: RouteNames.callSupport,
    builder: (context, state) => const CallSupportScreen(),
  ),
  GoRoute(
    path: RouteNames.requestCallback,
    builder: (context, state) => const RequestCallbackScreen(),
  ),
  GoRoute(
    path: RouteNames.emailSupport,
    builder: (context, state) => const EmailSupportScreen(),
  ),
  GoRoute(
    path: RouteNames.faqs,
    builder: (context, state) => const FaqsScreen(),
  ),
  GoRoute(
    path: RouteNames.rideIssues,
    builder: (context, state) => const ReportRideIssueScreen(),
  ),
  GoRoute(
    path: RouteNames.lostItems,
    builder: (context, state) => const ReportLostItemScreen(),
  ),
  GoRoute(
    path: RouteNames.safetyResources,
    builder: (context, state) => const SafetyResourcesScreen(),
  ),
  GoRoute(
    path: RouteNames.sosGuide,
    builder: (context, state) => const SosGuideScreen(),
  ),
  GoRoute(
    path: RouteNames.membership,
    builder: (context, state) =>
        const AccountHubPlaceholderScreen(title: 'Membership'),
  ),
  // Wallet
  GoRoute(
    path: RouteNames.wallet,
    pageBuilder: (context, state) =>
        NoTransitionPage<void>(key: state.pageKey, child: const WalletScreen()),
  ),
  GoRoute(
    path: RouteNames.addMoney,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Add Money'),
  ),
  GoRoute(
    path: RouteNames.sendMoney,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Send Money'),
  ),
  GoRoute(
    path: RouteNames.addPaymentMethod,
    redirect: (context, state) => RouteNames.addCard,
  ),
  GoRoute(
    path: RouteNames.voucherDetails,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Voucher details'),
  ),
  GoRoute(
    path: RouteNames.addVoucher,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Add voucher'),
  ),
  GoRoute(
    path: RouteNames.walletTransactions,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Wallet Transactions'),
  ),
  GoRoute(
    path: RouteNames.transactionDetails,
    builder: (context, state) {
      final id = state.uri.queryParameters['id'] ?? '';
      return SupportFlowPlaceholderScreen(
        title: id.isEmpty ? 'Transaction details' : 'Transaction #$id',
      );
    },
  ),
  // Safety
  GoRoute(
    path: RouteNames.safety,
    redirect: (context, state) => RouteNames.safetyCenter,
  ),
  GoRoute(
    path: RouteNames.safetyCenter,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const SafetyCenterScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.emergencySos,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Emergency SOS'),
  ),
  GoRoute(
    path: RouteNames.emergencyContacts,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Emergency Contacts'),
  ),
  GoRoute(
    path: RouteNames.trustedContacts,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Trusted Contacts'),
  ),
  GoRoute(
    path: RouteNames.rideCheck,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Ride Check'),
  ),
  // Inbox
  GoRoute(
    path: RouteNames.inbox,
    pageBuilder: (context, state) =>
        NoTransitionPage<void>(key: state.pageKey, child: const InboxScreen()),
  ),
  GoRoute(
    path: RouteNames.inboxDetail,
    builder: (context, state) => const InboxDetailScreen(),
  ),
  // Saved places
  GoRoute(
    path: RouteNames.savedPlaces,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const SavedPlacesScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.savedPlaceDetail,
    builder: (context, state) => const SavedPlaceDetailScreen(),
  ),
  GoRoute(
    path: RouteNames.addSavedPlace,
    builder: (context, state) => const AddSavedPlaceScreen(),
  ),
  GoRoute(
    path: RouteNames.editSavedPlace,
    builder: (context, state) => const EditSavedPlaceScreen(),
  ),
  GoRoute(
    path: RouteNames.businessTravel,
    builder: (context, state) =>
        const AccountHubPlaceholderScreen(title: 'Business travel'),
  ),
  GoRoute(
    path: RouteNames.safetyCheckup,
    builder: (context, state) =>
        const AccountHubPlaceholderScreen(title: 'Safety checkup'),
  ),
  // Family
  GoRoute(
    path: RouteNames.family,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const FamilyProfileScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.addFamilyMember,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const AddFamilyMemberScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.addParentGuardian,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const AddParentGuardianScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.familyAdultSetup,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Family adult setup'),
  ),
  GoRoute(
    path: RouteNames.familySeniorSetup,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Family senior setup'),
  ),
  GoRoute(
    path: RouteNames.familyTeenSetup,
    redirect: (context, state) => RouteNames.inviteTeen,
  ),
  GoRoute(
    path: RouteNames.inviteTeen,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const InviteTeenScreen(),
    ),
  ),
  // Profile details
  GoRoute(
    path: RouteNames.profileDetails,
    builder: (context, state) => const ProfileDetailsScreen(),
  ),
  GoRoute(
    path: RouteNames.editProfile,
    builder: (context, state) => const EditProfileScreen(),
  ),
  GoRoute(
    path: RouteNames.editProfileName,
    redirect: (context, state) => RouteNames.editProfile,
  ),
  GoRoute(
    path: RouteNames.editPhone,
    redirect: (context, state) => RouteNames.editProfile,
  ),
  GoRoute(
    path: RouteNames.editEmail,
    redirect: (context, state) => RouteNames.profileDetails,
  ),
  // Settings, privacy & security
  GoRoute(
    path: RouteNames.settings,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const SettingsScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.languageSettings,
    builder: (context, state) => const LanguageSettingsScreen(),
  ),
  GoRoute(
    path: RouteNames.privacySettings,
    builder: (context, state) => const PrivacySettingsScreen(),
  ),
  GoRoute(
    path: RouteNames.securitySettings,
    builder: (context, state) => const SecuritySettingsScreen(),
  ),
  GoRoute(
    path: RouteNames.security,
    builder: (context, state) => const SecurityScreen(),
  ),
  GoRoute(
    path: RouteNames.changePassword,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Change password'),
  ),
  GoRoute(
    path: RouteNames.authenticatorApp,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Authenticator app'),
  ),
  GoRoute(
    path: RouteNames.twoStepVerification,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: '2-step verification'),
  ),
  GoRoute(
    path: RouteNames.recoveryPhone,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Recovery phone'),
  ),
  GoRoute(
    path: RouteNames.privacyPolicy,
    builder: (context, state) => const PrivacyPolicyScreen(),
  ),
  GoRoute(
    path: RouteNames.privacyAndData,
    builder: (context, state) => const PrivacyAndDataScreen(),
  ),
  GoRoute(
    path: RouteNames.privacyCenter,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Privacy Center'),
  ),
  GoRoute(
    path: RouteNames.communicationPreferences,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Communication Preferences'),
  ),
  GoRoute(
    path: RouteNames.privacySafetyCheckup,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Safety Checkup'),
  ),
];
