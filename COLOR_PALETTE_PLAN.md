# Color Palette Harmonization Plan

## Objective

Migrate the RYD U Passenger Flutter app from the legacy blue brand palette to **#EF8561** (warm coral/peach) as the primary brand anchor, while preserving dark-theme character, semantic colors, and all UI structure.

---

## Current Brand Palette (Audit)

| Role | HEX | Flutter | Usage |
|------|-----|---------|-------|
| Primary | `#2F6BFF` | `Color(0xFF2F6BFF)` | CTAs, accents, nav active, links |
| Primary Light | `#4D7DFF` | `Color(0xFF4D7DFF)` | Gradient ends, soft accents |
| Primary Dark | `#2962FF` | `Color(0xFF2962FF)` | Pressed / gradient starts |
| Secondary blue | `#3B82F6` | `Color(0xFF3B82F6)` | Activity tab, safety center |
| Services accent | `#2E5BFF` | `Color(0xFF2E5BFF)` | Services hub |
| Welcome accent | `#2962FF` | `Color(0xFF2962FF)` | Onboarding |
| Splash dots | `#304FFE` | `Color(0xFF304FFE)` | Loading indicator |
| Soft blue text | `#9EB4FF` | `Color(0xFF9EB4FF)` | FAQ/support icons |
| Label blue | `#7EB0FF` | `Color(0xFF7EB0FF)` | Category labels |
| Security accent | `#5D8DFF` | `Color(0xFF5D8DFF)` | Security screen |
| Selected bg (blue tint) | `#1A2F55` | `Color(0xFF1A2F55)` | Selected cards, place wells |
| Nav active bg | `#332F6BFF` | `Color(0x332F6BFF)` | Bottom nav bubble (20%) |
| Alpha brand fills | `#1A2F6BFF`, `#4D2F6BFF`, `#662F6BFF`, `#802F6BFF` | Various | Containers, borders, glows |

---

## Current Non-Brand Palette (Preserved)

| Role | HEX | Notes |
|------|-----|-------|
| Background base | `#050A12`, `#060B14`, `#0A0E14` | Dark navy — **preserve** |
| Surface | `#111827` | Card base — **preserve** |
| Surface alt | `#182235`, `#0D1523` | Elevated/inner — **preserve** |
| Border | `#2A3548` | Neutral subtle — **preserve** |
| Text primary | `#FFFFFF` | **preserve** |
| Text secondary | `#B8C0D4` | **preserve** |
| Text muted | `#9CA3AF` | **preserve** |
| Success | `#22C55E` | Semantic — **preserve** |
| Warning | `#F59E0B` | Semantic — **preserve** |
| Error/Danger | `#DC2626`, `#EF4444` | Semantic — **preserve** |
| Map/ride/payment semantics | Various greens, reds, purples | Feature-specific — **preserve** |

---

## Background Evaluation

Current dark backgrounds (`#050A12`, `#060B14`, `#111827`) are **low-saturation neutral navy**. They provide strong contrast with warm coral and do **not** carry old blue brand tint. **No background changes required.**

---

## Proposed Harmonized Brand Palette

Derived from `#EF8561` (H≈16°, S≈83%, L≈66%) using controlled lightness/chroma adjustments on the same hue family.

| Role | HEX | Flutter | Purpose |
|------|-----|---------|---------|
| **primary** | `#EF8561` | `Color(0xFFEF8561)` | Main brand accent, CTAs, active icons |
| **primaryLight** | `#F5A882` | `Color(0xFFF5A882)` | Gradient highlights, soft accent text |
| **primaryDark** | `#D66B45` | `Color(0xFFD66B45)` | Pressed states, gradient depth |
| **primarySoft** | `#EF8561` @ 20% | `Color(0x33EF8561)` | Nav active bg, subtle fills |
| **primaryContainer** | `#2A211C` | `Color(0xFF2A211C)` | Selected card bg, icon wells (warm dark) |
| **primaryBorder** | `#EF8561` @ 40% | `Color(0x66EF8561)` | Selected borders, sheet tops |
| **primaryGlow** | `#EF8561` @ 30% | `Color(0x4DEF8561)` | BoxShadow / focus halo |
| **onPrimary** | `#111827` | `Color(0xFF111827)` | Text on primary buttons (better contrast than white) |

### Light theme variants

| Role | HEX | Notes |
|------|-----|-------|
| primaryContainer (light) | `#FFF4EF` | Very subtle warm tint for light mode |
| primaryBorder (light) | `#99EF8561` | Slightly stronger for light surfaces |
| All other brand tones | Same as dark | Primary anchor unchanged |

---

## Replacement Mapping

| Old value | New value | Context |
|-----------|-----------|---------|
| `#2F6BFF` | `#EF8561` / `AppColors.dark.primary` | All brand accents |
| `#4D7DFF` | `#F5A882` / `primaryLight` | Gradient ends, accentSoft |
| `#2962FF`, `#3B82F6`, `#2E5BFF`, etc. | `#EF8561` or `#D66B45` | Legacy brand blues |
| `#9EB4FF`, `#7EB0FF`, `#5D8DFF` | `#F5A882` or `#E8A088` | Soft brand text/icons |
| `#1A2F55` | `#2A211C` / `primaryContainer` | Blue-tinted selected bg |
| `#332F6BFF` | `#33EF8561` / `primarySoft` | Nav active background |
| `#1A2F6BFF` | `#1AEF8561` | 10% primary fill |
| `#4D2F6BFF` | `#4DEF8561` | 30% primary border |
| `#662F6BFF` | `#66EF8561` | 40% primary border |
| `#802F6BFF` | `#80EF8561` | 50% primary border |
| `#304FFE` (splash dots) | `#EF8561` | Brand loading dots |
| White on primary buttons | `#111827` / `onPrimary` | Improved readability on coral |

---

## Semantic Colors — Protected (No Change)

- Success greens (`#22C55E`, `#16A34A`, `#10B981`)
- Warning/ gold (`#F59E0B`, `#C9A227`)
- Error/emergency reds (`#DC2626`, `#EF4444`)
- Ride status, payment credit/debit, map markers
- Saved place types: orange, pink, green (non-brand categories)
- Rental illustration purples (decorative hero art)
- Help center FAQ purple (`#8B5CF6`) — feature semantic
- Safety center ride purple — feature semantic
- Offers gold/red badges

---

## Implementation Strategy

1. **Centralize** in `lib/app/theme/app_colors.dart` — add tonal fields to `AppColors` dark/light instances.
2. **Update** `app_theme.dart` — `onPrimary`, ColorScheme, button foregrounds.
3. **Harmonize** all 39 `*_tokens.dart` files — reference `AppColors.dark.*` for brand roles.
4. **Clean up** hardcoded brand colors in widgets (`driver_found_screen`, `payment_method_modal`, `saved_place_card`, etc.) and data layer mock ARGB values.
5. **Preserve** layout, spacing, typography, logic — color values only.

---

## Gradient Harmonization

All brand gradients currently use `[#2F6BFF, #4D7DFF]` → rebalance to `[#EF8561, #F5A882]` or `[#D66B45, #EF8561]` preserving direction/stops.

---

## Files to Change (Summary)

- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_text_styles.dart`
- All 39 `*_tokens.dart` under `lib/features/`
- Widget hardcodes: ~10 files
- Data mocks: `inbox_message_model.dart`, `services_local_datasource.dart`
