# Seed Color Theme Migration Report

## Seed Color

HEX: #EF8561  
RGB: 239, 133, 97  
Flutter: `Color(0xFFEF8561)` / `AppBrand.seed`

---

## Material Theme Strategy

The global dark theme is built with **Material 3 `ColorScheme.fromSeed`**:

```dart
ColorScheme.fromSeed(
  seedColor: AppBrand.seed, // #EF8561
  brightness: Brightness.dark,
)
```

Generated seed tones drive **primary**, **secondary**, **tertiary**, and container relationships. Premium dark surfaces are **manually tuned** after generation because raw M3 dark surfaces can skew brown/orange — the app preserves its near-black navy-charcoal character.

Implementation lives in `AppTheme.darkColorScheme()` (`lib/app/theme/app_theme.dart`).

Key overrides:
- `primary` → exact brand `#EF8561`
- `onPrimary` → `#111827` (dark text for contrast on coral)
- `surface` / scaffold → `#050A12` (premium dark neutral)
- `surfaceContainer*` hierarchy → navy-charcoal steps
- `outline` / `outlineVariant` → neutral borders
- `secondary` → **seed-generated** (not forced equal to primary)

Light theme uses the same seed with `Brightness.light` and minimal overrides.

---

## Scaffold Color

| | Value |
|---|--------|
| **Previous** | `#050A12` (manual `AppColors.background`) |
| **Final** | `#050A12` via `AppDarkSurfaces.scaffold` → `colorScheme.surface` + `scaffoldBackgroundColor` |
| **Why it works** | Extremely low-saturation near-black navy. Provides strong contrast with `#EF8561` without orange/brown tint. Matches existing premium dark UI. |

Scaffold is **NOT** `#EF8561`.

---

## Generated / Approved Color Roles

| Role | HEX | Flutter value | Purpose |
|------|-----|---------------|---------|
| **seed** | `#EF8561` | `AppBrand.seed` | Material 3 seed anchor |
| **primary** | `#EF8561` | `AppBrand.primary` | CTAs, links, active nav, focus |
| **onPrimary** | `#111827` | `AppBrand.onPrimary` | Text on primary buttons |
| **primaryLight** | `#F5A882` | `AppBrand.primaryLight` | Gradient highlights, soft accents |
| **primaryDark** | `#D66B45` | `AppBrand.primaryDark` | Pressed button state |
| **primaryContainer** | `#2A211C` | `AppBrand.primaryContainer` | Selected surfaces, nav indicator |
| **primarySoft** | `#EF8561` @ 20% | `AppBrand.primarySoft` | Selection, nav bubble fill |
| **primaryBorder** | `#EF8561` @ 40% | `AppBrand.primaryBorder` | Active/selected borders |
| **primaryGlow** | `#EF8561` @ 30% | `AppBrand.primaryGlow` | Brand shadows/glows |
| **scaffold** | `#050A12` | `AppDarkSurfaces.scaffold` | Page background |
| **surface** | `#111827` | `AppDarkSurfaces.surface` | Cards, sheets, nav surface |
| **surfaceElevated** | `#182235` | `AppDarkSurfaces.surfaceElevated` | Elevated containers |
| **surfaceContainerLow** | `#0D1523` | `AppDarkSurfaces.surfaceContainerLow` | Inner card depth |
| **inputSurface** | `#182235` | `AppDarkSurfaces.inputSurface` | Form field fill |
| **surfaceSelected** | `#2A211C` | `AppDarkSurfaces.surfaceSelected` | Selected card tint |
| **outline** | `#2A3548` | `AppDarkSurfaces.border` | Default borders |
| **outlineVariant** | `#1F2937` | `AppDarkSurfaces.borderSubtle` | Subtle dividers |
| **textPrimary** | `#FFFFFF` | `AppDarkText.primary` | Body headings |
| **textSecondary** | `#B8C0D4` | `AppDarkText.secondary` | Secondary copy |
| **textMuted** | `#9CA3AF` | `AppDarkText.muted` | Hints, inactive labels |
| **textDisabled** | `#6B7280` | `AppDarkText.disabled` | Disabled button text |
| **disabled** | `#2A3548` | `AppColors.dark.disabled` | Disabled button fill |

Semantic colors (unchanged): success `#22C55E`, warning `#F59E0B`, danger `#DC2626`.

---

## Auth Screen Audit

Sign In (`/auth`) harmonized via `AuthScreenTokens` → global surface system:

