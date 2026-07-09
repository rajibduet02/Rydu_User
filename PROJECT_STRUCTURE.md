# Project Structure

Folder tree summary for `rydu_user`. Paths are relative to the repository root.

## Top level

```
Rydu_User/
├── android/                    # Android native project (Auth0 manifest placeholders)
├── ios/                        # iOS native project
├── lib/                        # Dart source (~800 files)
├── test/                       # Unit tests (auth + router)
├── env.example                 # dart-define template (no secrets)
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── ARCHITECTURE.md
├── PROJECT_STRUCTURE.md        # this file
├── BACKEND_API_REQUIREMENTS.md
├── ENVIRONMENT_SETUP.md
├── PRODUCTION_READINESS_CHECKLIST.md
└── PROJECT_ANALYSIS.md         # detailed static analysis
```

## `lib/` overview

```
lib/
├── main.dart                   # Entry: bootstrap → ProviderScope → RyduUserApp
├── bootstrap.dart              # WidgetsFlutterBinding + SharedPreferences
├── app/                        # Application shell (see below)
├── core/                       # Shared infrastructure (see below)
├── features/                   # 20 feature modules (see below)
├── shared/                     # Cross-feature models, enums, extensions
└── react_code/                 # Reference React/Figma prototype (not compiled)
```

Legacy or empty top-level folders (`config/`, `models/`, `providers/`, `repositories/`, `screens/`, `services/`, `utils/`) may exist but are **not** the primary architecture. Active code lives under `app/`, `core/`, and `features/`.

## `lib/app/` — application shell

```
lib/app/
├── app.dart
├── providers/
│   ├── dio_provider.dart           # createDio() → ApiClient
│   ├── storage_providers.dart
│   ├── shared_preferences_provider.dart
│   └── location_provider.dart
├── router/
│   ├── app_router.dart             # goRouterProvider (watches auth session)
│   ├── route_names.dart            # ~100+ canonical paths
│   ├── route_guards.dart           # Auth-based redirects
│   ├── main_shell_screen.dart      # Bottom navigation shell
│   ├── shell_scroll_padding.dart
│   └── routes/
│       ├── auth_routes.dart
│       ├── shell_routes.dart
│       ├── home_routes.dart
│       ├── service_routes.dart
│       ├── account_routes.dart
│       ├── ride_routes.dart
│       └── payment_routes.dart
└── theme/
    ├── app_theme.dart
    ├── app_colors.dart
    ├── app_spacing.dart
    ├── app_text_styles.dart
    └── app_theme_mode_provider.dart
```

## `lib/core/` — shared infrastructure

```
lib/core/
├── constants/
│   ├── api_constants.dart          # API_BASE_URL, timeouts
│   ├── auth0_config.dart           # AUTH0_* dart-define
│   ├── auth_constants.dart         # API paths + storage keys
│   └── app_constants.dart
├── network/
│   ├── dio_factory.dart
│   ├── error_interceptor.dart
│   ├── auth_interceptor.dart
│   ├── api_client.dart
│   ├── api_response_parser.dart
│   └── network_exception.dart
├── storage/
│   ├── secure_storage_service.dart
│   └── local_storage_service.dart
├── widgets/
│   ├── app_button.dart
│   ├── app_text_field.dart
│   ├── app_loader.dart
│   └── app_error_view.dart
├── utils/
│   ├── validators.dart
│   └── formatters.dart
├── errors/
│   ├── exceptions.dart
│   └── failures.dart
└── location/
    └── location_service.dart       # stub
```

## `lib/features/` — feature modules (20)

Each module typically contains `data/`, `domain/`, and `presentation/`.

| Feature | Path | Notes |
|---------|------|-------|
| account | `lib/features/account/` | Largest module (~266 files); wallet, inbox, family, support |
| activity | `lib/features/activity/` | Activity tab |
| auth | `lib/features/auth/` | Auth0 + backend; session provider |
| chat | `lib/features/chat/` | In-ride chat (stub remote) |
| home | `lib/features/home/` | Home tab |
| intercity | `lib/features/intercity/` | Intercity booking UI |
| map | `lib/features/map/` | Map screen (stub) |
| notifications | `lib/features/notifications/` | Push/in-app (stub) |
| offers | `lib/features/offers/` | Promotional offers |
| onboarding | `lib/features/onboarding/` | First-run onboarding |
| payment | `lib/features/payment/` | Payment methods |
| profile | `lib/features/profile/` | User profile (stub remote) |
| rentals | `lib/features/rentals/` | Hourly rental flows |
| reserve | `lib/features/reserve/` | Scheduled rides |
| ride_booking | `lib/features/ride_booking/` | Core ride request flow |
| ride_history | `lib/features/ride_history/` | Past trips (stub) |
| ride_tracking | `lib/features/ride_tracking/` | Driver search & tracking |
| services | `lib/features/services/` | Services hub tab |
| settings | `lib/features/settings/` | App settings |
| splash | `lib/features/splash/` | Cold start + session restore |

### Typical feature layout

```
lib/features/<name>/
├── data/
│   ├── datasources/
│   │   ├── <name>_local_datasource.dart
│   │   └── <name>_remote_datasource.dart   # stub except auth
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    │   ├── <name>_dependencies.dart
    │   └── *_controller.dart
    ├── screens/                # *_screen.dart
    ├── widgets/
    ├── state/
    └── theme/                  # feature design tokens
```

### Auth module (refactor focus)

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth0_datasource.dart
│   │   ├── auth_remote_datasource.dart
│   │   ├── auth_remote_datasource_impl.dart
│   │   └── auth_local_datasource.dart
│   ├── models/session_model.dart
│   ├── repositories/auth_repository_impl.dart
│   └── utils/
│       ├── jwt_validator.dart
│       ├── passenger_session_parser.dart
│       ├── auth_error_mapper.dart
│       └── auth_debug_logger.dart
├── domain/
│   ├── entities/user_entity.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       ├── restore_session_usecase.dart
│       ├── get_current_user_usecase.dart
│       └── request_password_reset_usecase.dart
└── presentation/
    ├── providers/
    │   ├── auth_dependencies.dart
    │   ├── auth_session_provider.dart
    │   └── register_controller.dart
    ├── state/auth_session_state.dart
    └── screens/
        ├── auth_screen.dart
        ├── register_screen.dart
        └── ...
```

## `lib/shared/`

```
lib/shared/
├── models/user_model.dart
├── enums/
└── extensions/
```

## `test/`

```
test/
├── widget_test.dart
├── app/router/route_guards_test.dart
└── features/auth/
    ├── jwt_validator_test.dart
    ├── auth_error_mapper_test.dart
    └── passenger_session_parser_test.dart
```

## Native projects

### Android (`android/`)

- Application ID: `com.rydu.user`
- Auth0 placeholders in `android/app/build.gradle.kts`: `auth0Domain`, `auth0Scheme`

### iOS (`ios/`)

- Bundle display name: Rydu User
- Auth0 URL scheme configuration may be required in `Info.plist` for OAuth callbacks (see [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md))

## File counts (approximate)

| Area | `.dart` files |
|------|---------------|
| `lib/features/` | ~676 |
| `lib/app/` + `lib/core/` | ~44 |
| `test/` | 5 |
| Screens (`*_screen.dart`) | ~86 |
| Route constants | ~100+ paths in `route_names.dart` |

## Related docs

- [ARCHITECTURE.md](ARCHITECTURE.md) — layer rules and auth flow
- [BACKEND_API_REQUIREMENTS.md](BACKEND_API_REQUIREMENTS.md) — API surface by feature
