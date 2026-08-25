# Passenger Ride History Implementation Report

**Scope:** Passenger Flutter app only. Backend and Driver Android were not modified.  
**Date:** 18 August 2026

**Final status:** READY FOR PASSENGER RIDE HISTORY RETEST

---

## Shared Activity / History architecture

One pipeline, one controller, one list body.

| Entry | Route | UI |
|---|---|---|
| Bottom-nav Activity | `/activity` | `ActivityScreen` → `RideHistoryBody(title: Activity)` |
| Account → Ride History | `/ride-history` | `RideHistoryScreen` → same `RideHistoryBody(title: Ride History)` |

Both screens watch `rideHistoryControllerProvider`. Previous rides are not stored twice.

Active ride is **not** loaded from the history list. It stays on `rideBookingControllerProvider` / `GET /bookings/active`. The History body only **displays** `HomeActiveRideCard(showCancel: false)` when `RideBookingState.hasActiveBooking` is true.

Previous rides come from `GET /api/v1/passenger/bookings?page=&limit=&filter=`.

---

## API integration

Uses the existing authenticated `ApiClient` / Dio stack. No second Dio client. No `/rides/history`.

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/v1/passenger/bookings/active` | Active card (existing restore) |
| GET | `/api/v1/passenger/bookings?page=1&limit=20&filter=all\|completed\|cancelled` | Previous rides |
| GET | `/api/v1/passenger/bookings/:bookingId` | Read-only detail |

`RideHistoryRemoteDatasourceImpl` performs the list and detail calls. Placeholder `fetchRides() → []` / `fetchRide() → null` is gone.

Activity no longer loads the local empty activity datasource for rides.

---

## Pagination

Envelope:

```json
{
  "success": true,
  "data": [...],
  "metadata": { "pagination": { "page": 1, "limit": 20, "total": 50, "totalPages": 3 } }
}
```

- Default `page=1`, `limit=20`
- `loadMore()` when `page < totalPages` and near the bottom of the list
- Append by booking id; duplicate ids are ignored
- Filter change clears the list and fetches page 1
- Pull-to-refresh fetches page 1 without dropping rows on failure

---

## Active-first behavior

1. If `hasActiveBooking`, the **Active Ride** section is rendered first.
2. Previous rides are below, newest-first from the backend.
3. If the history page includes the active `bookingId`, that row is hidden client-side.
4. Tapping the active card / **View ride** calls `resumeActiveRide()` (Finding Driver or Driver Found). It does **not** open read-only detail.

History active card reuses `HomeActiveRideCard` without Cancel.

---

## `no_drivers` mapping

Backend status `no_drivers` is **Expired** in the UI, never Completed and never Cancelled.

Copy: “No driver was available for this ride.”

The `cancelled` filter still returns cancelled + `no_drivers` (backend contract). Chips stay distinct: **Cancelled** vs **Expired**.

Unknown historical statuses are title-cased. They are **not** mapped to searching / active.

---

## Dedupe

- History append uses a booking-id set.
- `RideHistoryState.previousRides(activeBookingId:)` strips the live booking from Previous.
- Active data is never copied into History controller state.

---

## Terminal refresh

`RideHistoryController` listens to `rideBookingControllerProvider`.

When `hasActiveBooking` goes from true → false (`completed`, `cancelled`, `no_drivers` / expired):

- Active card hides
- History `refresh()` runs once per `bookingId:phase` key (no extra sockets)

Refresh also calls `restoreActiveBooking(navigate: false)` then reloads page 1 of the current filter. If the history request fails, existing rows and the active card are kept.

---

## Detail screen

`RideDetailsScreen` is a real read-only snapshot from `GET /bookings/:bookingId`.

Shows: status, booking number, timestamps, pickup, destination, service, fare, payment, driver, vehicle, distance/duration, cancellation reason, “Recording available” when `recording.available` is true.

Does **not** show: Cancel, live map, Call, Chat, recording consent, live location, active controls.

If `rideId` equals the current active booking id, it resumes the live ride instead.

---

## Files changed

### Domain / parsers
- `lib/features/ride_booking/domain/entities/ride_planning_entities.dart` — history fields + `BookingVehicleEntity`
- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` — nested booking/history payload
- `lib/core/network/api_response_parser.dart` — `bookings` list key

### History feature
- `lib/features/ride_history/data/datasources/ride_history_remote_datasource.dart`
- `lib/features/ride_history/data/repositories/ride_history_repository_impl.dart`
- `lib/features/ride_history/domain/repositories/ride_history_repository.dart`
- `lib/features/ride_history/domain/ride_history_filter.dart`
- `lib/features/ride_history/domain/entities/pagination_meta.dart`
- `lib/features/ride_history/domain/entities/ride_history_page.dart`
- `lib/features/ride_history/domain/usecases/list_ride_history_usecase.dart`
- `lib/features/ride_history/presentation/providers/ride_history_dependencies.dart`
- `lib/features/ride_history/presentation/providers/ride_history_controller.dart`
- `lib/features/ride_history/presentation/providers/ride_history_provider.dart`
- `lib/features/ride_history/presentation/ride_history_presentation.dart`
- `lib/features/ride_history/presentation/theme/ride_history_tokens.dart`
- `lib/features/ride_history/presentation/widgets/ride_history_body.dart`
- `lib/features/ride_history/presentation/widgets/ride_history_card.dart`
- `lib/features/ride_history/presentation/widgets/ride_history_tile.dart`
- `lib/features/ride_history/presentation/screens/ride_history_screen.dart`
- `lib/features/ride_history/presentation/screens/ride_details_screen.dart`

### Other UI
- `lib/features/activity/presentation/screens/activity_screen.dart` — real history body
- `lib/features/home/presentation/widgets/home_active_ride_card.dart` — `showCancel`, driver/fare lines

### Removed stubs
- `lib/features/ride_history/domain/entities/ride_history_item_entity.dart`
- `lib/features/ride_history/data/models/ride_history_item_model.dart`
- `lib/features/ride_history/domain/usecases/get_ride_details_usecase.dart` (replaced in `list_ride_history_usecase.dart`)

Support/lost-item mock trip selectors were not changed.

---

## Tests

New:

- `test/features/ride_history/ride_history_presentation_test.dart`
- `test/features/ride_history/ride_history_controller_test.dart`

Covered: active-first, hide active section, dedupe, completed/cancelled/`no_drivers`→Expired, page 1, page 2 append, duplicate ids, `totalPages` stop, filter reset, cancelled filter includes Expired, pull-to-refresh page reset, terminal refresh, history failure keeps active, empty previous, shared controller, View ride resumes live ride, read-only detail + cancellation reason, timestamps.

Existing restore and recording-consent tests still pass.

---

## Analyze / test / build

```
flutter analyze     → No issues found
flutter test        → All tests passed! (155)
flutter build apk --debug → Built build\app\outputs\flutter-apk\app-debug.apk
```

Gradle printed existing Kotlin plugin warnings; they are unrelated to this work.

---

## Manual QA result

Device/manual pass of A–G was **not** run in this session. Automated tests cover the same behaviors (active-first, dedupe, status chips, pagination, terminal refresh, shared controller, resume vs detail).

**Retest on device:**

A. Active card first, previous below, no duplicate  
B. Complete → active gone, completed row first in Previous  
C. Cancel → Cancelled row first  
D. `no_drivers` → Expired  
E. >20 rides, scroll loads page 2, no duplicates  
F. Restart: `/active` restores live ride; History loads independently  
G. Account → Ride History matches Activity  

---

READY FOR PASSENGER RIDE HISTORY RETEST
