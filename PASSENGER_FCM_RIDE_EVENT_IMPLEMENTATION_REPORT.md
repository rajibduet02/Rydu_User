# Passenger FCM Ride-Event Implementation Report

**Scope:** Passenger Flutter app only (`Rydu_User`). Backend and Driver were not modified.  
**Date:** 19 August 2026

**Final status:** IMPLEMENTATION COMPLETE — FIREBASE CONFIG REQUIRED FOR DEVICE QA

`google-services.json` is not in this repo and was **not fabricated**. Code, analyzer, unit tests, and debug APK build succeed without it. Real-device FCM QA cannot start until the Android Firebase app for `com.rydu.user` is added.

Booking creation, `RideBookingController` state machine, Socket.IO handlers, active restore, Ride History, recording consent, profile/account, payment, and logout architecture were not redesigned. FCM is wake-up + token plumbing that hydrates existing REST.

---

## Architecture (unchanged contract)

| Layer | Owner |
|---|---|
| Foreground realtime | Socket.IO → existing `RideBookingController` |
| Background / locked / terminated | FCM notification + data (OS tray) |
| Authoritative recovery | `GET /bookings/active` and `GET /bookings/:id` |

Tap flow: session restore → REST hydrate → existing live ride or Ride Details. Payload is never source of truth.

---

## Firebase setup

| Item | State |
|---|---|
| `firebase_core` `^4.13.0` | Added |
| `firebase_messaging` `^16.5.0` | Added |
| `flutter_local_notifications` `^22.3.0` | Added (channel only; not used to re-display OS tray) |
| `permission_handler` | **Not** added; Android 13 uses `FirebaseMessaging.requestPermission` |
| `Firebase.initializeApp()` | `lib/bootstrap.dart` via `initializePassengerFirebase()` — **try/catch**, app continues if config missing |
| Background handler | Top-level: initialize Firebase only. No navigation, no REST, no local notification |
| `android/app/google-services.json` | **Missing** — Gradle plugin applied **only if the file exists** |
| Google Services plugin | `com.google.gms.google-services` `4.4.3` (`apply false` + conditional apply) |
| Default channel meta-data | `com.google.firebase.messaging.default_notification_channel_id` = `ride_updates` |
| Core library desugaring | Enabled for `flutter_local_notifications` |
| iOS `GoogleService-Info.plist` | **Not fabricated** |
| iOS bundle id | Xcode still `com.example.ryduUser` (Flutter template). Shipping/Android id is `com.rydu.user`. Align bundle id when adding iOS Firebase — do not ship FCM against the example id. |
| iOS `UIBackgroundModes` | `remote-notification` added |

Without native config, `NoopFcmGateway` is used. Socket + REST still work.

---

## Stable device identity

`PassengerDeviceIdentity` (`lib/core/device/passenger_device_identity.dart`)

- One UUID (`uuid` package), SharedPreferences key `passenger_device_id`
- Generated once, cached in memory
- Survives login, token refresh, and **logout**
- Reinstall may mint a new id

There is no second `loginDeviceId` / `pushDeviceId` / `apiDeviceId`.

---

## Login / device binding

Existing Auth0 → `POST /api/v1/passenger/auth/login` now sends:

- `deviceId` = stable UUID
- `deviceInfo` = `Platform.operatingSystem` (unchanged)

`AuthRepositoryImpl` was extended with optional `deviceIdentity` and `unregisterPushToken`. Auth0 identity flow is unchanged.

---

## X-Device-ID

Existing Dio `AuthInterceptor` attaches:

- `Authorization: Bearer <jwt>` (unchanged)
- `X-Device-ID: <same UUID>`

Same client. Push register/unregister automatically carry the header.

---

## Token registration / refresh / unregister

Paths (`PassengerApiPaths.pushToken`):

- `PUT /api/v1/passenger/push-token` body `{ token, deviceId }` — no `customerId`
- `DELETE /api/v1/passenger/push-token`

Timing:

1. Auth0 login  
2. Passenger login **with** `deviceId`  
3. JWT stored  
4. Permission if appropriate  
5. `getToken` → PUT  

Also after splash/home session restore if already authenticated (no repeated OS prompt).

`onTokenRefresh` → PUT again with current JWT + same device id.

