# RYDU PASSENGER AIRPORT FARE INTEGRATION REPORT

**Repository:** Rydu_User (Passenger Flutter)  
**Date:** 2026-09-11  
**Scope:** Display backend airport fare breakdown. No local geofence, fee math, FX, or SAN hardcode.

**Final status:**  
`RYDU PASSENGER AIRPORT FARE INTEGRATION COMPLETE`

Physical device QA was **not** performed. Checklist is in section 14.

---

## 1. Current Passenger fare flow audit

Fare enters the app from the backend only.

| Step | Where | What |
|------|--------|------|
| Locations | `PlaceEntity` / `LatLngWaypoint` | Coordinates required. Optional `placeId` from Places details. GPS pickup often has empty `placeId`. |
| Route preview | `POST /api/v1/passenger/routes/preview` | Pickup/dropoff lat/lng + optional address/placeId. No fare. |
| Quote | `POST /api/v1/passenger/bookings/quote` | Same waypoints. Response `quotes[].finalFare` (+ currency, originalFare, discount). |
| UI mapping | `rideOptionFromQuote` | `price = "$currency ${finalFare}"`. Cards show this total. |
| Selection | `RideBookingController.selectVehicle` | `estimatedFare = option.price` (formatted total). |
| Booking create | `POST /api/v1/passenger/bookings` | Service id, waypoints, payment method. **No client fare/amount.** |
| Payment | Stripe PaymentSheet | Uses backend `clientSecret` / PaymentIntent. Flutter does not add airport fee to a payment amount. |
| History | `BookingEntity.formattedFare` | Single total from `fare.amount` / `finalFare`. |

User-visible price before booking:

1. **Ride selection** — each `RideOptionCard` shows total; bottom bar is payment + Choose. **This is the primary confirmation surface** (`continueToConfirmPickup` often calls `confirmBooking()` directly).
2. **Confirm pickup** — fallback pa                                                                   `th; showed `vehicle · estimatedFare`.
3. Finding-driver / driver-found / home active card — total string only.
4. Ride history list — total. Detail — single `Fare` row.

---

## 2. Location / Place ID behavior

Already correct; unchanged:

```dart
LatLngWaypoint.toJson()
  latitude, longitude
  address if non-empty
  placeId if non-empty   // omitted when null/empty
