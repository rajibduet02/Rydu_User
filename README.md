# RYD U User (Passenger App)

Cross-platform Flutter mobile app for ride-hailing passengers. The codebase follows **feature-based Clean Architecture** with Riverpod state management, GoRouter navigation, Auth0 authentication, and a shared Dio HTTP client.

> **Refactor note:** Recent work focused on infrastructure (routing, session management, networking, tests). **No UI changes** were made.

## Tech stack

| Category | Technology |
|----------|------------|
| Language | Dart `^3.11.5` |
| Framework | Flutter (Material 3) |
| State management | `flutter_riverpod` ^2.6.1 |
| Routing | `go_router` ^14.6.2 |
| HTTP | `dio` ^5.7.0 |
| Auth provider | `auth0_flutter` ^2.3.0 |
| Secure storage | `flutter_secure_storage` ^9.2.2 |
| Local preferences | `shared_preferences` ^2.3.3 |
| Linting | `flutter_lints` ^6.0.0 |
| Platforms | Android, iOS |

## Prerequisites

- Flutter SDK compatible with Dart `^3.11.5`
- Android Studio / Xcode for device builds
- Auth0 tenant and backend API access (see [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md))

## Quick start

```bash
# Install dependencies
flutter pub get

# Run (pass environment values — see env.example)
flutter run \
  --dart-define=API_BASE_URL=http://your-api-host:3000 \
  --dart-define=AUTH0_DOMAIN=your-tenant.us.auth0.com \
  --dart-define=AUTH0_CLIENT_ID=your_native_client_id \
  --dart-define=AUTH0_AUDIENCE=https://api.example.com \
  --dart-define=AUTH0_CONNECTION=Username-Password-Authentication
```

Copy variable names and example values from [`env.example`](env.example). **Do not commit real client IDs or secrets.**

## Build

```bash
# Android APK
flutter build apk --release \
  --dart-define=API_BASE_URL=... \
  --dart-define=AUTH0_DOMAIN=... \
  --dart-define=AUTH0_CLIENT_ID=... \
  --dart-define=AUTH0_AUDIENCE=...

# iOS (requires macOS + Xcode)
flutter build ios --release \
  --dart-define=API_BASE_URL=... \
  --dart-define=AUTH0_DOMAIN=... \
  --dart-define=AUTH0_CLIENT_ID=... \
  --dart-define=AUTH0_AUDIENCE=...
```

## Test

```bash
flutter test
```

Current test coverage includes route guards, JWT validation, auth error mapping, and passenger session parsing. See `test/`.

## Project status

- **Presentation:** ~86 screens across 20 feature modules; UI is substantially built.
- **Backend integration:** Auth module makes real HTTP calls; most other features use local/mock datasources.
- **Session & routing:** `AuthSessionProvider`, route guards, and splash session restore are implemented.

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Clean Architecture rules, layer boundaries, auth flow |
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | Folder tree and module layout |
| [BACKEND_API_REQUIREMENTS.md](BACKEND_API_REQUIREMENTS.md) | Implemented and missing API endpoints |
| [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) | `dart-define` vars, Auth0 dashboard, platform notes |
| [PRODUCTION_READINESS_CHECKLIST.md](PRODUCTION_READINESS_CHECKLIST.md) | Release readiness tracker |
| [PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md) | Detailed static codebase analysis |

## Entry points

| File | Role |
|------|------|
| `lib/main.dart` | App entry; wraps `ProviderScope` |
| `lib/bootstrap.dart` | Async init (`SharedPreferences`) |
| `lib/app/app.dart` | `MaterialApp.router` + theme |
| `lib/app/router/app_router.dart` | GoRouter assembly (delegates to `routes/`) |
| `lib/features/splash/presentation/screens/splash_screen.dart` | Cold start + session restore |

## License

Private project — not published to pub.dev (`publish_to: 'none'`).
