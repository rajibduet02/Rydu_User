abstract final class PassengerProfileErrorCodes {
  static const auth0Error = 'AUTH0_ERROR';
  static const accountDeactivated = 'ACCOUNT_DEACTIVATED';
  static const validationError = 'VALIDATION_ERROR';

  static const auth0NameMessage =
      'Could not update your name right now. Please try again.';
  static const deactivatedMessage =
      'This account has been deactivated. Contact support if you need it reactivated.';
  static const activeRideBlocksDeactivate =
      'Finish or cancel your active ride before deactivating your account.';
}
