# DriveWize Passenger — New Service Category UI Audit

Audit only. No Passenger production code, APIs, booking state, payment, maps, or assets were changed.

Final status: **PASSENGER NEW SERVICE CATEGORY AUDIT COMPLETE — IMPLEMENTATION PLAN READY**

The instant-book service cards are already generated from `POST /api/v1/passenger/bookings/quote`. The app does not keep a hardcoded list of bookable category UUIDs, and it does not invent a `serviceCategoryId`. Legacy Bike / CNG / Moto / Ride / Premium / Comfort names still appear as Home, Services, and Offers entry labels, and as dead local fixtures. Those labels do not filter the quote list and are not sent as the booking category id.

---

## 1. Current service-selection architecture

Live path:

1. Home, Services, Offers, or Welcome opens plan-your-ride with a string `selectedType` (`Ride`, `Bike`, `CNG`, `Premium`, `Comfort`, `Reserve`).
2. `RideBookingScreen` stores that string as `RideBookingState.selectedRideType`. It is a flow label. It is not sent on the quote request and it does not filter cards.
3. After pickup and dropoff are resolved, `RideBookingController` calls route preview, then quote.
4. `PassengerRideRemoteDatasource.quoteBooking` posts pickup, dropoff, and stops only.
5. `RidePlanningParsers.bookingQuote` reads `quotes` (fallback keys `services`, `options`) into `ServiceQuoteEntity`.
6. `rideOptionFromQuote` maps each quote to `RideOptionEntity`. `id` is `serviceCategoryId`. Every option is forced into the local presentation bucket `recommended`.
7. `RideSelectionScreen` groups options by that bucket and renders a vertical list of `RideOptionCard`.
8. Tap calls `selectVehicle(option.id)`.
9. Confirm calls `createBooking(serviceCategoryId: state.selectedVehicleId)`.

`GET /api/v1/passenger/services` is declared and never called. The Services tab reads a local catalog.

`RideBookingRepositoryImpl.getRideOptions()` returns an empty list on purpose. The local fixture list in `ride_booking_local_datasource.dart` (CNG, Moto, Bike, Premier, UberXL, and so on) is not on the live path. `GetRideOptionsUsecase` is registered and unused by any screen.

Rentals are a separate hourly flow with their own local vehicle ids. They are not the instant passenger quote selector.

## 2. API endpoints used

| Endpoint | Used by instant selection? | Role |
| --- | --- | --- |
| `POST /api/v1/passenger/routes/preview` | Yes, before quote | Polyline and bounds. No category. |
| `POST /api/v1/passenger/bookings/quote` | Yes | Source of the card list. |
| `GET /api/v1/passenger/services` | No | Path constant only. |
| `POST /api/v1/passenger/bookings` | Yes | Create booking. Body includes `serviceCategoryId` from the selected quote. |
| `GET /api/v1/passenger/bookings/active` and `GET /api/v1/passenger/bookings/:id` | Restore / history | Read `serviceCategoryId`, `serviceCode`, `serviceName` as returned. |

Quote body fields: `pickup`, `dropoff`, `stops`. No category code and no category id.

Paths live in `lib/core/constants/passenger_api_paths.dart`. Prefix is `/api/v1/passenger`.

## 3. Models involved

| Layer | Type | Relevant fields |
| --- | --- | --- |
| Parser | `RidePlanningParsers.serviceQuote` | `serviceCategoryId` (also `id`, `serviceId`), `serviceCode` (also `code`), `serviceName` (also `name`, else `"Ride"`), `description`, `iconKey` (also `icon`), `capacity` (default 4), fare from `finalFare` / `price` / nested `fare`, `currency` (default `BDT`) |
| Domain | `ServiceQuoteEntity` | The fields above, plus distance, duration, ETA, discount, airport, promotion |
| Domain | `BookingQuoteEntity` | `route` + `quotes` |
| Presentation | `RideOptionEntity` via `rideOptionFromQuote` | `id` = category id, `name` = `serviceName`, `capacity` string, `price` = `"{currency} {finalFare}"`, `iconEmoji` from `_iconFor`, `serviceCode` |
| Booking body | `BookingCreateRequest` | `serviceCategoryId` plus waypoints and payment. Fare is not sent. |
| Restored booking | `BookingEntity` | Optional `serviceCategoryId`, `serviceCode`, `serviceName`. No whitelist. |

