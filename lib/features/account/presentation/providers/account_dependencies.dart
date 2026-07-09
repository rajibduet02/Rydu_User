import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/account_local_datasource.dart';
import '../../data/datasources/account_settings_local_datasource.dart';
import '../../data/datasources/family_local_datasource.dart';
import '../../data/datasources/help_center_local_datasource.dart';
import '../../data/datasources/inbox_local_datasource.dart';
import '../../data/datasources/privacy_local_datasource.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/datasources/saved_places_local_datasource.dart';
import '../../data/datasources/security_local_datasource.dart';
import '../../data/datasources/support_local_datasource.dart';
import '../../data/datasources/wallet_local_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/account_settings_repository_impl.dart';
import '../../data/repositories/family_repository_impl.dart';
import '../../data/repositories/help_center_repository_impl.dart';
import '../../data/repositories/inbox_repository_impl.dart';
import '../../data/repositories/privacy_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/saved_places_repository_impl.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/account_settings_repository.dart';
import '../../domain/repositories/family_repository.dart';
import '../../domain/repositories/help_center_repository.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/privacy_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/saved_places_repository.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/repositories/support_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/continue_family_member_flow_usecase.dart';
import '../../domain/usecases/enable_trip_sharing_usecase.dart';
import '../../domain/usecases/get_account_profile_usecase.dart';
import '../../domain/usecases/get_account_settings_usecase.dart';
import '../../domain/usecases/get_call_support_info_usecase.dart';
import '../../domain/usecases/get_emergency_contacts_usecase.dart';
import '../../domain/usecases/get_faqs_usecase.dart';
import '../../domain/usecases/get_inbox_messages_usecase.dart';
import '../../domain/usecases/get_live_chat_messages_usecase.dart';
import '../../domain/usecases/get_lost_item_trips_usecase.dart';
import '../../domain/usecases/get_profile_details_usecase.dart';
import '../../domain/usecases/get_ride_issue_trips_usecase.dart';
import '../../domain/usecases/get_safety_center_data_usecase.dart';
import '../../domain/usecases/get_saved_places_usecase.dart';
import '../../domain/usecases/get_security_data_usecase.dart';
import '../../domain/usecases/get_wallet_data_usecase.dart';
import '../../domain/usecases/initiate_support_call_usecase.dart';
import '../../domain/usecases/mark_inbox_message_read_usecase.dart';
import '../../domain/usecases/prepare_adult_family_profile_usecase.dart';
import '../../domain/usecases/prepare_teen_family_profile_usecase.dart';
import '../../domain/usecases/request_data_download_usecase.dart';
import '../../domain/usecases/send_guardian_invite_usecase.dart';
import '../../domain/usecases/send_live_chat_message_usecase.dart';
import '../../domain/usecases/send_teen_invite_usecase.dart';
import '../../domain/usecases/submit_email_support_usecase.dart';
import '../../domain/usecases/submit_lost_item_report_usecase.dart';
import '../../domain/usecases/submit_ride_issue_usecase.dart';

// --- Datasources ---

final accountLocalDatasourceProvider = Provider<AccountLocalDatasource>((ref) {
  return AccountLocalDatasourceImpl();
});

final walletLocalDatasourceProvider = Provider<WalletLocalDatasource>((ref) {
  return WalletLocalDatasourceImpl();
});

final inboxLocalDatasourceProvider = Provider<InboxLocalDatasource>((ref) {
  return InboxLocalDatasourceImpl();
});

final helpCenterLocalDatasourceProvider = Provider<HelpCenterLocalDatasource>((
  ref,
) {
  return HelpCenterLocalDatasourceImpl();
});

final savedPlacesLocalDatasourceProvider = Provider<SavedPlacesLocalDatasource>(
  (ref) {
    return SavedPlacesLocalDatasourceImpl();
  },
);

final supportLocalDatasourceProvider = Provider<SupportLocalDatasource>((ref) {
  return SupportLocalDatasourceImpl();
});

