# DriveWize Passenger — New Service Category Implementation Report

Final status: **DRIVEWIZE PASSENGER NEW SERVICE CATEGORIES IMPLEMENTED — DEVICE QA REQUIRED**

The instant-book list is still produced only by `POST /api/v1/passenger/bookings/quote`. No local catalog of Economy, Executive, SUV, Van, Mini-Van, or ADA was added. No category UUIDs were hardcoded. `BookingCreateRequest` was not modified.

## 1. Files changed

- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
- `lib/features/ride_booking/presentation/models/ride_vehicle_option.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/providers/home_controller.dart`
- `lib/features/services/data/datasources/services_local_datasource.dart`
- `lib/features/services/domain/constants/service_ids.dart`
- `lib/features/services/presentation/providers/services_controller.dart`
- `lib/features/offers/domain/entities/offer_entity.dart`
- `lib/features/offers/data/datasources/offers_local_datasource.dart`
- `lib/features/offers/presentation/providers/offers_controller.dart`
- `lib/features/ride_booking/domain/constants/ride_booking_type_ids.dart`
- `test/features/ride_booking/service_category_presentation_test.dart` (new)

`RideOptionCard` was not redesigned. Dead local ride-option fixtures were left in place. `GET /api/v1/passenger/services` was not wired up.

## 2. Parser changes

`RidePlanningParsers.serviceQuote` now chooses the passenger label in this order:

1. `displayName`
2. `serviceName`
3. `name`
4. existing fallback `"Ride"`

`displayName` is optional. A payload that only has `serviceName` or `serviceCode` still parses. Quote order is unchanged: the list stays in the order the backend returns.

The booking/history parser was not changed. Restored and historical rows still show the stored `serviceName`, then `serviceCode`.

## 3. New iconKey mapping

Still emoji inside the existing 56×56 well. No image assets and no `pubspec.yaml` asset changes.

| iconKey | Emoji |
| --- | --- |
| `economy` | 🚘 |
| `executive` | ✨ |
| `suv` | 🚙 |
| `van` | 🚐 |
| `minivan` | 🚕 |
| `ada` | ♿ |
| unknown, including `bus` | 🚗 |

Legacy branches remain after the exact keys:

- `bike` or `moto` → 🏍️
- `cng` → ⚡
- `xl` or `suv` inside a longer legacy key → 🚙

The map is display-only. It does not choose the category id or the fare.

## 4. Home changes

Removed the Bike and CNG category tiles.

Removed the promo rows that opened booking as CNG, Bike, Premium, or Comfort (“Go with RYD U CNG”, “Hop on RYD U”, “Premium”, “Comfort”).

Home still has:

- “Where to?” / search, which opens the generic ride flow (`selectedType: Ride`)
- Later / reserve
- A Ride tile that opens the same generic flow
- Rentals, which still opens the existing rentals flow

No six-category button row was added. The six services appear only after a quote returns.

## 5. Services changes

The local services grid no longer includes Bike or CNG.

It still includes Ride, Intercity, Reserve, and Rentals. Ride opens the quote flow. Intercity, Reserve, and Rentals keep their existing separate routes.

## 6. Offers changes

`OfferActionType.premium` was removed so a book action cannot start a trip as Premium.

The local “30% off Premier” item is now “30% off your next ride” and uses `OfferActionType.ride`, which pushes ride booking with `selectedType: 'Ride'`. Intercity is unchanged. No new promotions were added.

## 7. Generic Ride entry behavior

`RideBookingTypeIds.ride` remains the generic plan-your-ride label. It is not a backend category id and it is not sent as `serviceCategoryId`.

Home search, the Home Ride tile, the Services Ride tile, and ride offers all open that same flow. After pickup and dropoff, the app requests a quote and renders whatever services the backend returns, in that order.

## 8. Legacy / historical compatibility

No remapping of Bike → Economy or Premium → Executive.

Quote parsing still accepts `serviceName: Bike` and `serviceName: CNG`, and those icon keys still render 🏍️ and ⚡ if a quote contains them.

History and active-booking restore still display the backend-stored name. A completed booking with `serviceName: Premium` still reads as Premium.

## 9. serviceCategoryId flow

Unchanged:

quote `serviceCategoryId` → `RideOptionEntity.id` → `selectedVehicleId` → `BookingCreateRequest.serviceCategoryId` → `POST /api/v1/passenger/bookings`

The create-booking body builder was not edited. A targeted test passes the selected option id into that body and expects the same string back.

## 10. Bus confirmation

No Bus card, icon product mapping, quote, booking type, or custom quote flow was added. A quote payload that does not include Bus is returned with the same length the backend sent. If a future payload used iconKey `bus`, it would use the generic car emoji. It is not a current product visual.

## 11. Tests run / results

`flutter test test/features/ride_booking/service_category_presentation_test.dart`

17 tests, all passed. They cover the six categories, `displayName`, quote order, booking id passthrough, unknown-icon fallback, legacy Bike/CNG quotes, a historical Premium booking, readable long names, Services catalog, Offers, Home entry copy, and Bus not being injected.

`flutter test test/features/ride_booking/ride_planning_parsers_test.dart` was run together with the new file on the first pass. All tests in that run passed, including the existing CNG quote fixture.

## 12. Build / analyze result

`flutter analyze` on the 12 changed Dart files:

**No issues found.**

No Android or iOS driver tests were run. No device build was run.

## 13. Exact physical QA steps

1. Open Home. Confirm Bike, CNG, Premium, and Comfort tiles and promos are gone. Confirm Ride, search, Later, and Rentals are still there.
2. Tap Ride or “Where to?”, set a pickup and destination, and wait for the quote sheet.
3. Confirm the cards match the live quote, in backend order, with names Economy Sedan, Executive Sedan, SUV, Passenger Van, Mini-Van, and ADA Accessible when the backend returns them.
4. Confirm capacity (3, 3, 6, 8, 5, 4), fare, and currency match the response. Confirm Executive Sedan, Passenger Van, and ADA Accessible stay readable.
5. Select each card and confirm the footer says `Choose {that name}`.
6. Complete one booking and confirm the request body `serviceCategoryId` is the selected quote id, not a code such as `ECONOMY`.
7. Open Services. Confirm Ride is present and Bike and CNG are absent. Open Ride and confirm the same quote sheet.
8. Open Offers. Confirm no card says Premium or Premier. Book the ride offer and confirm it enters the generic quote flow.
9. Open an old completed trip whose stored name is Bike, CNG, Moto, Ride, Premium, or Comfort. Confirm the history label is unchanged.
10. Confirm Bus does not appear unless the quote response itself includes it.

## 14. Remaining visual / design limitation

Vehicle art is still emoji, not a dedicated illustration.

- Economy uses 🚘, which is distinct from the unknown-category car 🚗.
- Executive uses ✨, not a sedan drawing.
- Passenger Van uses 🚐. Mini-Van uses 🚕.
- ADA uses ♿.
- SUV uses 🚙.

Distinct PNG, JPG, WebP, or SVG assets are still required if the product wants real vehicle illustrations. That was intentionally left out of this change.
