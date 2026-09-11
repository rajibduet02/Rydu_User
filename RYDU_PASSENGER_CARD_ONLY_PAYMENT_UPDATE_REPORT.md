# RYDU Passenger Card-Only Payment Update Report

Passenger Flutter app (`Rydu_User`) now shows **Card** as the only booking payment option and sends `paymentMethodCode: "card"`. Cash is no longer displayed in the booking UI and is never used as a silent fallback.

Backend, Driver, and Admin were not modified. Maps, quote, Auth0, Firebase, sockets, FCM, cancel API, and the existing Stripe Phase C PaymentSheet flow were not redesigned.

---

## Status

**RYDU PASSENGER CARD-ONLY PAYMENT UPDATE COMPLETE — DEVICE QA REQUIRED**

Physical-device QA (Card label, Confirm Ride → PaymentSheet with `4242 4242 4242 4242`, Stripe-unavailable message) has not been run on a phone.

---

## Files changed

### Booking / Stripe (reused Phase C, Card-only defaults)

- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
  - Default `paymentMethod` / `paymentMethodCode` is Card / `card`
  - `bookingPaymentLabel` never returns Cash
  - Quote load uses `_cardPaymentSelection()` (Card-only visible list)
  - `confirmBooking()` always POSTs `paymentMethodCode: "card"`
  - `_isStripeCardUsable()` requires backend `cardEnabled` + `pk_` key **and** payment methods that include `card`
  - If Card/Stripe is unavailable: show message, **do not** create a booking
- `lib/features/ride_booking/domain/entities/booking_payment_entities.dart`
  - `CardBookingPayment` (`code`, `label`, `visibleForBooking`, `unavailableMessage`)
- `lib/core/payments/rydu_payments.dart`
  - `cardUnavailableMessage`: `Card payment is currently unavailable. Please try again later.`
- `lib/core/network/passenger_api_error_mapper.dart`
  - Stripe codes map to the same unavailable message (no “pay with cash” copy)

### UI (Cash labels/icons replaced)

- `lib/features/ride_booking/presentation/screens/ride_selection_screen.dart`
- `lib/features/ride_booking/presentation/screens/confirm_pickup_screen.dart`
- `lib/features/ride_booking/presentation/widgets/payment_method_tile.dart`
- `lib/features/payment/presentation/widgets/payment_method_modal.dart`
- `lib/features/rentals/presentation/widgets/rental_payment_method_card.dart`
- `lib/features/payment/presentation/providers/payment_method_controller.dart`
- `lib/features/payment/domain/usecases/select_payment_method_usecase.dart`
- `lib/features/ride_booking/domain/entities/ride_booking_entity.dart`
- `lib/features/ride_tracking/data/datasources/ride_tracking_local_datasource.dart`
- `lib/features/rentals/presentation/providers/rental_driver_found_controller.dart`
- `lib/features/payment/data/datasources/payment_local_datasource.dart` (local fixture default is Card, not Cash)

### Tests

- `test/features/ride_booking/stripe_phase_c_test.dart`
- `test/features/ride_booking/active_ride_flow_test.dart`

Stripe PaymentSheet, polling, quoted restore, and Retry Payment remain in the existing Phase C files (`FlutterStripePaymentGateway`, `card_payment_status_panel.dart`, payment poller). No second Stripe service was added.

---

## Where Cash was removed

| Location | Before | After |
|---|---|---|
| Ride selection payment tile | `Cash` / `'Cash'` fallback | `state.bookingPaymentLabel` → **Card** |
| Confirm pickup payment tile | same | **Card** |
| Pay with sheet options | backend Cash + first-method default | `CardBookingPayment.visibleForBooking()` — **Card only** |
| Payment method tile icon | cash-style / mixed | `Icons.credit_card_rounded` (blue) |
| Rental payment card | cash emoji `💵` on green | credit-card icon on blue |
| Controller defaults | empty / Cash / first method | Card / `card` |
| Confirm Ride POST | could send `cash` | always `card` (or no POST) |
| Stripe error copy | mentioned cash | Card unavailable message |
| Local payment fixture | Cash as default | Card as default |

