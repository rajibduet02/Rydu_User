# RYDU PASSENGER LOCATION COUNTRY AUDIT

**Repository:** Rydu_User (Passenger Flutter)  
**Date:** 2026-09-10  
**Scope:** Read-only. No code was modified. Backend source is not in this repository.

**Final status:**  
`RYDU PASSENGER LOCATION COUNTRY AUDIT COMPLETE — H. NO_US_RESTRICTION_FOUND + F. CURRENT_LOCATION_COUNTRY_NOT_DETECTED (Flutter hardcodes country=BD, not US)`

---

## Executive finding

Pickup and destination search is **not USA-restricted in Flutter**.

The only Places country filter Flutter sends is a **hardcoded Bangladesh code**:

```dart
country: 'BD'
```

in `RideBookingController._runAutocomplete`.

There is **no** `country=US`, `countryCode=US`, `components=country:us`, `region=us`, or USA `LatLngBounds` in the location-search path.

If a live device still returns United States predictions, that cannot be explained by a Flutter `country=US` parameter. The remaining unverified cause would be the **Rydu backend Places proxy** (this repo does not contain that service).

What this app *does* currently enforce is **Bangladesh-only autocomplete**, and it does so without detecting country from GPS.

---

## 1. Complete pickup search flow

Plan Your Ride screen: `RideBookingScreen` (`lib/features/ride_booking/presentation/screens/ride_booking_screen.dart`), title **"Plan your ride"**.

### Entry

1. Home `HomeController.openSearch()` / `openRideBooking()` → `RouteNames.rideBooking` (`/ride-booking`).
2. `RideBookingScreen` post-frame calls `RideBookingController.initializeSelectedType(...)`.
3. If pickup is not already resolved, `loadInitialData()` → `bootstrapCurrentLocation()`.

### GPS pickup bootstrap (before typing)

| Step | Class / function | File |
|------|------------------|------|
| Permission + GPS | `LocationService.requestPermission` / `getCurrentPosition` | `lib/core/location/location_service.dart` |
| Store raw coords | `RideBookingController.bootstrapCurrentLocation` → `rawPickupCoordinates` | `ride_booking_controller.dart` |
| Reverse geocode | `RideBookingRepository.reverseGeocode` → `PassengerRideRemoteDatasource.reverseGeocode` | repository + datasource |
| HTTP | `GET /api/v1/passenger/places/reverse-geocode?lat=&lng=` | `PassengerApiPaths.reverseGeocode` |
| Parse | `RidePlanningParsers.place` | `ride_planning_parsers.dart` |
| Apply pickup | `_applyResolvedCurrentPickup` sets `pickupPlace`, `pickupLocation`, `pickupSource=currentLocation`, `isPickupResolved=true` | controller |
| Suggestions | `_loadBackendSuggestions` → `GET .../places/suggestions?lat=&lng=` | controller + datasource |

`LocationService` uses `geolocator` only. No SIM, locale, or country lookup.

If reverse geocode fails, Flutter still keeps GPS lat/lng with a coordinate label. Pickup is considered resolved from coordinates, even with empty `placeId`.

### Typed pickup autocomplete

| Step | Class / function | File |
|------|------------------|------|
| UI field | `LocationInputCard` pickup `TextField` | `location_input_card.dart` |
| On change | `RideBookingScreen` → `updatePickupLocation` | `ride_booking_screen.dart` |
| Debounce 400 ms, min 2 chars | `_scheduleAutocomplete(..., ActiveSearchField.pickup)` | controller |
| Request | `_runAutocomplete` | controller |
| Repository | `RideBookingRepository.autocomplete` | `ride_booking_repository.dart` / `_impl.dart` |
| HTTP | `GET /api/v1/passenger/places/autocomplete` | `PassengerRideRemoteDatasourceImpl.autocomplete` |
| UI list | `_PredictionList` → `selectPrediction` | `ride_booking_screen.dart` |
| Place details | `GET /api/v1/passenger/places/details?placeId=&sessionToken=` | datasource |
| Apply pickup | `pickupPlace = details`, `pickupSource=manualSelection` | controller |
| Route preview | `_previewRouteAndOpenSelection` if destination already resolved | controller |

Pickup and destination share the **same** `_runAutocomplete` path. The only difference is `ActiveSearchField`.

---

## 2. Complete destination search flow

