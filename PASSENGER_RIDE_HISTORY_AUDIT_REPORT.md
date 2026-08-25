# Passenger Ride History Audit Report

**Scope:** Passenger Flutter app only (`Rydu_User`).  
**Mode:** Audit only. No application code was modified.  
**Date:** 17 August 2026

---

## Executive summary

The Passenger app already has:

- A bottom-nav **Activity** hub with empty-state UI.
- A routed **Ride History** / **Ride Details** feature folder that is a placeholder.
- Authoritative **active booking** state in `RideBookingController` / `RideBookingState`.
- Live booking APIs: create, active, by-id, cancel, quote — **no list/history HTTP call**.
- A reusable booking parser (`RidePlanningParsers.booking`) that is **active-oriented**.
- A production **Home active-ride card** that already matches the desired Active Ride history card.

It does **not** yet have a real history list, pagination, history models, pull-to-refresh, or a read-only past-ride detail screen.

**Final status:**  
**AUDIT COMPLETE — PASSENGER HISTORY GAPS:** no implemented history list API, placeholder History/Details screens, thin history models, unused Activity feed, no pagination pattern, booking parser missing timestamps / cancellation / payment-status / distance-duration, dual History entry points.

---

## 1. History / Activity UI

### 1.1 Primary surfaces

| Surface | Screen | Route | Navigation entry | Controller / provider | Repository / datasource | Real / mock / placeholder |
|---|---|---|---|---|---|---|
| **Activity tab** | `ActivityScreen` | `/activity` (`RouteNames.activity`) | Bottom nav index 2 (“Activity”) in `MainShellScreen` / `HomeBottomNav`. Also `homeController`, `servicesController`, `accountController.selectBottomNav(2)`. | `activityControllerProvider` (`ActivityController` / `ActivityState`) | `activityRepositoryProvider` → `ActivityRepositoryImpl` → `ActivityLocalDatasourceImpl` | **Placeholder / empty local stub.** Filter apply hits a 300ms delay and returns `[]`. TODO: “Replace with paginated activity API”. Tab open **resets** state and does **not** load. |
| **Ride History** | `RideHistoryScreen` | `/ride-history` (`RouteNames.rideHistory`) | Account: `AccountFeatureCard` “Ride History” and rating tap → `AccountController.openRideHistory()` → `push('/ride-history')`. | `rideHistoryRepositoryProvider` only. **No screen controller.** `GetRideDetailsUsecase` is unused by presentation. | `RideHistoryRepositoryImpl` → `RideHistoryRemoteDatasourceImpl` | **Placeholder.** Screen is `Center(child: Text('Ride History'))`. Remote returns empty list / `null`. **No Dio call.** |
| **Ride Details** | `RideDetailsScreen` | `/ride-details?rideId=` | Routed; **no in-app navigation found** that pushes it. | None | Same history repository `getRide(id)` | **Placeholder.** `Text('Ride Details ${rideId ?? ''}')`. |
| **Activity placeholder (dead)** | `ActivityPlaceholderScreen` | Not registered | None | None | None | Unused copy of “Your activity and trips will appear here.” |

### 1.2 Related “trips / bookings / orders” UI (not History)

| Surface | Notes |
|---|---|
| Inbox filter **Trips** | `InboxFilters.trips` — local inbox seed, not ride history. |
| Report ride issue | `GetRideIssueTripsUsecase` → `SupportLocalDatasourceImpl._rideIssueTrips` — **hardcoded mock** (Camry / City / X-Trail). TODO: “Load recent trips from ride history API”. |
| Report lost item | `GetLostItemTripsUsecase` → hardcoded mock completed trips. TODO: “Load completed trips from ride history API”. |
| FAQs | Copy mentions “receipt breakdown in Ride History”. |
| Account `rideCount` | Mock `127` from `AccountLocalDatasourceImpl`. |

### 1.3 Activity feed contract (too thin for History)

`ActivityItemEntity`: `id`, `title`, `subtitle`, `timestampLabel`.  
No status, fare, pickup, destination, driver, or booking id semantics.

Filter sheet categories: My orders / Business / Family.  
Services: All / Rides / Eats / 2-Wheeler / Rentals.  
Section header on the tab is already **“Past”**.

