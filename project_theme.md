# RYD U Project Theme Analysis

> **Scope:** `lib/` only (excluding `lib/react_code`).  
> **Purpose:** Document the current dark-mode visual system before adding light mode.  
> **Note:** This file is documentation only — no app code was changed.

---

## Discovery Summary (pre-documentation scan)

### Central theme layer (`lib/app/theme/`)

| File | Role |
|------|------|
| `lib/app/app.dart` | `MaterialApp.router` — applies `AppTheme.dark` only |
| `lib/app/theme/app_theme.dart` | `ThemeData` + `ColorScheme.dark` |
| `lib/app/theme/app_colors.dart` | Legacy palette (light-oriented values; **not wired into `AppTheme.dark`**) |
| `lib/app/theme/app_text_styles.dart` | 3 static `TextStyle`s referencing `AppColors` (minimal usage) |
| `lib/app/theme/app_spacing.dart` | `xxs`–`xxl` spacing constants |

### Shell / navigation

| File | Role |
|------|------|
| `lib/app/router/main_shell_screen.dart` | Tab shell background `#050A12`, per-tab nav accent colors |
| `lib/features/home/presentation/widgets/home_bottom_nav.dart` | Floating bottom bar visuals |

### Feature token files (39 `*_tokens.dart` files)

Decentralized per-feature palettes under `lib/features/**/presentation/theme/`:

- **Auth:** `auth_screen_tokens`, `otp_tokens`, `name_input_tokens`, `terms_screen_tokens`
- **Onboarding:** `welcome_tokens`
- **Splash:** `splash_tokens`
- **Home:** `home_screen_tokens`
- **Services:** `services_screen_tokens`
- **Activity:** `activity_screen_tokens`
- **Offers:** `offers_tokens`
- **Ride booking:** `ride_booking_tokens`
- **Ride tracking:** `finding_driver_tokens`
- **Intercity:** `intercity_tokens`
- **Reserve:** `reserve_tokens`
- **Rentals:** `rentals_tokens`, `rental_time_tokens`, `rental_ride_tokens`, `rental_driver_found_tokens`
- **Payment:** `add_card_tokens` + inline tokens in `payment_method_modal.dart`
- **Account (large set):** `account_screen_tokens`, `settings_screen_tokens`, `wallet_tokens`, `help_center_tokens`, `inbox_tokens`, `saved_places_tokens`, `profile_details_tokens`, `security_screen_tokens`, `privacy_and_data_tokens`, `faqs_tokens`, `family_*`, `invite_teen_*`, support/report/safety tokens, etc.

### Core shared widgets (`lib/core/widgets/`)

| File | Theme usage |
|------|-------------|
| `app_button.dart` | Uses default `FilledButton` from `ThemeData` (inherits `ColorScheme.primary`) |
| `app_text_field.dart` | Default `OutlineInputBorder` — not feature-styled |
| `app_loader.dart`, `app_error_view.dart` | Minimal / generic |

### Hardcoded color patterns

- **~150+** `Color(0xFF……)` declarations across `lib/**/*.dart`
- **Dominant pattern:** feature `*Tokens` classes + responsive `TextStyle(fontSize: (w * factor).clamp(...))`
- **Errors:** `Theme.of(context).colorScheme.error` (~25 screens) → `#DC2626` via `AppColors.error`
- **Modals:** `showModalBottomSheet` with `backgroundColor: Colors.transparent` + custom container colors
- **Gradients:** blue `#2F6BFF` → `#4D7DFF`, map `#2A3548` → `#0D1523`, green promo, live-chat multi-color

---

## 1. Current Theme Overview

