# Rydu Passenger — Driver and Vehicle Identification

Final status: **PASSENGER DRIVER & VEHICLE IDENTIFICATION IMPLEMENTED — BACKEND GAPS AND DEVICE QA TO REVIEW**

After a driver accepts a booking, the passenger accepted-ride screen shows that booking’s driver and the vehicle on the ride assignment. It does not substitute the selected service category or a previously cached driver.

## 1. Existing implementation audit

- Booking creation still posts through the existing passenger bookings API. Acceptance is not a new request.
- `PassengerSocketService` already listens for `booking:searching`, `booking:accepted`, `booking:status`, `booking:expired`, `driver:location`, plus recording events.
- `RidePlanningParsers.booking` already parsed `driver` / `assignedDriver` and a booking-level `vehicle` object (`make`, `model`, `color`, `plateNumber`).
- That vehicle was stored on `BookingEntity` only. `RideBookingState` kept `assignedDriver` and dropped `booking.vehicle`.
- `DriverFoundController` filled the car line with `driver.vehicleName`, then the selected service name (`selectedVehicle.name`). The plate came only from the driver object.
- The accepted screen (`DriverFoundScreen`) already shows the live map (`ActiveRideMap`, driver marker), pickup, ETA title, reconnect banner, and cancel flow.
- `driver:location` updates `RideBookingState.driverLocation`. Invalid or zero coordinates are ignored. ETA is not computed from GPS.
- App restart restores `GET /bookings/active` through `restoreActiveBooking`, which calls `_applyBookingEntity`.
- Call previously showed a snackbar (“Calling driver…”) and did not open the dialer. Message opened `RouteNames.chat`, whose screen is the literal text “Chat”. `ChatRemoteDatasourceImpl` does not send messages. There is no driver-message path in `PassengerApiPaths`.
- A local ride-tracking datasource still contains a hardcoded driver (`MOHAMMAD MOHIDUL ISLAM`, plate `DHM-LA-63-525`). The accepted-ride screen does not read it.
- Trip details previously showed a hardcoded drop-off, “Bashir Super Market”, and “1 Person (Add)”.

## 2. Actual API fields and Socket.IO events

No new endpoints or event names were added.

| Source | Fields used |
| --- | --- |
| `GET /bookings/active`, `GET /bookings/{id}` | Existing booking parser |
| Socket `booking:accepted`, `booking:status`, `booking:searching`, `booking:expired` | Same payload keys already forwarded by the socket client |
| Socket `driver:location` | `driverId`, `bookingId`, `latitude`/`lat`, `longitude`/`lng`, `heading`, `speedKph`, `accuracyMeters`, `timestamp` |

Driver object keys already parsed, plus photo URL keys that match the passenger profile contract when they appear on the driver:

- `id` / `driverId`
- `name` / `fullName` / `driverName`
- `phone` / `phoneNumber`
- `plateNumber` / `plate` / `maskedPlate`
- `rating` / `driverRating` (string or number; no default)
- `vehicleName` / `vehicle` (string only) / `vehicleType` — not used as the ride car
- `etaMinutes` / `driverEtaMinutes` / `eta`
- `profileImageUrl` / `avatarUrl` / `imageUrl` / `photoUrl`

Booking vehicle object:

- `id` / `vehicleId`, `make` / `brand`, `model`, `color`
- `plateNumber` / `plate` / `maskedPlate`
- `year` when it is an integer from 1950 through 2100

Booking-level ETA remains `driverEtaMinutes` / `etaMinutes`.

There is no socket event in this app for a vehicle exchange. A nested `booking` object on an existing booking event is parsed with the same booking parser.

## 3. Driver information implemented

The card uses the driver on the current booking:

- Full name from the assigned driver
- Photograph when a photo URL is present (relative paths resolve with the existing profile URL helper)
- Initials on a blue circle when the photo is missing or fails to load
- Rating only when `rating` or `driverRating` is present

A missing rating is omitted. Nothing defaults to 5.0 or any other score.

## 4. Vehicle information implemented

The card uses `BookingEntity.vehicle` / the socket `vehicle` object:

- Make and model
- Color and year when present
- License plate in a high-contrast plate badge

If the vehicle object has no plate, the plate on the assigned driver of this booking is used. Make, model, color, and year stay blank when absent. The service category name is not shown as the car. “Plate unavailable” is shown when neither source has a plate.

## 5. Live location and ETA integration

Unchanged mechanisms:

- `driver:location` still moves the driver marker on `ActiveRideMap`
- Pickup and drop-off still come from the booking places
- Reconnect still shows “Reconnecting… ride status preserved” and refreshes the booking

ETA label uses `driver.etaMinutes`, otherwise booking `driverEtaMinutes`. GPS updates do not invent an ETA. If neither value exists, the title stays “Driver assigned” or the live status (“Driver en route”, “Driver arrived”, “Trip in progress”). Drop-off is shown on the sheet from the restored destination, not a placeholder address.

## 6. Call / message support

