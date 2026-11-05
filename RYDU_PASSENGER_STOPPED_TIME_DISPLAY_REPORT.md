# RYDU Passenger Soft Meter Stopped-Time Fare Display

Passenger Flutter (`Rydu_User`) now shows the backend **distance + stopped-time fare breakdown** on the existing On-Demand Soft Meter panel.

No new meter module. No local tariff math. Quoted-fare Stripe payments are unchanged. Walk-Up stays hidden.

---

## Status

**STOPPED-TIME DISPLAY COMPLETE — DEVICE QA REQUIRED**

Physical-device QA against a live driver meter session has not been run.

---

## Files changed

| File | Change |
|---|---|
| `lib/features/ride_booking/domain/entities/passenger_meter_entities.dart` | Optional stop/fare-cent fields, formatters, merge |
| `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` | Nested `fare` / `fareBreakdown` + snake_case |
| `lib/features/ride_tracking/presentation/widgets/soft_meter_panel.dart` | Compact breakdown rows + notices |
| `test/features/ride_booking/soft_meter_test.dart` | Stopped-time parser, freeze, UI, payment-safety tests |
| `RYDU_PASSENGER_STOPPED_TIME_DISPLAY_REPORT.md` | This report |

Unchanged: REST path, socket event names, `stateVersion` ordering, reconnect/foreground refresh, Stripe, booking quote, DriverFound screen structure.

---

## API fields parsed

Read from GET `/api/v1/passenger/bookings/:bookingId/meter` and `meter:state` / `meter:fare`. Missing keys stay **null**. Explicit `0` is kept.

### Meter-level

| Field | Aliases / nesting |
|---|---|
| `eligibleStoppedSeconds` | `eligible_stopped_seconds` |
| `waitingSeconds` | `waiting_seconds` (display fallback only) |
| `excludedStopSeconds` | `excluded_stop_seconds` |
| `stopStreak` | `stop_streak` |
| `stopPolicy` | `stop_policy` (string, or object `name`/`label`/`id`/`code`) |

### Fare-level

Looked up on nested `fare`, `fareBreakdown` / `fare_breakdown`, then the meter object, then the envelope.

| Field | Aliases |
|---|---|
| `flagDropCents` | `flag_drop_cents` |
| `distanceChargeCents` | `distance_charge_cents` |
| `waitingChargeCents` | `waiting_charge_cents` |
| `totalCents` | `total_cents` |
| `billedStoppedMinutes` | `billed_stopped_minutes` |
| `unbilledStoppedRemainderSeconds` | `unbilled_stopped_remainder_seconds` |
| `waitingPolicyApplied` | `waiting_policy_applied` |
| `distanceTimePolicyApplied` | `distance_time_policy_applied` |

Cents are **displayed** as `USD (cents / 100)`. That is formatting, not a tariff calculation. Flag drop, distance, and waiting are never summed in Flutter.

`waitingSeconds` is used for “Eligible stopped time” **only when** `eligibleStoppedSeconds` is absent.

---

## UI behavior

Existing `SoftMeterPanel` on `DriverFoundScreen`.

Always shown when the panel is visible:

- “Provisional meter fare — not an additional charge”
- “Stopped-time charges apply only when the vehicle is confirmed stationary.”
- Booking quote (unchanged `estimatedFare`)

When the backend supplies the value (including zero):

- Combined provisional fare (`totalCents` if present, else `provisionalFare`)
- Initial flag drop
- Distance traveled
- Distance charge
- Eligible stopped time
- Stopped-time charge
- Billed stopped minutes
- Unbilled remainder

Absent optional fields omit the row.

### Pause / Resume

- Title **Soft Meter Paused**
- “Distance and time charges are suspended.”
- Latest server fare and stopped-time values stay on screen
- No passenger-device GPS / local timer
- Stale lower `stateVersion` events cannot replace a newer paused snapshot
- Resume uses a newer backend snapshot (socket or REST)

No Pause/Resume, Checkout, Pay now, or QR controls.

Walk-Up `sessionType` still hides the panel.

---

## Synchronization

Unchanged:

- `GET /api/v1/passenger/bookings/:bookingId/meter`
- Socket `meter:state` / `meter:fare`
- Booking-id filter (socket + controller)
- `stateVersion` stale rejection
- REST refresh on restore, reconnect, foreground, and `in_progress`
- No extra polling
- Meter REST failure does not call Stripe or change the quoted fare

---

## Test results

`flutter analyze` on touched files: **No issues found.**

| Suite | Result |
|---|---|
| `test/features/ride_booking/soft_meter_test.dart` | Pass |
| `test/features/ride_booking/stripe_phase_c_test.dart` | Pass |

Stopped-time cases:

- Combined distance + stopped-time display
- Explicit zero waiting charge (`USD 0.00`, not hidden)
- Backend billed stopped minutes
- Unbilled partial-minute remainder
- Missing optional fields omit rows
- Paused fare and stopped time stay frozen vs stale socket
- Reconnect REST refresh (no `bookingPayment` call)
- Unrelated booking id ignored
- Quoted fare unchanged
- Walk-Up with fare cents stays hidden; no Checkout/QR

---

## Build results

```
flutter build apk --debug
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

| Artifact | Value |
|---|---|
| Path | `build/app/outputs/flutter-apk/app-debug.apk` |
| Size | 215,609,211 bytes (~206 MB) |
| Built | 2026-11-02 14:47 |

Existing Kotlin Gradle Plugin warning only; build succeeded.

---

## Known limitations

1. Eligible stopped time does **not** tick on the passenger device. It updates when the backend sends a new snapshot.
2. `stopStreak`, `excludedStopSeconds`, `stopPolicy`, and policy-applied flags are parsed but not shown as extra rows (panel stays compact).
3. Combined fare prefers `totalCents` when present. Flutter does not reconcile it against flag drop + distance + waiting.
4. Device QA against a live driver session is still required.
5. Live metered charging remains disabled. The passenger is not charged the provisional meter amount.

---

## Backend contract mismatches

Local Driver Android / Driver iOS trees in this workspace **do not contain** `eligibleStoppedSeconds` / `waitingChargeCents` (or the other new keys). Those apps were not modified.

Passenger parsing therefore follows:

- This task’s field list
- Existing DriveWize `{ success, data }` envelope
- Nested `fare` / `fareBreakdown` and snake_case aliases used elsewhere in the passenger client

If the live backend nests cents under a different object name than `fare` / `fareBreakdown`, those rows will stay blank until the key is added to the existing parser. No extra keys were invented.

Authenticated live payloads were not dumped (no passenger JWT in this repo).

---

## Out of scope (honored)

- Backend, Driver Android, Driver iOS, Admin Web
- Flutter tariff / stationary / GPS calculations
- Production metered charging
- Quoted-fare Stripe / PaymentIntent / completion changes
- Walk-Up payment UI
- Checkout button or payment QR
