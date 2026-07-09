# Production Readiness Checklist

Track release readiness for the RYD U passenger app. Status keys:

| Status | Meaning |
|--------|---------|
| **Done** | Implemented and usable in the current codebase |
| **Needs backend** | UI/architecture ready; requires API implementation |
| **Needs dashboard** | Requires Auth0 or third-party console configuration |
| **Needs manual QA** | Requires human testing on devices |

Last updated after infrastructure refactor (routing, session, network, tests). **No UI changes** in that refactor.

---

## Architecture & infrastructure

| Item | Status | Notes |
|------|--------|-------|
| Feature-based Clean Architecture | **Done** | `lib/features/<name>/{data,domain,presentation}` |
| Router split into `lib/app/router/routes/*.dart` | **Done** | `app_router.dart` assembles modules |
| Global Dio via `dio_factory.dart` | **Done** | `lib/core/network/dio_factory.dart` |
| `ErrorInterceptor` (debug logging) | **Done** | No secrets logged |
| `AuthInterceptor` (Bearer JWT) | **Done** | `lib/core/network/auth_interceptor.dart` |
| `env.example` template | **Done** | Root `env.example` |
| Unit tests (`test/`) | **Done** | Guards, JWT, error mapper, session parser |
| Widget/integration test coverage | **Needs manual QA** | Only default `widget_test.dart` beyond unit tests |

---

## Authentication & session

| Item | Status | Notes |
|------|--------|-------|
| Auth0 email/password login | **Done** | `auth0_datasource.dart` |
| Backend token exchange | **Done** | `POST /api/v1/passenger/auth/login` |
| Passenger registration API | **Done** | `POST /api/v1/passenger/auth/register` |
| Logout API (best-effort) | **Done** | `POST /api/v1/passenger/auth/logout` |
| Email forgot-password API | **Done** | `POST /api/v1/passenger/auth/forgot-password` |
| `AuthSessionProvider` | **Done** | `auth_session_provider.dart` |
| Route guards | **Done** | `route_guards.dart` + tests |
| Splash session restore | **Done** | `splash_screen.dart` + `restore_session_usecase.dart` |
| JWT expiry validation (client) | **Done** | `jwt_validator.dart` — no signature verify |
| Auth0 Native app + callbacks | **Needs dashboard** | See [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) |
| Auth0 Password grant enabled | **Needs dashboard** | Tenant-dependent |
| `dart-define` secrets in CI/release | **Needs dashboard** | Override code defaults |
| Phone OTP auth APIs | **Needs backend** | `sendOtp` / `verifyOtp` stubbed |
| `GET /auth/me` current user | **Needs backend** | `currentUser()` stubbed |
| JWT refresh / token rotation | **Needs backend** | Not implemented |
| Phone-based auth UI vs email API alignment | **Needs manual QA** | Forgot-password screen uses phone flow |
| Session restore after OS kill | **Needs manual QA** | Test cold start with valid/expired JWT |
| Logout end-to-end | **Needs manual QA** | Remote + local + Auth0 clear |

---

## Navigation & access control

| Item | Status | Notes |
|------|--------|-------|
| ~100+ routes defined | **Done** | `route_names.dart` |
| Protected routes redirect to `/auth` | **Done** | `RouteGuards` |
| Authenticated users skip auth screens | **Done** | Guest-only redirect to `/home` |
| Deep link handling | **Needs manual QA** | GoRouter paths exist; not fully verified |
| Onboarding gating (first launch) | **Needs manual QA** | Route exists; persistence logic unclear |

---

## Networking

| Item | Status | Notes |
|------|--------|-------|
| Configurable `API_BASE_URL` | **Done** | `--dart-define` |
| 30s timeouts | **Done** | `api_constants.dart` |
| Response envelope parsing | **Done** | `api_response_parser.dart` |
| Global error handling (non-auth) | **Needs backend** | `network_exception.dart` exists; feature usage limited |
| Retry / offline handling | **Needs backend** | Not implemented |
| Certificate pinning | **Needs manual QA** | Not implemented — evaluate for production |

---

## Feature modules — backend integration

| Feature | Status | Stub / local file |
|---------|--------|-------------------|
| Auth (core) | **Done** (partial) | See auth section above |
| Home | **Needs backend** | `home_remote_datasource.dart` |
| Ride booking | **Needs backend** | `ride_booking_remote_datasource.dart` |
| Ride tracking | **Needs backend** | `ride_tracking_remote_datasource.dart` |
| Ride history | **Needs backend** | `ride_history_remote_datasource.dart` |
| Payment | **Needs backend** | `payment_remote_datasource.dart` |
| Profile | **Needs backend** | `profile_remote_datasource.dart` |
| Chat | **Needs backend** | `chat_remote_datasource.dart` |
| Notifications | **Needs backend** | `notifications_remote_datasource.dart` |
| Map | **Needs backend** | `map_remote_datasource.dart` + maps SDK |
| Account (wallet, inbox, family, etc.) | **Needs backend** | `*_local_datasource.dart` only |
| Intercity | **Needs backend** | `intercity_local_datasource.dart` |
| Rentals | **Needs backend** | `rentals_local_datasource.dart` |
| Reserve | **Needs backend** | `reserve_local_datasource.dart` |
| Offers | **Needs backend** | `offers_local_datasource.dart` |
| Activity | **Needs backend** | `activity_local_datasource.dart` |
| Services | **Needs backend** | `services_local_datasource.dart` |
| Onboarding | **Done** (client) | Can remain client-side |
| Splash | **Done** | Session bootstrap only |
| Settings | **Needs backend** | `settings_local_datasource.dart` |

