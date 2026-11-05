# RYDU Passenger — Payment Status Sync After PaymentSheet

After a successful in-app Stripe PaymentSheet, the passenger UI now follows the backend meter-payment status. Booking `7ee40579-449b-46ce-b1f4-191604d79c71` shows Paid and View Receipt when the backend says paid. Pay Now stays hidden. No live Stripe payment was run in this change.

## Root cause

Pay Now stayed visible for three reasons:

1. The post-sheet refresh was a single `GET /meter-payment`. If that read was still pending, or an older in-flight read finished later, the canonical state stayed `payment_pending`.
2. A refresh already in progress was ignored, so the read after PaymentSheet could be dropped.
3. Ride history rendered the cached booking `meterPayment`, so a paid update in the ride controller did not change the history card.

PaymentSheet success was never treated as Paid. The missing piece was applying the later backend `paid` snapshot everywhere Pay Now is drawn.

## Canonical state

`RideBookingState.meterPayment` is the shared record for the meter screen, ride details, Home, and the history row for that booking id.

`_commitMeterPayment` writes that record and clears `unpaidMeterPayment` when `needsPayNow` is false (`paymentStatus=paid` or `paymentRequired=false`).

History overlays `ride.meterPayment` onto the matching history card. Ride details already prefer that live record when the booking ids match.

`canOfferMeterPayNow` is false while checkout is starting or while confirmation is in progress.

## Retry behavior

After PaymentSheet returns success, the app does not create another PaymentIntent. It reads `GET /api/v1/passenger/bookings/{bookingId}/meter-payment` up to 5 times, with delays of 0 ms, 400 ms, 800 ms, 1.6 s, and 3.2 s.

- Paid, failed, refunded, or meter-unresolved stops the loop.
- While the backend is still pending, the UI shows “Confirming payment...” and hides Pay Now.
- HTTP 429 waits for `Retry-After` when the header is present, then continues inside the same budget.
- If the budget ends still unpaid, the UI shows “Payment is being verified. It will update when the bank confirms it.” and does not mark Paid.
- Cancel leaves the ride unpaid after one refresh.
- A failed sheet still allows another Pay Now.
- Resume clears the confirming lock and reads meter-payment plus unpaid recovery again.
- A null unpaid-meter-payment response clears the Home reminder.
- Each status read has an epoch. An older response cannot overwrite a newer one.
- Socket `booking:meter_payment` updates the same record. A lower `paymentVersion` cannot replace Paid. `_listenSocket` cancels the previous subscription before registering another, including after reconnect.

## Files changed

- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `lib/features/ride_booking/presentation/widgets/meter_payment_card.dart`
- `lib/features/ride_booking/presentation/screens/meter_payment_screen.dart`
- `lib/features/ride_booking/domain/entities/meter_payment_entities.dart`
- `lib/features/ride_history/presentation/screens/ride_details_screen.dart`
- `lib/features/ride_history/presentation/widgets/ride_history_body.dart`
- `lib/core/network/passenger_api_error_mapper.dart`
- `test/features/ride_booking/meter_payment_test.dart`

## Tests and build

`flutter test test/features/ride_booking/meter_payment_test.dart test/features/ride_booking/stripe_phase_c_test.dart`

**All passed** (63).

Covered: verified paid fixture (`paymentStatus=paid`, `paymentRequired=false`, `finalFareCents=480`, `currency=USD`, `receiptAvailable=true`), sheet success then GET Paid, delayed retry, 429 then Paid, cancel stays unpaid, failed sheet can retry, stale socket cannot undo Paid, Home reminder cleared, history Paid UI, resume refresh, null unpaid recovery, one PaymentIntent per Pay Now, no external browser, quoted-prepay PaymentSheet unchanged.

### `flutter analyze`

**2 issues found**, both pre-existing unused imports:

- `test/features/ride_booking/service_area_test.dart`
- `test/features/ride_tracking/driver_vehicle_display_delay_test.dart`

### `flutter build apk --debug`

Succeeded: `build/app/outputs/flutter-apk/app-debug.apk`

Pre-existing Gradle notice: Kotlin Gradle Plugin on the app and plugins. Not introduced by this change.

## Remaining device check

On the passenger device, complete or reopen booking `7ee40579-449b-46ce-b1f4-191604d79c71` and confirm Pay Now is gone, Paid and View Receipt are shown, and the Home reminder is gone without restarting the app.