**Call Driver** is shown only when the assigned driver has `phone` or `phoneNumber`. It opens the system dialer with `tel:` (`url_launcher`). If the dialer cannot open, the snackbar shows the phone number.

**Message Driver** is not shown. This app has no passenger-to-driver message API. `/chat` is a placeholder screen, and the chat datasource does not send or receive ride messages. A button that only opened that screen was removed from the identification card.

Share trip status is unchanged and still reports that sharing is not available.

## 7. Vehicle exchange behavior

The ride vehicle changes only when an authoritative booking payload includes `vehicle`:

- `GET` booking apply replaces driver and vehicle together. A null vehicle clears the previous car.
- Socket `booking:accepted` / `booking:status` replaces the vehicle when the event, or a nested `booking` object, contains `vehicle`.
- A later status event that omits `vehicle` keeps the current ride vehicle.
- A different driver id without a `vehicle` field clears the previous plate, make, model, color, year, and ETA, then refetches the booking with the existing `bookingById` / `activeBooking` path.
- Returning to `searching` without a driver clears the assignment so the next driver cannot inherit the previous car.
- `driver.vehicleName` and the selected service category never overwrite the ride vehicle.

## 8. Backend contract gaps

- No sample booking in this repository includes a driver photograph. The UI shows a photo only if the driver object carries `profileImageUrl`, `avatarUrl`, `imageUrl`, or `photoUrl`.
- No sample includes `year`. The UI shows a year only when vehicle `year` is present and in range.
- No socket event or endpoint updates an active ride’s vehicle by itself. If dispatch changes the car without putting `vehicle` on the booking or on `booking:accepted` / `booking:status`, the passenger cannot see the new car.
- No driver messaging API or socket event exists, so in-app Message Driver is not available.
- `driver:location` has no ETA field. Arrival time appears only when the booking or driver payload includes `etaMinutes` / `driverEtaMinutes`.

## 9. Files changed

- `lib/features/ride_booking/domain/entities/ride_planning_entities.dart`
- `lib/features/ride_booking/domain/accepted_ride_identity.dart`
- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
- `lib/features/ride_booking/data/utils/ride_assignment.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `lib/features/ride_tracking/presentation/providers/driver_found_controller.dart`
- `lib/features/ride_tracking/presentation/screens/driver_found_screen.dart`
- `lib/features/ride_tracking/presentation/widgets/driver_info_card.dart`
- `lib/features/ride_tracking/presentation/widgets/trip_details_card.dart`
- `lib/features/ride_tracking/presentation/utils/dial_driver_phone.dart`
- `lib/features/home/presentation/widgets/home_active_ride_card.dart` (home banner uses the booking vehicle label and plate, not `vehicleName`)
- `pubspec.yaml`, `pubspec.lock` (`url_launcher`)
- `android/app/src/main/AndroidManifest.xml` (`tel` dial query)
- `ios/Runner/Info.plist` (`tel` query scheme)
- `test/features/ride_tracking/driver_vehicle_identification_test.dart`

## 10. Targeted tests and build result

`flutter test test/features/ride_tracking/driver_vehicle_identification_test.dart test/features/ride_booking/active_ride_flow_test.dart`

38 tests passed, including:

- Assigned driver name, photo URL, and rating
- No fabricated rating or photo
- Vehicle make, model, color, year, and plate
- Missing fields omitted; service category not used as the car
- Plate badge and missing-plate fallback
- Restored booking identity and ETA
- Status updates that omit `vehicle` keep the ride car
- Driver id change clears the previous vehicle and requests a booking refresh
- Explicit `vehicle` payload replaces the car
- Searching clears the previous assignment

`flutter analyze` on the changed Dart files: no issues.

`flutter build apk --debug`: success. Output: `build\app\outputs\flutter-apk\app-debug.apk`.

## 11. Physical-device QA steps

1. Book a ride and wait until a driver accepts. Confirm the sheet shows that driver’s name, photo or initials, rating only if the API sent one, make/model, color/year if sent, and the plate badge.
2. Confirm the map marker moves with `driver:location` and the ETA matches the booking payload rather than a countdown invented on the phone.
3. Confirm pickup and drop-off match the booked addresses. Minimize to Home and reopen; the same driver and plate should remain.
4. Kill and relaunch the app during an accepted ride. The restored card should match `GET /bookings/active`, not a previous trip.
5. Turn the network off and on. The reconnect banner should appear, then the same assignment should return after the booking refresh.
6. If dispatch sends a new `vehicle` on the booking or `booking:status`, the plate and make/model should change. If only the driver’s general fleet changes and the booking `vehicle` does not, the plate should stay.
7. If a different driver is assigned without a `vehicle` object, the old plate should disappear until the booking refetch returns the new car.
8. Tap Call Driver when a phone is present and confirm the dialer opens. Confirm there is no Message Driver action.
9. Cancel the ride, or let the driver cancel back to searching, and confirm the next offer does not show the previous driver’s name or plate.