### 1.4 Ride History feature files

```
lib/features/ride_history/
  data/datasources/ride_history_remote_datasource.dart   # empty stub
  data/models/ride_history_item_model.dart               # id, summary, completedAt
  data/repositories/ride_history_repository_impl.dart
  domain/entities/ride_history_item_entity.dart
  domain/repositories/ride_history_repository.dart       # listRides(), getRide(id)
  domain/usecases/get_ride_details_usecase.dart          # unused by UI
  presentation/providers/ride_history_provider.dart      # repository only
  presentation/screens/ride_history_screen.dart          # placeholder
  presentation/screens/ride_details_screen.dart          # placeholder
  presentation/widgets/ride_history_tile.dart            # unused ListTile
```

**Recommendation:** Treat **Activity (`/activity`)** as the user-facing History hub (bottom nav + “Past”). Treat **`/ride-history`** as the Account deep-link into the **same** list, not a second pipeline. Do not ship two different history implementations.

---

## 2. Active booking state

### 2.1 Authoritative source

**Backend is already treated as authoritative for the live booking.**

| Layer | Role |
|---|---|
| `GET /api/v1/passenger/bookings/active` | Restore after splash, login, Home appear, app resume, and `ACTIVE_BOOKING_EXISTS` on create. |
| `GET /api/v1/passenger/bookings/{id}` | Consent refresh / booking-by-id fallback. |
| Socket (`PassengerSocketService`) | Live status + driver location for the **current** `_activeBookingId` only. |
| `RideBookingState` | In-memory session cache. **Not persisted** to SharedPreferences / secure storage. |

Controller: `rideBookingControllerProvider` (`NotifierProvider<RideBookingController, RideBookingState>`).

### 2.2 Restore points

| Call site | `navigate` | Behavior |
|---|---|---|
| `SplashScreen._bootstrap` | `false` | Restore quietly; timeout 4s; continue Home even on failure. |
| `AuthScreen` after login | `false` | Same. |
| `HomeScreen.initState` | `false` | Quiet restore so `HomeActiveRideCard` can appear. |
| `HomeScreen.didChangeAppLifecycleState(resumed)` | `false` | Re-sync from backend. |
| Create booking `ACTIVE_BOOKING_EXISTS` | `true` | Restore and open Finding Driver / Driver Found. |

`restoreActiveBooking` returns `false` if booking is null or `!booking.isActive`. Terminal bookings are not restored.

### 2.3 Duplicate-active prevention (already present)

- Create booking is blocked server-side; client maps `ACTIVE_BOOKING_EXISTS` / message containing `"active booking"` to restore.
- Socket ignores events whose `bookingId` ≠ `_activeBookingId`.
- `hasActiveBooking` is **not** “any `bookingId`”: it requires searching **or** assigned phases.

**History implication:** Deduplicate by `bookingId`. Prefer `RideBookingState.hasActiveBooking` (or GET active) over leftover `bookingId` after a terminal event (see §9).

### 2.4 Active ride screens (operational — do not reuse as History detail)

| Screen | Route | Actions |
|---|---|---|
| `FindingDriverScreen` | `/finding-driver` | Search animation, elapsed timer, cancel, minimize to Home. |
| `DriverFoundScreen` | `/driver-found` | Live map, driver location, call, chat, share, recording consent, **Cancel ride**. |

Home banner: `HomeActiveRideCard` — status, pickup → destination, service, **View ride**, optional **Cancel**.

### 2.5 Socket

`PassengerSocketService` events:

- `booking:searching`
- `booking:accepted`
- `booking:status` (generic; completed / cancelled / en_route / etc. arrive here)
- `booking:expired`
- `driver:location`
- `recording:consent_updated` / `recording:session_available`

Connection states: `idle | connecting | connected | reconnecting | disconnected | authFailed`.

There is **no** history socket channel.

### 2.6 Fields already available for an Active Ride history card

From `RideBookingState` / `HomeActiveRideCard` (session, after restore):