Same screen, destination field of `LocationInputCard`.

| Step | Class / function |
|------|------------------|
| On change | `updateDestinationQuery` |
| Debounce | `_scheduleAutocomplete(..., ActiveSearchField.destination)` |
| HTTP | **same** `GET .../places/autocomplete` as pickup, including `country=BD` |
| Select | `selectPrediction` or `selectDestination` |
| Details | **same** `GET .../places/details` |
| Apply | `dropoffPlace`, `selectedDestination`, `destinationQuery` |
| Route | `_previewRouteAndOpenSelection` |

Location bias for destination search is the **already-resolved pickup** (`state.pickupPlace` lat/lng), not a USA default.

"Search in a different city" / "Set location on map" navigate to **placeholder** routes (`SupportFlowPlaceholderScreen`). They do not change country or Places parameters.

Live chips on the idle panel come from `GET .../places/suggestions` (lat/lng only). Local Dhaka fixture lists in `RideBookingLocalDatasourceImpl` are **not** used (`getSuggestedLocations()` returns `[]`).

---

## 3. Exact autocomplete request

Places are **not** called from Flutter via Google Places SDK. There is no `googleapis.com`, `GooglePlaces`, `componentRestrictions`, or Maps Places client in Dart.

All search goes through the Rydu Passenger API.

### Endpoint

```
GET {API_BASE_URL}/api/v1/passenger/places/autocomplete
```

Default `API_BASE_URL` = `http://103.208.181.253:3000` (`ApiConstants`).

Path helper: `PassengerApiPaths.autocomplete`.

### Query parameters actually sent

Built in `PassengerRideRemoteDatasourceImpl.autocomplete` and populated by `_runAutocomplete`:

| Parameter | Sent? | Value |
|-----------|-------|--------|
| `input` | yes | typed query (trimmed, length ≥ 2) |
| `lat` | yes if pickup resolved | `state.pickupPlace?.latitude` |
| `lng` | yes if pickup resolved | `state.pickupPlace?.longitude` |
| `city` | **no** | datasource supports it; controller never passes it |
| `country` | **always yes** | **hardcoded `'BD'`** |
| `sessionToken` | yes | UUID v4 stored in `_placesSessionToken` until place details completes |
| `radius` | **no** | not in Flutter request |
| `locationBias` / `locationRestriction` | **no** | not sent; only optional lat/lng |
| `components` / `componentRestrictions` | **no** | |
| `language` | **no** | |
| `region` / `regionCode` | **no** | |
| `countryCode` | **no** | Flutter uses query key `country`, value `BD` |

### Body

None (GET).

### Headers (Dio)

- `Content-Type: application/json`
- `Accept: application/json`
- `Authorization: Bearer <JWT>` (AuthInterceptor)
- `X-Device-ID: <id>` (AuthInterceptor)

No `Accept-Language`. Interceptors do not inject country/region.

### Session token

- Created in `_runAutocomplete`: `_placesSessionToken ??= _uuid.v4()`
- Reused for subsequent autocomplete keystrokes in the same session
- Sent again on place details
- Cleared after successful `placeDetails`

### Example URL (destination typed after GPS pickup in Dhaka)

```
GET /api/v1/passenger/places/autocomplete?input=Mirpur&lat=23.75&lng=90.38&country=BD&sessionToken=<uuid>
```

If pickup is not yet resolved, `lat`/`lng` are omitted; `country=BD` is still sent.

---

## 4. Exact country / region / bounds parameters

### Autocomplete

- **Country restriction:** `country=BD` (hardcoded).
- **Location bias:** optional `lat`/`lng` from `pickupPlace` only. Not a USA box.
- **No radius, no LatLngBounds, no region.**

### Place details

```
GET /api/v1/passenger/places/details?placeId=<id>&sessionToken=<uuid>
```

No country, region, language, or bias.

### Reverse geocode

```
GET /api/v1/passenger/places/reverse-geocode?lat=<gps>&lng=<gps>
```

No country/region.

### Place suggestions

```
GET /api/v1/passenger/places/suggestions?lat=<optional>&lng=<optional>
```

No country.

### Route preview

```
POST /api/v1/passenger/routes/preview
```

Body:

