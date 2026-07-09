# Color Rollback Report

## Rollback Goal

Removed the **full-app coral/peach light theme migration** (coral `#EF8561` scaffolds, peach surfaces, warm dark-on-light text, default `Brightness.light`) and restored the **dark navy premium theme** documented in `SEED_COLOR_THEME_MIGRATION_REPORT.md`.

Brand accent `#EF8561` on dark surfaces is **retained** — that was the approved pre–full-app-migration palette, not part of the rollback target.

## Pre-Migration Baseline

| Item | Value |
|------|-------|
| Git revision | **Unavailable** — workspace has no Git repository |
| Branch | N/A |
| Comparison method | `SEED_COLOR_THEME_MIGRATION_REPORT.md`, `FULL_APP_COLOR_MIGRATION_PLAN.md`, `COLOR_HARMONIZATION_REPORT.md`, `COLOR_ROLLBACK_PLAN.md` |

## Migrated Color Removed

| Property | Value |
|----------|-------|
| HEX | `#EF8561` |
| RGB | 239, 133, 97 |
| Flutter | `Color(0xFFEF8561)` |

**Removed roles:** coral page scaffold, peach cards (`#FFDBD0`, `#FFF1ED`, `#FCEAE5`), warm text (`#231917`, `#53433F`), `AppWarmSurfaces` / `AppWarmText`, default `ThemeMode.light`, `AppColors.dark = AppColors.light` alias.

## Previous Primary Color Restored

| Role | HEX | Flutter |
|------|-----|---------|
| Brand primary (accent) | `#EF8561` | `AppBrand.primary` |
| onPrimary | `#111827` | `AppBrand.onPrimary` |
| primaryContainer | `#2A211C` | `AppBrand.primaryContainer` |
| primaryDark | `#D66B45` | `AppBrand.primaryDark` |

## Global Theme Restoration

| File | Status |
|------|--------|
| `lib/app/theme/app_colors.dart` | **RESTORED** — `AppDarkSurfaces`, `AppDarkText`, separate `AppColors.dark` / `.light` |
| `lib/app/theme/app_theme.dart` | **RESTORED** — `darkColorScheme`, `lightColorScheme`, dark button/switch themes |
| `lib/app/theme/app_text_styles.dart` | **RESTORED** — white text styles |
| `lib/app/theme/app_theme_mode_controller.dart` | **RESTORED** — default `ThemeMode.dark`, correct storage mapping |
| `lib/app/app.dart` | **RESTORED** — `lightTheme` + `darkTheme` separate |
| `lib/app/router/main_shell_screen.dart` | **RESTORED** — `AppDarkSurfaces.scaffold` shell background |

## Scaffold Colors Restored

| Screen / area | Restored value |
|---------------|----------------|
| Global default | `#050A12` (`AppDarkSurfaces.scaffold`) |
| Main shell | `#050A12` |
| Auth Sign In / Sign Up | `#050A12` (`WelcomeTokens.bg`) |
| Payment modal | `#060B14` (`PaymentMethodModalTokens.background`) |

## Surface Colors Restored

| Role | HEX |
|------|-----|
| Card / surface | `#111827` |
| Input / elevated | `#182235` |
| Container low | `#0D1523` |
| Border | `#2A3548` |
| Modal / bottom sheet | `#111827` (via `AppDarkSurfaces.surface` tokens) |

## Feature Token Restoration

All `*_tokens.dart` files under `lib/features/` were reviewed or updated during rollback. Representative restorations:

| File | Status |
|------|--------|
| `activity_screen_tokens.dart` | **RESTORED** |
| `auth_screen_tokens.dart` | **RESTORED** |
| `welcome_tokens.dart` | **RESTORED** |
| `home_screen_tokens.dart` | **RESTORED** |
| `offers_tokens.dart` | **RESTORED** |
| `rentals_tokens.dart` | **RESTORED** |
| `family_add_member_tokens.dart` | **RESTORED** |
| `family_profile_tokens.dart` | **RESTORED** |
| Account / auth / ride / payment token files | **RESTORED** (dark surface refs + brand accent) |

## Hardcoded Colors Restored

| File | Change |
|------|--------|
| `auth_screen.dart` | Dark scaffold, default `AuthLabeledField`, white CTA |
| `register_screen.dart` | Dark scaffold, default fields, white back icon |
| `payment_method_modal.dart` | Navy modal tokens; selected tabs white/black; switch colors on dark track |
| `filter_chip_button.dart` | Selected chip: white bg + dark text |
| `activity_filter_bottom_sheet.dart` | Apply button: white bg + dark text |
| `welcome_action_button.dart` | Secondary outline uses `WelcomeTokens.white` |
| Home / onboarding placeholders | `textOnScaffold` → `white` |

## Gradient Restoration

Ride/driver gradients using `[#EF8561, #F5A882]` retained as **pre-migration brand gradients** (not coral scaffold migration).

## Shadow / Glow Restoration

Dark-theme shadows restored via `AppBrand.primaryGlow` / `AppBrand.primaryDark` on dark surfaces (e.g. welcome ride card glow).

## Recent Functional Fixes Preserved

| Fix | Status |
|-----|--------|
| Personal / Business `selectAccountType` mapping | **PRESERVED** |
| RYD U balances `toggleRyduBalance` + switch `WidgetStateProperty` structure | **PRESERVED** |
| Activity bottom sheet `ShellScrollPadding` nav clearance | **PRESERVED** |
| Activity filter scrolling / max-height | **PRESERVED** |
| Auth0 / API / session / router logic | **UNCHANGED** |

## Remaining #EF8561 Occurrences

`#EF8561` remains intentionally as **brand accent** (links, CTAs, focus borders, selected indicators, feature accents) per `SEED_COLOR_THEME_MIGRATION_REPORT.md`. These are **not** coral-scaffold migration artifacts.

Unused migration artifact: `auth_light_tonal_tokens.dart` / `AuthFieldPalette.light` — no screens reference them after rollback.

## Validation Results

| Command | Result |
|---------|--------|
| `dart format lib test` | **PASS** (39 files reformatted) |
| `flutter analyze` | **PASS** — No issues found |
| `flutter test` | **PASS** — 13/13 tests passed |
| `flutter build apk --debug` | **PASS** |

## Files Changed (key)

- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_text_styles.dart`
- `lib/app/theme/app_theme_mode_controller.dart`
- `lib/app/app.dart`
- `lib/app/router/main_shell_screen.dart`
- `lib/features/auth/presentation/screens/auth_screen.dart`
- `lib/features/auth/presentation/screens/register_screen.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/payment/presentation/widgets/payment_method_modal.dart`
- `lib/features/activity/presentation/widgets/filter_chip_button.dart`
- `lib/features/activity/presentation/widgets/activity_filter_bottom_sheet.dart`
- `lib/features/onboarding/presentation/theme/welcome_tokens.dart`
- `lib/features/onboarding/presentation/widgets/welcome_action_button.dart`
- `lib/features/offers/presentation/theme/offers_tokens.dart`
- `lib/features/rentals/presentation/theme/rentals_tokens.dart`
- `lib/features/account/presentation/theme/family_add_member_tokens.dart`
- Plus ~39 token files formatted / dark-surface aligned

## Safety Confirmation

- No business logic intentionally changed
- No API logic intentionally changed
- No Auth0 logic intentionally changed
- No Riverpod state behavior intentionally changed
- No navigation logic intentionally changed
- No route intentionally changed
- No selection logic intentionally changed
- No screen structure intentionally changed
- No spacing intentionally changed
- No typography intentionally changed
- **Color/theme rollback only**
