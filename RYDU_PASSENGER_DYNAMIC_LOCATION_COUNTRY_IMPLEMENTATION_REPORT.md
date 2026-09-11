# RYDU PASSENGER DYNAMIC LOCATION COUNTRY IMPLEMENTATION REPORT

**Repository:** Rydu_User (Passenger Flutter)  
**Date:** 2026-09-10  
**Scope:** Places autocomplete country selection only. Backend, routing, payments, Auth0, and maps were not modified.

**Final status:**  
`RYDU PASSENGER DYNAMIC LOCATION COUNTRY COMPLETE — BACKEND PLACES VERIFICATION REQUIRED`

---

## 1. Files changed

| File | Change |
|------|--------|
| `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart` | Removed hardcoded `country: 'BD'`. Resolve ISO country from pickup/GPS place truth. Debug log `country=BD` / `US` / `<none>`. |
| `lib/features/ride_booking/data/utils/ride_planning_parsers.dart` | Added `normalizedCountryCode`. Place parser still preserves `country` / `countryCode` (also `country_code`). |
| `test/features/ride_booking/autocomplete_country_test.dart` | New focused tests A–L plus GPS-retype fallback. |
| `test/features/ride_booking/ride_planning_parsers_test.dart` | Parser preservation + normalization unit tests. |

**Not changed:** datasource (already omitted empty `country`), repository, route preview, quote, booking create, maps, Auth0, phone codes, Stripe.

---

## 2. Exact country resolution logic

`RideBookingController._resolvedAutocompleteCountry()`:

1. `RidePlanningParsers.normalizedCountryCode(state.pickupPlace?.countryCode)`
2. Else `normalizedCountryCode(_previousResolvedPickup?.countryCode)`  
   (GPS reverse-geocode stash, or last manually selected pickup after the user starts retyping and `pickupPlace` is cleared)
3. Else `null` → omit the query parameter

Normalization:

- Trim
- Uppercase
- Accept only exactly two ASCII letters (`A–Z`)
- `bd` → `BD`, `us` → `US`
- `Bangladesh`, `USA`, `+1`, empty → `null`

Other valid ISO codes (e.g. `IN`) are passed through. Flutter does **not** coerce them to BD or US.

Not used: phone dial code, Auth0, locale, SIM, device language, address-text guessing.

---

## 3. Pickup behavior

GPS reverse geocode that returns `countryCode=BD` stores it on `pickupPlace`. Pickup autocomplete sends `country=BD`.

Same for `US`.

While the user is typing a pickup query that diverges from the resolved label, `pickupPlace` is cleared (existing behavior). Country then comes from `_previousResolvedPickup` (the GPS or last selected pickup), so search stays in the same country.

---

## 4. Destination behavior

Destination uses the same `_runAutocomplete` path.

Country is the **resolved pickup** `countryCode`:

- Pickup Dhaka / BD → destination `country=BD`
- Pickup New York / US → destination `country=US`

Device location is not re-read for destination after a pickup is selected.

---

## 5. Manual pickup override

If GPS is Bangladesh and the user then selects a US pickup:

- `selectPrediction` stores the US `PlaceEntity` (including `countryCode`) as `pickupPlace`
- `_stashResolvedPickup` replaces the GPS stash
- Subsequent destination (and pickup) autocomplete uses `country=US`

The reverse (GPS US → manual BD pickup) uses `country=BD`.

---

## 6. Fallback when country unknown

If `countryCode` is missing or not a 2-letter ISO code:

- Resolver returns `null`
- Datasource already does `if (country != null && country.isNotEmpty) 'country': country`
- Request omits `country` entirely (no `country=` / `country=null`)

Debug log: `country=<none>`.

---

## 7. Tests

`flutter test` (autocomplete country + parsers + pickup + plan-ride search): **59 passed**.

| Case | Result |
|------|--------|
| A. Reverse geocode BD → pickup sends BD | pass |
| B. Reverse geocode US → pickup sends US | pass |
| C. Selected pickup BD → destination sends BD | pass |
| D. Selected pickup US → destination sends US | pass |
| E. GPS BD then manual US pickup → destination US | pass |
| F. GPS US then manual BD pickup → destination BD | pass |
| G. `bd` → `BD` | pass |
| H. `us` → `US` | pass |
| I. Missing countryCode → omit | pass |
| J. Invalid (`Bangladesh`) → omit | pass |
| K. No hardcoded `'BD'` in `_runAutocomplete` | pass |
| L. No hardcoded `'US'` introduced | pass |

Parser tests also cover `country` / `countryCode` / `country_code` preservation.

---

## 8. Build / analyze result

```
dart analyze [changed files]
```

No errors. One prior info-level style issue in the normalizer was fixed (`prefer_function_declarations_over_variables`).

---

## 9. Remaining backend verification requirement

Flutter now sends `country=BD`, `country=US`, or omits `country`, based on place/GPS `countryCode`.

This repo cannot prove that the Passenger Places proxy:

- honors `country=BD` / `country=US` when calling Google
- returns `countryCode` on reverse-geocode and place-details
- does not ignore Flutter’s param and force a single country internally

**Required before dual-country search can be trusted in production:** verify live `GET /api/v1/passenger/places/autocomplete` and reverse-geocode/details payloads for both Bangladesh and United States coordinates.

---

**RYDU PASSENGER DYNAMIC LOCATION COUNTRY COMPLETE — BACKEND PLACES VERIFICATION REQUIRED**
