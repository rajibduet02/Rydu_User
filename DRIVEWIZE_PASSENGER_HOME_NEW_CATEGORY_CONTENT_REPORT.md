# DriveWize Passenger — Home New Category Content Report

Final status: **PASSENGER HOME NEW CATEGORIES UPDATED — ORIGINAL UI PRESERVED — DEVICE QA REQUIRED**

Home and Services category **content** now show the six current ride categories. Card widgets, promo section structure, search/Later/Rentals, and overall hierarchy were preserved. Quote booking remains authoritative.

## 1. Exact Home UI elements preserved

- `HomeTopBar`, `HomeSearchBar` (Where to? + Later/Reserve)
- `_ForYouHeader` + offers arrow
- `RideCategoryCard` component (same surface, border, discount pill slot, emoji + label layout)
- Promo section titles: “Commute smarter”, “Elevate your ride”
- Two-up `HomePromoCard` rows (styles, spacing, placement unchanged)
- Active ride card, bottom spacing, shell scroll padding
- Rentals tile still present in the category strip

Only category **data** and the strip’s scroll behavior for six items changed (see below).

## 2. Old category content replaced

| Before | After |
| --- | --- |
| Ride | Economy Sedan (`ECONOMY`) |
| Bike | Executive Sedan (`EXECUTIVE`) |
| CNG | SUV (`SUV`) |
| (n/a) | Passenger Van (`VAN`) |
| (n/a) | Mini-Van (`MINIVAN`) |
| (n/a) | ADA Accessible (`ADA`) |
| Rentals | Rentals (unchanged) |

Bike and CNG no longer appear as current Home ride categories.

Because six ride tiles + Rentals cannot fit in the old 4-up `Expanded` row without shrinking cards, the strip is a **horizontal `ListView`** with each card width equal to the previous 4-up slot width. That keeps card size; it does not redesign the card.

`RideCategoryCard` label `maxLines` went from 1 → 2 so longer names remain readable without changing card chrome.

## 3. Source of new category data

Shared presentation catalog (codes + display names + iconKeys + capacity):

`lib/features/ride_booking/domain/constants/passenger_service_categories.dart`

Ids are **service codes** (`ECONOMY`, …), never category UUIDs.

Emoji via existing `serviceCategoryIconEmoji` (economy/executive/suv/van/minivan/ada).

## 4. Whether GET /passenger/services was integrated

**No.**

Reasons (architecture stop, as requested):

- Path exists in `PassengerApiPaths.services` but there is no remote client, parser, or repository call today.
- Services hub also mixes non-catalog products (Intercity, Reserve, Rentals) that are local product flows.
- Home previously rendered a synchronous static list; wiring an async remote catalog would add loading/error UI and a parallel data path beyond a content swap.
- Response field shape is not consumed anywhere in the app yet.

Prefer a dedicated follow-up to wire `GET /api/v1/passenger/services` once payload contract and Rentals/Intercity mixing rules are product-confirmed.

## 5. Home category tap behavior

Tap still calls `openRideBooking(selectedType)` → existing plan-your-ride route with `RideBookingRouteArgs(selectedType: <CODE>)`.

- `selectedType` is a **presentation hint** (e.g. `ECONOMY`), not a UUID.
- Quote API is unchanged (no category filter field invented).
- Quote cards still come from `POST /api/v1/passenger/bookings/quote`.
- Booking still uses the selected quote’s `serviceCategoryId`.

Search / “Where to?” still opens with generic `Ride`.

## 6. Services changes

Same principle: grid/card design unchanged.

Local catalog now lists the six ride categories (full display names + emoji), then Intercity, Reserve, Rentals (still dimmed product flows).

`ServicesController` opens ride booking for any current ride code; Intercity/Reserve/Rentals routes unchanged.

Bike/CNG removed from the Services catalog.

## 7. Promo wording changes / unresolved copy

Promo **layout preserved**. Obsolete category words updated to current product names:

| Slot | Before | After | Tap hint |
| --- | --- | --- | --- |
| Green | Go with RYD U **CNG** / ⚡ | Go with RYD U **Economy** / 🚘 | `ECONOMY` |
| Dark | Hop on RYD U / 🏍️ | Hop on RYD U / 🚘 | `ECONOMY` |
| Blue | **Premium** / 🚗 | **Executive** / ✨ | `EXECUTIVE` |
| Dark outlined | **Comfort** / “Affordable luxury” | **SUV** / “Room for six” | `SUV` |

**Unresolved product marketing (not redesigned here):**

- Offers still has local “30% off **Premier**” and `selectedType: 'Premium'` (`offers_local_datasource` / `offers_controller`). Needs product copy approval; left alone this pass to avoid Offers redesign scope.

Final promo marketing lines may still want UX/content review.

## 8. Confirmation: no UUIDs hardcoded

Yes. Entry ids are codes: `ECONOMY`, `EXECUTIVE`, `SUV`, `VAN`, `MINIVAN`, `ADA`. Tests assert they are not UUID-shaped.

## 9. Confirmation: quote remains authoritative

Yes. Home/Services do not create bookings from codes. `serviceCategoryId` still flows:

quote → `RideOptionEntity.id` → `selectedVehicleId` → `BookingCreateRequest` → `POST /bookings`.

## 10. Historical compatibility

Unchanged. History/restore still display stored Bike/CNG/Moto/Ride/Premium/Comfort names. Legacy icon branches remain. Bus is not injected.

## 11. Files changed

- `lib/features/ride_booking/domain/constants/passenger_service_categories.dart` (new)
- `lib/features/ride_booking/domain/constants/ride_booking_type_ids.dart`
- `lib/features/ride_booking/presentation/models/ride_vehicle_option.dart` (`serviceCategoryIconEmoji` public)
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/providers/home_controller.dart`
- `lib/features/home/presentation/widgets/ride_category_card.dart` (`maxLines: 2`)
- `lib/features/services/data/datasources/services_local_datasource.dart`
- `lib/features/services/domain/constants/service_ids.dart`
- `lib/features/services/presentation/providers/services_controller.dart`
- `test/features/ride_booking/service_category_presentation_test.dart`

Parser `displayName` support from the prior category migration remains in place.

## 12. Tests

`flutter test test/features/ride_booking/service_category_presentation_test.dart`

**16 tests, all passed** — six quote categories, `displayName`, `serviceCategoryId` passthrough, unknown fallback, legacy Bike/CNG, historical Premium, no Bus injection, long names, Home/Services codes (not UUIDs), Services catalog content.

## 13. Analyze result

`flutter analyze` on the 10 changed Dart files:

**No issues found.**

## 14. Exact device QA steps

1. Full restart the app (not hot reload only).
2. Home: confirm Bike/CNG tiles are gone; six categories + Rentals appear; horizontal scroll works; cards look same size as before.
3. Confirm promo sections still present; titles no longer say CNG/Premium/Comfort as retired products.
4. Tap Economy Sedan → plan-your-ride → set pickup/dropoff → quote sheet shows backend options (all six when returned).
5. Select a quote and confirm booking uses that quote’s `serviceCategoryId` (not the Home code alone).
6. Services tab: six categories + Intercity/Reserve/Rentals; cards look the same; Bike/CNG gone.
7. Open an old history trip with Bike/CNG/Premium — labels still show stored names.
8. Confirm Bus does not appear unless the quote API returns it.