Push errors do not log the user out, do not disconnect Socket.IO, and do not block startup.

---

## Permission / channel

- Android: `POST_NOTIFICATIONS` in the main manifest  
- Requested via FCM after login (once) or when Settings Notifications is turned on  
- Settings switch is **truthful**: on only if user preference **and** OS permission granted  
- Off: best-effort DELETE, session and Socket stay up  
- Channel `ride_updates` / “Ride updates” / **high** importance  
- Created at Firebase init; not duplicated as extra channels  

---

## Foreground behavior

`FirebaseMessaging.onMessage`:

- Parse / ignore unknown type and malformed payloads (`accepted` is not a valid event)
- Dedupe key `bookingId:event`
- **No tray notification** (iOS foreground presentation disabled)
- **No navigation** — Socket remains UI authority

---

## Background tap

`onMessageOpenedApp` stores a pending `RidePushEvent`, waits until the router is past splash **and** the session is authenticated, then REST-hydrates.

---

## Cold-start tap

`getInitialMessage()` is captured after Firebase init / listener attach. It is **not** processed during splash session restore.

- Authenticated → REST recovery after Home is the landing surface  
- Unauthenticated → pending hint kept → Auth → after login, hydrate  
- RouteGuards are not bypassed  

---

## REST recovery

| FCM event | First REST | Then |
|---|---|---|
| `driver_en_route`, `arrived`, `in_progress` | existing `restoreActiveBooking(navigate: true)` | if null / id mismatch → `loadDetail` / `bookingById` |
| `completed`, `cancelled`, `no_drivers` | existing `GET /bookings/:id` via Ride History `loadDetail` | if unexpectedly active → existing live restore; else `/ride-details?rideId=` |
| 404 | Activity + non-fatal snackbar | |

Searching/offered vs assigned screens still come from existing `_navigateForActivePhase` / `resumeActiveRide`.

---

## Dedupe / stale push

- Key: `bookingId` + normalized event  
- Duplicate tap does not navigate twice (`navigatedKeys`)  
- Lifecycle rank: searching → offered → `driver_en_route` → arrived → in_progress → completed / cancelled / no_drivers  
- If REST/local status is later than the push, REST wins (e.g. completed tap target, never Driver Found from stale `driver_en_route`)  

Existing `lastNavigatedPhaseKey` is untouched.

---

## Logout integration

Existing path only:

`AccountController.logout()` → `AuthRepository.signOut()`:

1. Best-effort `DELETE /push-token` (JWT still present)  
2. Existing `POST /passenger/auth/logout`  
3. Existing local session clear  
4. Existing socket disconnect (callers unchanged)  

Unregister failure is logged (no token) and **logout continues**. Device UUID is **not** cleared. Deactivate still reuses `logout()`. `ACCOUNT_DEACTIVATED` is not revived by FCM recovery.

---

## Tests

`flutter analyze` — no issues  
`flutter test` — **223 passed**, including existing restore, ride phase, recording consent, Ride History, profile/logout

New coverage includes: stable UUID, persist, logout keep UUID, login `deviceId`, `X-Device-ID`, register same device id, token refresh re-PUT, unregister-before-clear, unregister failure, `ride_updates` channel, foreground no tray, unknown/malformed/`accepted` ignored, all six contract events parsed, tap hydrate, cold-start waits for session, active restore, active-null fallback, terminal `bookingById`, stale REST wins, duplicate nav, Socket foreground authority.

---

## Real-device results

**Not run.** Blocker: `android/app/google-services.json` for application id `com.rydu.user`.

Debug APK built: `build/app/outputs/flutter-apk/app-debug.apk`

After placing the Firebase Android config (do not invent it), re-apply is automatic and QA checklist from the implementation brief applies (login PUT 200, foreground no duplicate tray, background/locked/terminated taps, stale push, token rotation, logout DELETE, relogin same UUID).

---

## What to add next (config only)

1. Firebase Console Android app `com.rydu.user` → download `google-services.json` into `android/app/`  
2. For iOS later: set bundle id to `com.rydu.user`, add `GoogleService-Info.plist`, Push capability  
3. Repeat manual Android QA on a real device  

**Status:** IMPLEMENTATION COMPLETE — FIREBASE CONFIG REQUIRED FOR DEVICE QA
