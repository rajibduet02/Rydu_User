# RYDU Passenger — PaymentIntent Response Contract

Passenger Flutter now reads the backend PaymentIntent payload for completed On-Demand Soft Meter rides, including `paymentIntentClientSecret` and `publishableKey`.

No backend, Driver, Admin, or Walk-Up changes. No live Stripe payment was performed.

## Contract

`POST /api/v1/passenger/bookings/{bookingId}/meter-payment/payment-intent`

Body: `{}`

Top-level fields, also accepted inside `{ success, data }`:

| Field | Use |
| --- | --- |
| `bookingId` | Meter payment record |
| `paymentIntentClientSecret` | Existing PaymentSheet only. Not stored on ride UI state |
| `paymentIntentId` | Parsed, not logged |
| `publishableKey` | Stripe SDK init when it is a `pk_test` key |
| `finalFareCents` | Displayed fare |
| `currency` | Displayed fare |
| `paymentStatus` | Pending / paid / failed |
| `testMode` | Test-mode labeling |
| `paymentVersion` | Socket ordering unchanged |
| `productionCharge` | `true` blocks the sheet |

Older aliases still work: `clientSecret`, `client_secret`, `payment_intent_client_secret`. `paymentIntentClientSecret` wins when both are present.

The HTTP client already unwraps `data`. The parser also unwraps a success/data envelope so the same JSON works in tests and if a caller passes the raw body.

## PaymentSheet behavior

1. Pay Now posts `{}` and does not send a fare.
2. A `pk_test` publishable key from this response initializes the existing Stripe SDK.
3. If that key is absent, the existing payments-config key is used.
4. PaymentSheet is presented with `paymentIntentClientSecret`.
5. A null secret does not open PaymentSheet. The app refreshes `GET .../meter-payment`. Paid is applied only when that refresh says paid.
6. `pk_live` or `productionCharge: true` does not open PaymentSheet.
7. Sheet success still waits for backend confirmation.
8. History Pay Now, Home unpaid recovery, and resume refresh are unchanged.
9. No external browser is opened.

Client secrets are not written to ride state. Debug sanitization already redacts any key whose name contains `clientSecret`, which includes `paymentIntentClientSecret`. Logs record publishable-key mode only.

## Files changed

- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
- `lib/features/ride_booking/domain/entities/meter_payment_entities.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `test/features/ride_booking/meter_payment_test.dart`

## Tests and build

`flutter test test/features/ride_booking/meter_payment_test.dart test/features/ride_booking/stripe_phase_c_test.dart`

**All passed** (56). Coverage includes the exact backend JSON flat and inside `{ success, data }`, alias precedence, null secret with REST refresh, backend Paid without a sheet, `pk_test` initialization, `pk_live` blocked, no browser, and quoted-prepay PaymentSheet unchanged.

### `flutter analyze`

**2 issues found**, both pre-existing unused imports:

- `test/features/ride_booking/service_area_test.dart`
- `test/features/ride_tracking/driver_vehicle_display_delay_test.dart`

### `flutter build apk --debug`

Succeeded: `build/app/outputs/flutter-apk/app-debug.apk`

Pre-existing Gradle notice: Kotlin Gradle Plugin on the app and plugins. Not introduced by this change.

## Backend mismatches

None against the listed top-level fields. The previous client only documented `clientSecret` / `client_secret`. It now reads `paymentIntentClientSecret` first.

## Remaining device testing

Still required on a device: complete a meter ride, confirm Pay Now opens PaymentSheet with the test key, cancel leaves the ride unpaid, and Paid appears only after the backend confirms it.
