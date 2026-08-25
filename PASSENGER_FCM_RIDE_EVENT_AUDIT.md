# Passenger FCM Ride-Event Notifications Audit Report

**Scope:** Passenger Flutter app only (`Rydu_User`).  
**Mode:** Audit only. No application code was modified.  
**Date:** 19 August 2026

**Architecture that must remain (do not replace in later work):**

- Socket.IO = foreground realtime
- Active ride restore via `GET /bookings/active` must remain the source of truth after notification tap for live rides
- Ride History must remain the read-only terminal path
- Booking / recording-consent flow must remain unchanged
- Existing profile / logout path must remain the single session teardown

FCM must **converge into the existing `RideBookingController` / `RideHistoryController` state**, not invent a second ride state machine.

---

## Executive summary

Passenger is **not FCM-ready**. There is no Firebase SDK, no native Firebase config, no messaging handlers, no push-token API, no OS notification permission, and no notification channels.

Foreground ride updates already work through Socket.IO → `RideBookingController`. Cold-start / resume already hydrate live rides through `restoreActiveBooking()`. Terminal rides already hydrate through `GET /bookings/:id` into Ride Details / Activity.

Those existing paths are the correct FCM landing zone. What is missing is the entire push stack around them.

**Passenger Firebase registration (from this repo):** **Not present.** This repository has no `google-services.json`, no `GoogleService-Info.plist`, and no `firebase_options.dart`. Console registration cannot be verified from source. Android application id is `com.rydu.user`; iOS bundle id in Xcode is still `com.example.ryduUser`. Even if a Firebase project exists elsewhere, this app binary is not wired to it.

**Final classification:**  
**E. MULTIPLE_GAPS**

Exact gap list:

1. **FIREBASE_CONFIG_MISSING** — no `firebase_core` / `firebase_messaging`, no native config files, no Gradle Google Services plugin, no iOS Firebase plist, no `Firebase.initializeApp`
2. **TOKEN_REGISTRATION_MISSING** — app never obtains an FCM token and never POSTs it to the backend
3. **MESSAGE_ROUTING_MISSING** — no `onMessage` / `onMessageOpenedApp` / `getInitialMessage` / `onBackgroundMessage`
4. **POST_NOTIFICATIONS missing** — Android 13+ permission not in manifest and not requested at runtime
5. **iOS notification permission / entitlements missing** — no `UIBackgroundModes` remote-notification, no Push entitlements, no permission request
6. **No device identity** — no persisted device id and no `X-Device-ID` header on API calls (do not invent a second identity later)
7. **No notification channels**
8. **Logout has no push-token unregister** (nothing to unregister yet; must hook the existing logout, not a parallel path)
9. **No FCM tests**

---

## 1. Firebase / FCM foundation

### 1.1 Dart packages

`pubspec.yaml` dependencies relevant to this audit:

| Package | Present? |
|---|---|
| `firebase_core` | **No** |
| `firebase_messaging` | **No** |
| `flutter_local_notifications` | **No** |
| `permission_handler` | **No** |
| `socket_io_client` | Yes (`^3.1.6`) — foreground realtime |
| `uuid` | Yes (`^4.5.3`) — used for Places session + booking idempotency, **not** device id |

### 1.2 Android native

| Item | State |
|---|---|
| `google-services.json` | **Missing** (not in repo) |
| Google Services Gradle plugin (`com.google.gms.google-services`) | **Missing** from `android/settings.gradle.kts` and `android/app/build.gradle.kts` |
| Application id | `com.rydu.user` |
| `MainActivity` | `FlutterActivity` only; `launchMode="singleTop"` (good for notification tap reuse of the same task) |
| Firebase init | **None** |

`android/app/build.gradle.kts` plugins: `com.android.application`, `kotlin-android`, `dev.flutter.flutter-gradle-plugin`. Maps API key injection exists. No Firebase.

### 1.3 iOS native