| Aspect | Current state |
|--------|----------------|
| App entry | `MaterialApp.router` in `lib/app/app.dart` |
| Global theme | `AppTheme.dark` only — **no `darkTheme` / `theme` split** |
| `themeMode` | **Not set** (defaults to `ThemeMode.system`, but only one theme is provided) |
| `ColorScheme.fromSeed` | **Not used** |
| Custom `AppTheme` | **Yes** — `lib/app/theme/app_theme.dart` |
| `AppColors` / `AppSpacing` | Exist but **features mostly ignore them** |
| Feature tokens | **39 feature-level `*_tokens.dart` files** (primary styling source) |
| Hardcoded colors | **Extensive** in tokens + some inline widget code |
| Brightness | **Dark only in practice** — `AppTheme.light` aliases to `AppTheme.dark` |
| Forced dark | **De facto yes** — single dark `ThemeData`; no light implementation |

**Architecture in one sentence:** A thin global `ThemeData` shell prevents white flashes, while almost all UI color, radius, and typography live in per-screen token files and responsive inline styles.

---

## 2. Current MaterialApp Theme

**Location:** `lib/app/app.dart`

```dart
return MaterialApp.router(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.dark,
  routerConfig: router,
);
```

**Location:** `lib/app/theme/app_theme.dart`

| Property | Value |
|----------|--------|
| `useMaterial3` | `true` |
| `brightness` | `Brightness.dark` |
| `scaffoldBackgroundColor` | `#050A12` |
| `canvasColor` | `#050A12` |
| `colorScheme` | `ColorScheme.dark(...)` manual (not from seed) |
| `colorScheme.primary` | `#2F6BFF` |
| `colorScheme.surface` | `#050A12` |
| `colorScheme.onSurface` | `#FFFFFF` |
| `colorScheme.error` | `#DC2626` (`AppColors.error`) |
| `dialogTheme.backgroundColor` | `#111827` |
| `appBarTheme.backgroundColor` | `#050A12` |
| `appBarTheme.foregroundColor` | `#FFFFFF` |
| `materialTapTargetSize` | `padded` |
| `AppTheme.light` | **Same as dark** (alias) |

**Not configured globally:** `textTheme`, `inputDecorationTheme`, `elevatedButtonTheme`, `bottomSheetTheme`, `cardTheme`, `dividerTheme`, `snackBarTheme`.

**Navigation:** `NoTransitionPage` used widely in `app_router.dart` to avoid flash during pushes (complements dark scaffold).

---

## 3. Current Color Palette

Colors below are **actually used** in the project (from token files + `AppTheme`). Variants marked *variant* appear in subsets of screens.

