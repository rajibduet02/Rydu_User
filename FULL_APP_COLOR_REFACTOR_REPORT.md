# Full App Color Refactor Report

## Seed Color

| Property | Value |
|----------|-------|
| HEX | `#EF8561` |
| RGB | 239, 133, 97 |
| Flutter | `Color(0xFFEF8561)` |

## Theme Direction

The application now uses a **warm coral seed-based light visual theme** derived from Material 3 `ColorScheme.fromSeed(seedColor: #EF8561, brightness: light)`.

Visual hierarchy:

1. **Scaffold** — `#EF8561` coral
2. **Cards / containers** — `#FFDBD0` light peach (`primaryContainer`)
3. **Inputs / elevated surfaces** — `#FFF1ED` soft warm cream (`surfaceContainerLow`)
4. **Borders** — `#D8C2BB` subtle coral outline (`outlineVariant`)
5. **Text / icons** — warm dark neutrals (`#231917`, `#53433F`, `#85736E`)
6. **Primary actions** — white/cream button on coral scaffold with warm dark label

The legacy dark navy / near-black application theme has been removed from normal UI surfaces.

## Previous Dark Palette (Removed from Non-Semantic Surfaces)

| Role | Old HEX |
|------|---------|
| Scaffold | `#050A12`, `#060B14`, `#0A0E14`, `#0B0E14` |
| Card | `#111827` |
| Input / elevated | `#182235` |
| Container low | `#0D1523` |
| Border | `#2A3548`, `#1F2937` |
| Text primary | `#FFFFFF` |
| Text secondary | `#B8C0D4` |
| Primary container | `#2A211C` |
| Theme | `Brightness.dark` default |

## Approved Global Palette

| Role | HEX | Flutter | Purpose |
|------|-----|---------|---------|
| primary | `#EF8561` | `AppBrand.primary` | Seed / brand anchor |
| primaryLight | `#F5A882` | `AppBrand.primaryLight` | Soft accent |
| primaryDark | `#D66B45` | `AppBrand.primaryDark` | Active / selected accent |
| primarySoft | `#33EF8561` | `AppBrand.primarySoft` | Glow / selection tint |
| primaryContainer | `#FFDBD0` | `AppBrand.primaryContainer` | Card / form surface |
| primaryBorder | `#66EF8561` | `AppBrand.primaryBorder` | Selected border |
| primaryGlow | `#4DEF8561` | `AppBrand.primaryGlow` | Focus glow |
| onPrimary | `#FFFFFF` | `AppBrand.onPrimary` | Text on strong primary |
| scaffold | `#EF8561` | `AppWarmSurfaces.scaffold` | Page background |
| cardSurface | `#FFDBD0` | `AppWarmSurfaces.surface` | Cards |
| containerSurface | `#FCEAE5` | `AppWarmSurfaces.surfaceElevated` | Sections / modals |
| inputSurface | `#FFF1ED` | `AppWarmSurfaces.inputSurface` | Text fields |
| surfaceSelected | `#F7E4DF` | `AppWarmSurfaces.surfaceSelected` | Selected state |
| surfaceDisabled | `#FFF1ED` | `AppWarmSurfaces.disabled` | Disabled fill |
| borderSubtle | `#E8D4CC` | `AppWarmSurfaces.borderSubtle` | Subtle outline |
| border | `#D8C2BB` | `AppWarmSurfaces.border` | Normal border |
| borderActive | `#EF8561` | `AppWarmSurfaces.borderActive` | Focus border |
| textPrimary | `#231917` | `AppWarmText.primary` | Body / labels on light surfaces |
| textSecondary | `#53433F` | `AppWarmText.secondary` | Secondary labels |
| textMuted | `#85736E` | `AppWarmText.muted` | Hints / inactive |
| textDisabled | `#85736E` | `AppWarmText.disabled` | Disabled text |
| textOnScaffold | `#FFFFFF` | `AppWarmText.onScaffold` | Headings on coral |
| iconPrimary | `#231917` | `AppColors.light.iconPrimary` | Icons on light surfaces |
| primaryAction | `#FFFFFF` | `AppColors.light.primaryAction` | CTA background |
| onPrimaryAction | `#231917` | `AppColors.light.onPrimaryAction` | CTA label |

## Global Theme Changes