`displayName` is not read on a quote or a booking. If the backend sends the passenger label only as `displayName`, and omits `serviceName` and `name`, the card name becomes the fallback `"Ride"`. If `serviceName` is already `"Economy Sedan"` (and the other display names), the current parser shows the correct name.

A quote is dropped only when `serviceCategoryId` / `id` / `serviceId` is missing, or when no fare number can be parsed. Unknown codes are not dropped.

## 4. Dynamic vs hardcoded

**Dynamic (live cards):** the ride-selection list is the quote array. Count, order, names, capacity, fare, currency, and ids follow the response. Tests already accept one quote or six quotes with arbitrary ids.

**Hardcoded, and not the card list:**

- Home category row and promo tiles: Ride, Bike, CNG, Premium, Comfort, Rentals.
- Services grid: Ride, Bike, CNG, Intercity, Reserve, Rentals.
- Offers dummy row that opens booking with `selectedType: Premium`.
- Local ride-option fixtures (unreachable from the screen).
- Presentation section titles: `recommended`, `premier`, `popular`, `economy`. Quote mapping always sets `recommended`, so every backend card appears under “Rides we think you'll like”. The word `economy` here is a section id, not service code `ECONOMY`.

**Not hardcoded:** category UUIDs. None are reconstructed from BIKE, CNG, MOTO, RIDE, PREMIUM, or COMFORT.

## 5. Legacy Bike / CNG / Moto / Ride / Premium / Comfort assumptions

`ride` as a word is mostly booking-lifecycle terminology (ride booking, active ride, ride history). Those hits are not the old `RIDE` service category. Category-shaped hits are below.

### Hardcoded service category

| Location | What it hardcodes |
| --- | --- |
| `lib/features/home/presentation/providers/home_controller.dart` | `HomeCategoryIds`: Ride, Bike, CNG, Premium, Comfort. Promo methods open booking with those strings. |
| `lib/features/home/presentation/screens/home_screen.dart` | Bookable cards Bike and CNG. Promos CNG, Bike (“Hop on RYD U”), Premium, Comfort. |
| `lib/features/services/domain/constants/service_ids.dart` | Ride, Bike, CNG. |
| `lib/features/services/data/datasources/services_local_datasource.dart` | Services grid labels and emojis for Ride, Bike, CNG. |
| `lib/features/services/presentation/providers/services_controller.dart` | Ride / Bike / CNG all push the same ride-booking route with that string as `selectedType`. |
| `lib/features/ride_booking/domain/constants/ride_booking_type_ids.dart` | Ride, Bike, CNG, Premium, Comfort. Default flow label is Ride. |
| `lib/features/offers/domain/entities/offer_entity.dart` | `OfferActionType.premium`. |
| `lib/features/offers/data/datasources/offers_local_datasource.dart` | Local “Premier” offer uses `OfferActionType.premium`. |
| `lib/features/offers/presentation/providers/offers_controller.dart` | Opens booking with `selectedType: 'Premium'` or `'Ride'`. |
| `lib/features/ride_booking/data/datasources/ride_booking_local_datasource.dart` | Fixture options CNG, Moto, Bike 41, Bike Saver. Not used by the live selector. |
| `lib/shared/enums/vehicle_type.dart` | `economy`, `comfort`, `premium`, `xl`. Defined only. No other Dart file references `VehicleType`. |

These strings are not turned into `serviceCategoryId`.

### Icon / image mapping

`lib/features/ride_booking/presentation/models/ride_vehicle_option.dart` `_iconFor`:

- key contains `bike` or `moto` → 🏍️
- key contains `cng` → ⚡
- key contains `xl` or `suv` → 🚙
- anything else → 🚗

Home and Services use the same emoji set on their hardcoded tiles. There is no image asset map.

### Fallback mapping