final familyLocalDatasourceProvider = Provider<FamilyLocalDatasource>((ref) {
  return FamilyLocalDatasourceImpl();
});

final profileLocalDatasourceProvider = Provider<ProfileLocalDatasource>((ref) {
  return ProfileLocalDatasourceImpl();
});

final securityLocalDatasourceProvider = Provider<SecurityLocalDatasource>((
  ref,
) {
  return SecurityLocalDatasourceImpl();
});

final privacyLocalDatasourceProvider = Provider<PrivacyLocalDatasource>((ref) {
  return PrivacyLocalDatasourceImpl();
});

final accountSettingsLocalDatasourceProvider =
    Provider<AccountSettingsLocalDatasource>((ref) {
      return AccountSettingsLocalDatasourceImpl();
    });

// --- Repositories ---

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountLocalDatasourceProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(walletLocalDatasourceProvider));
});

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return InboxRepositoryImpl(ref.watch(inboxLocalDatasourceProvider));
});

final helpCenterRepositoryProvider = Provider<HelpCenterRepository>((ref) {
  return HelpCenterRepositoryImpl(ref.watch(helpCenterLocalDatasourceProvider));
});

final savedPlacesRepositoryProvider = Provider<SavedPlacesRepository>((ref) {
  return SavedPlacesRepositoryImpl(
    ref.watch(savedPlacesLocalDatasourceProvider),
  );
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepositoryImpl(ref.watch(supportLocalDatasourceProvider));
});

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepositoryImpl(ref.watch(familyLocalDatasourceProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileLocalDatasourceProvider));
});

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return SecurityRepositoryImpl(ref.watch(securityLocalDatasourceProvider));
});

final privacyRepositoryProvider = Provider<PrivacyRepository>((ref) {
  return PrivacyRepositoryImpl(ref.watch(privacyLocalDatasourceProvider));
});

final accountSettingsRepositoryProvider = Provider<AccountSettingsRepository>((
  ref,
) {
  return AccountSettingsRepositoryImpl(
    ref.watch(accountSettingsLocalDatasourceProvider),
  );
});

// --- Use cases ---

final getAccountProfileUsecaseProvider = Provider<GetAccountProfileUsecase>((
  ref,
) {
  return GetAccountProfileUsecase(ref.watch(accountRepositoryProvider));
});

final getWalletDataUsecaseProvider = Provider<GetWalletDataUsecase>((ref) {
  return GetWalletDataUsecase(ref.watch(walletRepositoryProvider));
});

final getInboxMessagesUsecaseProvider = Provider<GetInboxMessagesUsecase>((
  ref,
) {
  return GetInboxMessagesUsecase(ref.watch(inboxRepositoryProvider));
});

final markInboxMessageReadUsecaseProvider =
    Provider<MarkInboxMessageReadUsecase>((ref) {
      return MarkInboxMessageReadUsecase(ref.watch(inboxRepositoryProvider));
    });

final getFaqsUsecaseProvider = Provider<GetFaqsUsecase>((ref) {
  return GetFaqsUsecase(ref.watch(helpCenterRepositoryProvider));
});

final getSavedPlacesUsecaseProvider = Provider<GetSavedPlacesUsecase>((ref) {
  return GetSavedPlacesUsecase(ref.watch(savedPlacesRepositoryProvider));
});

final getLiveChatMessagesUsecaseProvider = Provider<GetLiveChatMessagesUsecase>(
  (ref) {
    return GetLiveChatMessagesUsecase(ref.watch(supportRepositoryProvider));
  },
);

final sendLiveChatMessageUsecaseProvider = Provider<SendLiveChatMessageUsecase>(
  (ref) {
    return SendLiveChatMessageUsecase(ref.watch(supportRepositoryProvider));
  },
);

final getRideIssueTripsUsecaseProvider = Provider<GetRideIssueTripsUsecase>((
  ref,
) {
  return GetRideIssueTripsUsecase(ref.watch(supportRepositoryProvider));
});

