# RYDU Passenger Payment Method Parsing Fix Report

Passenger Flutter app (`Rydu_User`) was treating a valid payment-methods response as an empty list. That made `cardReturnedByBackend=false` and blocked Confirm Ride with “Card payment is currently unavailable.”

This change is a **parser fix only**. Stripe init, PaymentSheet, booking create, polling, restore, Card-only UI, backend, maps, Auth0, FCM, and sockets were not modified.

---

## Status

**RYDU PASSENGER PAYMENT METHOD PARSING FIX COMPLETE — DEVICE QA REQUIRED**

Hot-restart / rebuild the running `flutter run` session before re-testing on device.

---

## Exact root cause

Backend returns:

```json
{
  "success": true,
  "data": [
    { "id": "...", "code": "cash", "name": "Cash", "isActive": true },
    { "id": "...", "code": "card", "name": "Card", "isActive": true }
  ]
}
```

The booking datasource did:

```dart
final data = ApiResponseParser.unwrapData(response.data);
final listRaw =
    data['paymentMethods'] ?? data['methods'] ?? data['items'] ?? data;
if (listRaw is List) { ... }
```

`unwrapData()` only unwraps `data` when it is a **Map**. When `data` is a **List**, it returns the **root object** `{ success, data }`.

Then:

- `paymentMethods` / `methods` / `items` are missing on the root
- fallback `listRaw` is the root **Map**, not the list
- `listRaw is List` is false
- parsed methods = `[]`
- logs: `paymentMethods=[]`, `cardReturnedByBackend=false`

`ApiResponseParser.unwrapList()` already handles `{ success, data: [ ... ] }`. Payment methods were using the wrong helper.

Item mapping already supported `code` and `name`. Items were not dropped because of `isActive`. The list never reached the item parser.

---

## Parser before / after

### Before

```dart
final data = ApiResponseParser.unwrapData(response.data);
final listRaw =
    data['paymentMethods'] ?? data['methods'] ?? data['items'] ?? data;
```

Root `{ success, data: List }` → empty methods.

### After

```dart
final methods = RidePlanningParsers.paymentMethods(response.data);
```

`RidePlanningParsers.paymentMethods()` uses `ApiResponseParser.unwrapList(raw)`, which reads `root.data` when it is a List.

Each item uses backend fields:

| Backend | Parser |
|---|---|
| `code` | payment method code (`cash`, `card`) |
| `name` | display label (`Cash`, `Card`) |
| `id` | ignored as code (UUID, not `card`) |
| `isActive` | not used to drop items |

Card detection remains `code.toLowerCase() == "card"`. Cash stays in the parsed list; Card-only UI still selects Card.

Expected logs after the fix:

```
[STRIPE_DEBUG] paymentMethods=[cash, card]
[STRIPE_DEBUG] cardReturnedByBackend=true
[STRIPE_DEBUG] finalCardAvailable=true
```

---

## Files changed

- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
  - `paymentMethods(raw)` via `unwrapList`
  - item parser uses `code` + `name` (does not treat UUID `id` as the method code)
- `lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart`
  - booking `GET /payment-methods` uses the new parser
- `lib/features/payment/data/datasources/payment_remote_datasource.dart`
  - same envelope on the same endpoint
- `test/features/ride_booking/ride_planning_parsers_test.dart`
  - exact backend JSON fixture

Not changed: Stripe SDK, PaymentSheet, create booking, polling, restore, Card-only UI, backend.

---

## Tests / build

| Check | Result |
|---|---|
| New envelope test (length 2, codes `cash`/`card`, card detected, Stripe config usable) | Pass |
| `flutter test` | **246 passed** |
| `flutter analyze` | **No issues found** |
| Android debug APK | `build\app\outputs\flutter-apk\app-debug.apk` |

---

## Device QA

1. Hot restart the Passenger app.
2. Open ride selection / Confirm Ride.
3. Confirm logs:
   - `paymentMethods=[cash, card]`
   - `cardReturnedByBackend=true`
   - `finalCardAvailable=true`
4. Confirm Ride should open Stripe PaymentSheet (sandbox `4242…`).

---

**RYDU PASSENGER PAYMENT METHOD PARSING FIX COMPLETE — DEVICE QA REQUIRED**
