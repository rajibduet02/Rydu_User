# RYDU Passenger Soft Meter Implementation Report

Passenger Flutter app (`Rydu_User`) now shows a **live Soft Meter preview** on the existing On-Demand active-ride screen. Backend, Driver Android, Driver iOS, and Admin were **not** modified.

Live metered charging remains **disabled**. The booking quote and Stripe PaymentSheet flow are unchanged. The provisional meter amount is never treated as the amount the passenger must pay.

---

## Status

**RYDU PASSENGER SOFT METER LIVE VISIBILITY COMPLETE — DEVICE QA REQUIRED**

Physical-device QA (running/paused meter with a real driver session, reconnect, background restore) has not been run on a phone.

---

## Backend contract inspected

`GET /api/v1/passenger/bookings/:bookingId/meter` is registered on the live DriveWize API (`http://103.208.181.253:3000`). An unauthenticated call returns **401**, not 404.

Authenticated response bodies could not be dumped from this checkout (no passenger JWT in the repo; sibling Driver/Admin trees here do not contain Soft Meter models). Parsing therefore follows:

- The passenger task contract (`meter: null`, running / paused / stopped / finalized / review-required, `settlement`, `quotedFareUnchanged`, `fareFrozen`, `stateVersion`)
- The existing DriveWize `{ success, data }` envelope used by booking payment and recording consent
- The existing passenger parser convention: **camelCase plus snake_case for the same key only**

No tariff, extra, or payment fields were invented.

---

## Files changed

### New

- `lib/features/ride_booking/domain/entities/passenger_meter_entities.dart` — snapshot, status, settlement flags, `stateVersion` merge
- `lib/features/ride_tracking/presentation/widgets/soft_meter_panel.dart` — compact On-Demand preview panel
- `test/features/ride_booking/soft_meter_test.dart` — parser, controller, UI tests
- `RYDU_PASSENGER_SOFT_METER_IMPLEMENTATION_REPORT.md`

### Updated (existing architecture reused)

