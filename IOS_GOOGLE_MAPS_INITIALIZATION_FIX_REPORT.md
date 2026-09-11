# iOS Google Maps Initialization Fix Report

## Status

**READY FOR IOS MAP RETEST**

## Problem

On a real iPhone, Ride Selection crashed when the Flutter `GoogleMap` widget created a native `GMSMapView`:

```
GMSServicesException:
Google Maps SDK for iOS must be initialized via
[GMSServices provideAPIKey:...] prior to use
```

GPS, reverse geocode, Places autocomplete, place details, `POST /routes/preview`, and booking quote already succeeded. Those use backend Maps APIs, not the iOS Maps SDK. The crash was isolated to native map view creation.

## Root cause

`AppDelegate` already imported `GoogleMaps` and attempted `GMSServices.provideAPIKey`, but the call never ran with a real key.

1. `Info.plist` has `GMSApiKey = $(GOOGLE_MAPS_IOS_API_KEY)`.
2. That build setting was not defined in xcconfig, so the built app’s `GMSApiKey` was an **empty string**.
3. `export GOOGLE_MAPS_IOS_API_KEY` on the Mac is **not** inherited by the iOS app process on a physical device.
4. AppDelegate treated empty / placeholder keys as a silent skip, so `provideAPIKey` was never called.
5. `google_maps_flutter_ios` then called `[GMSServices sharedServices]` when Ride Selection rendered `GoogleMap`, which throws if the SDK was not initialized.

This build’s processed plist confirmed the gap: `GMSApiKey` existed and was empty.

## Fix (iOS Maps init only)

No changes to booking, route preview, autocomplete, FCM, profile, history, Socket.IO, Android Maps, or backend Maps APIs.

### 1. Initialize before the Flutter map plugin

`ios/Runner/AppDelegate.swift`

- `import GoogleMaps` (already present).
- Resolve key from `Info.plist` `GMSApiKey` (xcconfig substitution), then `GOOGLE_MAPS_IOS_API_KEY` env.
- Reject empty / `$(GOOGLE_MAPS_IOS_API_KEY)` / `YOUR_*` placeholders.
- Call `GMSServices.provideAPIKey` in:
  - `application(_:didFinishLaunchingWithOptions:)`
  - `didInitializeImplicitFlutterEngine` **before** `GeneratedPluginRegistrant`
- Debug: `fatalError` with setup instructions if the key is missing.
- Release: log and skip (no hardcoded key).

`ios/Runner/SceneDelegate.swift`

- Call the same initializer in `scene(_:willConnectTo:options:)` **before** `super`, because UIScene launch can register Flutter plugins before `didFinishLaunching` returns.

### 2. Existing key/config pattern (no hardcoded key)

| Source | Role |
|--------|------|
| `Info.plist` `GMSApiKey` = `$(GOOGLE_MAPS_IOS_API_KEY)` | Runtime value AppDelegate reads |
| `ios/Flutter/MapsSecrets.xcconfig` (gitignored) | Build-time key, same idea as Android `local.properties` |
| `export GOOGLE_MAPS_IOS_API_KEY` | Written to `MapsSecrets.xcconfig` on `pod install`; also injected into the built plist |
| `ios/Flutter/MapsSecrets.xcconfig.example` | Template only |

`Debug.xcconfig` / `Release.xcconfig` now `#include? "MapsSecrets.xcconfig"`.

`ios/Flutter/inject_ios_maps_api_key.sh` runs in the Thin Binary phase and bakes a resolved key into the built `Info.plist` when xcconfig substitution left a placeholder. The key is never logged.

## Retest setup (required)

This machine had **no** `GOOGLE_MAPS_IOS_API_KEY` in the shell, xcconfig, or `local.properties`. Until a real **iOS Maps SDK** key (bundle id `com.example.ryduUser`) is provided, debug launches fail at init instead of later at `GoogleMap`.

```bash
echo "GOOGLE_MAPS_IOS_API_KEY=your_ios_maps_sdk_key" > ios/Flutter/MapsSecrets.xcconfig
# or: export GOOGLE_MAPS_IOS_API_KEY=your_ios_maps_sdk_key
```

Then:

```bash
flutter run -d 00008030-001270541E52802E
# if Xcode debug attach times out:
open ios/Runner.xcworkspace
# Product > Run, destination: R2A IT’s iPhone
```

Do not reuse the Android Maps key unless that Google Cloud key is also enabled for Maps SDK for iOS and this bundle id.

## Verification

| Check | Result |
|-------|--------|
| Scope limited to iOS Maps SDK init | Yes |
| `import GoogleMaps` + `provideAPIKey` before plugin / `GoogleMap` | Yes |
| Key from Info.plist / xcconfig / env, not hardcoded | Yes |
| Debug fails clearly on missing/placeholder key | Yes (`fatalError`) |
| Android Maps / backend Maps / autocomplete country | Unchanged |
| Xcode compile for device | **Succeeded** (`Xcode build done` 20.6s, `com.example.ryduUser`) |
| Built `GMSApiKey` | Present, **empty** (no local iOS key) |
| App launch + Ride Selection + `GoogleMap` on device | **Blocked** — Xcode `CONFIGURATION_BUILD_DIR` debug timeout, then `devicectl` install hung on the same iPhone (pre-existing device/Xcode attach issue) |

On-device UI path (select destination → route preview 200 → Ride Selection → map tiles, no `GMSServicesException`) is ready to retest after the iOS key is set and the app is launched from Xcode or a successful `flutter run`.

## Files touched (this fix)

- `ios/Runner/AppDelegate.swift`
- `ios/Runner/SceneDelegate.swift`
- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Release.xcconfig`
- `ios/Flutter/MapsSecrets.xcconfig.example`
- `ios/Flutter/inject_ios_maps_api_key.sh`
- `ios/Podfile` (env → `MapsSecrets.xcconfig`)
- `ios/Runner.xcodeproj/project.pbxproj` (invoke inject script)
- `.gitignore` (`ios/Flutter/MapsSecrets.xcconfig`)
- `env.example` (iOS key instructions)

## READY FOR IOS MAP RETEST