| Field | Source | History card |
|---|---|---|
| Status label | `activeRideStatusLabel` / `phase` / `bookingStatus` | Yes |
| Pickup | `pickupSpotLabel` / `pickupLocation` / `pickupPlace` | Yes |
| Destination | `destinationLabel` / `dropoffPlace` | Yes |
| Service | `serviceNameLabel` / `selectedVehicle` | Yes |
| Fare | `estimatedFare` / `fareCurrency` | Yes (quote/booking fare) |
| Driver | `assignedDriver` (name, plate, vehicle, phone, rating, eta) | Yes when assigned |
| Booking id / number | `bookingId`, `bookingNumber` | Yes |
| Payment method | `paymentMethod` / `paymentMethodCode` | Partial |
| View ride | `resumeActiveRide()` | Yes |
| Search elapsed | `searchStartedAt` | Local only; not a ride date |

From `BookingEntity` (GET active / GET by id):

`id`, `status`, `bookingNumber`, `serviceCategoryId`, `serviceName`, `paymentMethodCode`, `pickupAddress`, `dropoffAddress`, pickup/dropoff lat/lng, `currency`, `finalFare`, `driver`, `encodedPolyline`, `driverEtaMinutes`, `recordingConsent`.

**Not on BookingEntity today:** created/completed timestamps, distance, duration, cancellation reason, payment status, vehicle as a first-class object.

---

## 3. Existing history APIs

**Do not invent endpoints.** Below are calls **implemented in Passenger code**.

### 3.1 `PassengerApiPaths` (live)

Prefix: `/api/v1/passenger` (via `ApiConstants.passengerPathPrefix`).

| Method | Path helper | Used for |
|---|---|---|
| GET | `places/reverse-geocode` | Pickup geocode |
| GET | `places/autocomplete` | Search |
| GET | `places/details` | Place resolve |
| GET | `places/suggestions` | Suggestions |
| GET | `pickup-spots` | Confirm pickup |
| POST | `routes/preview` | Route polyline |
| POST | `bookings/quote` | Service quotes |
| GET | `services` | Path exists; not a history list |
| GET | `payment-methods` | Methods |
| GET | `drivers/nearby` | Nearby markers (deferred in UI) |
| **POST** | **`bookings`** | **Create booking only** |
| **GET** | **`bookings/active`** | **Active booking restore** |
| **GET** | **`bookings/{bookingId}`** | **Single booking (any status if backend returns it)** |
| POST | `bookings/{bookingId}/cancel` | Cancel |
| POST | `bookings/{bookingId}/recording-consent` | Consent |

There is **no** `GET bookings` list, **no** query `page`/`limit`/`cursor`, **no** `history` path in `PassengerApiPaths`.

`PassengerApiPaths.bookings` is **POST-only** in `PassengerRideRemoteDatasourceImpl.createBooking`.

### 3.2 Ride history remote (not an API)

`RideHistoryRemoteDatasourceImpl`:

- `fetchRides()` → `[]` (no HTTP)
- `fetchRide(id)` → `null` (no HTTP)

### 3.3 Activity remote (not an API)

`ActivityLocalDatasourceImpl.fetchActivities(...)` → `[]` after delay. TODO mentions a paginated activity API; **not implemented**.

### 3.4 Support “trips” (not an API)

Hardcoded local lists. TODOs explicitly wait on a ride history API.

### 3.5 Docs vs code (not implemented)

`BACKEND_API_REQUIREMENTS.md` **suggests**:

- `GET /api/v1/passenger/rides/history`
- `GET /api/v1/passenger/rides/history/{id}`

Those paths are **not** in `PassengerApiPaths` and are **not** called. Treat them as documentation of the stub, not as a confirmed backend contract.

**Integration blocker:** History list cannot be wired until backend publishes a paginated list contract. The only implemented read that could serve a **known** past ride is `GET bookings/{id}`.

---

## 4. Domain models

### 4.1 Reusable for History

