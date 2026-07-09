/// Passenger auth API paths and secure-storage keys.
abstract final class AuthConstants {
  static const registerPath = '/api/v1/passenger/auth/register';
  static const loginPath = '/api/v1/passenger/auth/login';
  static const logoutPath = '/api/v1/passenger/auth/logout';
  static const forgotPasswordPath = '/api/v1/passenger/auth/forgot-password';

  static const backendJwtKey = 'backend_jwt';
  static const sessionIdKey = 'session_id';
  static const userIdKey = 'user_id';
  static const userEmailKey = 'user_email';
  static const userNameKey = 'user_name';
}
