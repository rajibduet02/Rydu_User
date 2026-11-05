# RYDU Passenger — Metered Booking Without Upfront Payment

Passenger Flutter (`Rydu_User`) now honors backend `metered_post_trip` billing. New instant On-Demand Soft Meter bookings skip the original Stripe PaymentSheet, enter driver search immediately, and still collect the finalized meter fare after the trip through existing Stripe Test Checkout.

No backend, Driver, or Admin changes. Production metered charging stays off. No live Stripe end-to-end payment was performed.

## 1. Files changed

### Added

- `lib/features/ride_booking/domain/entities/booking_billing_mode.dart`

### Parsing / domain / booking flow

- `lib/features/ride_booking/domain/entities/ride_planning_entities.dart`
- `lib/features/ride_booking/domain/entities/ride_option_entity.dart`
- `lib/features/ride_booking/domain/entities/meter_payment_entities.dart`
- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
- `lib/features/ride_booking/presentation/models/ride_vehicle_option.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `lib/features/ride_booking/presentation/widgets/meter_payment_card.dart`
- `lib/features/ride_history/presentation/widgets/ride_history_card.dart`

### Tests

- `test/features/ride_booking/meter_payment_test.dart`

Existing post-trip meter payment screens, Checkout launcher, unpaid recovery, and Soft Meter live UI were reused (not rebuilt).

## 2. Billing-mode response parsing

Quote, booking create, booking detail, active booking, and history parsers now read:

| Field | Use |
| --- | --- |
| `billingMode` | `metered_post_trip` / `quoted_prepay` |
| `paymentRequiredBeforeDispatch` | Whether PaymentSheet is required before search |
| `paymentRequiredAfterCompletion` | Soft Meter post-trip payment expected |
| `fareClassification` | Backend tariff classification (display/metadata only) |

`CreateBookingResult` still accepts:

- Flat booking object (no `payment` envelope) — typical `metered_post_trip` create
- Nested `{ booking, payment }` — typical `quoted_prepay` create

Booking-create fields override any earlier quote classification on `_applyBookingEntity`.

Null / missing billing mode remains compatible with historical bookings (unknown → existing quoted PaymentSheet rules when `status == quoted` or payment needs authorization).

## 3. Exact PaymentSheet bypass condition

```dart
booking.skipsUpfrontCardAuthorization
// == billingMode == metered_post_trip
// && paymentRequiredBeforeDispatch != true
```

`_bookingNeedsCardAuthorization` returns **false** when that holds.

Then confirmBooking:

- Does **not** present PaymentSheet
- Does **not** fetch a quoted PaymentIntent / clientSecret
- Treats `paymentStatus: pending` as expected
- Sets phase from booking status (`searching`) and connects the live socket
- Navigates to Finding Driver

If the quote suggested `metered_post_trip` but create returns `quoted_prepay` with `paymentRequiredBeforeDispatch: true`, PaymentSheet still runs. Create response wins.

Stripe SDK readiness is deferred when the quote already indicates Soft Meter post-trip billing, and only initialized if create then requires prepay.

## 4. Booking navigation after creation

For `metered_post_trip` create with `status: searching`:

1. Apply booking entity (billing fields authoritative)
2. Skip PaymentSheet
3. `_connectAndListen(bookingId)`
4. Phase → `bookingSearching`
5. Existing Finding Driver navigation

Quoted restore still reconciles PaymentSheet only when status is `quoted` **and** the booking does **not** skip upfront authorization.

## 5. Fixed-price screens checked

For Soft Meter / `metered_post_trip` UI (`usesSoftMeterUi`):

| Screen | Behavior |
| --- | --- |
| Ride selection | **Metered** instead of fixed amount |
| Confirm pickup | No fixed payable price; Soft Meter copy |
| Finding Driver | Soft Meter copy, not quoted amount |
| Active ride Soft Meter | Backend provisional fare |
| Trip details | No “Booking quote” payable amount |
| Home active card | Hides quoted fare |
| Completed / history | Backend `finalFareCents` / Pay Now |

Copy used before trip:

> Your fare is calculated by the Soft Meter based on distance traveled and eligible stopped time. Payment is due after your ride.

Checkout still shows:

> Stripe Test Mode — no real money charged.

## 6. Non-metered compatibility

- `quoted_prepay` + `paymentRequiredBeforeDispatch: true` → existing PaymentSheet path
- Stripe Phase C tests remain green
- Rentals / Reserve still force Soft Meter UI off (`usesSoftMeterUi == false`)
- Historical bookings with null billing mode keep previous fare / PaymentSheet behavior
- No client `billingMode` override is sent on create

## 7. Post-trip Stripe Checkout compatibility

Unchanged endpoints and rules:

- `GET …/meter-payment`
- `POST …/meter-payment/checkout` with body `{}`
- `GET …/meter-payment/receipt`
- `GET …/unpaid-meter-payment`
- `booking:meter_payment` + `paymentVersion`

Payable amount remains backend `finalFareCents`. Paid only from backend-confirmed status. Browser return does not mark Paid.

## 8. Unpaid recovery

Startup / login / Home resume still call unpaid-meter-payment recovery and show the Home Payment Pending reminder. History still exposes Pay Now for older unpaid metered rides.

## 9. Missing-meter handling

`paymentStatus: meter_unresolved` (booking and/or meter-payment record):

- Shown as **Fare under review**
- No quoted fallback amount
- No PaymentSheet
- No invented fare
- No Paid
- No Checkout (`startMeterCheckout` refused)
- Ride remains visible in completed history

## 10. Test and build results

### `flutter analyze`

**2 issues found** (pre-existing unused imports; unrelated to this change):

- `test/features/ride_booking/service_area_test.dart` — unused `google_maps_flutter` import
- `test/features/ride_tracking/driver_vehicle_display_delay_test.dart` — unused `ride_planning_entities` import

No analyzer issues in the metered booking / billing-mode files.

### Focused Flutter tests

All passed (`+72`):

- `test/features/ride_booking/meter_payment_test.dart`
- `test/features/ride_booking/stripe_phase_c_test.dart`
- `test/features/ride_booking/soft_meter_test.dart`

Covered: metered create without payment envelope, PaymentSheet skip, no PaymentIntent fetch, searching dispatch, pending status expected, quoted_prepay override of prior metered quote, historical null billing mode, no client billing override, Checkout `{}` / HTTPS URL, Paid only from backend, unpaid recovery, history Pay Now, `meter_unresolved`, Rentals isolation.

### `flutter build apk --debug`

Succeeded: `build/app/outputs/flutter-apk/app-debug.apk`

Pre-existing Gradle warning: Kotlin Gradle Plugin applied by app / plugins (`auth0_flutter`, `google_maps_flutter_android`, Stripe, etc.) — future Flutter Built-in Kotlin migration notice. Not introduced by this change.

## 11. Backend API mismatches

None observed against the documented `metered_post_trip` contract in this client. Remaining notes:

1. Quote may still include a display `finalFare` for metered options; Flutter hides it when classification is Soft Meter / `metered_post_trip`.
2. If create omits `billingMode` but returns `searching` with no payment object, PaymentSheet is already skipped by existing “no payment needsPayment / not quoted” logic; explicit `billingMode` is preferred.
3. `meter_unresolved` must be returned by the backend for incomplete meter finalization; Flutter will not invent a fare.

## 12. Remaining integration-testing requirements

Still needed against a live backend (not performed here):

1. Instant Economy quote → create → Searching with no PaymentSheet
2. Live Soft Meter during trip
3. Completion → meter-payment → Stripe Test Checkout → webhook Paid
4. Skip payment → history Pay Now → unpaid recovery after kill/relogin
5. Scheduled Economy / Reserve / Rentals still use `quoted_prepay` PaymentSheet
6. Completed ride with `meter_unresolved` shows review state and never Checkout
7. Confirm no production metered charge and Test Mode labeling on Checkout
