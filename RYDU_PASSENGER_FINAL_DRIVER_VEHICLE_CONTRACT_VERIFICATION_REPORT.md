# Rydu Passenger — Final Driver and Vehicle Contract Verification

Final status: **PASSENGER DRIVER & VEHICLE CONTRACT VERIFIED — DEVICE QA REQUIRED**

The accepted-ride screen already followed the booking driver and `vehicle` objects. One compatibility correction was required: `booking:status` was able to clear or replace the assigned vehicle and the accept-time ETA. Status updates now keep the driver, vehicle, and `etaMinutes` captured at acceptance or from a booking snapshot.

## Backend field compatibility

`booking:accepted`, `GET /api/v1/passenger/bookings/active`, and `GET /api/v1/passenger/bookings/:bookingId` all go through `RidePlanningParsers.booking` / `RideAssignment`. Active and by-id both unwrap `data.booking` or the data object, then call that same parser.

| Contract field | Mapping |
| --- | --- |
| `driver.id` | Assigned driver id |
| `driver.name` | Card title |
| `driver.phone` | Call Driver dials this number. The button is hidden when phone is null |
| `driver.profileImageUrl` | Loaded with the existing profile URL resolver. `https://` URLs stay absolute. Paths such as `/uploads/...` are joined to the API origin, not to `/api/v1` |
| `driver.plateNumber` | Parsed and stored. The plate badge uses `vehicle.plateNumber` |
| `vehicle.id` | Assigned vehicle id from the booking |
| `vehicle.make` / `model` / `color` | Shown when present. Omitted when null |
| `vehicle.year` | Integer renders in the color/year line (`White · 2019`). Null is omitted. The vehicle object is still kept |
| `vehicle.plateNumber` | License plate badge |
| `etaMinutes` | Accept-time estimate (`7 min`). Null leaves the status title with no invented minutes |

No rating is read from this contract, and none is displayed. Message Driver stays absent. No new endpoint or socket event was added.

## Changes required

- `RideAssignment.mergeSocket` treats `booking:status` as a phase update. It does not clear the driver, does not replace the assigned vehicle, and does not change `etaMinutes`, including when the status payload contains another vehicle or another ETA.
- `RideAssignment.fromBooking` is what active-booking restore and booking-by-id apply. A new snapshot replaces the previous driver, vehicle, and ETA.
- Socket events whose `bookingId` does not match the active booking are ignored.

`driver:location` still updates only the map marker. That method does not write `etaMinutes`.

`booking:searching` without a driver still clears the previous assignment so a new search cannot keep the last car.

## Tests performed

`flutter test test/features/ride_tracking/driver_vehicle_contract_test.dart test/features/ride_tracking/driver_vehicle_identification_test.dart test/features/ride_booking/active_ride_flow_test.dart`

46 tests passed, covering:

- `booking:accepted` driver, vehicle, plate, photo, phone, and `etaMinutes`
- The same parser for an active snapshot and a nested by-id snapshot
- A second booking replacing the first driver and plate
- Absolute and relative photo URLs, and a null photo
- Year `2019` and year `null`
- Plate taken from the vehicle when the driver plate differs
- Null phone, photo, color, year, and ETA fallbacks
- `booking:status` keeping the accepted vehicle and the original ETA
- `driver:location` parsing without touching ETA
- A different `bookingId` being rejected

No new APK build. These tests compiled the parser and assignment changes.

## Remaining gaps

- Photo bytes are not fetched in unit tests. A device still has to load the image from the resolved URL.
- In-app messaging is still unsupported. There is no driver-message API, so no message button was added.
- This contract has no driver rating. The card does not show one.
- `booking:searching` clears the current assignment. That is the new-search case, not a status update during the accepted ride.

## Physical-device QA checklist

1. Accept a ride and confirm name, photo, make, model, color, year, and the vehicle plate match the `booking:accepted` payload.
2. Confirm the plate matches `vehicle.plateNumber`.
3. Confirm ETA shows the accepted `etaMinutes` and does not change when the car moves or when status becomes arrived or in progress.
4. Confirm the driver marker still moves on `driver:location`.
5. Force-close and reopen. `GET /bookings/active` should restore the same driver, vehicle, plate, and ETA.
6. Open the same ride via booking id and confirm the same card.
7. Try a relative `profileImageUrl` and an absolute `https` URL. A null photo should show initials.
8. With `year: null`, color/make/model and the plate should remain, without a year.
9. With `phone` set, Call Driver should open the dialer for that number. With `phone: null`, the call button should be hidden.
10. Start a second booking and confirm the first driver’s name and plate are gone.