```json
{
  "pickup": { "latitude": ..., "longitude": ..., "address": "...", "placeId": "..." },
  "dropoff": { "latitude": ..., "longitude": ..., "address": "...", "placeId": "..." },
  "stops": [],
  "travelMode": "DRIVE",
  "routePreference": "TRAFFIC_AWARE"
}
```

No country. Coordinates are passed through unchanged.

### Flutter → backend: does Flutter send US?

| Parameter | Sent by Flutter? |
|-----------|------------------|
| `country=US` | **no** |
| `countryCode=US` | **no** |
| `region=US` | **no** |
| `components=country:us` | **no** |
| `country=BD` | **yes, always, on autocomplete** |

---

## 5. All hardcoded US / BD / country matches (relevant)

### Affects pickup + destination search

| File | Function / class | Exact value | Effect |
|------|------------------|-------------|--------|
| `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart` | `RideBookingController._runAutocomplete` | `country: 'BD'` | **Autocomplete country filter for both pickup and destination** |
| `lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart` | `autocomplete` | query key `'country'` | Forwards whatever the controller passes; no default of its own |

Introduced in commit `6c517ec5` ("latest UI", 2026-07-21). Git history in this repo has **no** `country: 'US'` in Dart.

### Parsed but unused for search

| File | Function / class | Exact value | Effect |
|------|------------------|-------------|--------|
| `lib/features/ride_booking/domain/entities/ride_planning_entities.dart` | `PlaceEntity.country` / `countryCode` | optional strings from API | Stored on pickup/dropoff place; **never read** for autocomplete |
| `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` | `RidePlanningParsers.place` | `map['country']`, `map['countryCode']` | Parsing only |

`RideBookingState` has **no** dedicated `countryCode` / service-country field.

### Tests / fixtures (not a live US restriction)

| File | Value | Effect |
|------|-------|--------|
| `test/features/ride_booking/plan_ride_search_test.dart` | `'country': 'Bangladesh'`, `'countryCode': 'BD'`, Dhaka addresses | Parser fixture |
| Many ride_booking tests | Dhaka coords `23.75, 90.38` | Fixtures, not US |
| `lib/features/ride_booking/data/datasources/ride_booking_local_datasource.dart` | Dhaka POI names | Unused for live suggestions |
| `lib/features/offers/data/datasources/offers_local_datasource.dart` | `"Bangladesh"` in offer subtitles | Offers UI only |
| `lib/features/account/...` invite/guardian | `countryCode = '+880'` | Phone, not Places |
| `lib/features/auth/presentation/providers/login_controller.dart` | `selectedCountryCode = '+880'` | Phone |
| `lib/features/auth/presentation/providers/auth_controller.dart` | `selectedCountryCode = '+1'` | **Phone default only**, not location search |
| `lib/features/auth/presentation/widgets/phone_input_card.dart` | `_codes = ['+880', '+1', '+44', '+91']` | Phone picker |
| `android/app/build.gradle.kts` | `dev-5pz66h48u0jnn4sg.us.auth0.com` | Auth0 tenant host (`.us.` is Auth0 region), not Places |

### Strings searched with **zero** location-search hits

`components=country:us`, `country:us`, `country=US`, `countryCode = 'US'`, `countries: ['US']`, `region=us`, `United States`, `USA`, `New York`, `California`, `San Francisco`, `componentRestrictions`, `locationBias`, `locationRestriction`, `GooglePlaces`.

---

## 6. Current-location country detection

| Source | Used to detect service country? |
|--------|----------------------------------|
| GPS | Coordinates only. No country derivation in Flutter. |
| Reverse geocode | May return `country` / `countryCode` if the backend includes them. Parsed onto `PlaceEntity`. **Not copied into search state. Not passed to autocomplete.** |
| Place result | Same: stored on entity, unused for filtering. |
| Device locale | Not used. Language settings screen is a placeholder. |
| SIM | Not used. No telephony/SIM APIs. |
| Backend | Reverse-geocode response is the only possible BD/US signal, and Flutter ignores it for search. |
| Hardcoded constant | Autocomplete always uses `'BD'`. |

**Resolved country stored in state?**  
No dedicated field. At most `state.pickupPlace?.countryCode` if the backend sent it.

**If current location is Dhaka/Bangladesh, does the app ever obtain `"BD"`?**