| Token Name | Current Color | Usage |
|------------|---------------|--------|
| **background** | `#050A12` | `AppTheme` scaffold/canvas; shell; many account/support screens |
| backgroundAuth | `#050A18` | Auth, welcome, invite teen (*variant*) |
| backgroundHome | `#060B14` | Home, ride booking, wallet, settings (*variant*) |
| backgroundActivity | `#0B0E14` | Activity, account hub, OTP, FAQs (*variant*) |
| backgroundProfile | `#0A0E21` | Profile details (*variant*) |
| backgroundPureBlack | `#000000` | Offers, family profile, family add member (*variant*) |
| backgroundSplash | `#0B1221` | Splash only |
| **surface** | `#111827` | Cards, dialogs, bottom sheets, nav bar, payment modal |
| surfaceDeep | `#0D1523` | Card bottoms, fields, gradients (*variant*) |
| surfaceAlt | `#182235` | Inputs, icon wells, chips (*variant*) |
| surfaceCardAuth | `#1C1C1E` | Family/invite iOS-style cards (*variant*) |
| surfaceElevated | `#12161F` | Security/privacy cards (*variant*) |
| **border** | `#2A3548` | Primary border (cards, inputs, nav, sheets) |
| borderMuted | `#2A3142` | Security/privacy (*variant*) |
| borderFamily | `#2A2A2A` | Family flows (*variant*) |
| **primary** | `#2F6BFF` | Buttons, accents, focus borders, nav (most tabs) |
| primaryWelcome | `#2962FF` | Welcome/onboarding accent (*variant*) |
| primaryServices | `#2E5BFF` | Services tab accent (*variant*) |
| primaryActivity | `#3B82F6` | Activity tab accent (*variant*) |
| **primaryLight** | `#4D7DFF` | Gradient ends, OTP accent, highlights |
| primarySoft | `#448AFF` | Welcome (*variant*) |
| primaryMuted | `#9EB4FF` | FAQ/support link text (*variant*) |
| **textPrimary** | `#FFFFFF` | Titles, buttons on dark |
| **textSecondary** | `#B8C0D4` | Subtitles (home, ride, wallet) |
| textMuted | `#9CA3AF` | Labels (account, security) (*variant*) |
| textMutedAlt | `#A0A0A0` | Welcome, OTP (*variant*) |
| textPlaceholder | `#6B7280` | Form placeholders (*variant*) |
| textLink | `#3B82F6` | Auth links (*variant*) |
| **success** | `#22C55E` | Online status, cash, verified, intercity offer |
| successDark | `#16A34A` | Promo gradient end (*variant*) |
| successTrusted | `#10B981` | Safety trusted contacts (*variant*) |
| **warning** | `#F59E0B` | Gold badges, phone orange, wallet |
| warningOrange | `#FF6B2C` | “New” badges, ride surge (*variant*) |
| warningOrangeAlt | `#FF8A3D` | Support/report accents (*variant*) |
| **danger** | `#DC2626` | `ColorScheme.error`, discount red |
| dangerBright | `#EF4444` | Logout, SOS, emergency (*variant*) |
| dangerPure | `#FF0000` | Welcome discount, services (*variant*) |
| **disabled** | `#2A3548` / opacity `0.45–0.55` | Disabled buttons, nav opacity |
| disabledPill | `#3A3A3C` | Family/invite disabled CTAs (*variant*) |
| **CTA white** | `#FFFFFF` bg + `#000000` text | Welcome/auth primary pill buttons |
| **CTA light gray** | `#E5E5E5` / `#E5E7EB` | Family continue/send, intercity search |
| navActiveBg | `#332F6BFF` (20% alpha) | Home nav bubble (~`0x33` alpha prefix) |
| navActiveBgActivity | `#333B82F6` | Activity tab (*variant*) |
| overlayScrim | `black @ 65%` | Modal barriers |
| shadow | `black @ 45%` blur 28 | Bottom nav elevation |

---

## 4. Suggested Reusable Theme Tokens

Proposed consolidation (documentation only — **not applied**):

### AppColors

```dart
abstract final class AppColors {
  // Backgrounds
  static const background = Color(0xFF050A12);
  static const backgroundElevated = Color(0xFF060B14);
  static const backgroundAuth = Color(0xFF050A18);

  // Surfaces
  static const surface = Color(0xFF111827);
  static const surfaceAlt = Color(0xFF182235);
  static const surfaceDeep = Color(0xFF0D1523);
  static const card = Color(0xFF111827);
  static const cardBorder = Color(0xFF2A3548);

  // Brand
  static const primary = Color(0xFF2F6BFF);
  static const primaryLight = Color(0xFF4D7DFF);
  static const primaryDark = Color(0xFF2962FF);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB8C0D4);
  static const textMuted = Color(0xFF9CA3AF);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const disabled = Color(0xFF2A3548);
}
```

### AppSpacing

Already partially exists — align features to:

| Token | Value | Typical use |
|-------|-------|-------------|
| xxs | 4 | Tight gaps |
| xs | 8 | Icon gaps |
| sm | 12 | Title spacing |
| md | 16 | Field spacing |
| lg | 24 | Section padding |
| xl | 32 | Bottom safe padding |
| xxl | 48 | Large section gaps |

**Also used:** responsive horizontal padding `(width * 0.06).clamp(20, 28)` on most screens.

### AppRadius