| Model | Location | History usefulness |
|---|---|---|
| **`BookingEntity`** | `ride_planning_entities.dart` | Best existing booking shape. Active + by-id. Missing timestamps, cancel reason, payment status, distance/duration. |
| **`AssignedDriverEntity`** | same | Driver name, phone, plate, rating, vehicleName, eta. |
| **`PlaceEntity` / pickup-dropoff maps** | same | Addresses + coordinates. Parser reads `pickup` / `dropoff` objects. |
| **`PaymentMethodEntity`** | same | `code`, `label`, `isDefault`. Booking only stores `paymentMethodCode`. |
| **`ServiceQuoteEntity`** | same | Quote-time: `serviceCategoryId`, `serviceCode`, `serviceName`, capacity, `distanceKm`, `durationMin`, fares, currency, promotion. **Not copied onto BookingEntity.** |
| **`RoutePreviewEntity`** | same | Distance/duration/polyline at planning time. Booking keeps `encodedPolyline` only. |
| **`RideOptionEntity` / `RideVehicleOption`** | booking / presentation | Service card on active ride. |
| **`RideBookingState`** | controller | Session-only active card. Not a history list. |
| **`RecordingConsentInfo`** | booking | Active-only. Not required on History list. |

### 4.2 Too thin / mock — do not use as History source of truth

| Model | Why |
|---|---|
| `RideHistoryItemEntity` | `id`, `summary`, `completedAt` only. |
| `ActivityItemEntity` | Display strings only. |
| `RideTripEntity` | Mock support: title/subtitle/vehicle/fare/status. |
| `LostItemTripEntity` | Mock support: vehicle + date string. |
| `RideBookingEntity` | Legacy draft (pickup, option, fare). Not live booking. |
| `RideStatus` (`lib/shared/enums/ride_status.dart`) | **Unused.** `idle, requested, accepted, arriving, inProgress, completed, cancelled`. Do not introduce a second status enum. |

### 4.3 Parsers

**Reusable (extend, do not fork blindly):**

- `RidePlanningParsers.booking` — used by create, active, by-id, cancel.
- `RidePlanningParsers.assignedDriver`
- `RidePlanningParsers.paymentMethod`
- `RidePlanningParsers.serviceQuote` / `routePreview` — quote/route only.

**Active-only / dropped today on booking JSON:**

Parser does **not** read `createdAt`, `updatedAt`, `completedAt`, `cancelledAt`, `cancellationReason`, `cancelledBy`, `paymentStatus`, `distanceKm` / `durationMin` on the booking object, or a nested `vehicle` besides driver fields.

Unknown JSON keys are ignored. If GET by-id already returns extra fields, they are currently discarded.

**Recommendation:** Keep `RidePlanningParsers.booking` as the core mapper. Add optional history fields to `BookingEntity` (or a thin `RideHistoryItem` wrapping `BookingEntity`) when the list/detail payload is confirmed. Do not invent a parallel booking model.

---

## 5. Status mapping

### 5.1 Values handled by Passenger UI

`ridePhaseFromBookingStatus` (`ride_booking_controller.dart`):

| Backend `status` (lowercased) | `RidePlanningPhase` |
|---|---|
| `searching`, `requested`, `pending`, `created` | `bookingSearching` |
| `offered` | `bookingOffered` |
| `accepted` | `driverAccepted` |
| `en_route`, `driver_en_route` | `driverEnRoute` |
| `arrived`, `driver_arrived` | `driverArrived` |
| `in_progress`, `ongoing`, `started` | `rideInProgress` |
| `completed` | `completed` |
| `cancelled`, `canceled` | `cancelled` |
| `expired` | `expired` |
| `no_drivers`, `no_driver` | `noDrivers` |
| `scheduled` | `scheduled` |
| **anything else** | **`bookingSearching` (default)** |

`BookingEntity.isActive` is false for: `completed`, `cancelled`, `canceled`, `expired`, `no_drivers`.

`RideBookingState.hasActiveBooking` is true only for **searching/offered** or **accepted/en_route/arrived/in_progress** with a non-empty `bookingId`.  
`scheduled` is **not** treated as an active Home card.

`RideStatus` shared enum is unused.

### 5.2 Recommended presentation groups (use actual status strings)

**Active** (pin first; one card; `hasActiveBooking` / GET active):

`searching`, `requested`, `pending`, `created`, `offered`, `accepted`, `en_route`, `driver_en_route`, `arrived`, `driver_arrived`, `in_progress`, `ongoing`, `started`

Optional later: `scheduled` as a separate “Upcoming” row, not mixed into Previous.