- **As a detected country used for search:** no. Search does not read GPS country.
- **As a hardcoded query param:** yes — `'BD'` is always sent, even in the United States.
- **As a reverse-geocode field:** only if the backend returns `countryCode: "BD"`. Flutter would store it on `pickupPlace` and then ignore it.

This is classification **F. CURRENT_LOCATION_COUNTRY_NOT_DETECTED**.

---

## 7. Map default location

GoogleMap appears on:

- `RideSelectionScreen` (after route preview)
- `ActiveRideMap` (active ride)

There is **no** Plan Your Ride map. Search is a list UI.

Initial camera:

- Target = pickup lat/lng, else dropoff, else driver
- Zoom 13
- Bounds from `routePreview.routeBounds` or polyline, not a USA box

**No USA coordinates, no USA `LatLngBounds`, no Bangladesh hardcoded camera, no world fallback like (0,0) as a country default.** If there is no target, the widget shows a loading/unavailable placeholder instead of a US map.

Google Maps SDK keys (`GOOGLE_MAPS_API_KEY` / iOS key) are for **map tiles only**. They are not used for autocomplete.

A USA camera would not prove a Places restriction; here there is not even a USA camera.

Classification **C** does not apply.

---

## 8. Reverse geocode behavior

**Request:** `GET /api/v1/passenger/places/reverse-geocode?lat={gps}&lng={gps}`

Flutter does not send region/country. It does not rewrite coordinates.

For a Bangladesh GPS point, Flutter will display whatever address the backend returns (or a `lat, lng` fallback on error). It does **not** force a US-formatted address.

Whether Dhaka coords come back as a Bangladesh address, a US address, or an error is **backend/Google-proxy behavior**, not visible in this repo.

Parser accepts `country` / `countryCode` / `city` / `postalCode` when present.

---

## 9. Route preview behavior

**Request:** `POST /api/v1/passenger/routes/preview` with pickup/dropoff lat/lng (and optional address/placeId).

| Question | Finding |
|----------|---------|
| Does Flutter send country on route preview? | **No** |
| Does Flutter alter coordinates by country? | **No** |
| Does the route API accept arbitrary lat/lng from Flutter's perspective? | Flutter sends whatever resolved places have |
| Does backend reject Bangladesh coordinates? | **Unknown** — backend not in this repo |
| Does country affect the Flutter client path? | Only indirectly: bad autocomplete country can prevent selecting a BD/US place |

Quote (`POST .../bookings/quote`) and create-booking similarly send waypoints only.

Classification **E. BACKEND_ROUTE_SERVICE_RESTRICTED_US** cannot be confirmed from Flutter.

---

## 10. Backend endpoints involved

All under `{baseUrl}/api/v1/passenger`:

| Purpose | Method | Path |
|---------|--------|------|
| Reverse geocode | GET | `/places/reverse-geocode` |
| Autocomplete | GET | `/places/autocomplete` |
| Place details | GET | `/places/details` |
| Suggestions | GET | `/places/suggestions` |
| Pickup spots | GET | `/pickup-spots` |
| Route preview | POST | `/routes/preview` |
| Quote | POST | `/bookings/quote` |

Flutter does not call Google Places directly. Whether the backend applies `components=country:us`, ignores `country=BD`, or maps `country=BD` to Google `includedRegionCodes` **cannot be verified here**.

If production still looks USA-only despite `country=BD`, classify that separately as a **backend** investigation (**D** / **G**), not a Flutter `country=US` bug.

---

## 11. Tests enforcing country assumptions

No tests assert United States addresses, ZIP codes, New York, California, San Francisco, or `countryCode US` for Places.

Ride-planning tests use **Dhaka / Bangladesh fixtures**:

- `plan_ride_search_test.dart` — `countryCode: 'BD'`
- `pickup_resolution_controller_test.dart`, `pickup_and_ride_selection_fix_test.dart`, `ride_planning_parsers_test.dart`, etc. — `23.75, 90.38` style coords

These are **fixtures**, not an enforcement of USA-only behavior.

No unit test currently asserts that `_runAutocomplete` sends `country: 'BD'`. Fake repositories accept `country` and ignore it.

Phone tests (`passenger_profile_parser_test.dart`) cover `+1` / `+44` / `+880` — unrelated to location search.

---

## 12. Exact root cause

### Classification