- Missing quote name → `"Ride"`.
- Missing booking name on restore → `"Ride"`.
- `RideBookingState.serviceNameLabel` uses the selected quote name, then `selectedRideType`, then `"Ride"`. After quotes load, the selected card name wins, so a Home tap on Bike does not relabel Economy Sedan as Bike.
- Missing `iconKey` and a service code that matches none of the branches → 🚗.
- Missing capacity → `4` at parse time. Backend capacity replaces that default when present.
- `rideVehicleOptionFromExtra` default emoji is 🚗.

### UI label

Home, Services, and Offers still show Bike, CNG, Premium, and Comfort as ways to start a trip. The selector itself prints `quote.serviceName`. The bottom button prints `Choose {name}`.

### Business logic

No branch selects, hides, or prices a category from those legacy codes. `selectedRideType` is copied into navigation extras for finding-driver and is not part of the create-booking body.

`nearbyDrivers` accepts a `serviceCategoryId` argument. The repository forwards it. No screen currently calls it to build the selector.

### Model / API field

Parsers store whatever `serviceCode` and `serviceName` the backend sends, including historical `cng` or `CNG`. They do not switch on those values.

### Booking lifecycle terminology

`selectedType: 'Ride'`, route name ride booking, “Choose Ride” before a vehicle exists, finding-driver `selectedRideType` default `'Ride'`, and history copy such as “this ride” are product-flow words. Leave them. They are not the inactive `RIDE` category.

Welcome uses `selectedType: 'Ride'` the same way.

### Unrelated

- `app_colors.dart` comment “Premium dark surface”.
- `faqs_screen.dart` “premium travel experience”.
- Auth `displayName`.
- Rental vehicle ids such as `uberx-rentals`.

### Tests

Parser, history, active-booking, and Stripe tests use sample payloads with `serviceCode: cng` or `serviceName: CNG` as fixtures. They prove unknown codes parse. They are not a live category list. Do not treat them as a reason to strip legacy field parsing.

## 6. Current asset / icon mapping

Service cards do not use PNG, JPG, WebP, SVG, a remote image URL, or a Material icon for the vehicle.

They use a 56×56 well and a `Text` emoji from `_iconFor(iconKey ?? serviceCode)`.

Capacity uses `Icons.person_outline_rounded`. That is separate from the vehicle visual.

`pubspec.yaml` has no `flutter.assets` entries. A search of the repo found no `.png`, `.jpg`, `.jpeg`, `.webp`, or `.svg` files.

### Existing vehicle asset filenames

None.

### Mapping result for the new icon keys

| iconKey / serviceCode | Emoji today | Notes |
| --- | --- | --- |
| `economy` | 🚗 | Generic fallback |
| `executive` | 🚗 | Generic fallback |
| `suv` | 🚙 | Matched by `contains('suv')` |
| `van` | 🚗 | `van` is not a branch |
| `minivan` | 🚗 | Does not contain `suv` |
| `ada` | 🚗 | Generic fallback |
| `bike`, `moto`, `cng` | 🏍️ or ⚡ | Still in the mapper. Shown only if a quote still carries those keys. |

## 7. Compatibility matrix

Assumes a quote object includes `serviceCategoryId`, `serviceCode`, `serviceName` equal to the display name below, `description`, `iconKey`, `capacity`, and a fare field the parser already accepts (`finalFare`, `price`, or nested fare amount), plus `currency`.

| | Economy Sedan | Executive Sedan | SUV | Passenger Van | Mini-Van | ADA Accessible |
| --- | --- | --- | --- | --- | --- | --- |
| Code | ECONOMY | EXECUTIVE | SUV | VAN | MINIVAN | ADA |
| iconKey | economy | executive | suv | van | minivan | ada |
| Capacity | 3 | 3 | 6 | 8 | 5 | 4 |
| Parse | Yes | Yes | Yes | Yes | Yes | Yes |
| Render in the list | Yes, under “Rides we think you'll like” | Yes | Yes | Yes | Yes | Yes |
| Backend name | Yes, from `serviceName` or `name` | Yes | Yes | Yes | Yes | Yes |
| Name if only `displayName` is sent | Falls back to “Ride” | Same | Same | Same | Same | Same |
| Capacity | Yes, `3` | `3` | `6` | `8` | `5` | `4` |
| Fare and currency | Yes | Yes | Yes | Yes | Yes | Yes |
| Selection | Yes | Yes | Yes | Yes | Yes | Yes |
| `serviceCategoryId` on create | The quote id | The quote id | The quote id | The quote id | The quote id | The quote id |
| Correct dedicated visual | No | No | Closest existing emoji only | No | No | No |
| Generic / old visual | 🚗 | 🚗 | 🚙 | 🚗 | 🚗 | 🚗 |
| Fail closed | No | No | No | No | No | No |