| File | Change |
|------|--------|
| `lib/app/theme/app_colors.dart` | Added `AppWarmSurfaces`, `AppWarmText`; refactored `AppColors.light` as canonical palette; `AppColors.dark` aliases `light`; backward-compatible `AppDarkSurfaces`/`AppDarkText` forwarding |
| `lib/app/theme/app_theme.dart` | Single warm `AppTheme.theme` with `Brightness.light` M3 ColorScheme; contrasting button roles; coral scaffold |
| `lib/app/theme/app_text_styles.dart` | Warm text colors |
| `lib/app/theme/app_theme_mode_controller.dart` | Default `ThemeMode.light` |
| `lib/app/app.dart` | Both `theme` and `darkTheme` use warm theme |
| `lib/app/router/main_shell_screen.dart` | Coral shell background |

## Feature Color Migration

| Feature | Scaffold | Cards | Containers | Inputs | Text | Borders | Status |
|---------|----------|-------|------------|--------|------|---------|--------|
| Auth | ✅ Coral | ✅ Peach | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Splash | ✅ | — | — | — | ✅ | — | CHANGED |
| Onboarding | ✅ | ✅ | ✅ | — | ✅ | ✅ | CHANGED |
| Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Services | ✅ | ✅ | ✅ | — | ✅ | ✅ | CHANGED |
| Activity | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Account (+ sub-screens) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Ride Booking | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Ride Tracking | ✅ | ✅ | ✅ | — | ✅ | ✅ | CHANGED |
| Payment | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Reserve | ✅ | ✅ | — | — | ✅ | ✅ | CHANGED |
| Rentals | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Intercity | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | CHANGED |
| Offers | ✅ | ✅ | — | — | ✅ | ✅ | CHANGED |

Semantic colors preserved per feature: success green, error red, warning amber, wallet green, gold badges, map markers, ride status colors.

## Feature Token Refactor (40 files)

| Status | Count |
|--------|-------|
| CHANGED | 40 |
| PRESERVED (semantic only) | Semantic hex values within tokens |

All `*_tokens.dart` files now reference `AppWarmSurfaces` / `AppWarmText` / `AppBrand` where applicable.

## Legacy Dark Colors Removed

Removed from non-semantic surfaces:

- `#050A12`, `#050A18`, `#060B14`, `#0A0E14`, `#0B0E14`, `#0B121E`, `#0A0E1A`, `#0A0E21`
- `#111827`, `#182235`, `#0D1523`, `#0D1117`
- `#2A3548`, `#2A3142`, `#30363D`, `#1F2937`
- `#2A211C` dark primary container
- `#000000` normal UI backgrounds

## Dark Colors Intentionally Preserved

| Color | Location | Reason |
|-------|----------|--------|
| `#80000000` | Theme scrim | Modal overlay |
| `#231917`, `#53433F`, `#85736E`, `#723520` | Text / icons | Warm dark foreground for readability |
| Semantic reds/greens/yellows | Feature tokens | Status / safety / payment meaning |
| Map / illustration colors | Rentals hero, intercity | Decorative semantic assets |

## Semantic Colors Preserved

- **Success:** `#16A34A`, `#22C55E`
- **Warning:** `#F59E0B`
- **Error / danger:** `#DC2626`, `#EF4444`
- **Wallet / ride green:** `#22C55E`
- **Gold / offer accents:** `#C9A227`, `#F59E0B`
- **Map / window blues:** Decorative only
- **Rating / stars:** Unchanged where present

## Validation Results

| Command | Result |
|---------|--------|
| `dart format lib test` | ✅ Passed |
| `flutter analyze` | ✅ No issues found |
| `flutter test` | ✅ 13 tests passed |
| `flutter build apk --debug` | ✅ Built successfully |

## Key Files Changed

**Global:** `app_colors.dart`, `app_theme.dart`, `app_text_styles.dart`, `app_theme_mode_controller.dart`, `app.dart`, `main_shell_screen.dart`

**Tokens:** All 40 `*_tokens.dart` files under `lib/features/`

**Widgets / screens:** Home, onboarding, ride booking, ride tracking, payment modal, cancel rental sheet, FAQ card, add parent guardian, login redirect

**Tooling:** `tool/migrate_tokens.py`, `FULL_APP_COLOR_MIGRATION_PLAN.md`

## Safety Confirmation

- ✅ No layout intentionally changed
- ✅ No spacing intentionally changed
- ✅ No typography intentionally changed
- ✅ No screen structure intentionally changed
- ✅ No widget order intentionally changed
- ✅ No copy intentionally changed
- ✅ No routes intentionally changed
- ✅ No navigation logic intentionally changed
- ✅ No API logic intentionally changed
- ✅ No Auth0 logic intentionally changed
- ✅ No Riverpod behavior intentionally changed
- ✅ No business functionality intentionally changed