| Code | Applies? | Reason |
|------|----------|--------|
| **A. FLUTTER_AUTOCOMPLETE_HARDCODED_US** | **No** | Hardcoded value is `'BD'`, not `'US'` |
| **B. FLUTTER_LOCATION_BIAS_US_ONLY** | **No** | Bias is GPS/pickup lat/lng, not a USA region |
| **C. FLUTTER_MAP_DEFAULT_US_ONLY_BUT_SEARCH_GLOBAL** | **No** | Map camera is pickup/dropoff/route; search is not global anyway (`country=BD`) |
| **D. BACKEND_PLACES_HARDCODED_US** | **Unverified** | Backend not in this repo. Flutter asks for `BD`. |
| **E. BACKEND_ROUTE_SERVICE_RESTRICTED_US** | **Unverified** | Flutter sends raw lat/lng with no country |
| **F. CURRENT_LOCATION_COUNTRY_NOT_DETECTED** | **Yes** | No GPS/locale/SIM/backend country used for search |
| **G. GOOGLE_API_KEY_OR_PROVIDER_CONFIGURATION** | **Not in Flutter Places path** | Maps SDK key is tiles-only. Places go through Rydu API. Key restrictions on the **server** Google key are unknown. |
| **H. NO_US_RESTRICTION_FOUND** | **Yes (in this repo)** | No Flutter US Places restriction exists |
| **I. MULTIPLE_CAUSES** | Partial | H + F, plus a **BD** hardcode that is the real Flutter country filter |

### Precise cause of the current country filter

**Single Flutter line:**

`RideBookingController._runAutocomplete` always calls:

```dart
.autocomplete(
  input: input,
  lat: bias?.latitude,
  lng: bias?.longitude,
  country: 'BD',
  sessionToken: _placesSessionToken,
  cancelToken: cancelToken,
);
```

That is a **Bangladesh** restriction for both pickup and destination, independent of where the user is.

It does **not** explain a USA-only result set unless the backend ignores `country=BD` and applies its own US filter.

---

## 13. Files that would need modification (fix not implemented)

To support both United States and Bangladesh without a single hardcoded country:

1. `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`  
   Stop hardcoding `country: 'BD'`. Derive country from reverse geocode / selected place, or send both, or omit country and rely on lat/lng bias.

2. `lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart`  
   Only if the backend contract needs `countryCode`, multiple `country` values, or different query names.

3. `lib/features/ride_booking/domain/entities/ride_planning_entities.dart` + `RideBookingState`  
   If a resolved service country should live in planning state.

4. `lib/core/location/location_service.dart`  
   Only if country should be inferred on-device (currently it should not be required if reverse geocode returns `countryCode`).

5. Tests under `test/features/ride_booking/`  
   Assert the country query is dynamic (US vs BD), not a fixture-only BD assumption.

6. **Backend Places proxy** (outside this repo)  
   Must honor Flutter’s `country` (or equivalent) for both `US` and `BD`. If it currently forces Google `components=country:us`, Flutter cannot fix USA-only results by itself.

Do not treat Auth `+1` / login `+880` phone defaults as the Places country switch unless product explicitly ties them.

---

## Appendix — call chain (compact)

```
RideBookingScreen (Plan your ride)
  LocationInputCard
    updatePickupLocation / updateDestinationQuery
      _scheduleAutocomplete (400ms, min 2 chars)
        _runAutocomplete
          country: 'BD'          ← Flutter country restriction (BD, not US)
          lat/lng from pickupPlace
          RideBookingRepositoryImpl.autocomplete
            PassengerRideRemoteDatasourceImpl.autocomplete
              GET /api/v1/passenger/places/autocomplete
          predictions → _PredictionList
            selectPrediction
              GET /api/v1/passenger/places/details
              pickupPlace or dropoffPlace
              _previewRouteAndOpenSelection
                POST /api/v1/passenger/routes/preview
                POST /api/v1/passenger/bookings/quote
                → RideSelectionScreen GoogleMap
```

GPS pickup branch:

```
bootstrapCurrentLocation
  LocationService.getCurrentPosition
  GET /api/v1/passenger/places/reverse-geocode?lat&lng
  _applyResolvedCurrentPickup
```

---

**RYDU PASSENGER LOCATION COUNTRY AUDIT COMPLETE — H. NO_US_RESTRICTION_FOUND + F. CURRENT_LOCATION_COUNTRY_NOT_DETECTED (Flutter hardcodes country=BD, not US)**
