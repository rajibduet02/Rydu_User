# Architecture

RYD U User uses **feature-based Clean Architecture** with unidirectional dependencies and Riverpod for dependency injection.

## Layer model

```
┌─────────────────────────────────────────────────────────┐
│  Presentation  screens, widgets, controllers, providers │
├─────────────────────────────────────────────────────────┤
│  Domain        entities, repository interfaces, usecases│
├─────────────────────────────────────────────────────────┤
│  Data          datasources, models, repository impls    │
└─────────────────────────────────────────────────────────┘
         ▲                    ▲
         │                    │
    lib/core/            lib/shared/
    lib/app/             (cross-feature types)
```

### Dependency rules

| Layer | May depend on | Must not depend on |
|-------|---------------|-------------------|
| **Presentation** | Domain, `core/`, `shared/`, `app/` | Data implementations directly |
| **Domain** | `shared/` entities/models only | Presentation, Data, Flutter widgets |
| **Data** | Domain interfaces, `core/`, `shared/` | Presentation |

**Enforcement is by convention** (no build-time boundary checks). Keep imports pointing inward.

## Feature module pattern

Each feature under `lib/features/<name>/` follows:

```
features/<name>/
├── data/
│   ├── datasources/       # remote + local
│   ├── models/            # JSON / DTO mappers
│   └── repositories/      # *RepositoryImpl
├── domain/
│   ├── entities/
│   ├── repositories/      # abstract *Repository
│   └── usecases/
└── presentation/
    ├── providers/         # controllers + *_dependencies.dart
    ├── screens/
    ├── widgets/
    ├── state/             # (where used)
    └── theme/             # feature design tokens
```

### Wiring dependencies

Feature DI barrels live in `presentation/providers/*_dependencies.dart`. They expose Riverpod `Provider` / `NotifierProvider` instances for repositories and use cases. Example: `lib/features/auth/presentation/providers/auth_dependencies.dart`.

Global providers (Dio, storage) live in `lib/app/providers/`.

## Application shell (`lib/app/`)

| Area | Path | Responsibility |
|------|------|----------------|
| Root widget | `lib/app/app.dart` | `MaterialApp.router`, theme |
| Router | `lib/app/router/app_router.dart` | Assembles GoRouter from route modules |
| Route modules | `lib/app/router/routes/*.dart` | Feature-grouped route trees |
| Route names | `lib/app/router/route_names.dart` | Canonical path constants |
| Guards | `lib/app/router/route_guards.dart` | Auth-based redirects |
| Shell | `lib/app/router/routes/shell_routes.dart` | Bottom-nav `StatefulShellRoute` |
| Theme | `lib/app/theme/` | Colors, spacing, `AppTheme` |

### Router refactor

`app_router.dart` was slimmed down. Route definitions are split by domain:

| File | Routes |
|------|--------|
| `routes/auth_routes.dart` | Splash, onboarding, sign-in, register, OTP, legal |
| `routes/shell_routes.dart` | Main tab shell (home, services, activity, account) |
| `routes/home_routes.dart` | Home-adjacent flows |
| `routes/service_routes.dart` | Services hub, intercity, rentals, reserve |
| `routes/account_routes.dart` | Wallet, inbox, family, safety, support |
| `routes/ride_routes.dart` | Booking, tracking, map |
| `routes/payment_routes.dart` | Payment method flows |

`goRouterProvider` watches `authSessionProvider` and applies `RouteGuards.redirect` on every navigation.

## Core infrastructure (`lib/core/`)

### Network stack

| File | Role |
|------|------|
| `lib/core/network/dio_factory.dart` | Creates configured `Dio` with interceptors |
| `lib/core/network/error_interceptor.dart` | Debug-only request/response logging (no secrets) |
| `lib/core/network/auth_interceptor.dart` | Attaches `Authorization: Bearer <backend_jwt>` |
| `lib/core/network/api_client.dart` | Thin wrapper around `Dio` |
| `lib/core/network/api_response_parser.dart` | Unwraps `{ data: ... }` response envelopes |
| `lib/core/constants/api_constants.dart` | Base URL + timeouts (`--dart-define`) |

`lib/app/providers/dio_provider.dart` calls `createDio(secureStorage)` and exposes `dioProvider` / `apiClientProvider`.

### Storage

| File | Role |
|------|------|
| `lib/core/storage/secure_storage_service.dart` | JWT, session ID, user profile keys |
| `lib/core/storage/local_storage_service.dart` | Non-sensitive flags via SharedPreferences |

### Shared widgets & utilities

`lib/core/widgets/` (`AppButton`, `AppTextField`, `AppLoader`, `AppErrorView`), `lib/core/utils/`, `lib/core/errors/`.

## Authentication architecture

### Components