**Completed:**

`completed`

**Cancelled / Expired:**

`cancelled`, `canceled`, `expired`, `no_drivers`, `no_driver`

Differentiate visually: Completed = muted/success treatment; Cancelled/Expired = red/muted + status chip. Do not hide cancelled rides.

Unknown statuses should **not** inherit the parser default of “searching” on a history list — show raw status or “Unknown”, never as Active.

---

## 6. UI / UX audit

### 6.1 Design language

Premium dark navy (`AppDarkSurfaces.scaffold` `#060B14`, surface `#111827`, border `#2A3548`), white titles, muted `#B8C0D4` / `#9CA3AF`, brand blue `#2F6BFF`.

Patterns: 16–22px rounded cards, 1px border, large w800 titles, emoji/icon wells, floating pill bottom nav.

Feature tokens: `ActivityScreenTokens`, `HomeScreenTokens`, `RideBookingTokens`, `AccountScreenTokens`, `WalletTokens`.

### 6.2 Recommended History page structure (not implemented)

Reuse **Activity** chrome (title “Activity” or keep it; section “Past” → split as below). Account `/ride-history` should share the same body.

```
History / Activity

[Active Ride]                    ← only if hasActiveBooking / GET active
  live status (Finding a driver… / Driver is on the way / …)
  pickup → destination
  driver / vehicle when assigned
  [View ride]                    ← resumeActiveRide(), not a new tracker

Previous rides                   ← paginated, newest first
  date
  pickup → destination
  fare + currency
  status chip (Completed | Cancelled | Expired)
  service name
  tap → read-only detail
```

### 6.3 Existing components to reuse vs build

