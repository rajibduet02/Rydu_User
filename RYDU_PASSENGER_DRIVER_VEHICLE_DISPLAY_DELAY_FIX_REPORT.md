# Rydu Passenger — Driver and Vehicle Display Delay

The identification card was waiting on a second state copy, and a slower booking refresh could erase the driver that `booking:accepted` had already delivered.

## Confirmed root cause

`booking:accepted` is parsed in the same turn it arrives. Nothing in that path waits on an animation or a photo download. Two later steps were emptying or postponing the card:

1. **Stale REST overwrite.** Socket connect and reconnect always call `refreshRecordingConsentFromBackend()`, which loads `GET /bookings/:id` and then active booking. `_applyBookingEntity` replaced the ride assignment with that response. If the response was still `searching`, or omitted `driver` / `vehicle` / `etaMinutes`, it cleared the name, car, and plate that the socket event had just set. The card stayed empty until a later, complete response arrived.

2. **The card did not read the booking state.** `DriverFoundScreen` rendered `DriverFoundController`, which copied the booking only in a post-frame callback. The first paint could show “Driver assigned” and “Plate unavailable” even though `RideBookingState` already had the accepted payload. Navigation to that screen also returned early when `selectedVehicle` was null, so the accepted ride could stay on the searching screen until another update filled the service category.

The photo request does not block the name, make/model, or plate. `Image.network` loads beside that text and now shows initials until the bytes arrive.

## Flow after the fix

1. `PassengerSocketService` receives `booking:accepted` and logs it in debug.
2. `RideAssignment.mergeSocket` parses driver, vehicle, and `etaMinutes`. A complete accept does not start a REST fetch.
3. `RideBookingController` writes that assignment into ride state immediately.
4. Finding Driver opens Driver Found even if the service-category option is missing. The card does not use that option as the car.
5. `DriverFoundScreen` builds the card from `RideBookingState` on the same frame. Name, make/model, plate, and accept-time ETA render together.
6. The photo resolves in the background.
7. A later REST snapshot keeps the socket driver, vehicle, and ETA when it is missing those fields or is still an earlier status. A different booking id replaces the assignment. A terminal status still clears it. A searching event that arrives after accept is ignored.

`booking:status` still does not replace the assigned vehicle or the accept-time ETA.

## Debug logs

Debug builds print `[RideIdentity]` lines with a timestamp, a short booking id, and booleans for driver, vehicle, and ETA:

- `booking:accepted received`
- `identity parsed`
- `ride state updated`
- `identification card rendered`
- `REST refresh started` / `REST refresh completed`
- `ignored stale pre-assignment event`

Phone numbers, plates, tokens, and photo URLs are not logged.

## Tests

`flutter test` on:

- `test/features/ride_tracking/driver_vehicle_display_delay_test.dart`
- `test/features/ride_tracking/driver_vehicle_contract_test.dart`
- `test/features/ride_tracking/driver_vehicle_identification_test.dart`
- `test/features/ride_booking/active_ride_flow_test.dart`

All of those tests passed. They cover an immediate accept, a duplicate accept, a searching REST snapshot that must not wipe the socket assignment, a later complete snapshot, a searching event after accept, and a different booking id.

`flutter build apk --debug` succeeded. Output: `build\app\outputs\flutter-apk\app-debug.apk`.

## Device check

1. Request a ride and stay on Finding Driver. When the driver accepts, the name, make/model, and plate should appear with the screen change, without a second loading step.
2. In a debug log, `booking:accepted received`, `identity parsed`, `ride state updated`, and `identification card rendered` should be close together. A REST refresh may follow and must not clear those fields.
3. Turn the network off and on during the accepted ride. The same driver and plate should remain.
4. Use a slow image URL. Initials should show at once, then the photo, while the name and plate stay visible.
5. Start a second booking and confirm the first driver’s name and plate are gone.
