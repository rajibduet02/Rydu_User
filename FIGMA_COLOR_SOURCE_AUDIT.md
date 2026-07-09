# Figma Color Source Audit

## Reference Source

Primary design token file:

- `lib/react_code/src/styles/theme.css` — global CSS variables (`:root`)

Component-level verification:

| Component | File |
|-----------|------|
| Continue CTA | `lib/react_code/src/app/components/NameInputScreen.tsx` |
| Home screen + nav + Premium | `lib/react_code/src/app/components/HomeScreen.tsx` |
| Welcome / onboarding | `lib/react_code/src/app/components/WelcomeScreen.tsx` |
| Payment modal | `lib/react_code/src/app/components/PaymentMethodModal.tsx` |
| Wallet / gradients | `lib/react_code/src/app/components/WalletScreen.tsx` |

Secondary documentation (pre-coral migration mapping):

- `COLOR_HARMONIZATION_REPORT.md` — documents previous `#2F6BFF` brand family

## Exact Primary Blue

| Property | Value |
|----------|-------|
| HEX | `#2F6BFF` |
| RGB | 47, 107, 255 |
| Flutter | `Color(0xFF2F6BFF)` |
| Reference file | `lib/react_code/src/styles/theme.css` |
| Reference token | `--primary: #2F6BFF` |
| Reference component | `NameInputScreen.tsx` Continue button `from-[#2F6BFF] to-[#4D7DFF]` |

## Primary Blue Variants

| Role | HEX | Flutter | Reference file | Reference component / token |
|------|-----|---------|----------------|----------------------------|
| primary | `#2F6BFF` | `Color(0xFF2F6BFF)` | `theme.css` | `--primary` |
| primaryLight / hover | `#4D7DFF` | `Color(0xFF4D7DFF)` | `theme.css` | `--primary-hover`, `--chart-4` |
| primaryDark | `#2962FF` | `Color(0xFF2962FF)` | `COLOR_HARMONIZATION_REPORT.md` | Payment modal `blue`, pressed depth |
| onPrimary | `#FFFFFF` | `Color(0xFFFFFFFF)` | `theme.css` | `--primary-foreground` |
| primarySoft (20%) | `#332F6BFF` | `Color(0x332F6BFF)` | `HomeScreen.tsx` | `bg-[#2F6BFF]/20` nav active |
| primaryContainer | `#1A2F55` | `Color(0xFF1A2F55)` | `COLOR_HARMONIZATION_REPORT.md` | Blue selected/icon wells |
| primaryBorder (40%) | `#662F6BFF` | `Color(0x662F6BFF)` | `HomeScreen.tsx` | `border-[#2F6BFF]/40` |
| primaryGlow (30%) | `#4D2F6BFF` | `Color(0x4D2F6BFF)` | `HomeScreen.tsx` | `shadow-[#2F6BFF]/30` |
| ring / focus | `#2F6BFF` | `Color(0xFF2F6BFF)` | `theme.css` | `--ring` |

## Figma Background Colors

| Role | HEX | Reference |
|------|-----|-----------|
| background / scaffold | `#060B14` | `theme.css` `--background`, `HomeScreen.tsx` `bg-[#060B14]` |
| background secondary | `#0D1523` | `theme.css` `--background-secondary` |
| near-black variant | `#050A12` | Preserved in Flutter legacy screens (harmonization doc) |

## Figma Surface/Card Colors

| Role | HEX | Reference |
|------|-----|-----------|
| surface / card | `#111827` | `theme.css` `--surface`, `--card` |
| surface elevated | `#182235` | `theme.css` `--surface-elevated` |
| popover | `#182235` | `theme.css` `--popover` |

## Figma Input Colors

| Role | HEX | Reference |
|------|-----|-----------|
| input background | `#111827` | `theme.css` `--input-background` |
| field inner fill | `#182235` | `NameInputScreen.tsx` input `bg-[#182235]` |
| border | `#2A3548` | `theme.css` `--border` |
| focus border | `#2F6BFF` | `NameInputScreen.tsx` `focus:border-[#2F6BFF]` |

## Figma Text Colors

| Role | HEX | Reference |
|------|-----|-----------|
| text primary | `#FFFFFF` | `theme.css` `--foreground` |
| text secondary | `#B8C0D4` | `theme.css` `--muted-foreground` |
| muted border-as-label | `#2A3548` | `theme.css` `--muted` (border tone in CSS) |

## Figma Navigation Colors

| Role | HEX | Reference |
|------|-----|-----------|
| nav surface | `#111827` @ 95% + blur | `HomeScreen.tsx` `bg-[#111827]/95` |
| nav border | `#2A3548` | `HomeScreen.tsx` |
| active icon | `#2F6BFF` | `HomeScreen.tsx` `text-[#2F6BFF]` |
| active label | `#2F6BFF` | `HomeScreen.tsx` |
| active indicator bg | `#2F6BFF` @ 20% | `HomeScreen.tsx` `bg-[#2F6BFF]/20` |
| inactive icon/label | `#B8C0D4` | `HomeScreen.tsx` |

## Figma Semantic Colors (preserve — not primary blue)

| Role | HEX | Reference |
|------|-----|-----------|
| CNG / success green | `#22C55E` → `#16A34A` | `HomeScreen.tsx` CNG card gradient |
| discount badge red | `#DC2626` / `red-600` | `HomeScreen.tsx` service discount badges |
| warning | `#F59E0B` | `theme.css` `--warning` |
| destructive | `#d4183d` | `theme.css` `--destructive` |
| cash green | `#22C55E` | `PaymentMethodModal.tsx` |

## Component Color Trace

### Continue CTA (Name screen)

- Reference: `NameInputScreen.tsx` line 84
- Exact: `bg-gradient-to-r from-[#2F6BFF] to-[#4D7DFF]`, `text-white`

### Home selected icon

- Reference: `HomeScreen.tsx` line 215
- Exact: `text-[#2F6BFF]`

### Home selected indicator

- Reference: `HomeScreen.tsx` line 210
- Exact: `bg-[#2F6BFF]/20`

### Premium card

- Reference: `HomeScreen.tsx` line 166
- Exact: `bg-gradient-to-br from-[#2F6BFF] to-[#4D7DFF]`

### Payment selected radio / switch ON

- Reference: `PaymentMethodModal.tsx`
- Exact: `#2F6BFF` fill, white inner dot

## Coral Migration Mapping (to restore)

| Current coral role | Restore to |
|------------------|------------|
| `AppBrand.seed` `#EF8561` | `#2F6BFF` |
| `primaryLight` `#F5A882` | `#4D7DFF` |
| `primaryDark` `#D66B45` | `#2962FF` |
| `primarySoft` `0x33EF8561` | `0x332F6BFF` |
| `primaryContainer` `#2A211C` | `#1A2F55` |
| `primaryBorder` coral alpha | `0x662F6BFF` |
| `primaryGlow` coral alpha | `0x4D2F6BFF` |
| `onPrimary` `#111827` (coral contrast) | `#FFFFFF` (Figma blue CTA) |