| Token | Value | Usage in project |
|-------|-------|------------------|
| sm | 12 | Input fields |
| md | 16 | Tiles, chips |
| lg | 20 | Cards, auth cards, buttons |
| xl | 24 | Ride cards, hero |
| xxl | 28–32 | Bottom sheets (top radius) |
| pill | 999 | Pills, nav bar, CTAs |

### AppShadows

| Token | Approximation |
|-------|----------------|
| blueGlow | `primary @ 25–35%`, blur 14–18, offset (0, 4–8) |
| cardShadow | `black @ 20–25%`, blur 16, offset (0, 8) |
| modalShadow | `black @ 45%`, blur 28, offset (0, 14) |
| navGlow | `accent @ 8%`, blur 20 + `black @ 45%` |

---

## 5. Typography Analysis

The app **does not** define a rich `TextTheme` in `ThemeData`. Most text uses **responsive clamp** from screen width:

```dart
final titleSize = (w * 0.09).clamp(28.0, 34.0);
final subtitleSize = (w * 0.045).clamp(16.0, 18.0);
final bodySize = (w * 0.04).clamp(15.0, 16.0);
final labelSize = (w * 0.035).clamp(12.0, 14.0);
final navLabelSize = (w * 0.03).clamp(10.0, 12.0);
```

| Style | Font Size | Font Weight | Usage |
|-------|-----------|-------------|--------|
| displayLarge | 28–34 sp (`w * 0.09`) | w700 | Screen titles (auth, welcome, home sections) |
| displayMedium | 26–32 sp (`w * 0.085`) | w700 | OTP, name input titles |
| titleLarge | 20–24 sp (`w * 0.055–0.08`) | w700–w800 | Sheet titles, filter headers |
| titleMedium | 16–18 sp (`w * 0.045`) | w600–w700 | Section titles (“For you”, promos) |
| bodyMedium | 15–16 sp (`w * 0.04`) | w400–w500 | Subtitles, field text, buttons |
| labelMedium | 12–14 sp (`w * 0.035–0.038`) | w500–w600 | Field labels, links, chips |
| labelSmall | 10–12 sp (`w * 0.03`) | w600 | Bottom nav labels |

**Global `AppTextStyles` (underused):**

| Style | Size | Weight | Color (issue) |
|-------|------|--------|----------------|
| titleLarge | 22 | w600 | `AppColors.primary` = `#111827` (dark gray) |
| body | 16 | w400 | same |
| label | 14 | w500 | `AppColors.secondary` = `#2563EB` |

**Theme text usage (sparse):** `Theme.of(context).textTheme.headlineSmall`, `titleSmall`, `titleMedium`, `bodySmall` in auth header, onboarding, settings, select vehicle.

**Font family:** Default Material / system font (no custom `fontFamily` in theme).

---

## 6. Component Style Patterns

### Buttons

| Type | Background | Text | Border / radius | Notes |
|------|------------|------|-----------------|-------|
| **Primary blue (gradient)** | `#2F6BFF` → `#4D7DFF` | white | radius 20, height 56 | OTP verify, auth gradient (`_AuthGradientButton`), ride CTAs |
| **Primary blue (solid)** | `#2F6BFF` | white | radius 20 / pill | FilledButton via theme on rare core widgets |
| **White CTA** | `#FFFFFF` | `#000000` | pill (999), h 50–56 | `WelcomeActionButton.primary` — auth, register, reset password |
| **Dark outlined** | transparent | white | border `#2A3548` width 2, pill | `WelcomeActionButton.secondary` |
| **Light gray CTA** | `#E5E5E5` | `#000000` | pill | Family/invite continue & send |
| **Intercity search** | `#FFFFFF` | `#000000` | radius 20 | High-contrast white button on dark |
| **Book now (offers)** | `#1F2937` | white | pill | Muted gray pill |
| **Disabled** | opacity 0.45–0.55 or `#2A3548` / `#3A3A3C` | muted | same shape | `onPressed: null`, `disabledBackgroundColor` |