Nothing in the passenger app special-cases these six codes. Nothing rejects them.

## 8. Booking `serviceCategoryId` flow

1. Parser keeps the backend id string.
2. `rideOptionFromQuote` sets `RideOptionEntity.id` to that string.
3. The first quote is selected automatically. Later taps replace `selectedVehicleId` with the tapped card id.
4. `confirmBooking` sends `serviceCategoryId: state.selectedVehicleId`.
5. `BookingCreateRequest.body` copies that field through. It does not look up a code.

Uuid usage in this feature is the idempotency key and the places session token. It is not a category id.

Restored bookings keep `booking.serviceCategoryId` when the quote card is no longer in memory. That id is the one the backend stored on the booking. It is not guessed from a name.

## 9. UI / layout implications

`RideSelectionScreen` is a map plus a bottom sheet. The sheet is a vertical `ListView`, not a grid or carousel. Cards are full width, stacked with 10px gaps.

Each `RideOptionCard` is a row:

- Left: 56×56 emoji well.
- Center, `Expanded`: name (16px, w700, wraps, no max lines), then a `Wrap` of ETA, person icon + capacity, and an optional discount chip, then description at 12px, one line, ellipsis.
- Right: price, and struck original price when discounted.

Selected state: green border (2.5px), tinted fill, and the same id comparison `selectedVehicleId == option.id`.

ETA text is `{driverEtaMinutes} min`, or `{durationMin} min` when ETA is absent. It is trip duration when the quote has no driver ETA. It is not a separate “arrives in” field.

Overflow:

- “Executive Sedan”, “Passenger Van”, and “ADA Accessible” sit in an `Expanded` text with default wrapping. On a narrow phone the name can take two lines. It does not use a fixed height, so it does not clip.
- Description already ellipsizes.
- The footer button is `Choose {name}` at 18px inside a full-width button. “Choose Executive Sedan” and “Choose ADA Accessible” fit on one line at typical phone widths (about 360dp). There is no ellipsis on that label. A much longer future name would wrap inside the button rather than change the request.
- Capacity values 3, 4, 5, 6, and 8 are short and sit in a `Wrap`, so they move to the next line instead of overflowing the price.

No layout change is required for these six names to be readable. A `maxLines: 2` plus ellipsis on the name would only be polish.

The local section list cannot hide these cards, because mapping pins them to `recommended`, and `recommended` is rendered. A future change that set `category` from the service code `ECONOMY` would still show, because `economy` is one of the four section ids. A category string outside `recommended | premier | popular | economy` would be parsed and then omitted from the list. Do not start grouping by service code without rendering every bucket the backend returns.

## 10. Historical compatibility

History and restore do not whitelist service codes.

- `RidePlanningParsers.booking` copies `serviceName` and `serviceCode` as plain strings.
- `RideHistoryPresentation.serviceLabel` prints `serviceName`, otherwise `serviceCode`.
- Ride history cards and ride details use that label.
- Active-booking restore builds a vehicle row from `serviceName` when the live quote list is gone.

Bike, CNG, Moto, Ride, Premium, and Comfort therefore stay readable on old and restored bookings. Do not delete that parsing. New selection stops offering them only because the quote endpoint no longer returns inactive categories. The passenger app should not add a second filter that hides those codes if a quote or a history row still contains them.

`_iconFor` branches for bike, moto, and cng do not affect history text. They only affect a quote card if the backend still sends those keys.

## 11. Bus confirmation

No Dart file references Bus as a service. The passenger app does not insert a Bus card, a Bus quote, or a Bus category id. Bus appears only if a future backend quote includes it. Do not add a custom Bus quote flow.

