# RYDU Passenger — On-Demand Soft Meter PaymentSheet

Completed On-Demand Soft Meter rides now collect the finalized backend fare inside the Passenger app with the existing Flutter Stripe PaymentSheet. Hosted Checkout and the external browser are no longer used for these payments.

Quoted-prepay booking authorization is unchanged. No upfront PaymentSheet is shown for `metered_post_trip`. No live Stripe charge was performed.

## 1. Files changed

- `lib/core/constants/passenger_api_paths.dart`
- `lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart`
- `lib/features/ride_booking/data/repositories/ride_booking_repository_impl.dart`
- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
- `lib/features/ride_booking/domain/entities/meter_payment_entities.dart`
- `lib/features/ride_booking/domain/repositories/ride_booking_repository.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `test/features/ride_booking/meter_payment_test.dart`
- Fake repository signatures in Soft Meter, Stripe Phase C, active-booking, history, autocomplete, pickup, and recording-consent tests

Pay Now on the meter screen, ride details, and the Home unpaid reminder all call `RideBookingController.startMeterCheckout`. That method now presents PaymentSheet. History list Pay Now still opens the same meter screen.

The existing `StripePaymentGateway` / `FlutterStripePaymentGateway` is reused. No second Stripe SDK wrapper was added.

## 2. API integration

Pay Now posts an empty JSON object:

`POST /api/v1/passenger/bookings/{bookingId}/meter-payment/payment-intent`

Body: `{}`

Flutter does not send fare, currency, distance, waiting time, or a client-calculated amount.

The parser reads the PaymentIntent client secret from `clientSecret` or `client_secret` on the response, or nested under `payment`, `paymentIntent`, or `meterPayment`. `paymentIntentId` is read the same way. The secret is passed only into `presentPaymentSheet`. It is not stored on ride UI state and is not written to logs.

Fare display still uses backend `finalFareCents` / `totalCents`.

Unchanged reads:

- `GET /bookings/{id}/meter-payment`
- `GET /bookings/{id}/meter-payment/receipt`
- `GET /bookings/unpaid-meter-payment`
- `booking:meter_payment` with `paymentVersion` ordering

## 3. PaymentSheet lifecycle

1. Passenger taps Pay Now after the backend has a payable final fare.
2. Duplicate taps are ignored while the request or sheet is in flight.
3. `meter_unresolved`, missing final fare, and already-paid or refunded records do not open a sheet.
4. The app initializes the existing Stripe SDK from the backend publishable key when it is not already ready.
5. PaymentSheet is presented with the backend client secret.
6. Cancel leaves the ride unpaid and shows a cancellation message.
7. Sheet failure leaves the ride unpaid and allows another Pay Now.
8. Sheet completion refreshes meter-payment REST. Paid is applied only when that refresh or a newer socket event says paid.
9. App resume still refreshes REST meter status and unpaid recovery.

Stripe Test Mode copy remains: “Stripe Test Mode — no real money charged.”

## 4. Booking rules preserved

- `metered_post_trip` with `paymentRequiredBeforeDispatch != true` still skips the booking PaymentSheet and enters Searching.
- Ride selection still shows Metered instead of a fixed amount.
- Live trip fare remains the backend Soft Meter snapshot.
- `quoted_prepay` (scheduled Economy, Rentals, Reserve) still uses the original booking PaymentSheet when pre-dispatch payment is required.
- Booking-create classification still overrides an earlier quote.

## 5. Tests and build

`flutter test test/features/ride_booking/meter_payment_test.dart`

**35 passed**, including:

- Pay Now opens PaymentSheet with the backend client secret
- No hosted Checkout URL is launched
- Displayed fare is the backend finalized amount
- Cancel stays unpaid
- Sheet success does not mark Paid locally
- History / older unpaid Pay Now uses the same sheet
- Duplicate taps
- Failure then retry
- Already-paid response does not open a sheet
- No upfront PaymentSheet for `metered_post_trip`
- Quoted-prepay create still presents the booking PaymentSheet

Also passed in the same session before the final meter-test compile fix (those files were not changed afterward):

- `stripe_phase_c_test.dart`
- `soft_meter_test.dart`
- `active_booking_ux_test.dart`
- `ride_history_controller_test.dart`

### `flutter analyze`

**2 issues found**, both pre-existing unused imports:

- `test/features/ride_booking/service_area_test.dart`
- `test/features/ride_tracking/driver_vehicle_display_delay_test.dart`

### `flutter build apk --debug`

Succeeded: `build/app/outputs/flutter-apk/app-debug.apk`

Pre-existing Gradle notice: Kotlin Gradle Plugin on the app and plugins (`auth0_flutter`, `google_maps_flutter_android`, `stripe_android`, and others). Not introduced by this change.

## 6. Backend mismatches

The Passenger app now calls `POST .../meter-payment/payment-intent` with `{}` and expects a PaymentIntent `clientSecret`. The previous hosted Checkout URL on `POST .../meter-payment/checkout` is no longer opened.

If the live backend still creates the PaymentIntent on `/meter-payment/checkout`, or uses a different path or secret field, Pay Now will fail until that path matches. Confirm the response includes `clientSecret` (top-level or under `payment` / `paymentIntent`) and that amount stays server-side.

## 7. Remaining integration testing

Not performed against a live backend or Stripe:

1. Complete an On-Demand meter ride and confirm Pay Now opens PaymentSheet inside the app.
2. Cancel the sheet and confirm the ride stays unpaid in history and on the Home reminder.
3. Complete a Stripe test card and confirm Paid appears only after the webhook/REST refresh.
4. Retry a failed PaymentIntent.
5. Kill and relaunch the app and pay an older unpaid ride from history.
6. Confirm scheduled, Rental, and Reserve bookings still use the quoted PaymentSheet before dispatch.
7. Confirm Test Mode labeling and that no production meter charge is created.
