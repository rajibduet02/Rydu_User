# Color Harmonization Report

## New Primary Brand Color

HEX: #EF8561  
RGB: 239, 133, 97  
Flutter: `Color(0xFFEF8561)`

---

## Previous Brand Palette

| Role | HEX | Where used |
|------|-----|------------|
| Primary | `#2F6BFF` | AppColors, all feature accents, CTAs, nav |
| Primary Light | `#4D7DFF` | Gradients, accentSoft, glows |
| Primary Dark | `#2962FF` | Welcome/onboarding, payment modal |
| Activity/Safety blue | `#3B82F6` | Activity tab, safety center |
| Services accent | `#2E5BFF` | Services hub |
| Auth button blues | `#427DFF`, `#3D7BFF`, `#4D7CFF` | Auth flow buttons/links |
| Soft blue text | `#9EB4FF`, `#7EB0FF`, `#5D8DFF` | FAQ, support, security |
| Splash dots | `#304FFE` | Splash loading indicator |
| Blue selected bg | `#1A2F55` | Selected cards, saved place wells |
| Alpha brand fills | `#332F6BFF`, `#1A2F6BFF`, `#4D2F6BFF`, etc. | Nav bubbles, borders, containers |

---

## Approved Harmonized Palette

| Role | HEX | Flutter value | Purpose |
|------|-----|---------------|---------|
| primary | `#EF8561` | `AppBrand.primary` / `Color(0xFFEF8561)` | Main brand accent, CTAs, active icons |
| primaryLight | `#F5A882` | `AppBrand.primaryLight` | Gradient highlights, soft accents |
| primaryDark | `#D66B45` | `AppBrand.primaryDark` | Pressed states, gradient depth |
| primarySoft | `#EF8561` @ 20% | `AppBrand.primarySoft` / `Color(0x33EF8561)` | Nav active bg, subtle fills |
| primaryContainer | `#2A211C` | `AppBrand.primaryContainer` | Warm dark selected/icon wells |
| primaryBorder | `#EF8561` @ 40% | `AppBrand.primaryBorder` / `Color(0x66EF8561)` | Selected borders, sheet tops |
| primaryGlow | `#EF8561` @ 30% | `AppBrand.primaryGlow` / `Color(0x4DEF8561)` | BoxShadow / focus halo |
| onPrimary | `#111827` | `AppBrand.onPrimary` | Text on primary buttons (better contrast on coral) |

**Backgrounds:** Preserved (`#050A12`, `#060B14`, `#111827`, etc.) — no changes.  
**Surfaces:** Preserved — hierarchy unchanged.  
**Neutral borders:** Preserved (`#2A3548`) — only brand-active borders harmonized.

---

## Global Theme Changes

| File | Changes |
|------|---------|
| `lib/app/theme/app_colors.dart` | Added `AppBrand` static tonal system; updated `AppColors.dark` / `.light` palettes |
| `lib/app/theme/app_theme.dart` | `onPrimary` uses `AppBrand.onPrimary`; filled/elevated button foregrounds updated |
| `lib/app/theme/app_text_styles.dart` | Label color references `AppBrand.primary` |

---

## Background Harmonization

**Preserved.** Existing dark navy backgrounds (`#050A12`, `#050A18`, `#060B14`, `#0A0E14`, `#111827`) are low-saturation neutral darks that contrast well with `#EF8561`. No orange-tinted or brown screen backgrounds were introduced.

---

## Surface Harmonization

**Preserved** for standard surfaces. One brand-tinted surface role was rebalanced:

| Old | New | Context |
|-----|-----|---------|
| `#1A2F55` (blue-tinted) | `#2A211C` (`primaryContainer`) | Report issue selected bg, saved place "blue" icon well |

---

## Border Harmonization

| Role | Old | New |
|------|-----|-----|
| Unread inbox border | `#802F6BFF` | `#80EF8561` |
| Secure card border | `#4D2F6BFF` | `#4DEF8561` |
| Rental sheet top | `#662F6BFF` | `#66EF8561` |
| Selected ride/rental | `#2F6BFF` | `#EF8561` |
| Neutral borders | `#2A3548` | **Unchanged** |

---

## Feature Token Audit

All 39 `*_tokens.dart` files were reviewed.