| Item | State |
|---|---|
| `GoogleService-Info.plist` | **Missing** |
| `firebase_options.dart` / `firebase.json` | **Missing** |
| `AppDelegate.swift` | Google Maps `GMSServices.provideAPIKey` only; no Firebase, no APNs registration |
| `SceneDelegate.swift` | Empty `FlutterSceneDelegate` |
| Push entitlements | **None** (no `.entitlements` files) |
| Bundle id | Xcode `PRODUCT_BUNDLE_IDENTIFIER = com.example.ryduUser` — **not aligned** with Android `com.rydu.user` |

`ios/Runner/Info.plist` has location + photo usage strings and Google Maps key placeholder. No `UIBackgroundModes`, no `FirebaseAppDelegateProxyEnabled`, no APNs / notification keys.

### 1.4 Flutter initialization

```dart
// lib/bootstrap.dart
Future<SharedPreferences> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  return SharedPreferences.getInstance();
}
```

Comment mentions Firebase as a future example. **`Firebase.initializeApp` is not called.** `lib/main.dart` only loads SharedPreferences and `runApp`.

### 1.5 Is the Passenger app registered in Firebase?

**Not from this repository.** There is no Firebase app config artifact to prove console registration. Treat as **unregistered in this codebase**. Later work must add a Firebase Android app for `com.rydu.user` and an iOS app whose bundle id matches the shipping iOS identifier (today `com.example.ryduUser`).

---

## 2. Notification permission

### 2.1 Android 13+ `POST_NOTIFICATIONS`

**Manifest:** `android/app/src/main/AndroidManifest.xml` declares only:

