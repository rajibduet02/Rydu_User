import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/dio_provider.dart';
import '../../../../app/providers/storage_providers.dart';
import '../../data/datasources/auth0_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/register_with_phone_usecase.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/sign_in_with_phone_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

final auth0DatasourceProvider = Provider<Auth0Datasource>((ref) {
  return Auth0DatasourceImpl();
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasourceImpl>((ref) {
  return AuthRemoteDatasourceImpl(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasourceImpl(ref.watch(secureStorageServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(authLocalDatasourceProvider),
    ref.watch(auth0DatasourceProvider),
  );
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.watch(authRepositoryProvider));
});

final restoreSessionUsecaseProvider = Provider<RestoreSessionUsecase>((ref) {
  return RestoreSessionUsecase(ref.watch(authRepositoryProvider));
});

final requestPasswordResetUsecaseProvider =
    Provider<RequestPasswordResetUsecase>((ref) {
      return RequestPasswordResetUsecase(ref.watch(authRepositoryProvider));
    });

final verifyOtpUsecaseProvider = Provider<VerifyOtpUsecase>((ref) {
  return VerifyOtpUsecase(ref.watch(authRepositoryProvider));
});

final signInWithPhoneUsecaseProvider = Provider<SignInWithPhoneUsecase>((ref) {
  return SignInWithPhoneUsecase(ref.watch(authRepositoryProvider));
});

final registerWithPhoneUsecaseProvider = Provider<RegisterWithPhoneUsecase>((
  ref,
) {
  return RegisterWithPhoneUsecase(ref.watch(authRepositoryProvider));
});

final sendOtpUsecaseProvider = Provider<SendOtpUsecase>((ref) {
  return SendOtpUsecase(ref.watch(authRepositoryProvider));
});

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  return ResetPasswordUsecase(ref.watch(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(ref.watch(authRepositoryProvider));
});

final getMeUsecaseProvider = Provider<GetMeUsecase>((ref) {
  return GetMeUsecase(ref.watch(authRepositoryProvider));
});

/// One-time message shown on the sign-in screen (e.g. after successful sign-up).
final authFlashMessageProvider = StateProvider<String?>((ref) => null);
