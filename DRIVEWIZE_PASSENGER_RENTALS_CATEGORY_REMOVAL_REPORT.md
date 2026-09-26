# DriveWize Passenger — Rentals Removal From Current Category UI

Final status: **PASSENGER RENTALS REMOVED FROM CURRENT CATEGORY UI — DEVICE QA REQUIRED**

Rentals was removed only from UI lists that present the current DriveWize service-category catalog. The Rentals feature (routes, screens, controllers, constants, `openRentals`) was not deleted.

## 1. What changed

### Home “For you” category strip
- Removed the local Rentals tile from the horizontal category list.
- Strip now renders only `PassengerServiceCategories.current` (six items).
- Card design, width formula, horizontal scroll, spacing, promos, search/Where to, Later/Reserve, and other Home sections were not redesigned.

Exact Home strip content now:

1. Economy Sedan  
2. Executive Sedan  
3. SUV  
4. Passenger Van  
5. Mini-Van  
6. ADA Accessible  

### Services screen catalog
- Removed the local Rentals entry from `ServicesLocalDatasourceImpl.getCatalog()`.
- Six backend ride categories remain.
- Intercity and Reserve remain in the Services grid (see report below).

## 2. What was intentionally left alone

- Rentals routes, screens, controllers, and `HomeController.openRentals` / `ServiceIds.rentals` / `HomeCategoryIds.rentals`
- Home Later / Reserve (`HomeSearchBar` → `openReserveFlow`)
- Home promo sections (design and placement)
- Offers
- Quote API, booking `serviceCategoryId` flow, maps, payments, history
- No Bike / CNG / Premium / Comfort / Bus added

## 3. Intercity and Reserve (reported, not removed)

Services still locally inserts **Intercity** and **Reserve** into the same Services grid as the six ride categories.

| Entry | In Home category strip? | In Services grid? | Backend service category? | Action this pass |
| --- | --- | --- | --- | --- |
| Economy…ADA (6) | Yes | Yes | Yes | Kept |
| Rentals | No (removed) | No (removed) | No | Removed from category UIs |
| Intercity | No | Yes | No | **Reported only — not removed** |
| Reserve | No (Home uses Later/Reserve search control) | Yes | No | **Reported only — not removed** |

No further removals were made without product confirmation.

## 4. Booking / quote confirmation

Unchanged:

quote `serviceCategoryId` → `RideOptionEntity.id` → `selectedVehicleId` → `BookingCreateRequest.serviceCategoryId`

No hardcoded category UUIDs.

## 5. Files changed

- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/services/data/datasources/services_local_datasource.dart`
- `test/features/ride_booking/service_category_presentation_test.dart`
- `DRIVEWIZE_PASSENGER_RENTALS_CATEGORY_REMOVAL_REPORT.md` (this file)

## 6. Tests

`flutter test test/features/ride_booking/service_category_presentation_test.dart`

**17 tests, all passed**, including:

- Home presentation has exactly six backend category names and no Rentals
- Services catalog has the six categories, Intercity, Reserve, and no Rentals

## 7. Analyze

`flutter analyze` on the three changed Dart files:

**No issues found.**

## 8. Device QA

1. Full restart the Passenger app.
2. Home “For you”: confirm exactly six category cards; Rentals absent.
3. Confirm horizontal scroll, card size, promos, Where to, and Later still look the same.
4. Services tab: confirm six categories; Rentals gone; note Intercity and Reserve still present.
5. Book a ride via a Home category → quote → confirm `serviceCategoryId` still comes from the selected quote.
