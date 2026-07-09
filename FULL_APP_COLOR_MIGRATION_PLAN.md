# Full App Color Migration Plan

## Seed Color

| Property | Value |
|----------|-------|
| HEX | `#EF8561` |
| RGB | 239, 133, 97 |
| Flutter | `Color(0xFFEF8561)` |

## Current State (Dark Navy Theme)

| Role | Current HEX | Source |
|------|-------------|--------|
| Scaffold | `#050A12` | `AppDarkSurfaces.scaffold` |
| Card / surface | `#111827` | `AppDarkSurfaces.surface` |
| Elevated / input | `#182235` | `AppDarkSurfaces.inputSurface` |
| Container low | `#0D1523` | `AppDarkSurfaces.surfaceContainerLow` |
| Border | `#2A3548` | `AppDarkSurfaces.border` |
| Text primary | `#FFFFFF` | `AppDarkText.primary` |
| Text secondary | `#B8C0D4` | `AppDarkText.secondary` |
| Text muted | `#9CA3AF` | `AppDarkText.muted` |
| Primary container | `#2A211C` | `AppBrand.primaryContainer` (dark) |
| Theme brightness | `Brightness.dark` | Default `ThemeMode.dark` |

**Migration coverage:** 8/40 token files reference `AppDarkSurfaces`; 32 hardcode navy hex values; 47 lib files contain target dark hex literals.

## Target State (Warm Coral Light Theme)

Derived from `ColorScheme.fromSeed(seedColor: #EF8561, brightness: light)`.

| Role | Target HEX | M3 Reference |
|------|------------|--------------|
| Scaffold | `#EF8561` | Custom (seed primary) |
| Card surface | `#FFDBD0` | `primaryContainer` |
| Container elevated | `#FCEAE5` | `surfaceContainer` |
| Input surface | `#FFF1ED` | `surfaceContainerLow` |
| Input focused | `#FFFFFF` | `surfaceContainerLowest` |
| Selected surface | `#F7E4DF` | `surfaceContainerHigh` |
| Border subtle | `#E8D4CC` | Harmonized |
| Border | `#D8C2BB` | `outlineVariant` |
| Border active | `#EF8561` | seed primary |
| Text primary | `#231917` | `onSurface` |
| Text secondary | `#53433F` | `onSurfaceVariant` |
| Text muted | `#85736E` | `outline` |
| Text on scaffold | `#FFFFFF` | High contrast on coral |
| Icon primary | `#231917` | warm dark |
| Primary action bg | `#FFFFFF` | Contrasts coral scaffold |
| Primary action fg | `#231917` | warm dark |
| Theme brightness | `Brightness.light` | Global default |

## Semantic Colors (Preserved)

| Role | HEX | Notes |
|------|-----|-------|
| Success | `#22C55E` / `#16A34A` | Unchanged |
| Warning | `#F59E0B` | Unchanged |
| Error / danger | `#DC2626` | Unchanged |
| Ride status / map / payment | Feature-specific | Surrounding surfaces migrate only |

## Migration Strategy

### Phase A — Global foundation
1. Replace `AppDarkSurfaces` → `AppWarmSurfaces` with light seed values
2. Replace `AppDarkText` → `AppWarmText` with warm dark text
3. Update `AppBrand.primaryContainer` to `#FFDBD0`
4. Refactor `AppColors.light` as canonical palette; alias `AppColors.dark` = `AppColors.light`
5. Update `app_theme.dart` to light seed `ColorScheme`, contrasting button roles
6. Default `ThemeMode.light`; both `theme` and `darkTheme` use warm palette

### Phase B — Token files (40 files)
- Replace `AppDarkSurfaces` / `AppDarkText` references → `AppWarmSurfaces` / `AppWarmText`
- Replace hardcoded navy hex with `AppWarmSurfaces.*` / `AppWarmText.*`
- Unify alternate scaffolds (`060B14`, `0A0E14`, etc.) → `AppWarmSurfaces.scaffold`
- Add `textPrimary` / `textOnScaffold` roles where `white` served dual purpose
- Preserve semantic colors (success, error, gold, green, etc.)

### Phase C — Widget / screen hardcoded colors
- `main_shell_screen.dart`, `login_screen.dart`, ride booking screens, payment modals, bottom sheets
- Replace inline dark hex with warm surface tokens

### Phase D — Text on light cards
- Card/surface widgets: use `textPrimary` (warm dark) instead of `white`
- Scaffold-level headings: use `textOnScaffold` (white)

## Dark Colors Targeted for Removal

```
0xFF050A12  scaffold (navy)
0xFF050A18  scaffold variant
0xFF060B14  scaffold alternate
0xFF0A0E14  scaffold alternate
0xFF0B0E14  scaffold alternate
0xFF111827  card/surface
0xFF182235  input/elevated
0xFF0D1523  container low
0xFF2A3548  border
0xFF1F2937  border subtle
0xFF2A211C  dark primary container
```

## Files Not Changing Semantics

- `lib/react_code/` — out of scope
- Domain / data layers — no AppColors imports
- Auth0, API, Riverpod, routes — unchanged

## Validation

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```