| Need | Existing | Verdict |
|---|---|---|
| Active card | `HomeActiveRideCard` | Reuse / extract. History copy should emphasize **View ride**; Cancel is optional (already on Home). |
| Previous-ride row | `RideHistoryTile` (bare `ListTile`) | Too thin. Prefer `TransactionTile` / `InboxMessageCard` / `RideOptionCard` visual language: bordered gradient card, title + muted subtitle + trailing amount/status. |
| Support trip row | `RideIssueTripSelector`, `LostItemTripSelector` | Visual hint only; data is mock. |
| Section header | Activity “Past” `Text` w700 | Reuse. Add “Active Ride” as a first section. |
| Empty | `ActivityEmptyState` (“You don't have any recent activity”) | Reuse copy/style; add retry if error. |
| Skeleton | **None in repo** | No shimmer. Use `CircularProgressIndicator` / `AppLoader` / Wallet `LinearProgressIndicator`. |
| Pull-to-refresh | **`RefreshIndicator` unused anywhere** | New for History. Wallet/Inbox/Offers load once in `initState`. |
| Pagination / infinite list | **None** | Closest: `ListView.builder` on Offers/Inbox/Wallet with **full local lists**. |
| Filters | Activity filter sheet | Keep as later enhancement; v1 = all previous rides, newest first. |
| Loading / error | Wallet + Inbox: top `LinearProgressIndicator` + error text + dismiss | Reuse. Offers: centered spinner + bottom error. |

Activity currently uses `SingleChildScrollView` (not a lazy list). History pagination needs `ListView` / `CustomScrollView` + `Sliver`s (active header + previous list).

---

## 7. History item data

| Field | Availability | Notes |
|---|---|---|
| Booking / reference | **AVAILABLE** | `BookingEntity.id`, `bookingNumber`. |
| Date / time | **NEEDS BACKEND** | Not parsed. `RideHistoryItemEntity.completedAt` unused. `searchStartedAt` is local search clock only. |
| Pickup | **AVAILABLE** | Address + lat/lng on booking; `PlaceEntity` after apply. |
| Destination | **AVAILABLE** | Same. |
| Service category | **AVAILABLE** | `serviceCategoryId`, `serviceName`. |
| Status | **AVAILABLE** | `status` string; map via §5. |
| Fare / currency | **AVAILABLE** | `finalFare`, `currency`, `formattedFare`. May be estimate vs charged — confirm backend. |
| Payment status | **NEEDS BACKEND** | Not on `BookingEntity`. |
| Payment method | **AVAILABLE** (code only) | `paymentMethodCode`. Label from GET payment-methods if needed. |
| Driver | **AVAILABLE** when assigned | `AssignedDriverEntity`. Searching rides have none. |
| Vehicle | **AVAILABLE** (partial) | `driver.vehicleName`, `plateNumber`; else `serviceName`. No vehicle id/color/year. |
| Distance | **NEEDS BACKEND** on booking | On `RoutePreviewEntity` / `ServiceQuoteEntity` only. |
| Duration | **NEEDS BACKEND** on booking | Same. |
| Cancellation reason | **NEEDS BACKEND** | Client **sends** `reason` on cancel; response parser does not keep it. Socket cancel does not store reason. |

**NOT REQUIRED** for v1 list card: recording consent, polyline, live driver location, idempotency keys, nearby drivers, chat.

**List card minimum (can start once timestamps exist):** date, pickup → destination, fare, status, service.  
**Detail extras:** driver, vehicle, payment method, distance/duration, cancel reason.

---

## 8. Detail screen

### 8.1 Existing candidates

| Screen | Reuse for previous rides? |
|---|---|
| `RideDetailsScreen` | **Yes as the shell** — currently placeholder. Route already accepts `rideId`. |
| `DriverFoundScreen` | **No.** Live map, socket, call, chat, share, recording consent, **Cancel ride**. |
| `FindingDriverScreen` | **No.** Search + cancel + minimize. |
| `TripDetailsCard` | **No as-is.** Includes Cancel + Share + “Switch” payment. Could inspire a read-only layout. |
| `DriverInfoCard` | **Partial.** Strip `onMessage` / `onCall` for past rides. |
| Report-issue / lost-item trip pickers | **No.** Mock selectors, not receipts. |

### 8.2 Recommended read-only architecture

1. Route: keep `/ride-details?rideId=` (or path param). Guard: if `rideId == activeBookingId` **and** `hasActiveBooking`, `resumeActiveRide()` instead of opening details.
2. Fetch: `GET bookings/{id}` via existing `bookingById` (extend parser). Do **not** subscribe to socket.
3. New read-only widgets (or flags): pickup → destination, status, fare, payment method, driver/vehicle **without** call/chat, distance/duration if present, cancellation reason if cancelled.
4. No: cancel, contact driver, live tracking, recording consent, share-trip-status as an active action.

`GetRideDetailsUsecase` can be wired once the remote is real.

---

## 9. Active → History transition

### 9.1 Current behavior

| Event | What happens | Booking cleared? |
|---|---|---|
| **Ride completed** (socket `booking:status` → `completed`) | Phase `completed`. Socket stopped. `DriverFoundScreen` → `Home`. `hasActiveBooking` becomes false. | **`bookingId` is NOT cleared.** Driver location cleared on apply. |
| **Passenger cancel** (`cancelActiveBooking`) | POST cancel. `_applyBookingEntity` then `_clearActiveBookingFields(cancelled)`. Finding Driver / Driver Found → Home. | **Yes.** |
| **Driver / backend cancel** (socket status `cancelled` / `canceled`) | Same as completed: phase + stop socket + navigate Home. | **`bookingId` NOT cleared.** |
| **Expired / no drivers** | Finding Driver expired UI. `clearTerminalBooking()` on dismiss / retry / change service. | **Yes**, on those actions. |
| **Restore** | GET active; skip if `!isActive`. | Terminal bookings never restored. |

`clearTerminalBooking()` → `_stopLiveUpdates()` + `_clearActiveBookingFields(initial)`. Used for expired UX, **not** automatically on completed.

Home card uses `hasActiveBooking`, so a leftover completed `bookingId` does **not** show as active. History must use the same helper (or GET active), never `bookingId != null` alone.

### 9.2 Recommended History refresh (minimal)

1. History controller listens to `rideBookingControllerProvider`.
2. On transition **into** `isTerminalRidePhase` (or successful passenger cancel): **invalidate/refetch page 0** of previous rides. Do not wait for a history socket.
3. Active section: bind to `hasActiveBooking` + GET active on History appear / pull-to-refresh.
4. Deduplicate: if the history list includes the active `bookingId`, hide that row from Previous.
5. Optional: call `clearTerminalBooking()` after completed/cancelled navigation so session state cannot be mistaken for active. Not required for History if grouping uses `hasActiveBooking`.

No local history cache to invalidate.

---

## 10. Pagination

**Current pattern: none.**

Searched: `pagination`, `pageSize`, `hasMore`, `loadMore`, `AsyncNotifier` list paging, infinite scroll — **no matches**.

Existing lists:

- `ActivityScreen`: `SingleChildScrollView` + map of in-memory items (always empty).
- Wallet / Inbox / Offers: `Notifier` + `loadX()` once; `ListView.builder` over a **full** local/mock list.
- No `RefreshIndicator`.

**Recommendation (first paginated feature in the app):**

- History-specific `Notifier` (match `ActivityController` / `WalletController`, not `AsyncNotifier` — the app does not use `AsyncNotifier` for lists).
- State: `items`, `page` or `cursor`, `hasMore`, `isLoading`, `isLoadingMore`, `errorMessage`.
- First page on appear; load-more when the user scrolls near the end (`ScrollController`).
- Pull-to-refresh resets to page 0.
- Page size / cursor **must follow the backend contract** (not specified in Passenger code).

Do not paginate the Active card.

---

## 11. Cache / restore

| Data | Today | History should |
|---|---|---|
| Active booking | Fetch GET active; hold in `RideBookingState`; restore on splash/login/Home/resume. **Not** persisted locally. | Same: session memory + GET active on History appear. |
| Quotes / places | In-memory in `RideBookingState`. | N/A |
| Account / wallet / inbox / activity | Local stubs; some in-memory lists. | Do not persist history to SharedPreferences. |
| Secure storage | JWT / session only. | Do not store ride receipts there. |

**Follow existing architecture:**

- **Fetch fresh** when History opens and on pull-to-refresh.
- **Cache in Riverpod state** for the session (page buffer).
- **Do not persist locally.** Backend remains authoritative (same as active booking).

Stale-while-revalidate is unused; do not add it for v1.

---

## 12. Error / offline UX

### 12.1 Existing patterns

| Pattern | Where | Reuse |
|---|---|---|
| Centered `CircularProgressIndicator` | Offers, many forms, `AppLoader` | First-page load |
| Top `LinearProgressIndicator` | Wallet, Inbox | Refresh / overlay |
| Inline `errorMessage` + dismiss | Wallet, Account, Activity | Yes |
| “Could not … Try again.” | Booking, cancel, filters, inbox | Copy style |
| Network mapper | `PassengerApiErrorMapper`: timeout, connection error, 401, 404, 429 | History Dio calls |
| GET active 404 | Treated as **no active booking**, not an error | Keep for Active section |
| Socket reconnect banner | Driver Found: “Reconnecting… ride status preserved” | Active ride only, not History list |
| Empty copy | `ActivityEmptyState` | No rides |
| Retry button | Finding Driver expired “Try again”; recording consent retry | History error: retry fetch |
| Pull-to-refresh | **Absent** | Add for History |
| Offline queue | **Absent** | Do not queue history writes |

### 12.2 Recommended History states

1. **Loading:** spinner or linear bar (no skeleton library).
2. **Empty:** reuse Activity empty copy if no active and no previous.
3. **Error:** mapped network message + Retry. Keep last good list if refresh fails.
4. **Offline:** same as connection error; Active section can still show in-memory `hasActiveBooking`.
5. **Pull-to-refresh:** refetch active + page 0.
6. **404 on detail:** “Ride not found” + back. 404 on active = hide Active card.

---

## 13. Tests

### 13.1 Existing (relevant, not History-specific)

| Area | File | Coverage |
|---|---|---|
| Active restore | `test/features/ride_booking/active_booking_ux_test.dart` | Restore searching/accepted without nav; Home card widget; cancel clears `bookingId`; minimize keeps booking; 429 cancel preserves booking; `ACTIVE_BOOKING_EXISTS` path. |
| Phases / statuses | `test/features/ride_booking/active_ride_flow_test.dart` | `ridePhaseFromBookingStatus` including `completed` / `cancelled` / `expired`; `hasActiveBooking` helpers. |
| Parsers | `test/features/ride_booking/ride_planning_parsers_test.dart` | Place, route, quote, `BookingEntity.isActive` excludes completed/cancelled. |
| Socket / booking id filter | Same parsers test | Ignores other `bookingId`. |
| Consent + restore | `test/features/ride_booking/recording_consent_test.dart` | Restore + cancelled booking entity in fakes. |
| Navigation guards | `test/app/router/route_guards_test.dart` | Auth vs splash/home; **not** History routes. |
| Pickup / quote | `pickup_*_test.dart`, `plan_ride_search_test.dart` | Planning only. |

**No tests** under `test/features/ride_history/` or `test/features/activity/`.

### 13.2 History tests needed later

1. Active card appears first iff `hasActiveBooking`; hidden when terminal leftover `bookingId` exists.
2. Previous list excludes the active `bookingId` (no duplicate).
3. Sort: previous newest-first (once timestamps exist).
4. Status chips: `completed` vs `cancelled`/`canceled` vs `expired`/`no_drivers`.
5. Parser: history extras (dates, cancel reason, distance) when backend shape is known; unknown keys ignored.
6. Pagination: first page, load-more, `hasMore` false, refresh resets.
7. Terminal event → history refetch (listener).
8. Detail: GET by-id; **no** cancel/call/socket.
9. Active row tap → `resumeActiveRide` / Finding Driver or Driver Found, not `RideDetailsScreen`.
10. Empty, error, retry, 404 detail.
11. Account `/ride-history` and Activity tab share the same provider/list.
12. `RideStatus` unused enum must not fork mapping.

---

## 14. Integration blueprint (audit only)

When implementation starts (separate change):

1. Confirm backend **paginated list** contract. Do not assume `/rides/history` from docs. Prefer extending the existing `/bookings` family if that is what backend ships.
2. Implement `RideHistoryRemoteDatasource` with Dio (like `PassengerRideRemoteDatasourceImpl`), not an empty stub.
3. Extend `BookingEntity` + `RidePlanningParsers.booking` for timestamps and other confirmed fields.
4. Add `RideHistoryController` (Notifier): active snapshot from `rideBookingControllerProvider` + paginated previous from API.
5. Replace `ActivityScreen` empty “Past” (or `RideHistoryScreen`) with Active + Previous. Point Account Ride History at the same UI.
6. Build read-only `RideDetailsScreen`; never open `DriverFoundScreen` for terminal rides.
7. On terminal phase / successful cancel: refresh page 0.
8. Add `RefreshIndicator` + infinite scroll; first pagination pattern in the app.
9. Add tests in §13.2.

---

## Gap checklist

| Gap | Severity |
|---|---|
| No implemented history **list** HTTP call | Blocker |
| `RideHistoryScreen` / `RideDetailsScreen` placeholders | Blocker |
| `RideHistoryItemEntity` too thin | Blocker for a useful list |
| Booking parser missing date/time, cancel reason, payment status, distance/duration | Blocker for full cards/detail |
| Activity tab never loads a real feed | Blocker for the nav entry users will tap |
| Dual entry (`/activity` vs `/ride-history`) unwired to one list | High |
| No pagination / pull-to-refresh patterns to copy | Medium (must be designed) |
| Support trip lists are mock | Medium (can share history API later) |
| Completed/driver-cancel leaves `bookingId` in session | Medium (mitigate with `hasActiveBooking`) |
| `scheduled` not represented on Home/History | Low for v1 |
| Unused `RideStatus` enum | Low (do not use) |
| `ActivityPlaceholderScreen` dead code | Low |

**Ready to reuse immediately:** active booking restore, `HomeActiveRideCard`, status mapping, `GET bookings/active`, `GET bookings/{id}`, `RidePlanningParsers.booking`, design tokens, Activity empty state, Account navigation.

---

## Final status

**AUDIT COMPLETE — PASSENGER HISTORY GAPS:** no list/history API in code, placeholder History/Details UI, Activity feed is an empty stub, history models and booking parser lack timestamps/cancel/payment/distance, and there is no pagination pattern yet. Active booking state, Home active card, and GET-by-id are sufficient foundations once a backend list contract exists.