### Inputs

| Property | Typical value |
|----------|----------------|
| Background | `#182235` or `#0D1523` or `#1C1C1E` |
| Border (default) | `#2A3548` |
| Border (focused) | `#2F6BFF` width 2 |
| Border (family focus) | `#FFFFFF` |
| Placeholder | muted @ 50% alpha |
| Label | `#9CA3AF` / `#B8C0D4`, 12–14 sp, w500 |
| Radius | 12 (`AuthScreenTokens.radiusField`) or 20 (card wrapper) |
| Padding | horizontal 16, vertical 14 |

### Cards

| Property | Typical value |
|----------|----------------|
| Background | `#111827` |
| Inner / field | `#0D1523` |
| Border | `#2A3548` 1px |
| Radius | 20–24 |
| Padding | 20–24 |
| Shadow | `black @ 20%`, blur 16, offset (0, 8) |

### Bottom Navigation

| Property | Value |
|----------|--------|
| Container bg | `HomeScreenTokens.surface` @ 98% opacity (`#111827`) |
| Border | `#2A3548` @ 90% |
| Outer radius | 28–36 (responsive) |
| Active bubble | Tab-specific `navActiveBg` (~20% primary alpha) |
| Active icon/text | Tab accent: `#2F6BFF`, `#2E5BFF`, `#3B82F6` |
| Inactive icon/text | `#B8C0D4` |
| Shadow | black 45% + primary 8% glow |
| Position | floating, left/right 24, bottom 18 + safe area |

### Modals / Bottom Sheets

| Property | Value |
|----------|--------|
| Sheet wrapper | `backgroundColor: Colors.transparent` |
| Barrier | `Colors.black @ 65%` |
| Sheet surface | `#111827` (activity), `#0B0D14` (payment) |
| Top radius | 28–32 vertical |
| Handle | `#2A3548`, 48×4, pill |
| Top border | optional `BorderSide` on sheet |

### Dialogs

| Property | Value |
|----------|--------|
| Background | `#111827` (from `dialogTheme` in `AppTheme`) |

### Error / success / warning (semantic)

| Role | Source | Color |
|------|--------|-------|
| Error text | `Theme.of(context).colorScheme.error` | `#DC2626` |
| Success | tokens `green` / `online` / `verified` | `#22C55E` |
| Warning | `gold`, `orange`, `newOrange` | `#F59E0B`, `#FF6B2C`, `#FF8A3D` |
| Emergency | `sosRed`, `emergencyRed` | `#EF4444` |

---

## 7. Current Problems / Duplication

### Duplicate background navy variants (same role, different hex)

- `#050A12`, `#050A18`, `#060B14`, `#0B0E14`, `#0A0E14`, `#0B0D14`, `#000000`
- **Risk for light mode:** inconsistent “base layer” if not unified first.

### Duplicate primary blue variants

- `#2F6BFF` (dominant), `#2962FF`, `#2E5BFF`, `#3B82F6`, `#4D7DFF`, `#3D7BFF`, `#5D8DFF`, `#9EB4FF`
- Tab nav uses **different** accent per tab instead of one `ColorScheme.primary`.

### Duplicate muted text colors

- `#B8C0D4`, `#9CA3AF`, `#A0A0A0`, `#B4BCCB`, `#9BA3AF`

### Duplicate card/surface stack

- `#111827` + `#0D1523` + `#182235` repeated in 20+ token files with copy-paste.

### Duplicate border radius

- `12`, `16`, `20`, `24`, `999` defined per feature; same values re-declared.

### `AppColors` / `AppTextStyles` drift

- Global `AppColors` uses **light-theme-like** values (`surface = #F9FAFB`) but app runs dark.
- `AppTextStyles` colors do not match on-screen white text.

### Inline hardcoded colors (bypass tokens)

Examples:

- `ride_selection_screen.dart` — `#FF6B2C`, `#2A3548`
- `driver_found_screen.dart` — gradients, `#22C55E`
- `live_chat_support_screen.dart` — multi-color gradient
- `login_screen.dart` — `#050A18` scaffold
- `family_profile_buttons.dart` — `#3A3A3A`

### Typography not centralized

- Same title/subtitle clamp formulas repeated in 50+ screens.
- `TextTheme` mostly empty — cannot switch light/dark from one place.

### Bottom sheet / modal patterns copied

- Transparent parent + custom `Container` decoration repeated (activity, payment, rentals cancel, saved places, report screens).

**Do not fix yet** — document only (per project rules).

---

## 8. Recommended Dark Theme Structure

Proposed layout (future refactor):

```
lib/app/theme/
├── app_theme.dart          # ThemeData.dark / .light builders
├── app_colors.dart         # AppColorsDark / AppColorsLight
├── app_color_scheme.dart   # ColorScheme factory
├── app_text_styles.dart    # TextTheme from colors
├── app_spacing.dart        # exists — extend if needed
├── app_radius.dart         # sm, md, lg, xl, pill
├── app_shadows.dart        # List<BoxShadow> presets
└── app_component_themes.dart # optional: input, button, sheet themes
```

Feature folders would **consume** app tokens:

```dart
// Example: thin wrapper (documentation only)
abstract final class HomeScreenTokens {
  static Color get background => AppColors.backgroundElevated;
  static Color get accent => AppColors.primary;
}
```

Or deprecate per-feature tokens gradually and use `Theme.of(context).extension<AppThemeExtension>()`.

### Sample `ThemeData.dark` (documentation snippet)

```dart
static ThemeData get dark {
  const colors = AppColorsDark();
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.dark(
      surface: colors.background,
      primary: colors.primary,
      onPrimary: colors.textPrimary,
      error: colors.danger,
    ),
    textTheme: AppTextStyles.darkTextTheme(colors),
    inputDecorationTheme: AppComponentThemes.input(colors),
    dialogTheme: DialogThemeData(backgroundColor: colors.surface),
  );
}
```

---

## 9. Future Light Mode Plan

### Strategy

1. **Freeze dark semantic tokens** — map all current variants to one `AppColorsDark` table.
2. **Introduce `AppColorsLight`** with paired semantics (not inverted hex blindly).
3. **Split themes:**

```dart
MaterialApp.router(
  themeMode: ThemeMode.system, // or user preference
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  routerConfig: router,
);
```

4. **Use `ColorScheme` + `ThemeExtension`** for brand/tab accents instead of per-tab hardcoded blues.
5. **Replace** `Color(0xFF...)` in widgets with:
   - `Theme.of(context).colorScheme.surface`
   - `Theme.of(context).extension<AppColors>()!.cardBorder`
6. **Keep feature tokens** as aliases during migration, then remove duplicates.
7. **Test** shell screens first (home, account, auth), then leaf flows.

### Light mode considerations

| Dark token | Light direction |
|------------|-----------------|
| `#050A12` bg | `#F5F7FA` or `#FFFFFF` |
| `#111827` surface | `#FFFFFF` + subtle border |
| `#2A3548` border | `#E5E7EB` |
| `#FFFFFF` text | `#111827` |
| `#B8C0D4` muted | `#6B7280` |
| White CTA button | May become primary-filled blue instead |
| Bottom nav shadow | lighter elevation, no heavy black glow |
| Modal scrim | `black @ 40%` still OK |

### Avoid

- `AppTheme.light => dark` (current alias) for real light mode
- Copy-pasting dark hex into light widgets
- Mixing `AppColors` legacy light values with dark UI

---

## 10. Recommended MaterialApp Theme

Future target (documentation only):

```dart
class RyduUserApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // later: user setting
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
```

### `darkTheme` aligned to current production UI