### CHANGED (brand colors harmonized)

| Token file | Brand roles updated |
|------------|---------------------|
| `auth_screen_tokens.dart` | accent, accentEnd, link → `AppBrand.*` |
| `name_input_tokens.dart` | borderFocused, buttonBlue, buttonBlueEnd |
| `otp_tokens.dart` | borderFocused, accent, accentEnd |
| `terms_screen_tokens.dart` | link, buttonBlue, buttonBlueEnd |
| `splash_tokens.dart` | dotBlue → primary |
| `welcome_tokens.dart` | accent, accentSoft, rideCardGlow |
| `home_screen_tokens.dart` | accent, accentSoft, navActiveBg → `AppBrand.*` |
| `services_screen_tokens.dart` | accent, navActiveBg → `AppBrand.*` |
| `activity_screen_tokens.dart` | accent, navActiveBg → `AppBrand.*` |
| `ride_booking_tokens.dart` | accent → `AppBrand.primary` |
| `finding_driver_tokens.dart` | accent, accentLight |
| `intercity_tokens.dart` | accent |
| `reserve_tokens.dart` | accentBlue |
| `rentals_tokens.dart` | *(PRESERVED — no brand roles)* |
| `rental_ride_tokens.dart` | borderSelected |
| `rental_time_tokens.dart` | sliderActive, sliderActiveEnd |
| `rental_driver_found_tokens.dart` | accent, accentAlt, reminderFill/Border |
| `add_card_tokens.dart` | accent, accentEnd, secureFill/Border |
| `account_screen_tokens.dart` | accent, accentSoft, navActiveBg → `AppBrand.*` |
| `wallet_tokens.dart` | accent, accentSoft |
| `settings_screen_tokens.dart` | accent |
| `saved_places_tokens.dart` | accent |
| `inbox_tokens.dart` | accent, borderUnread |
| `profile_details_tokens.dart` | accent |
| `security_screen_tokens.dart` | accent, protectionCircle; accentDark → warm `#4A2E24` |
| `help_center_tokens.dart` | accent, accentSoft, liveChat |
| `faqs_tokens.dart` | accent, accentSolid, expandAccent, categoryLabel, supportHeader |
| `live_chat_tokens.dart` | userBubble, accent |
| `call_support_tokens.dart` | accent, accentSolid, secureLabel |
| `email_support_tokens.dart` | accent |
| `report_lost_item_tokens.dart` | accent, accentSolid |
| `report_ride_issue_tokens.dart` | accent, accentSolid, selectedBorder, selectedBg |
| `safety_resources_tokens.dart` | accent, accentSolid |
| `safety_center_tokens.dart` | accent, accentDeep, accentSoft |
| `offers_tokens.dart` | *(PRESERVED — gold/red semantic badges only)* |
| `family_*` / `invite_teen_tokens.dart` | *(PRESERVED — neutral family flow)* |
| `privacy_and_data_tokens.dart` | *(PRESERVED — no brand roles)* |

### PRESERVED (semantic / non-brand)

- Success greens, warning golds, error/emergency reds across all features
- Map/ride/payment status colors
- Offers gold/red badge system
- Rental hero illustration purples (`personHead`, etc.)
- Help center FAQ purple (`#8B5CF6`)
- Safety center ride purple (`#8B5CF6`)
- Saved place color types: orange, pink, green
- Intercity offer green gradients

---

## Old Brand Accent Cleanup

Removed from all `lib/**/*.dart` production code:

- `#2F6BFF`, `#4D7DFF`, `#2962FF`, `#3B82F6`, `#2E5BFF`
- `#427DFF`, `#3D7BFF`, `#448AFF`, `#4D7CFF`, `#5D8DFF`, `#2D70F5`, `#304FFE`
- `#9EB4FF`, `#7EB0FF`, `#4B8BFF`
- All alpha variants of old blue brand (`#332F6BFF`, `#1A2F6BFF`, etc.)
- Blue-tinted selected background `#1A2F55` → warm `#2A211C`

**Remaining old blues:** `lib/react_code/` (React reference prototypes only — not part of the Flutter runtime app).

---

## Semantic Colors Preserved

