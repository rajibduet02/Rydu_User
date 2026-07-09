/// Auth0 tenant configuration loaded from `--dart-define` at build time.
abstract final class Auth0Config {
  static const domain = String.fromEnvironment(
    'AUTH0_DOMAIN',
    defaultValue: 'dev-5pz66h48u0jnn4sg.us.auth0.com',
  );

  static const clientId = String.fromEnvironment(
    'AUTH0_CLIENT_ID',
    defaultValue: 'jLzPEij6eQBwlh3djHEri1tPaQ0T6kab',
  );

  static const audience = String.fromEnvironment(
    'AUTH0_AUDIENCE',
    defaultValue: 'https://api.drivewize.com',
  );

  static const connection = String.fromEnvironment(
    'AUTH0_CONNECTION',
    defaultValue: 'Username-Password-Authentication',
  );
}