- `INTERNET`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_FINE_LOCATION`

**`POST_NOTIFICATIONS` is not declared.** Debug/profile manifests add only `INTERNET`.

**Runtime request:** None. Location uses `Geolocator.requestPermission()` in `LocationService`. Settings “Notifications” toggle does **not** call the OS.

Settings copy already documents the gap:

> “Notifications on. TODO: request OS permission when FCM is integrated.”  
> “Notifications off. TODO: unregister push tokens when backend is ready.”

That toggle is local UI state (`AccountSettingsLocalDatasourceImpl` always returns `notificationsEnabled: true`). It does not talk to the OS or backend.

### 2.2 iOS

**Not configured.**

- No `UNUserNotificationCenter` request in AppDelegate
- No Flutter `FirebaseMessaging.requestPermission`
- No Push Notifications capability / entitlements
- No `remote-notification` background mode

### 2.3 Current state

| Platform | Manifest / capability | Runtime request | Result |
|---|---|---|---|
| Android 13+ | Missing `POST_NOTIFICATIONS` | Missing | System tray notifications will be silently dropped on API 33+ |
| iOS | Missing push capability | Missing | APNs / FCM display will not be authorized |

---

## 3. FCM service / handlers

Repo-wide search for:

- `FirebaseMessaging.onMessage`
- `onMessageOpenedApp`
- `getInitialMessage`
- `onBackgroundMessage`
- token / `onTokenRefresh`

**Result: nothing exists.** Zero Dart, Kotlin, or Swift hits.

| Handler | Exists? | Needed for |
|---|---|---|
| `Firebase.initializeApp` | **No** | Foundation |
| `getToken` / `onTokenRefresh` | **No** | Backend registration |
| `onMessage` (foreground) | **No** | Must **not** show a tray duplicate; Socket already owns UI |
| `onMessageOpenedApp` (background tap) | **No** | Hydrate then route |
| `getInitialMessage` (terminated tap) | **No** | Cold-start hydrate then route |
| `onBackgroundMessage` (isolate) | **No** | Only if data-only messages must be processed while backgrounded; OS tray can display `notification` payloads without this |

There is an in-app **Notifications** feature (`lib/features/notifications/`), but it is a stub inbox:

- `NotificationsRemoteDatasourceImpl.fetch()` returns `[]`
- `NotificationsScreen` is a centered `"Notifications"` placeholder
- Home bell (`RouteNames.notifications`) and unread badge (`hasUnreadNotification: true`) are not FCM

**Do not confuse that inbox stub with FCM ride-event handling.**

---

## 4. Token registration

**Missing. State clearly: the Passenger app does not send an FCM token to the backend.**

Searched API paths, datasources, and strings for `push-token`, `fcm token`, `device token`, `pushToken`, `fcmToken`, `deviceToken`.

`PassengerApiPaths` has bookings, profile, places, consent — **no push-token path**.

Login body *can* include optional `deviceId` / `deviceInfo` (`AuthRemoteDatasourceImpl.exchangeAuth0Token`), but:

- `deviceId` is **never passed** by `AuthRepositoryImpl.login`
- `deviceInfo` is only `Platform.operatingSystem`
- That is **not** an FCM token

Later work needs a backend contract (out of this repo) such as register/unregister push token with `{ token, deviceId, platform }`, then a Passenger client method on the existing Dio + JWT stack.

---

## 5. Device id / session

### 5.1 What exists today

| Mechanism | Used for | Persistent device identity? |
|---|---|---|
| `AuthInterceptor` | `Authorization: Bearer <jwt>` only | No |
| Login `deviceId` body field | Optional, unused | No |
| Login `deviceInfo` | `"android"` / `"ios"` string | No |
| `uuid` package | Places autocomplete session token; booking/cancel `Idempotency-Key` | No |
| Secure storage keys | `backend_jwt`, `session_id`, `user_id`, `user_email`, `user_name` | Session, not device |
| `X-Device-ID` header | **Does not exist** | — |

There is **no** generated-and-stored device id, and **no** `X-Device-ID` on normal API calls.

### 5.2 Reuse recommendation

**Do not create a second device identity for push.**

When FCM is added:

1. Generate **one** stable UUID (the `uuid` package is already a dependency).
2. Persist it (secure storage or SharedPreferences — one store, reused).
3. Attach it as `X-Device-ID` on the existing Dio interceptor so **all** Passenger API calls share it.
4. Send that **same** id on login `deviceId` (field already exists, unused) **and** on push-token register/unregister.

Until that single identity exists, push registration has nothing durable to bind a token to across reinstall vs session. Reinstall may mint a new id; logout must not wipe device id unless product explicitly wants tokens to die with local storage.

---

## 6. Existing Socket.IO ride events

**Foreground realtime owner:** `PassengerSocketService` (`lib/core/network/passenger_socket_service.dart`)  
**State owner:** `RideBookingController` (`rideBookingControllerProvider`)  
**Provider:** `passengerSocketServiceProvider`

Connect uses backend JWT (`AuthConstants.backendJwtKey`) against `ApiConstants.socketUrl`. Active booking id is set via `setActiveBookingId`; events for other bookings are dropped.

### 6.1 Event → controller → screen

| Socket event | Service mapping | Controller | Resulting `RidePlanningPhase` | Screen / navigation |
|---|---|---|---|---|
| `booking:searching` | `_emitBooking('searching')` | `_applySocketBookingEvent` | `bookingSearching` | `FindingDriverScreen` (`/finding-driver`) |
| `booking:accepted` | `_emitBooking('accepted')` | same | `driverAccepted` | Finding Driver **pushReplacement** → `DriverFoundScreen` (`/driver-found`) |
| `booking:status` | `_emitBooking('status')` + payload `status` | `ridePhaseFromBookingStatus` | see map below | Assigned phases stay on Driver Found; terminal handled below |
| `booking:expired` | `_emitBooking('expired')` | same | `expired` | Stays on Finding Driver (expired UI); from Driver Found → back to Finding Driver |
| `driver:location` | `driverLocationStream` | `_applyDriverLocation` | (location only) | Active ride map on Finding Driver / Driver Found |
| `recording:consent_updated` | `recordingEventStream` | `_applyRecordingSocketEvent` | consent overlay | `RecordingConsentOverlay` on Driver Found |
| `recording:session_available` | same | `refreshRecordingConsentFromBackend()` | GET booking | Same overlay / flags |
| `authenticated` | connection | `socketStatus = connected` | — | Reconnect also refreshes consent |
| `unauthorized` | connection | `authFailed` | — | No ride navigation |

`booking:status` payload `status` is mapped by `ridePhaseFromBookingStatus`:

| Backend status | Phase |
|---|---|
| `searching` / `requested` / `pending` / `created` | `bookingSearching` |
| `offered` | `bookingOffered` |
| `accepted` | `driverAccepted` |
| `en_route` / `driver_en_route` | `driverEnRoute` |
| `arrived` / `driver_arrived` | `driverArrived` |
| `in_progress` / `ongoing` / `started` | `rideInProgress` |
| `completed` | `completed` |
| `cancelled` / `canceled` | `cancelled` |
| `expired` | `expired` |
| `no_drivers` / `no_driver` | `noDrivers` |
| `scheduled` | `scheduled` |
| unknown | **falls through to `bookingSearching`** |

### 6.2 Terminal navigation already in UI

- **Finding Driver + cancelled** → `context.go(Home)`
- **Driver Found + cancelled or completed** → `context.go(Home)`
- **Driver Found + expired / no_drivers** → `pushReplacement(FindingDriver)`
- **Finding Driver + expired / no_drivers** → stay on screen (expired copy)
- Phase navigation is gated by `lastNavigatedPhaseKey = '$bookingId:${phase.name}'` (`hasNavigatedForPhase`)

### 6.3 FCM implication

FCM must **not** reimplement these transitions. After a tap (or a rare foreground data message), call:

- live: `restoreActiveBooking` / existing phase navigation
- terminal: `GET /bookings/:id` → Ride Details / Activity

Socket remains authoritative while the process is foreground and connected.

---

## 7. Active ride restore — `GET /bookings/active`

**Path:** `PassengerApiPaths.activeBooking` → `{passengerPrefix}/bookings/active`  
**Datasource:** `PassengerRideRemoteDatasourceImpl.activeBooking()` — 404 → `null`  
**Repository:** `RideBookingRepository.activeBooking()`  
**Controller:** `RideBookingController.restoreActiveBooking({bool navigate = false})`

### 7.1 Restore timing (already implemented)

| When | `navigate` | What the user sees |
|---|---|---|
| Splash after session restore | `false` | Home; persistent `HomeActiveRideCard` if still active |
| Home `initState` | `false` | Same card, no forced live screen |
| Home `AppLifecycleState.resumed` | `false` | Reconcile after background |
| Sign-in success | `false` | Then `go(Home)` |
| `ACTIVE_BOOKING_EXISTS` on create | `true` | `go` Finding Driver or Driver Found |
| Activity / history refresh | `false` (`_refreshActiveQuietly`) | Active row stays out of “previous” list |

Splash timeout: 4 seconds; failure is ignored so the user still reaches Home.

### 7.2 How booking id / status is reconciled

1. GET active booking.
2. If `null` or `!booking.isActive` → return `false` (no live ride).
3. `_applyBookingEntity` writes `bookingId`, `bookingStatus`, phase, driver, route, consent.
4. `_connectAndListen(booking.id)` — socket `setActiveBookingId` + connect (socket failure is swallowed; booking still restored).
5. If `navigate: true` → `_navigateForActivePhase`:
   - assigned / in progress → `/driver-found`
   - else (searching / offered) → `/finding-driver`

`BookingEntity.isActive` is false for `completed`, `cancelled`/`canceled`, `expired`, `no_drivers`.

**This is the primary path after a notification tap for active events.** Do not route from the FCM payload’s stale status. Open app → `restoreActiveBooking(navigate: true)` (or restore then `resumeActiveRide()`). If restore returns false, treat as terminal / stale (section 8–9).

User can also reopen a minimized live ride from `HomeActiveRideCard` / Activity via `resumeActiveRide()`.

---

## 8. Booking detail — `GET /bookings/:id`

**Path:** `PassengerApiPaths.bookingById(id)`  
**Used by:**

- `RideBookingRepository.bookingById` — consent refresh / socket reconnect
- `RideHistoryRemoteDatasource.fetchRide` → `RideHistoryController.loadDetail`

**Parser:** same `RidePlanningParsers.booking` as active restore. Status, fares, timestamps (`completedAt`, `cancelledAt`, …), driver, addresses all land on `BookingEntity`.

### 8.1 Can it hydrate terminal notifications?

| Terminal event | Entity status | History presentation | Ride Details |
|---|---|---|---|
| completed | `completed` (`isActive == false`) | “Completed” | Yes — `loadDetail(id)` |
| cancelled | `cancelled` / `canceled` | “Cancelled” | Yes |
| no driver | `no_drivers` | “Expired” | Yes |

`RideDetailsScreen` (`/ride-details?rideId=`):

- If that id is the **current active** booking → `resumeActiveRide()` (live screens), not read-only details
- Else → `loadDetail(id)` and render history detail

So **yes**: terminal FCM taps should refresh via `GET /bookings/:id` (and/or history list), then open read-only Ride Details. If the booking is still active, the same screen already redirects into the live flow.

`restoreActiveBooking` will **not** open a completed/cancelled/no_drivers ride as live. That is correct.

---

## 9. Notification tap routing

### 9.1 Current router

- `go_router` via `goRouterProvider`
- `initialLocation: /splash`
- `RouteGuards`: unauthenticated users hitting private routes → `/auth`; splash restores session first
- Ride routes: `/finding-driver`, `/driver-found`, `/ride-history`, `/ride-details?rideId=`
- Activity tab (`/activity`) is `RideHistoryBody`
- `MainActivity` `singleTop` — notification tap should resume the existing task, not spawn a second copy
- **No FCM / deep-link query handling today.** `RouteNames` comment mentions deep links; there is no `uni_links` / `app_links` / `getInitialMessage` consumer

Tap handling must wait until auth session is restored (splash already does this). Unauthenticated tap → auth, then existing post-login `restoreActiveBooking(navigate: false)`.

### 9.2 Recommended tap behavior (do not navigate from stale payload)

**Active-class events** (searching, accepted, en_route, arrived, started / in_progress):

1. Open / resume app
2. Ensure session
3. `restoreActiveBooking(navigate: true)` **or** restore with `navigate: false` then `resumeActiveRide()` if still `hasActiveBooking`
4. If restore is false → booking is no longer live; fall through to terminal path using payload `bookingId` only as a **hint** for `GET /bookings/:id`

**Terminal events** (completed, cancelled, no_drivers / expired):

1. Open / resume app
2. `GET /bookings/:id` (and refresh history list)
3. If that booking is actually still active → live ride screens
4. Else → `/ride-details?rideId=<id>` (read-only). If id missing/404 → Activity / Ride History, not a fake completed UI

**Never** `go(driverFound)` solely because the notification said `accepted`.

---

## 10. Foreground UX

While the app is resumed, Socket.IO already updates `RideBookingController` and screens listen for phase changes.

**Recommendation:**

- **Do not** show a system tray notification for ride events when the app is in the foreground and Socket handled (or will handle) the same booking
- Update UI via Socket (already done)
- Optional lightweight in-app banner / SnackBar
- No `flutter_local_notifications` in `onMessage` for the same event

### 10.1 Existing banner / snackbar patterns

| Pattern | Where | Ride-event ready? |
|---|---|---|
| `SnackBar` | Many screens (settings, profile, finding-driver minimize, errors) | Generic; reusable for a one-line “Driver has arrived” if product wants it |
| `HomeActiveRideCard` | Home | Persistent **status** banner for an in-progress booking, not a flash for a new event |
| `RecordingConsentOverlay` | Driver Found | Consent only |
| Settings floating SnackBar | Notifications toggle | Local preference only |

There is **no** dedicated in-app ride-event toast service. A foreground FCM `onMessage` handler should either no-op (prefer Socket) or show one SnackBar **without** a tray notification.

Default Firebase behavior: notification messages in foreground do **not** auto-display in the tray unless the app displays them. Keep it that way.

---

## 11. Background / locked / closed

### 11.1 What the app does today

| Lifecycle | Behavior |
|---|---|
| Foreground | Socket connected; live UI |
| Home paused then **resumed** | `HomeScreen` observer → `restoreActiveBooking(navigate: false)` |
| Socket drop / reconnect | `socket_io_client` reconnection + `connectionStatusStream`; consent refresh on reconnect |
| Background (process alive, socket likely disconnected) | **No FCM**; user only sees updates after resume restore |
| Locked screen | Same as background; no lock-screen notification pipeline |
| Terminated | Splash → session restore → `restoreActiveBooking(navigate: false)` → Home card. **No** `getInitialMessage` |
| Force-stopped (Android) | Process cannot run; FCM typically will **not** start the app until the user opens it. Tray display of an FCM **notification** payload may still appear if the OS accepted it before force-stop; after force-stop, delivery is not guaranteed |

### 11.2 What FCM should own vs OS tray

| State | Socket | FCM | Handler |
|---|---|---|---|
| Foreground | Authority | Ignore tray; optional SnackBar | `onMessage` no-op / banner only |
| Background / locked (process alive) | Usually down | OS shows **notification** payload in tray | Tap → `onMessageOpenedApp` → hydrate |
| Terminated | None | OS tray from **notification** payload | Tap → `getInitialMessage` after splash/auth → hydrate |
| Data-only message in background | None | Requires `onBackgroundMessage` **or** no UI until tap/open | Prefer backend **notification+data** so OS tray works without a Dart isolate |
| Force-stopped | None | Unreliable | Document; user must open the app; restore path still works |

**Recommendation:** backend sends FCM **notification + data** (`bookingId`, `event`/`status`) so the OS draws the tray when backgrounded/terminated. Flutter background handler is then optional. Do not rely on a Dart isolate for the first version unless product requires data-only silent sync.

Lock-screen copy must stay non-sensitive (section 14).

---

## 12. Dedupe

**Recommended local key:** `bookingId + event/status`  
(normalize status the same way as `ridePhaseFromBookingStatus`, e.g. `canceled` → `cancelled`, `no_driver` → `no_drivers`).

### 12.1 What already suppresses duplicates

| Mechanism | What it does |
|---|---|
| Socket `_activeBookingId` filter | Drops other bookings’ events |
| `_applySocketBookingEvent` bookingId check | Same |
| `lastNavigatedPhaseKey` | Same booking + phase will not re-navigate |
| `BookingEntity.isActive` / `hasActiveBooking` | Restore will not revive terminal rides |
| Driver location timestamp | Ignores older GPS points |

**Do not invent another ride state machine.** On FCM:

1. If `state.bookingId == payload.bookingId` **and** current `bookingStatus` / phase already matches (or is newer than) the payload → ignore.
2. Foreground + socket connected → ignore FCM for UI (Socket wins).
3. After tap, always **GET** active or by-id; if server status disagrees with payload, server wins.

In-memory last-seen `(bookingId, status)` in a small helper is enough to suppress double tray actions / double navigations. Persist only if terminated taps can race splash restore; even then, GET remains authoritative.

---

## 13. Notification channels

**Existing channels:** none. No `AndroidNotificationChannel`, no `flutter_local_notifications`.

**Recommend one Passenger ride-events channel**, separate from future marketing / wallet / inbox:

| Channel id | Name (user-visible) | Importance |
|---|---|---|
| `ride_updates` | Ride updates | Default / high by event (see below) |

Do **not** reuse a generic “notifications” channel later invented for promo.

Suggested importance (Android):

| Event | Channel importance |
|---|---|
| Driver arrived | **High** |
| Ride cancelled | **High** |
| Urgent status change (e.g. no driver while waiting) | **High** |
| Ride completed | Default |
| Driver accepted | Default or high — product choice; default is enough if Socket covers foreground |

iOS: equivalent interruption via `UNNotificationSound` / FCM `apns` headers; still one logical “ride updates” category.

If the backend uses FCM **notification** payloads, Android 8+ still needs a channel id in the payload (`android.notification.channel_id = ride_updates`) **and** the app must create that channel at startup. Creating the channel is app-side work even when the OS renders the tray.

---

## 14. Copy / titles (recommendation only — do not ship in this audit)

Keep lock-screen text free of route, phone, plate, and exact fare.

| Event | Title / body |
|---|---|
| Driver accepted | “Your driver accepted the ride” |
| Arrived | “Your driver has arrived” |
| Ride started | “Your ride has started” |
| Completed | “Ride completed” |
| Cancelled | “Ride cancelled” |
| No driver | “No driver found” |

Optional subtitle: booking number only if product already treats it as non-sensitive. No pickup/dropoff addresses on the lock screen.

In-app SnackBar, if used, can match the same strings.

---

## 15. Profile / logout cleanup

### 15.1 Existing logout path (single path)

UI: Account → logout confirmation → `AccountController.logout()`.

```
AccountController.logout()
  → logoutUsecase → AuthRepository.signOut()
       → POST /api/v1/passenger/auth/logout
       → clear JWT / session / Auth0 credentials
  → passengerSocketService.disconnect()
  → authSession.markUnauthenticated()
  → passengerProfileController.clear()
  → invalidate rideHistoryControllerProvider
