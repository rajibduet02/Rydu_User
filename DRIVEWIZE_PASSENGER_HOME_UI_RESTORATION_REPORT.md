# DriveWize Passenger — Home UI Restoration Report

Final status: **PASSENGER ORIGINAL HOME UI RESTORED — NEW CATEGORY SUPPORT PRESERVED**

Home, Services, and Offers were restored from the repository versions that existed immediately before the service-category UI cleanup. Quote-level category compatibility remains.

## 1. Home changes the previous category task introduced

Compared to `HEAD` (pre-task working tree baseline for those files), the category implementation had:

**`lib/features/home/presentation/screens/home_screen.dart`**
- Removed Bike and CNG tiles from the “For you” category row
- Removed the entire “Commute smarter” promo section (CNG + Bike promos)
- Removed the entire “Elevate your ride” promo section (Premium + Comfort)
- Removed `HomePromoCard` usage / import
- Removed `_SectionTitle`
- Changed spacing after the category row

**`lib/features/home/presentation/providers/home_controller.dart`**
- Removed `HomeCategoryIds.bike`, `cng`, `premium`, `comfort`
- Removed `selectPromoCng`, `selectPromoHopOn`, `selectPromoPremium`, `selectPromoComfort`
- Reworded `openRideBooking` comment

These were visual/entry-point redesigns, not required for quote catalog compatibility.

## 2. Exactly what was restored

Restored from git `HEAD` (exact previous source, not reconstructed):

- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/providers/home_controller.dart`

Home again includes:

- Category row: Ride, Bike, CNG, Rentals
- “Commute smarter” promos: Go with RYD U CNG, Hop on RYD U
- “Elevate your ride” promos: Premium, Comfort
- Previous spacing, styling, ordering, and navigation presentation

Verified in the restored `home_screen.dart`: Bike, CNG, Premium, Comfort, and the promo taps are present again.

## 3. Services / Offers restoration

Yes. The same category task had also changed Services and Offers UI/entry points. Those were restored from `HEAD` as well:

- `lib/features/services/data/datasources/services_local_datasource.dart` — Bike and CNG cards restored
- `lib/features/services/domain/constants/service_ids.dart` — bike/cng ids restored
- `lib/features/services/presentation/providers/services_controller.dart` — Bike/CNG navigation cases restored
- `lib/features/offers/domain/entities/offer_entity.dart` — `OfferActionType.premium` restored
- `lib/features/offers/data/datasources/offers_local_datasource.dart` — “30% off Premier” / premium action restored
- `lib/features/offers/presentation/providers/offers_controller.dart` — Premium `selectedType` booking open restored
- `lib/features/ride_booking/domain/constants/ride_booking_type_ids.dart` — Bike, CNG, Premium, Comfort entry constants restored

Home tiles / Services cards / Offers still open the existing plan-your-ride flow with a legacy-looking `selectedType` label. That label does not filter the quote list or invent a `serviceCategoryId`. The bookable cards still come from `POST /api/v1/passenger/bookings/quote`.

## 4. Production files remaining changed for category compatibility

| File | Status |
| --- | --- |
| `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` | kept |
| `lib/features/ride_booking/presentation/models/ride_vehicle_option.dart` | kept |
| `test/features/ride_booking/service_category_presentation_test.dart` | kept (tests only) |

No Home, Services, Offers, or entry-type production files remain modified for this migration.

Other dirty ride-booking presentation files in the working tree (for example `ride_selection_screen.dart`, tokens, payment tiles) were **not** part of this restoration task and were left untouched.

## 5. Why each remaining production file is necessary

**`ride_planning_parsers.dart`**
- Additive `displayName` preference: `displayName` → `serviceName` → `name` → `"Ride"`
- Required so new backend label fields render correctly without breaking old payloads

**`ride_vehicle_option.dart`**
- Explicit emoji mapping for `economy`, `executive`, `suv`, `van`, `minivan`, `ada`
- Keeps legacy bike/moto/cng branches
- Generic car fallback for unknown keys (including bus)
- Display-only; does not affect booking ids

## 6. Confirmation: original Home layout/design restored

Yes. Home screen and Home controller match the repository versions from before the category UI cleanup. Bike/CNG tiles and Premium/Comfort/CNG/Bike promos are back with prior structure and behavior.

## 7. Confirmation: quote list still supports the six new backend categories

Yes. The selector remains quote-driven. Parser + icon mapping still support:

- ECONOMY / Economy Sedan / economy
- EXECUTIVE / Executive Sedan / executive
- SUV / SUV / suv
- VAN / Passenger Van / van
- MINIVAN / Mini-Van / minivan
- ADA / ADA Accessible / ada

No local six-button Home catalog was added.

## 8. Confirmation: serviceCategoryId flow unchanged

Still:

quote `serviceCategoryId` → `RideOptionEntity.id` → `selectedVehicleId` → `BookingCreateRequest.serviceCategoryId` → `POST /api/v1/passenger/bookings`

`BookingCreateRequest` was not modified. No hardcoded category UUIDs. Historical Bike/CNG/Moto/Ride/Premium/Comfort names remain displayable. Bus is not injected locally.

## 9. Tests

`flutter test test/features/ride_booking/service_category_presentation_test.dart`

**14 tests, all passed**, covering:

1. ECONOMY parse/render  
2. EXECUTIVE parse/render  
3. SUV parse/render  
4. VAN parse/render  
5. MINIVAN parse/render  
6. ADA parse/render  
7. quote order preserved  
8. `displayName` support  
9. `serviceCategoryId` passthrough into booking body  
10. unknown icon fallback  
11. legacy Bike/CNG parse/render  
12. historical Premium booking display  
13. Bus not injected  
14. long names readable on `RideOptionCard`

Home/Services/Offers redesign assertions were removed from this test file so they no longer fight the restored UI.

## 10. Analyze result

`flutter analyze` on:

- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
- `lib/features/ride_booking/presentation/models/ride_vehicle_option.dart`
- `test/features/ride_booking/service_category_presentation_test.dart`

**No issues found.**

---

If a hot-reload session is still on the previous Home build, perform a full restart (`R` / stop + `flutter run`) so the restored Home UI is loaded.