## 12. Exact files that need changes

When implementation starts, the smallest set is:

| File | Change |
| --- | --- |
| `lib/features/ride_booking/presentation/models/ride_vehicle_option.dart` | Map `economy`, `executive`, `suv`, `van`, `minivan`, `ada` to distinct emoji or, later, assets. Keep the bike / moto / cng branches so an old quote still has an icon. |
| `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` | Read `displayName` as a name candidate when present (`displayName`, then `serviceName`, then `name`). Do not require it if `serviceName` is already the label. |
| `lib/features/home/presentation/screens/home_screen.dart` | Remove Bike and CNG as bookable home categories, and remove Premium / Comfort / CNG / bike promos as fake service entry points. Leave a single ride entry that opens the quote flow. |
| `lib/features/home/presentation/providers/home_controller.dart` | Stop passing Bike, CNG, Premium, and Comfort as `selectedType`. |
| `lib/features/services/data/datasources/services_local_datasource.dart` | Remove Bike and CNG from the local services grid. |
| `lib/features/services/domain/constants/service_ids.dart` | Drop bike and cng ids if nothing else references them. |
| `lib/features/services/presentation/providers/services_controller.dart` | Drop the Bike / CNG navigation cases. |
| `lib/features/ride_booking/domain/constants/ride_booking_type_ids.dart` | Stop using Bike, CNG, Premium, and Comfort as entry ids. Keep `Ride` as the generic flow label. |
| `lib/features/offers/presentation/providers/offers_controller.dart` and the local offers datasource | Open the generic ride quote flow. Do not label the trip Premium. |

Optional, not required for correctness:

- `lib/features/ride_booking/presentation/widgets/ride_option_card.dart` — two-line ellipsis on the name.
- `lib/features/ride_booking/data/datasources/ride_booking_local_datasource.dart` — delete or ignore the fixture catalog. It is already off the live path.
- `lib/shared/enums/vehicle_type.dart` — unused. Safe to leave.

Do not change for this category work:

- `BookingCreateRequest`, create-booking call, payment, Stripe, sockets, FCM, maps, route preview, booking phase machine.
- History parsers, beyond the optional `displayName` read. That read is additive.
- Backend, Admin, and driver apps.

Tests that embed CNG as sample JSON can stay. Add one quote fixture for the six new codes only if you want a regression lock. Do not assert a fixed UUID.

## 13. Recommended smallest implementation

1. Leave the quote-driven list as the only source of instant-book cards.
2. Do not add a local list of ECONOMY, EXECUTIVE, SUV, VAN, MINIVAN, or ADA, and do not add UUIDs.
3. Prefer `displayName` when the payload has it, otherwise keep `serviceName`.
4. Point `_iconFor` at six distinct emoji (or image assets, if design supplies them). Unknown keys stay on 🚗.
5. Remove legacy category entry points on Home, Services, and Offers so new trips are not advertised as Bike, CNG, Premium, or Comfort. The quote screen already shows only what the backend returns.
6. Keep history and restore able to print any `serviceName` / `serviceCode`.
7. Do not add Bus.

No booking-contract change is required. `serviceCategoryId` already travels from the selected quote to `POST /bookings`.

## 14. Whether new vehicle image assets are required

Not required for parse, render, select, or book.

Required only if the product wants a distinct illustration per category. The repo has no vehicle image files. Today five of the six keys share the generic car emoji. `suv` already has a separate SUV emoji. Adding PNG or SVG assets would be new work on top of the emoji mapper, including a `pubspec.yaml` assets entry. This audit did not add any files.

## 15. What already works without a code change

If quote responses contain the six active categories with `serviceCategoryId`, `serviceName`, `capacity`, fare, and `currency`:

- all six cards render
- names and capacities match the payload
- fares render
- selection works
- create booking sends that quote’s `serviceCategoryId`
- inactive categories disappear from the selector as soon as the backend omits them
- old bookings still show their stored names

The gaps are presentation and entry points: generic emoji, no `displayName` field, and Home / Services / Offers still advertising retired categories that do not change the quote list.