Still **not** changed (not booking selector UI):

- Wallet copy “RYD U Cash” (wallet balance, not a booking payment method)
- Ride-history labels for historical cash trips
- Parser tests for backend cash JSON (API shape still exists)

---

## Card default behavior

1. `RideBookingState` defaults to `paymentMethod: "Card"` and `paymentMethodCode: "card"`.
2. Quote / payment-methods load filters the UI list to Card only. Card is selected/default.
3. Selecting Cash (if a stale extra/label appears) is remapped to Card.
4. Confirm Ride always sends:

```json
"paymentMethodCode": "card"
```

It does **not** fall back to `"cash"` when Card is available, and it does **not** pick the first backend method if that method is Cash.

---

## No-cash-fallback behavior

Removed:

- Default to first payment method (when that was Cash)
- Fallback to Cash when the list is empty
- Preserve Cash as default
- Create a cash booking when Stripe/Card is unavailable

If Stripe/Card is unavailable, Confirm Ride:

1. Shows: `Card payment is currently unavailable. Please try again later.`
2. Stays on quote-loaded
3. Does **not** call `POST /api/v1/passenger/bookings`
4. Does **not** start driver search

---

## Stripe availability handling

Still uses backend as source of truth:

- `GET /api/v1/config/payments` — requires `cardEnabled = true` and `publishableKey` starting with `pk_`
- `GET /api/v1/passenger/payment-methods` — must include `card`

`_isStripeCardUsable()` fails closed if either check fails (including a missing `card` method or a missing/invalid publishable key). No `sk_` keys are hardcoded.

Existing Phase C flow is unchanged:

Passenger selects ride → Card shown → Confirm Ride → `POST /bookings` with `paymentMethodCode: "card"` → quoted booking + `clientSecret` → PaymentSheet → poll payment → `authorized` → searching / sockets continue.

Quoted bookings stay payment-pending until authorization. Retry Payment reuses the same booking and PaymentIntent. App restart restores the quoted booking; it does not create a second booking.

Sandbox test card: `4242 4242 4242 4242`.

---

## Booking request verification

`BookingCreateRequest.body()` still sends only:

- `serviceCategoryId`
- `pickup` / `dropoff` / `stops`
- `paymentMethodCode`
- `schedulingType`

No `amount`, `fare`, `finalFare`, or `paymentMethodId`.

Unit test: even if controller state is seeded with `paymentMethodCode: cash`, confirm still POSTs `card` (when Stripe/Card is usable). If Stripe/Card is not usable, `createCalls == 0`.

---

## Tests / build results

| Check | Result |
|---|---|
| 1. Cash no longer displayed in booking UI | Pass (source guards + Card-only visible list) |
| 2. Card is displayed | Pass |
| 3. Card selected by default | Pass |
| 4. Booking sends `paymentMethodCode = "card"` | Pass |
| 5. No amount/fare sent by app | Pass |
| 6. PaymentSheet opens | Pass (unit: presentPaymentSheet after quoted create) |
| 7. Quoted booking does not search before authorization | Pass |
| 8. Authorized payment continues to searching | Pass |
| 9. Stripe unavailable does **not** fall back to cash | Pass (config off **and** methods without `card`) |
| 10. `flutter analyze` | **No issues found** (70.7s) |
| 11. Android debug build | **Pass** — `build\app\outputs\flutter-apk\app-debug.apk` |

Additional:

- `flutter test` — **244 tests passed**
- iOS build not run (Windows host)
- Device PaymentSheet QA not run

---

## Device QA still required

On a physical Android device with sandbox backend:

1. Open ride selection — payment row shows **Card**, not Cash.
2. Confirm Ride — booking is quoted, PaymentSheet opens.
3. Pay with `4242 4242 4242 4242` — booking becomes searching.
4. Kill/reopen during quoted/payment-pending — same booking, Retry Payment, no second booking.
5. If Card is disabled on backend — message shown, no cash booking created.

---

**RYDU PASSENGER CARD-ONLY PAYMENT UPDATE COMPLETE — DEVICE QA REQUIRED**