```

Quote and booking both use this. GPS / missing Place ID remains valid. Place IDs are never derived from address text. Passenger does **not** send `airportId`, `airportFee`, or `airportTripType`.

---

## 3. Quote contract changes

Parser (`RidePlanningParsers.serviceQuote` / `bookingQuote`) now reads, when present:

| Field | Aliases |
|-------|---------|
| `regularFare` | `regular_fare` |
| `airportFee` | `airport_fee` |
| `airport` | `{ id, code, name, tripType }` plus `airportId` / `airportCode` / `iata` / `airportName` / `type` |
| `finalFare` | existing `fare` / `price` (numeric). Nested `fare.amount` if `fare` is an object. |

Envelope-level `airport` / `airportFee` / `regularFare` apply to services that omit them.

Absent `airportFee` → `0`. Absent `airport` → `null`. Older quotes without these fields still parse.

---

## 4. Model changes

- `AirportQuoteEntity` — backend classification only.
- `ServiceQuoteEntity` — `regularFare`, `airportFee`, `airport`; `finalFare` remains passenger total.
- `RideOptionEntity` — same fields for UI.
- `BookingEntity` — optional snapshot for history/detail **if the backend sends it**.

Display:

- Total = backend `finalFare` (never Stripe-side `regular + fee`).
- Trip fare line = `regularFare`, or `finalFare - airportFee` only as a **display** fallback.
- Breakdown shown only when `airportFee > 0`.

---

## 5. Airport pickup UI

When `tripType` is pickup (or `pick_up` / `airport_pickup`):

`{CODE} Airport Pickup Fee`

Example: `SAN Airport Pickup Fee` — **code comes from the quote**, not a Flutter constant.

Shown once on ride selection (above payment) and on confirm pickup if that screen is used. Option cards still show **total only**.

---

## 6. Airport drop-off UI

`{CODE} Airport Drop-Off Fee`

Raw `pickup` / `dropoff` enums are not shown. If code is missing, backend `name` is used.

---

## 7. Regular-trip behavior

`airport == null` and `airportFee == 0` (including currency-mismatch quotes that omit the public airport object):

- No airport row
- No `Airport Fee ৳0`
- Cards and totals unchanged (`BDT 1500.00`)

---

## 8. Currency behavior

Uses quote/booking `currency`. Default remains `BDT` when missing (existing parser). Does **not** switch to USD because the airport is in the US. No conversion. Unknown codes use the same `"$currency ${amount}"` format.

---

## 9. Payment-flow impact

**None** on Stripe amounts. `BookingCreateRequest` still has no `amount` / `fare` / `airportFee`. PaymentSheet still uses backend `clientSecret`. UI total is `option.price` / `finalFare`.

---

## 10. Booking-create behavior

Unchanged payload: coordinates, optional placeIds, service, payment method. Backend redetects/snapshots airport. Flutter does not requote a client-side airport fee.

---

## 11. History / detail support status

- **List cards:** total only (`formattedFare`).
- **Detail:** if booking JSON includes `fare.airportFee` + airport object (or top-level equivalents), detail shows Trip Fare / Airport Fee / Total.
- **If history API still only returns a total today:** no invented breakdown; documented as remaining backend work. Quote/booking flow does not depend on this.

Active ride screens were left as total-only (they already show a single fare string).

---

## 12. Files changed

| File | Role |
|------|------|
| `lib/features/ride_booking/domain/entities/ride_planning_entities.dart` | Airport entity; quote/booking fare fields |
| `lib/features/ride_booking/domain/entities/ride_option_entity.dart` | Option-level fare fields |
| `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` | Parse airport quote/booking snapshot |
| `lib/features/ride_booking/presentation/models/ride_vehicle_option.dart` | Map quote → option / extras |
| `lib/features/ride_booking/presentation/models/airport_fare_presentation.dart` | Labels + money |
| `lib/features/ride_booking/presentation/widgets/airport_fare_breakdown.dart` | Breakdown widget |
| `lib/features/ride_booking/presentation/screens/ride_selection_screen.dart` | Show breakdown once |
| `lib/features/ride_booking/presentation/screens/confirm_pickup_screen.dart` | Show breakdown if used |
| `lib/features/ride_history/presentation/screens/ride_details_screen.dart` | Snapshot breakdown if present |
| `test/features/ride_booking/airport_fare_test.dart` | Cases A–U |

Not changed: Stripe, Auth0, maps camera, route preview API, booking create shape (except existing optional placeId), Driver apps, backend.

---

## 13. Tests / analyze / build

```
dart analyze [changed files]   → no errors
flutter test test/features/ride_booking test/features/ride_history
  → 212 passed
flutter test test/features/ride_booking/airport_fare_test.dart
  → 27 passed
```

Covered: A–U (regular/airport parse, totals, labels, Place IDs, no geofence/FX/SAN hardcode, PaymentIntent unchanged, legacy quotes).

No full `flutter build apk` in this task.

---

## 14. Physical QA checklist (not executed)

1. Regular BDT ride — no airport row; total matches quote.
2. BDT-configured airport pickup — `{CODE} Airport Pickup Fee` and total = trip + fee.
3. BDT-configured airport drop-off — Drop-Off Fee label; total matches backend.
4. Pickup without Place ID (GPS) — quote/booking still succeed.
5. Drop-off without Place ID — still valid.
6. Admin changes airport fee — **new** quote shows new fee.
7. Existing booking keeps **old** snapshotted fee.
8. Inactive airport → regular trip UI.
9. Unsupported/USD airport in current BDT market → no airport fee row (backend omits it).
10. Stripe PaymentIntent amount equals displayed total.

---

## 15. Exact remaining work

1. **Live backend verification** that quote JSON uses these property names (or the aliases already parsed). If production uses different keys, add them to the parser only.
2. **History API** should include `regularFare` / `airportFee` / `airport` on booking detail if product wants breakdown after the trip. Until then, history shows total only.
3. **Physical QA** on the checklist above.
4. Confirm envelope vs per-service airport fields in the deployed Passenger quote contract.

---

**RYDU PASSENGER AIRPORT FARE INTEGRATION COMPLETE**