| Category | Colors kept |
|----------|-------------|
| Success | `#22C55E`, `#16A34A`, `#10B981`, `#3DDC97` |
| Warning | `#F59E0B`, `#C9A227` |
| Error/Emergency | `#DC2626`, `#EF4444` |
| Map/Ride | Green active driver, bolt orange `#FF6B2C` |
| Payment | Cash green, credit/debit semantics |
| Ratings | Gold star tones |
| Feature purples | FAQ `#8B5CF6`, rental illustration purples |

---

## Gradient Harmonization

| Location | Old stops | New stops |
|----------|-----------|-----------|
| Auth CTA buttons | `#427DFF` → `#4D7DFF` | `#EF8561` → `#F5A882` |
| OTP / Terms buttons | blue gradient | primary → primaryLight |
| Driver info card / driver found | `#2F6BFF` → `#4D7DFF` | `#EF8561` → `#F5A882` |
| Wallet balance card | brand blue gradient | primary → primaryLight |
| Card preview / add card | brand blue gradient | primary → primaryLight |
| Welcome ride card glow | `#2962FF` | `#D66B45` (primaryDark) |
| Rental time slider | `#3B82F6` → `#4D7DFF` | `#EF8561` → `#F5A882` |
| Settings footer brand text | `#2F6BFF` | `#EF8561` |
| Live chat header gradient | `#2F6BFF` | `#EF8561` |

Semantic gradients (intercity offer green, promo green) **unchanged**.

---

## Glow and Shadow Harmonization

Brand-derived glows now use primary tonal alpha via token values or `.withValues(alpha:)` on harmonized accent colors:

- Ride option card selected shadow → `accent.withValues(alpha: 0.2)`
- Home bottom nav accent shadow → `accent.withValues(alpha: 0.08)` / `0.35`
- Auth button shadows → primary-based alpha preserved
- Wallet/card preview `shadow-[brand]/30` equivalents → primary glow alpha

Non-brand black shadows **unchanged**.

---

## Validation

| Command | Result |
|---------|--------|
| `dart format lib test` | **Passed** — formatted successfully (note: many files received formatting-only line-wrap changes from the formatter) |
| `flutter analyze` | **Passed** — `No issues found!` |
| `flutter test` | **Passed** — `12 tests passed` |
| `flutter build apk --debug` | **Passed** — `Built build\app\outputs\flutter-apk\app-debug.apk` |

---

## Files Changed

### Core theme
- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_text_styles.dart`

### Feature tokens (brand colors)
- All token files listed in **CHANGED** section above (35 files with brand color updates)

### Widgets / data (hardcoded brand cleanup)
- `lib/features/account/presentation/widgets/saved_place_card.dart`
- `lib/features/account/presentation/widgets/settings_footer.dart`
- `lib/features/account/presentation/screens/live_chat_support_screen.dart`
- `lib/features/account/data/models/inbox_message_model.dart`
- `lib/features/services/data/datasources/services_local_datasource.dart`
- `lib/features/payment/presentation/widgets/payment_method_modal.dart`
- `lib/features/ride_tracking/presentation/screens/driver_found_screen.dart`
- `lib/features/ride_tracking/presentation/widgets/driver_info_card.dart`
- `lib/features/rentals/presentation/widgets/cancel_rental_bottom_sheet.dart`

### Documentation
- `COLOR_PALETTE_PLAN.md` (new)
- `COLOR_HARMONIZATION_REPORT.md` (new)

### Formatting-only
- `dart format` may have applied line-wrap formatting across additional `lib/` and `test/` files without functional changes.

### Intentionally excluded
- `lib/react_code/**` — React design reference, not Flutter runtime

---

## Functional Safety Confirmation

- No UI layout intentionally changed
- No spacing intentionally changed
- No typography intentionally changed
- No widget structure intentionally changed
- No copy intentionally changed
- No route intentionally changed
- No navigation logic intentionally changed
- No API logic intentionally changed
- No authentication logic intentionally changed
- No business functionality intentionally changed

---

## Architecture Note

`AppBrand` was added in `app_colors.dart` as a static const holder for the brand tonal system. Feature tokens reference `AppBrand.primary`, `AppBrand.primaryLight`, etc. Theme instances (`AppColors.dark` / `.light`) mirror these values for `ThemeData` / `ColorScheme` integration.