| Component | Path |
|-----------|------|
| Session state | `lib/features/auth/presentation/state/auth_session_state.dart` |
| Session notifier | `lib/features/auth/presentation/providers/auth_session_provider.dart` |
| Route guards | `lib/app/router/route_guards.dart` |
| Auth0 login | `lib/features/auth/data/datasources/auth0_datasource.dart` |
| Backend exchange | `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart` |
| Local session | `lib/features/auth/data/datasources/auth_local_datasource.dart` |
| Repository | `lib/features/auth/data/repositories/auth_repository_impl.dart` |
| JWT check | `lib/features/auth/data/utils/jwt_validator.dart` |
| Session parser | `lib/features/auth/data/utils/passenger_session_parser.dart` |

### Auth session states

```dart
enum AuthSessionStatus { loading, authenticated, unauthenticated }
```

- **loading** — session restore in progress (splash / cold start)
- **authenticated** — valid backend session in secure storage
- **unauthenticated** — no valid session

### Sign-in flow (email + password)

```
AuthScreen
  → loginUsecaseProvider
    → AuthRepositoryImpl.login()
      → Auth0Datasource.loginWithEmailPassword()     // Auth0 access token
      → AuthRemoteDatasource.exchangeAuth0Token()    // backend JWT + user
      → AuthLocalDatasource.saveSession()
  → authSessionProvider.markAuthenticated(user)
  → GoRouter → /home
```

Files: `lib/features/auth/presentation/screens/auth_screen.dart`, `lib/features/auth/domain/usecases/login_usecase.dart`.

### Sign-up flow

```
RegisterScreen
  → registerUsecaseProvider
    → AuthRepositoryImpl.register()
      → AuthRemoteDatasource.registerPassenger()   // backend only, no auto-login
  → Navigate to /auth (sign in)
```

### Session restore (cold start)

```
SplashScreen._bootstrap()
  → authSessionProvider.restore()
    → RestoreSessionUsecase → hasValidSession() (JWT expiry via JwtValidator)
    → GetCurrentUserUsecase → user from local storage
  → Wait min 2s (splash animation)
  → /home if authenticated, else /auth
```

Files: `lib/features/splash/presentation/screens/splash_screen.dart`, `lib/features/auth/domain/usecases/restore_session_usecase.dart`.

### Logout flow

```
AccountController.logout()
  → AuthRepositoryImpl.signOut()
    → remote logout (best-effort)
    → clear local session + Auth0 credentials
  → authSessionProvider.markUnauthenticated()
  → GoRouter → /auth
```

### Route protection

`RouteGuards` (`lib/app/router/route_guards.dart`):

| Session | Behavior |
|---------|----------|
| `loading` | Stay on `/splash`; redirect all other paths to splash |
| `authenticated` | Redirect guest-only paths (`/auth`, `/login`, `/register`) to `/home` |
| `unauthenticated` | Allow `publicPaths`; redirect protected paths to `/auth` |

Public paths include splash, onboarding, auth screens, OTP, password reset, and legal pages.

### Token storage keys

Defined in `lib/core/constants/auth_constants.dart`:

| Key | Storage |
|-----|---------|
| `backend_jwt` | Secure storage (attached by `AuthInterceptor`) |
| `session_id` | Secure storage |
| `user_id`, `user_email`, `user_name` | Secure storage |

Auth0 credentials are managed separately by `auth0_flutter` credentials manager.

## State management

- **Riverpod 2.x** — `Notifier` / `NotifierProvider` for feature controllers
- **Provider** — repositories, use cases, Dio, storage
- **StateProvider** — ephemeral UI state (e.g. flash messages)

Navigation from controllers uses `ref.read(goRouterProvider).go(...)` or `context.go(...)` in widgets.

## Testing strategy

Unit tests live under `test/` and target pure logic (guards, parsers, validators). Widget/integration tests are minimal. Run with `flutter test`.

| Test file | Covers |
|-----------|--------|
| `test/app/router/route_guards_test.dart` | Redirect rules per session state |
| `test/features/auth/jwt_validator_test.dart` | Token expiry checks |
| `test/features/auth/auth_error_mapper_test.dart` | Dio/Auth0 error mapping |
| `test/features/auth/passenger_session_parser_test.dart` | Login response parsing |

## Known gaps (architectural)

- Most non-auth features use **local/mock datasources** only.
- `AuthRemoteDatasource.sendOtp`, `verifyOtp`, `currentUser` are **stubbed** (no HTTP).
- Phone-based auth paths in `auth_local_datasource.dart` are legacy/local-only.
- JWT refresh is not implemented (`SessionModel` may carry refresh token but it is unused).
- `lib/core/location/location_service.dart` is a stub (no maps SDK).

See [BACKEND_API_REQUIREMENTS.md](BACKEND_API_REQUIREMENTS.md) and [PRODUCTION_READINESS_CHECKLIST.md](PRODUCTION_READINESS_CHECKLIST.md).