Full endpoint list: [BACKEND_API_REQUIREMENTS.md](BACKEND_API_REQUIREMENTS.md).

---

## Maps & location

| Item | Status | Notes |
|------|--------|-------|
| Maps SDK (Google/Mapbox) | **Needs dashboard** | Not in `pubspec.yaml` |
| Location permissions (Android/iOS) | **Needs manual QA** | Manifest/plist entries may be incomplete |
| `LocationService` | **Needs backend** | Stub in `lib/core/location/location_service.dart` |
| Live driver tracking WebSocket | **Needs backend** | Stub stream in ride tracking |

---

## Payments & wallet

| Item | Status | Notes |
|------|--------|-------|
| Payment methods UI | **Done** | Presentation layer |
| Payment methods API | **Needs backend** | `payment_remote_datasource.dart` |
| Wallet UI | **Done** | Mock data in `wallet_local_datasource.dart` |
| Wallet / top-up / transfer API | **Needs backend** | TODO in local datasource |
| PCI / tokenization provider | **Needs dashboard** | Stripe/etc. not integrated |

---

## Push notifications

| Item | Status | Notes |
|------|--------|-------|
| FCM / APNs SDK | **Needs dashboard** | Not in dependencies |
| Device token registration API | **Needs backend** | Not implemented |
| In-app notification list API | **Needs backend** | `notifications_remote_datasource.dart` |

---

## Android release

| Item | Status | Notes |
|------|--------|-------|
| Application ID `com.rydu.user` | **Done** | `build.gradle.kts` |
| Auth0 manifest placeholders | **Done** | Domain + scheme |
| Release signing keystore | **Needs manual QA** | Debug signing used for release |
| Play Store listing / privacy policy | **Needs manual QA** | External |
| ProGuard / R8 rules for Auth0 | **Needs manual QA** | Verify release build |

---

## iOS release

| Item | Status | Notes |
|------|--------|-------|
| Bundle ID configuration | **Needs manual QA** | Verify in Xcode |
| Auth0 URL scheme in Info.plist | **Needs dashboard** | May need `CFBundleURLTypes` |
| Apple Developer provisioning | **Needs dashboard** | Certificates + profiles |
| App Store listing / privacy nutrition | **Needs manual QA** | External |
| Push notification entitlements | **Needs dashboard** | If using APNs |

---

## Security

| Item | Status | Notes |
|------|--------|-------|
| Secure storage for JWT | **Done** | `flutter_secure_storage` |
| No secrets in repo | **Done** | Use `env.example` only |
| Auth debug logging gated to debug | **Done** | `auth_debug_logger.dart`, `error_interceptor.dart` |
| Client-side JWT expiry only | **Needs manual QA** | No signature verification |
| Certificate pinning | **Needs manual QA** | Not implemented |
| Obfuscation (`--obfuscate`) | **Needs manual QA** | Not configured |

---

## Quality assurance

| Item | Status | Notes |
|------|--------|-------|
| `flutter analyze` clean | **Needs manual QA** | Run before release |
| `flutter test` passing | **Needs manual QA** | 5 test files |
| Sign-in / sign-up / logout flows | **Needs manual QA** | On physical devices |
| Session restore (kill app, reopen) | **Needs manual QA** | Splash → home vs auth |
| Route guard behavior | **Needs manual QA** | Deep links to protected routes |
| Register → login → home happy path | **Needs manual QA** | No auto-login after register |
| Error messages (network, Auth0, backend) | **Needs manual QA** | `AuthException` display |
| Accessibility audit | **Needs manual QA** | Not assessed |
| Performance profiling | **Needs manual QA** | Large account module |

---

## Documentation

| Item | Status | Notes |
|------|--------|-------|
| README.md | **Done** | This refactor |
| ARCHITECTURE.md | **Done** | |
| PROJECT_STRUCTURE.md | **Done** | |
| BACKEND_API_REQUIREMENTS.md | **Done** | |
| ENVIRONMENT_SETUP.md | **Done** | |
| PRODUCTION_READINESS_CHECKLIST.md | **Done** | This file |

---

## Suggested release phases

### Phase 1 — Auth MVP (current focus)
- Auth0 dashboard + dart-define in CI
- Backend auth endpoints stable
- Manual QA: login, register, logout, session restore, route guards

### Phase 2 — Core ride loop
- Ride draft, estimate, confirm, track, cancel, history APIs
- Maps SDK + location permissions
- Manual QA: full ride happy path

### Phase 3 — Account & payments
- Wallet, payment methods, profile, saved places
- Payment provider dashboard setup

### Phase 4 — Production hardening
- Release signing, obfuscation, certificate pinning
- Push notifications, chat WebSocket
- Store submission + compliance review