| Element | Color role |
|---------|------------|
| Scaffold | `AppDarkSurfaces.scaffold` |
| Field outer card | `AppDarkSurfaces.surface` |
| Input inner fill | `AppDarkSurfaces.inputSurface` |
| Borders | `AppDarkSurfaces.border` |
| Focus border | `AppBrand.primary` (via theme + widgets) |
| Forgot password / Sign up links | `AppBrand.primary` |
| Enabled Sign In button | White fill (WelcomeActionButton) — theme FilledButtons use `#EF8561` |
| Links / brand accents | `AppBrand.primary` |

Layout, spacing, typography, and button dimensions **unchanged**.

---

## Feature Token Audit

### CHANGED (aligned to global seed/surface system)

| File | Changes |
|------|---------|
| `auth_screen_tokens.dart` | Surfaces, borders, text → `AppDarkSurfaces` / `AppDarkText` / `AppBrand` |
| `welcome_tokens.dart` | Scaffold, surfaces, accents → global tokens |
| `home_screen_tokens.dart` | Background, surface, border, muted |
| `ride_booking_tokens.dart` | Full surface hierarchy |
| `account_screen_tokens.dart` | Background, card, icon well, border |
| `activity_screen_tokens.dart` | Background, sheet, chips, border |
| `services_screen_tokens.dart` | Background, card, border, muted |
| `splash_tokens.dart` | Background → scaffold |

### PRESERVED (brand already harmonized; semantic/feature-specific)

All other `*_tokens.dart` files retain feature-specific values. Brand accent roles already use `#EF8561` from prior harmonization. Semantic colors (success, error, map, ride status, payment, offers gold/red, rental illustration purples, etc.) **unchanged**.

---

## Semantic Colors Preserved

- Success greens (`#22C55E`, `#16A34A`, `#10B981`)
- Warning / gold (`#F59E0B`, `#C9A227`)
- Error / emergency reds (`#DC2626`, `#EF4444`)
- Map pickup/destination/route colors
- Ride / payment / driver status colors
- Rating stars
- Offers badge gold/red
- Help center FAQ purple (`#8B5CF6`)
- Safety center feature purples
- Saved place type colors (orange, pink, green)

---

## Material 3 Component Themes Added/Updated

`app_theme.dart` now configures (colors only):

- `cardTheme`
- `navigationBarTheme` / `bottomNavigationBarTheme`
- `tabBarTheme`
- `chipTheme`
- `switchTheme` / `checkboxTheme` / `radioTheme`
- `progressIndicatorTheme`
- `textButtonTheme`
- `textSelectionTheme`
- `filledButtonTheme` / `elevatedButtonTheme` (with **pressed → primaryDark**)
- All existing themes preserved (sizes, radii, padding)

---

## Validation

| Command | Result |
|---------|--------|
| `dart format lib test` | Passed |
| `flutter analyze` | **No issues found** |
| `flutter test` | **13/13 passed** |
| `flutter build apk --debug` | **Built successfully** |

---

## Files Changed

### Core theme
- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_theme.dart`

### Router / shell
- `lib/app/router/main_shell_screen.dart`

### Feature tokens
- `lib/features/auth/presentation/theme/auth_screen_tokens.dart`
- `lib/features/onboarding/presentation/theme/welcome_tokens.dart`
- `lib/features/home/presentation/theme/home_screen_tokens.dart`
- `lib/features/ride_booking/presentation/theme/ride_booking_tokens.dart`
- `lib/features/account/presentation/theme/account_screen_tokens.dart`
- `lib/features/activity/presentation/theme/activity_screen_tokens.dart`
- `lib/features/services/presentation/theme/services_screen_tokens.dart`
- `lib/features/splash/presentation/theme/splash_tokens.dart`

### Documentation
- `SEED_COLOR_THEME_MIGRATION_REPORT.md` (this file)

---

## Safety Confirmation

- No layout changed
- No spacing changed
- No typography changed
- No text/copy changed
- No navigation or routes changed
- No API logic changed
- No auth logic changed (theme/navigation fixes from prior session preserved)
- No business functionality changed
- Color-only migration within theme and token layers

---

## Usage for Feature Development

Prefer these imports for new presentation code:

```dart
import 'package:rydu_user/app/theme/app_colors.dart';

// Brand
AppBrand.seed / AppBrand.primary / AppBrand.primaryContainer

// Dark surfaces
AppDarkSurfaces.scaffold / .surface / .inputSurface / .border

// Text
AppDarkText.secondary / .muted

// Full palette + ThemeExtension
Theme.of(context).extension<AppThemeColors>()?.palette
Theme.of(context).colorScheme // M3 from seed
```