```

Deactivate account **reuses** `logout()` after profile deactivate succeeds.  
`AuthController.signOut()` and deactivated-account handling on the auth screen also disconnect the socket and clear session — keep FCM unregister on the **repository `signOut` / `AccountController.logout` line**, not a third button.

Settings notifications-off is **not** logout; it should eventually unregister or disable the token **and** still leave session intact.

### 15.2 What is not cleared today

Logout does **not** reset `rideBookingControllerProvider` in-memory booking. Out of FCM scope except: after unregister, do not keep displaying a live card for a signed-out user (router already sends them to `/auth`).

### 15.3 Future FCM hook

**Unregister the push token on the same logout path** (best-effort POST, then clear local token cache). Do **not** create a parallel logout. Order suggestion:

1. Unregister FCM token with backend (needs JWT + device id) — best-effort
2. Existing `logoutPassenger` + local auth clear
3. Existing socket disconnect

If unregister fails, still complete logout (same pattern as 401/403 on logout already clearing local auth).

---

## 16. Tests needed (later; none exist for FCM)

Existing coverage that FCM must **not** break:

- `test/features/ride_booking/active_booking_ux_test.dart` — restore searching/accepted, Home card, minimize
- `test/features/ride_booking/active_ride_flow_test.dart` — `ridePhaseFromBookingStatus`
- `test/features/ride_booking/recording_consent_test.dart` — restore + wrong-booking socket ignore
- `test/features/ride_history/*` — completed / cancelled / `no_drivers` presentation
- `test/features/account/passenger_profile_controller_test.dart` — logout / deactivate reuse logout

| Test | Assert |
|---|---|
| Token sync | After login/session restore, `getToken` is sent with the **same** device id used as `X-Device-ID`; refresh re-POSTs |
| Foreground message, no duplicate tray | `onMessage` does not create a local notification when Socket already applied the same `bookingId+status` |
| Background tap | `onMessageOpenedApp` → `restoreActiveBooking` / `loadDetail`, not payload-only navigation |
| Terminated cold-start tap | `getInitialMessage` after splash auth → same hydrate |
| Active ride hydrate | Searching/accepted/arrived/in_progress tap → live screens only if GET active still `isActive` |
| Completed / cancelled hydrate | Tap → `GET /bookings/:id` → Ride Details; not Finding Driver |
| Stale notification | Payload `accepted` but GET active is null / completed → details or Activity, not Driver Found |
| Dedupe | Second identical `bookingId+status` does not navigate again (`lastNavigatedPhaseKey` / helper) |
| Logout unregister | `AccountController.logout` / `signOut` calls unregister; no second logout API |
| Restore regression | Splash/Home `navigate: false` still shows Home card; conflict create still `navigate: true` |

---

## 17. Output — classification

### What is already ready to *receive* FCM (do not rebuild)

- Socket.IO foreground ride state
- `restoreActiveBooking` + Home resume observer
- `GET /bookings/:id` + Ride Details / Activity
- `go_router` live vs history routes
- Single logout path + socket disconnect
- Phase-level navigation dedupe (`bookingId + phase`)

### What is missing

| Code | Item |
|---|---|
| **B** | FIREBASE_CONFIG_MISSING |
| **C** | TOKEN_REGISTRATION_MISSING |
| **D** | MESSAGE_ROUTING_MISSING |
| — | Android `POST_NOTIFICATIONS` + runtime request |
| — | iOS push permission, entitlements, `remote-notification` |
| — | Single persisted device id / `X-Device-ID` (none today; reuse one later) |
| — | Channel `ride_updates` |
| — | Logout token unregister hook |
| — | FCM tests |

### Final status

**AUDIT COMPLETE — E. MULTIPLE_GAPS**

Not **A. FCM_FOUNDATION_READY**.  
Foundation, token registration, and message routing are all absent. Socket restore and booking detail are the correct convergence points for a later implementation. No application code was changed.