final submitRideIssueUsecaseProvider = Provider<SubmitRideIssueUsecase>((ref) {
  return SubmitRideIssueUsecase(ref.watch(supportRepositoryProvider));
});

final getLostItemTripsUsecaseProvider = Provider<GetLostItemTripsUsecase>((
  ref,
) {
  return GetLostItemTripsUsecase(ref.watch(supportRepositoryProvider));
});

final submitLostItemReportUsecaseProvider =
    Provider<SubmitLostItemReportUsecase>((ref) {
      return SubmitLostItemReportUsecase(ref.watch(supportRepositoryProvider));
    });

final getCallSupportInfoUsecaseProvider = Provider<GetCallSupportInfoUsecase>((
  ref,
) {
  return GetCallSupportInfoUsecase(ref.watch(supportRepositoryProvider));
});

final initiateSupportCallUsecaseProvider = Provider<InitiateSupportCallUsecase>(
  (ref) {
    return InitiateSupportCallUsecase(ref.watch(supportRepositoryProvider));
  },
);

final submitEmailSupportUsecaseProvider = Provider<SubmitEmailSupportUsecase>((
  ref,
) {
  return SubmitEmailSupportUsecase(ref.watch(supportRepositoryProvider));
});

final getSafetyCenterDataUsecaseProvider = Provider<GetSafetyCenterDataUsecase>(
  (ref) {
    return GetSafetyCenterDataUsecase(ref.watch(securityRepositoryProvider));
  },
);

final enableTripSharingUsecaseProvider = Provider<EnableTripSharingUsecase>((
  ref,
) {
  return EnableTripSharingUsecase(ref.watch(securityRepositoryProvider));
});

final getEmergencyContactsUsecaseProvider =
    Provider<GetEmergencyContactsUsecase>((ref) {
      return GetEmergencyContactsUsecase(ref.watch(securityRepositoryProvider));
    });

final getProfileDetailsUsecaseProvider = Provider<GetProfileDetailsUsecase>((
  ref,
) {
  return GetProfileDetailsUsecase(ref.watch(profileRepositoryProvider));
});

final getSecurityDataUsecaseProvider = Provider<GetSecurityDataUsecase>((ref) {
  return GetSecurityDataUsecase(ref.watch(securityRepositoryProvider));
});

final requestDataDownloadUsecaseProvider = Provider<RequestDataDownloadUsecase>(
  (ref) {
    return RequestDataDownloadUsecase(ref.watch(privacyRepositoryProvider));
  },
);

final prepareAdultFamilyProfileUsecaseProvider =
    Provider<PrepareAdultFamilyProfileUsecase>((ref) {
      return PrepareAdultFamilyProfileUsecase(
        ref.watch(familyRepositoryProvider),
      );
    });

final prepareTeenFamilyProfileUsecaseProvider =
    Provider<PrepareTeenFamilyProfileUsecase>((ref) {
      return PrepareTeenFamilyProfileUsecase(
        ref.watch(familyRepositoryProvider),
      );
    });

final continueFamilyMemberFlowUsecaseProvider =
    Provider<ContinueFamilyMemberFlowUsecase>((ref) {
      return ContinueFamilyMemberFlowUsecase(
        ref.watch(familyRepositoryProvider),
      );
    });

final sendGuardianInviteUsecaseProvider = Provider<SendGuardianInviteUsecase>((
  ref,
) {
  return SendGuardianInviteUsecase(ref.watch(familyRepositoryProvider));
});

final sendTeenInviteUsecaseProvider = Provider<SendTeenInviteUsecase>((ref) {
  return SendTeenInviteUsecase(ref.watch(familyRepositoryProvider));
});

final getAccountSettingsUsecaseProvider = Provider<GetAccountSettingsUsecase>((
  ref,
) {
  return GetAccountSettingsUsecase(
    ref.watch(accountSettingsRepositoryProvider),
  );
});
