# Activity Bottom Sheet Fix Report

## Problem

On the Activity screen, opening the **"Filter by..."** bottom sheet caused the lower section of the sheet (Services chips and Apply button) to render underneath the persistent floating bottom navigation bar.

Users could not fully see or tap the bottom filter content because the custom nav overlays branch content via a `Stack` in `MainShellScreen`.

## Root Cause

**Combination of B + C + E:**

1. **Floating navigation overlay** — `MainShellScreen` renders `HomeBottomNav` in a `Stack`/`Positioned` layer above the branch `navigationShell`, not in `Scaffold.bottomNavigationBar`.

2. **Missing nav reserved space** — `ActivityFilterBottomSheet` only applied `16 + MediaQuery.paddingOf(context).bottom` (system inset). It did not reserve space for the ~150px floating nav clearance already defined in `ShellScrollPadding.tabScrollBottom`.

3. **SafeArea insufficient** — `SafeArea` handles device/system insets only; it does not account for the custom floating navigation bar height/offset.

4. **No max-height constraint** — The modal sheet could grow to the screen bottom with no height cap relative to the nav overlay, so bottom content sat behind the nav even though `SingleChildScrollView` was present.

The sheet is correctly opened from the branch navigator (not root), keeping the nav visible — the issue was layout padding, not navigator scope.

## Fix Applied

### 1. Bottom reserved space (`activity_filter_bottom_sheet.dart`)

- Imported `ShellScrollPadding` (same source used by Activity scroll content).
- Replaced `16 + systemBottomInset` with `ShellScrollPadding.tabScrollBottom(context)` for bottom content padding.
- Set `SafeArea(bottom: false)` to avoid double-counting the system inset while using the shared clearance constant.

### 2. Sheet height constraint (`activity_screen.dart`)

- Wrapped the sheet in `ConstrainedBox` with:
  `maxHeight: screenHeight * 0.88 - ShellScrollPadding.tabScrollBottom(ctx)`
- Preserves the existing top offset (`h * 0.12`) and ensures content scrolls within the visible area above the nav.

### 3. Shared layout documentation (`shell_scroll_padding.dart`)

- Extracted `floatingNavigationClearance()` semantic helper (150px — matches existing tab scroll behavior).
- Documented alignment with `MainShellScreen` / `HomeBottomNav` layout.

## Navigation Behavior

The persistent bottom navigation bar **remains visible** while the filter sheet is open. The sheet is not presented on the root navigator. Content is padded and constrained to sit above the nav reserved area.

## Files Changed

| File | Change |
|------|--------|
| `lib/features/activity/presentation/widgets/activity_filter_bottom_sheet.dart` | Nav clearance bottom padding |
| `lib/features/activity/presentation/screens/activity_screen.dart` | Max-height constraint for sheet |
| `lib/app/router/shell_scroll_padding.dart` | Semantic `floatingNavigationClearance()` helper |

## Validation

| Command | Result |
|---------|--------|
| `dart format lib test` | ✅ Passed |
| `flutter analyze` | ✅ No issues |
| `flutter test` | ✅ 13 tests passed |
| `flutter build apk --debug` | ✅ Built successfully |

## Safety Confirmation

- ✅ No colors changed
- ✅ No Activity UI redesign
- ✅ No navigation bar design changed
- ✅ No filter logic changed
- ✅ No routes changed
- ✅ No business logic changed
- ✅ Chip layout, typography, and spacing preserved (only bottom safe area adjusted)

## Manual Verification Checklist

1. Open Activity → tap filter icon
2. Confirm nav bar remains visible
3. Confirm Category and Services chips fully visible
4. Confirm Apply button visible and tappable above nav
5. Scroll sheet on smaller device — content reachable
6. Close/reopen sheet — behavior unchanged
