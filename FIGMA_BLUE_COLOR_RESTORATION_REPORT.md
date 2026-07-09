# Figma Blue Color Restoration Report

## Incorrect Color Removed

| Property | Value |
|----------|-------|
| HEX | `#EF8561` |
| RGB | 239, 133, 97 |
| Flutter | `Color(0xFFEF8561)` |

All coral-derived brand tones (`#F5A882`, `#D66B45`, `0x33EF8561`, `#2A211C` warm container, etc.) were removed from application UI code.

## Exact Figma Primary Blue

| Property | Value |
|----------|-------|
| HEX | `#2F6BFF` |
| RGB | 47, 107, 255 |
| Flutter | `Color(0xFF2F6BFF)` / `AppBrand.primary` |

## Source of Exact Blue

| Item | Value |
|------|-------|
| Reference file | `lib/react_code/src/styles/theme.css` |
| Reference token | `--primary: #2F6BFF` |
| Reference component | `NameInputScreen.tsx` Continue gradient `from-[#2F6BFF] to-[#4D7DFF]` |

## Figma Blue Tonal Roles

| Role | HEX | Flutter value | Reference source |
|------|-----|---------------|------------------|
| primary | `#2F6BFF` | `AppBrand.primary` | `theme.css` `--primary` |
| primaryLight | `#4D7DFF` | `AppBrand.primaryLight` | `theme.css` `--primary-hover` |
| primaryDark | `#2962FF` | `AppBrand.primaryDark` | `COLOR_HARMONIZATION_REPORT.md` / payment depth |
| onPrimary | `#FFFFFF` | `AppBrand.onPrimary` | `theme.css` `--primary-foreground` |
| primarySoft | `#332F6BFF` | `AppBrand.primarySoft` | `HomeScreen.tsx` nav `bg-[#2F6BFF]/20` |
| primaryContainer | `#1A2F55` | `AppBrand.primaryContainer` | Pre-migration blue selected wells |
| primaryBorder | `#662F6BFF` | `AppBrand.primaryBorder` | `HomeScreen.tsx` `border-[#2F6BFF]/40` |
| primaryGlow | `#4D2F6BFF` | `AppBrand.primaryGlow` | `HomeScreen.tsx` `shadow-[#2F6BFF]/30` |

## Background Restoration

| Role | HEX | Source |
|------|-----|--------|
| scaffold | `#060B14` | `theme.css` `--background`, `HomeScreen.tsx` |
| surface container low | `#0D1523` | `theme.css` `--background-secondary` |
| surface / card | `#111827` | `theme.css` `--surface` |
| input / elevated | `#182235` | `theme.css` `--surface-elevated` |
| border | `#2A3548` | `theme.css` `--border` |

## Surface Restoration

| Role | HEX |
|------|-----|
| card | `#111827` |
| container / input | `#182235` |
| selected brand well | `#1A2F55` |
| modal / sheet | `#111827` |

## Home Screen Verification

| Element | Restored color | Reference |
|---------|----------------|-----------|
| Continue / primary CTA blue | `#2F6BFF` → `#4D7DFF` gradient | `NameInputScreen.tsx` |
| Home selected navigation | `#2F6BFF` icon + `#332F6BFF` bg | `HomeScreen.tsx` |
| Premium card | `#2F6BFF` → `#4D7DFF` gradient | `HomeScreen.tsx` line 166 |
| CNG card | `#22C55E` → `#16A34A` | **PRESERVED** |
| Discount badges | `#DC2626` / red-600 | **PRESERVED** |

## Auth Color Restoration

| Screen | Change |
|--------|--------|
| Sign In / Register | Dark navy scaffold (`AppDarkSurfaces.scaffold`), default dark fields |
| Name input / OTP / Terms | Focus borders + CTA blues → `AppBrand.primary` / `primaryLight` |
| Continue button | Blue gradient tokens via `NameInputTokens.buttonBlue` |

## Activity Color Restoration

| Element | Color | Notes |
|---------|-------|-------|
| Filter selected chips | White bg + dark text | Matches `ActivityScreen.tsx` reference |
| Apply button | White bg + dark text | Matches reference |
| Nav active | `AppBrand.primary` | Via `ActivityScreenTokens` |
| Layout fix | `ShellScrollPadding` | **PRESERVED** |

## Payment Color Restoration

| Element | Color |
|---------|-------|
| Modal background | `#060B14` |
| Selected radio / switch ON | `#2F6BFF` |
| Personal/Business tabs | White selected bg + dark text (logic preserved) |
| Cash green | `#22C55E` **PRESERVED** |

## Feature Token Audit

36 token/widget files updated via `tool/restore_figma_blue.py` plus global theme files.

All `*_tokens.dart` files referencing `AppBrand.*` now resolve to Figma blue automatically.

Representative **CHANGED** files:

- `app_colors.dart`, `app_theme.dart`
- `home_screen_tokens.dart`, `welcome_tokens.dart`, `splash_tokens.dart`
- `name_input_tokens.dart`, `otp_tokens.dart`, `terms_screen_tokens.dart`
- All account/auth/payment/rentals/ride_tracking feature accent tokens
- `payment_method_modal.dart`, `driver_info_card.dart`, `settings_footer.dart`
- `services_local_datasource.dart`, `inbox_message_model.dart`

**PRESERVED** semantic tokens: `promoGreenStart/End`, `discountRed`, `cashGreen`, warning/danger/success colors.

## Remaining #EF8561 Occurrences

No accidental `#EF8561` application brand occurrences remain in `lib/` or `test/`.

Historical migration reports (`COLOR_HARMONIZATION_REPORT.md`, etc.) still document the old coral migration for audit purposes only.

Unused file `auth_light_tonal_tokens.dart` still contains peach surface literals but is **not referenced** by any screen after dark auth restoration.

## Functional Fixes Preserved

| Fix | Status |
|-----|--------|
| Personal selection mapping | **PRESERVED** |
| Business selection mapping | **PRESERVED** |
| RYD U balance switch logic | **PRESERVED** |
| Activity sheet overlap / nav spacing | **PRESERVED** |
| Auth / API / session / router logic | **UNCHANGED** |

## Validation Results

| Command | Result |
|---------|--------|
| `dart format lib test` | **PASS** |
| `flutter analyze` | **PASS** — No issues found |
| `flutter test` | **PASS** — 13/13 tests |
| `flutter build apk --debug` | **PASS** |

## Files Changed

### Global theme
- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_theme.dart`

### Tooling
- `tool/restore_figma_blue.py` (new)

### Documentation
- `FIGMA_COLOR_SOURCE_AUDIT.md` (new)

### Feature files (36 updated by restoration script)
Account, auth, payment, rentals, reserve, ride_tracking, services, splash tokens/widgets/data files — see `tool/restore_figma_blue.py` output.

## Safety Confirmation

- No business logic intentionally changed
- No API logic intentionally changed
- No Auth0 logic intentionally changed
- No Riverpod behavior intentionally changed
- No navigation logic intentionally changed
- No routes intentionally changed
- No screen layout intentionally changed
- No spacing intentionally changed
- No typography intentionally changed
- **Color/theme restoration only**