```dart
abstract final class AppTheme {
  static ThemeData get darkTheme {
    const bg = Color(0xFF050A12);
    const surface = Color(0xFF111827);
    const primary = Color(0xFF2F6BFF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: bg,
        onSurface: Colors.white,
        primary: primary,
        onPrimary: Colors.white,
        secondary: primary,
        error: Color(0xFFDC2626),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: surface),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get lightTheme {
    // TODO: define when ready — do not alias to dark
    return darkTheme; // temporary during migration only
  }
}
```

---

## 11. Migration Checklist

Use this when you are ready to refactor (not now):

- [ ] Audit and merge duplicate background hex values into `AppColorsDark.background*`
- [ ] Audit and merge primary blue variants into `primary` / `primaryVariant`
- [ ] Replace legacy `app_colors.dart` light values with dark semantic set
- [ ] Move shared text clamp helpers to `AppTextStyles` or `AppResponsiveText`
- [ ] Move spacing clamps to shared layout helpers (optional)
- [ ] Add `app_radius.dart` and reference from token files
- [ ] Add `app_shadows.dart` for nav, card, modal
- [ ] Wire `inputDecorationTheme` + `filledButtonTheme` in `ThemeData`
- [ ] Migrate **shell** screens (home, services, activity, account) first
- [ ] Migrate **auth** flow (uses `WelcomeTokens` + `AuthScreenTokens`)
- [ ] Migrate **ride** flow tokens
- [ ] Migrate **account** sub-features (largest token count)
- [ ] Replace inline `Color(0xFF...)` in widgets with tokens
- [ ] Standardize bottom sheet builder helper (barrier, radius, bg)
- [ ] Add `ThemeExtension` for tab-specific nav accent (optional)
- [ ] Implement `AppColorsLight` + `lightTheme`
- [ ] Add theme mode toggle in settings (persist preference)
- [ ] Visual regression pass: auth, home, ride, wallet, modals
- [ ] Remove deprecated per-feature duplicate constants (incremental)

---

## Appendix A — Theme-related files quick index

### App layer
- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_text_styles.dart`
- `lib/app/theme/app_spacing.dart`
- `lib/app/router/main_shell_screen.dart`

### All feature `*_tokens.dart` (39 files)
Under `lib/features/*/presentation/theme/` — see Discovery Summary for full list.

### Notable widgets with embedded style logic
- `lib/features/onboarding/presentation/widgets/welcome_action_button.dart`
- `lib/features/home/presentation/widgets/home_bottom_nav.dart`
- `lib/features/payment/presentation/widgets/payment_method_modal.dart`
- `lib/features/payment/presentation/widgets/payment_method_sheet.dart`
- `lib/features/activity/presentation/widgets/activity_filter_bottom_sheet.dart`
- `lib/features/auth/presentation/widgets/auth_labeled_field.dart`
- `lib/features/auth/presentation/widgets/phone_input_card.dart`

### Ignored per instructions
- `lib/react_code/**`
- Platform folders, `build/`, `.dart_tool/`

---

## Appendix B — Current vs recommended token mapping (dark)

| Current (scattered) | Recommended semantic |
|--------------------|----------------------|
| `HomeScreenTokens.background` | `AppColors.backgroundElevated` |
| `AuthScreenTokens.bg` | `AppColors.backgroundAuth` |
| `*Tokens.card` / `surface` | `AppColors.surface` |
| `*Tokens.field` / `iconWell` | `AppColors.surfaceAlt` |
| `*Tokens.border` | `AppColors.cardBorder` |
| `*Tokens.accent` | `AppColors.primary` |
| `*Tokens.muted` | `AppColors.textSecondary` |
| `*Tokens.white` | `AppColors.textPrimary` |
| `Theme.colorScheme.error` | `AppColors.danger` |

---

*Generated from static analysis of the RYD U Flutter codebase. Re-run this audit after major UI changes or before starting light-mode work.*