- `lib/core/constants/passenger_api_paths.dart` — `bookingMeter(id)`
- `lib/core/network/passenger_socket_service.dart` — `meter:state` / `meter:fare`
- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` — `passengerMeter`
- `lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart`
- `lib/features/ride_booking/domain/repositories/ride_booking_repository.dart`
- `lib/features/ride_booking/data/repositories/ride_booking_repository_impl.dart`
- `lib/features/ride_booking/domain/entities/ride_planning_entities.dart` — export
- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `lib/features/ride_tracking/presentation/screens/driver_found_screen.dart`
- `lib/features/ride_tracking/presentation/widgets/trip_details_card.dart` — booking-quote label
- Test fakes that implement `RideBookingRepository`

No new app, booking flow, PaymentIntent, Checkout Session, or poll loop.

---

## UI integration

The panel is on **`DriverFoundScreen`** (accepted → in progress), in the existing bottom sheet, above the status and driver cards.

Shown only when:

- The booking is an assigned On-Demand ride
- A meter **session** exists (`meter != null` / has session fields)
- The session is **not** Walk-Up

Copy:

| State | Passenger wording |
|---|---|
| Running / stopped / finalized | “Soft Meter” + “Provisional meter fare — not an additional charge” |
| `paused` or `fareFrozen: true` | “Soft Meter Paused” + “Distance and time charges are suspended.” |
| Review required | “This meter is marked for review. It is not a new charge.” |

Available backend values, when present:

- Provisional fare (USD when the payload says so)
- Meter status
- Traveled distance in miles
- Trip elapsed time
- Chargeable elapsed time
- Pause duration

The original **booking quote** stays visible:

- Soft Meter panel row: `Booking quote`
- Expanded trip details: `Booking quote · Use {paymentMethod} {estimatedFare}`

The provisional fare is **not** labeled as the amount due. There are **no** Pause / Resume / Pay now controls.

`FindingDriverScreen` is unchanged (pre-assignment). Ride history / completed details still use `formattedFare` / `finalFare`.

---

## REST API usage

Authenticated passenger Dio client (existing JWT interceptor).

| Method | Path | Role |
|---|---|---|
| GET | `/api/v1/passenger/bookings/{bookingId}/meter` | Authoritative snapshot |

Called from `RideBookingController.refreshMeterFromBackend()` when:

- An assigned booking is restored
- Socket reconnects
- The ride enters `in_progress`
- `DriverFoundScreen` opens or returns to foreground

Not called as a high-frequency poll.

404 → empty session (`meter: null` equivalent). Other errors keep the last snapshot and **do not** block ride tracking, completion, cancel, or Stripe.

`quotedFareUnchanged` and `settlement` are stored. They never overwrite `estimatedFare` and never start a charge.

---

## Socket.IO handling

Reuses `PassengerSocketService` (JWT `auth.token`, `setActiveBookingId`).

| Event | Handling |
|---|---|
| `meter:state` | Full/partial session merge |
| `meter:fare` | Fare/status merge with the same versioning rules |

Association:

1. Socket service drops payloads whose `bookingId` / `booking_id` is not the active booking
2. Nested `meter.bookingId` is lifted for that filter
3. Controller rejects a second time if the parsed snapshot belongs to another booking

`stateVersion`: an incoming socket update with a **lower** version is ignored. An older `running` event cannot replace a newer `paused` state.

REST refresh after reconnect / foreground is the recovery path. Driver location and booking status streams are unchanged.

---

## Pause / Resume display behavior

| Backend | Passenger UI |
|---|---|
| `status: paused` | Soft Meter Paused + frozen server fare |
| `fareFrozen: true` | Same paused display even if status is still running |
| Later `running` with a **newer** `stateVersion` | Status updates from the server snapshot |
| Passenger action | None. No pause/resume API is called |

Fare and distance are **not** calculated on the device.

---

## Booking lifecycle

| Booking state | Meter |
|---|---|
| Searching / offered | Hidden |
| Assigned / in progress + session | Shown (On-Demand only) |
| Walk-Up `sessionType` | Hidden |
| Completed | Panel hidden. Quoted fare / payment state unchanged. Completion is not blocked if meter REST fails |
| Cancelled / expired / booking change | Meter state cleared |

---

## Stripe compatibility

Unchanged:

- Card booking create still uses existing PaymentSheet + `GET .../bookings/:id/payment`
- No new PaymentIntent or Checkout Session
- Meter refresh does **not** call `bookingPayment`
- Finalized non-billable meters (`settlement.billable == false`) are not treated as a passenger charge
- `estimatedFare` remains the booking quote even when the meter moves

---

## Test results

`flutter analyze` on touched files: **No issues found.**

| Suite | Result |
|---|---|
| `test/features/ride_booking/soft_meter_test.dart` | Pass |
| `test/features/ride_booking/recording_consent_test.dart` | Pass |
| `test/features/ride_booking/stripe_phase_c_test.dart` | Pass |
| `test/features/ride_booking/active_booking_ux_test.dart` | Pass |
| `test/features/ride_booking/autocomplete_country_test.dart` | Pass |
| `test/features/ride_booking/pickup_resolution_controller_test.dart` | Pass |
| `test/features/ride_history/ride_history_controller_test.dart` | Pass |

Soft Meter cases covered:

- No meter session
- Running meter
- Paused meter
- Frozen fare (`fareFrozen`)
- Resume from a newer `stateVersion`
- Stale `stateVersion` rejection
- Unrelated booking event rejection
- REST restoration
- Quoted fare unchanged
- No passenger Pause/Resume controls
- Meter failure does not call Stripe `bookingPayment`

---

## Build results

```
flutter build apk --debug
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

| Artifact | Value |
|---|---|
| Path | `build/app/outputs/flutter-apk/app-debug.apk` |
| Size | 215,585,118 bytes (~206 MB) |
| Built | 2026-10-29 23:27 |

Gradle printed the existing Flutter Kotlin Gradle Plugin migration warning. It did not fail the build.

---

## Known limitations

1. **No authenticated live payload capture.** Parser keys are the documented contract plus camel/snake aliases already used in this app. Unexpected backend names simply leave that row blank.
2. **Live metered charging is still off.** Provisional fare is preview-only.
3. **Walk-Up is hidden**, including if a walk-up session is accidentally attached to this passenger booking.
4. **No local ticking.** Elapsed times are the last server values, not a client timer.
5. **Device QA not run.** Running/paused/resume against a real driver meter session still needs a phone.
6. **History/receipt UI** still shows the original quoted `finalFare`, by design.
7. **Finding Driver** does not show the meter (no trip session yet).

---

## Out of scope (honored)

- Backend, Driver Android, Driver iOS, Admin Web
- Enabling metered charging
- Changing the quoted-fare Stripe workflow
- Unapproved tariff rules
- Passenger Pause/Resume controls
- A second payment at trip completion
