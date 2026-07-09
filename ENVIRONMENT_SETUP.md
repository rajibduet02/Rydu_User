# Environment Setup

Configuration for local development and CI builds. **Never commit real secrets** — use `env.example` as a template only.

## dart-define variables

Read at compile time via `String.fromEnvironment` in:

| Variable | Dart constant | File |
|----------|---------------|------|
| `API_BASE_URL` | `ApiConstants.baseUrl` | `lib/core/constants/api_constants.dart` |
| `AUTH0_DOMAIN` | `Auth0Config.domain` | `lib/core/constants/auth0_config.dart` |
| `AUTH0_CLIENT_ID` | `Auth0Config.clientId` | `lib/core/constants/auth0_config.dart` |
| `AUTH0_AUDIENCE` | `Auth0Config.audience` | `lib/core/constants/auth0_config.dart` |
| `AUTH0_CONNECTION` | `Auth0Config.connection` | `lib/core/constants/auth0_config.dart` |

### Template

Copy from [`env.example`](env.example):

```bash
API_BASE_URL=http://your-api-host:3000
AUTH0_DOMAIN=your-tenant.us.auth0.com
AUTH0_CLIENT_ID=your_auth0_native_client_id
AUTH0_AUDIENCE=https://api.your-domain.com
AUTH0_CONNECTION=Username-Password-Authentication
```

### Run command

```bash
flutter run \
  --dart-define=API_BASE_URL=http://your-api-host:3000 \
  --dart-define=AUTH0_DOMAIN=your-tenant.us.auth0.com \
  --dart-define=AUTH0_CLIENT_ID=your_client_id \
  --dart-define=AUTH0_AUDIENCE=https://api.your-domain.com \
  --dart-define=AUTH0_CONNECTION=Username-Password-Authentication
```

### Build command

Pass the same `--dart-define` flags to `flutter build apk`, `flutter build appbundle`, or `flutter build ios`.

### Defaults in code

`api_constants.dart` and `auth0_config.dart` include `defaultValue` fallbacks for development. **Override these in production builds** — do not rely on baked-in defaults for release.

---

## Auth0 dashboard setup

### 1. Create a Native application

1. Log in to [Auth0 Dashboard](https://manage.auth0.com/).
2. **Applications → Create Application**.
3. Choose **Native** (mobile).
4. Note the **Domain** and **Client ID** — map to `AUTH0_DOMAIN` and `AUTH0_CLIENT_ID`.

### 2. Enable database connection

1. **Authentication → Database** → enable **Username-Password-Authentication** (or your custom DB connection).
2. Set `AUTH0_CONNECTION` to the connection name (default: `Username-Password-Authentication`).

### 3. Configure API audience

1. **Applications → APIs** → create or select your API.
2. Set the **Identifier** (audience) — map to `AUTH0_AUDIENCE`.
3. Ensure the Native app is authorized to request tokens for this API.

### 4. Allowed callback & logout URLs

Must align with the app package/bundle ID and custom URL scheme.

| Platform | Scheme / package | Example callback URL |
|----------|------------------|----------------------|
| Android | `com.rydu.user` | `com.rydu.user://your-tenant.us.auth0.com/android/com.rydu.user/callback` |
| iOS | Bundle ID `com.rydu.user` (verify in Xcode) | `com.rydu.user://your-tenant.us.auth0.com/ios/com.rydu.user/callback` |

Add matching URLs under the Native application's **Allowed Callback URLs** and **Allowed Logout URLs**.

### 5. Grant types

For Resource Owner Password login (used by `auth0_flutter`):

- Enable **Password** grant (or equivalent for your Auth0 plan/connection).
- Some tenants require enabling the grant on the application settings.

### 6. Link to backend

After Auth0 login, the app POSTs the Auth0 access token to:

```
POST {API_BASE_URL}/api/v1/passenger/auth/login
```

Ensure your backend validates the Auth0 token against the same `AUTH0_AUDIENCE` and issues a backend JWT consumed by `AuthInterceptor`.

---

## Android notes

**File:** `android/app/build.gradle.kts`

```kotlin
applicationId = "com.rydu.user"
manifestPlaceholders += mapOf(
    "auth0Domain" to "your-tenant.us.auth0.com",
    "auth0Scheme" to "com.rydu.user",
)
```

| Setting | Value | Must match |
|---------|-------|------------|
| `applicationId` | `com.rydu.user` | Auth0 callback URL path |
| `auth0Domain` | Your Auth0 tenant domain | `AUTH0_DOMAIN` dart-define |
| `auth0Scheme` | `com.rydu.user` | Auth0 callback scheme |

The `auth0_flutter` plugin injects intent filters from these placeholders.

**Release signing:** `build.gradle.kts` currently uses debug signing for release builds. Configure a release keystore before store submission.

**Min SDK:** Inherited from Flutter (`flutter.minSdkVersion`).

---

## iOS notes

**Bundle ID:** Verify `PRODUCT_BUNDLE_IDENTIFIER` in Xcode (`ios/Runner.xcodeproj`) matches `com.rydu.user` (or update Auth0 callbacks accordingly).

**URL scheme for Auth0:** Add a custom URL type in `ios/Runner/Info.plist` if not already present:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.rydu.user</string>
    </array>
  </dict>
</array>
```

**Display name:** `Rydu User` (set in `Info.plist`).

**Capabilities:** Push notifications, background location, and maps require additional entitlements not yet configured.

**Build:** Requires macOS with Xcode for device/simulator builds.

---

## Secure storage

Session data is written by `lib/features/auth/data/datasources/auth_local_datasource.dart` using `flutter_secure_storage` via `lib/core/storage/secure_storage_service.dart`.

Keys (see `lib/core/constants/auth_constants.dart`):

- `backend_jwt`
- `session_id`
- `user_id`, `user_email`, `user_name`

Clear app data or uninstall to reset session during development.

---

## Debugging

| Component | Behavior |
|-----------|----------|
| `lib/core/network/error_interceptor.dart` | Logs method + URI in debug mode (no Authorization header) |
| `lib/features/auth/data/utils/auth_debug_logger.dart` | Masked auth debug logs in debug mode |

Run with `flutter run` in debug mode to see HTTP traces. Do not enable verbose token logging in release builds.

---

## CI / team workflow

1. Store secrets in CI variables (not in the repo).
2. Pass `--dart-define` flags in CI build scripts.
3. Keep `env.example` updated when new variables are added.
4. Rotate `AUTH0_CLIENT_ID` and API credentials if exposed.

---

## Verification checklist

- [ ] `flutter pub get` succeeds
- [ ] App launches to splash (`/splash`)
- [ ] Register hits `POST /api/v1/passenger/auth/register`
- [ ] Login obtains Auth0 token, then exchanges at `POST /api/v1/passenger/auth/login`
- [ ] Cold start with valid session navigates to `/home`
- [ ] Logout clears session and returns to `/auth`
- [ ] Protected routes redirect to `/auth` when logged out

See [PRODUCTION_READINESS_CHECKLIST.md](PRODUCTION_READINESS_CHECKLIST.md) for full release criteria.
