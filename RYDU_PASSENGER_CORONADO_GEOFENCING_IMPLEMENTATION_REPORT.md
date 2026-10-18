# RYDU Passenger Coronado Geofencing Implementation Report

**Repository:** `Rydu_User` (Passenger Flutter) only  
**Date:** 17 October 2026  
**Status:** PASSENGER CORONADO GEOFENCING IMPLEMENTED — BD UNRESTRICTED — DEVICE QA PENDING

The passenger app now loads the backend service area from the pickup point, draws that geometry on the existing Google Maps, and blocks an obviously out-of-area US trip before quote or create. Bangladesh pickups are not restricted. The passenger's physical GPS position is not used as a booking gate. Quote and create responses remain the final decision.

The backend report named in the task (`DRIVEWIZE_BACKEND_US_BD_GEOFENCING_IMPLEMENTATION_REPORT.md`) is not in this repository. The client follows the contract in the integration request.

## Files changed

New:

- `lib/features/ride_booking/domain/service_area/service_area_models.dart`
- `lib/features/ride_booking/domain/service_area/service_area_geometry.dart`
- `lib/features/ride_booking/domain/service_area/service_area_parser.dart`
- `lib/features/ride_booking/domain/service_area/service_area_messages.dart`
- `lib/features/ride_booking/domain/service_area/service_area_rules.dart`
- `lib/features/ride_booking/domain/service_area/service_area_cache.dart`
- `lib/features/ride_booking/data/datasources/service_area_remote_datasource.dart`
- `lib/features/ride_booking/data/repositories/service_area_repository_impl.dart`
- `lib/features/ride_booking/presentation/service_area/service_area_polygons.dart`
- `lib/features/ride_booking/presentation/providers/service_area_sync.dart`
- `test/features/ride_booking/service_area_test.dart`

Updated:

- `lib/core/constants/passenger_api_paths.dart`
- `lib/core/network/passenger_api_error_mapper.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_dependencies.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `lib/features/ride_booking/presentation/screens/ride_booking_screen.dart`
- `lib/features/ride_booking/presentation/screens/ride_selection_screen.dart`
- `lib/features/ride_booking/presentation/widgets/active_ride_map.dart`

No Backend, Driver Android, Driver iOS, or Admin files were modified.

Booking phases, driver assignment, vehicle identity, Socket.IO, live tracking, ETA, fare math, payments, authentication, ride history, cancellation, and service categories were left in place. The new check runs before the existing quote and create calls.

## Service-area API integration

`GET /api/v1/config/service-area` is called through the existing authenticated Dio client.

Query parameters:

- `lat` — pickup latitude
- `lng` — pickup longitude
- `placeId` — pickup place id when the app has one

The response `data.marketCode`, `data.enforcementEnabled`, and `data.areas[]` are parsed. Each area's `geometry` is used as returned. No Coronado coordinates are hardcoded.

The query is built only from the selected pickup. Device GPS is not sent and is not an input to the local check, so a passenger whose phone is in Bangladesh can still book a pickup and drop-off inside the US area.

## Polygon rendering

When the active config is market `US`, enforcement is enabled, and the backend returned drawable geometry:

- `Polygon` and `MultiPolygon` are drawn on the ride-selection map and the active-ride map.
- The first ring is the outer boundary. Later rings are holes.
- GeoJSON positions are read as `[longitude, latitude]` and passed to Google Maps as `LatLng(latitude, longitude)`.
- Pickup, drop-off, driver, and route polylines stay on the map. Gestures and existing controls are unchanged.
- A short caption states that the highlight is a guide and Rydu confirms the booking.

When the market is `BD`, enforcement is off, geometry is missing, or the latest pickup query has not returned yet, no restriction polygon is drawn. A new pickup query hides the previous polygon immediately, so a US outline is not left on screen for a Bangladesh pickup.

## Market-based behavior

| Pickup result | Polygon | Local block |
| --- | --- | --- |
| US and `enforcementEnabled: true` with geometry | Yes | Pickup, drop-off, or stop outside the geometry |
| US and enforcement disabled | No | No |
| BD, including when enforcement is true on that payload | No | No |
| Config request failed for a reason other than service-area unavailable | No | No. Quote or create still runs |
| `SERVICE_AREA_UNAVAILABLE` | No | Yes. The failed check is not treated as a quote or booking |

A point is outside when it is outside every polygon, or inside a hole. The local result is only a pre-check. A successful backend quote or create is accepted even if a stale polygon would have disagreed.

## Quote and booking error handling

`PassengerApiErrorMapper` maps:

- `400` / `OUT_OF_SERVICE_AREA` to `This ride is outside the current service area.` The message also names `error.details.failedPoints` values `pickup`, `dropoff`, and `stop` when they are present.
- `SERVICE_AREA_UNAVAILABLE` to `The service area is temporarily unavailable. Please try again later.`

Those strings use the existing booking and location error text. The passenger can change pickup or drop-off and retry. A service-area failure does not move the ride into searching, assignment, or payment.

Before route preview, quote reload, and create, the app evaluates the current boundary. An obvious US violation or an unavailable service area stops the request and keeps the previous quote state on create (`quoteLoaded`). Other network failures do not invent a local rejection.

## Caching and refresh

In-memory cache, held for the app session:

- One entry per pickup query (`lat`, `lng`, `placeId`, rounded to 5 decimal places).
- One entry per market, replaced when a response has a higher area version.
- An older version does not replace a newer one for the same market.
- The visible config is always the market of the latest pickup query.
- Identical pickup coordinates reuse the cached payload. A drop-off change re-evaluates without a second request.
- The cache is not used as booking authorization. Create still depends on the backend unless the local geometry shows a clear US violation, or the service area itself is unavailable.

## Tests and build

`flutter test test/features/ride_booking/service_area_test.dart` — **16 passed**

Covered:

1. US boundary becomes a Google Map polygon with latitude/longitude in the correct order.
2. BD market produces no polygon and does not block.
3. US enforcement disabled does not block.
4. Pickup outside the fixture polygon.
5. Drop-off outside the fixture polygon.
6. Intermediate stop outside the fixture polygon.
7. `SERVICE_AREA_UNAVAILABLE` stops `confirmBooking` before a booking id exists.
8. GeoJSON `[longitude, latitude]` conversion, including rejection of a swapped pair that is not a valid latitude.
9. `Polygon` and `MultiPolygon` parsing.
10. Holes are excluded and passed through to the map polygon.
11. US then BD pickup clears the visible boundary.
12. A valid US pickup/drop-off is allowed without reading a Bangladesh device coordinate.
13. Accepted, en-route, and in-progress phases, and the live socket status enum, stay independent of an idle service-area decision.

Also re-ran `test/features/ride_booking/stripe_phase_c_test.dart` while the booking gate was in place. Those Stripe booking tests passed.

`flutter build apk --debug` — **success** (`build/app/outputs/flutter-apk/app-debug.apk`). Gradle reported the existing Kotlin Gradle Plugin migration warning. It did not fail the build.

`dart analyze` on the touched libraries reported no errors after the unused import was removed.

## Device QA checklist

- [ ] US pickup and drop-off inside Coronado: polygon matches the backend shape, quote and booking succeed.
- [ ] US pickup outside the polygon: message names pickup, quote is not sent, passenger can pick a new pickup.
- [ ] US drop-off outside the polygon: message names drop-off.
- [ ] Stop outside the polygon, once a stop can be entered: message names stop.
- [ ] Hole and any disconnected area match the backend geometry, not a circle or box.
- [ ] BD pickup and drop-off: no polygon, existing booking, map, route, and price behavior unchanged.
- [ ] Switch a US pickup to a BD pickup: US polygon disappears before the BD map is used.
- [ ] Phone physically in Bangladesh, pickup and drop-off inside Coronado: booking is not rejected for device location.
- [ ] Backend `OUT_OF_SERVICE_AREA` with `failedPoints` is shown and can be corrected.
- [ ] Backend `SERVICE_AREA_UNAVAILABLE` shows the retry message and does not open driver search.
- [ ] Active ride, driver marker, route line, ETA, and cancellation still behave as before while a polygon is visible.
- [ ] Airplane mode on a new pickup: no stale US polygon is treated as permission to book.

## Backend contract gaps

- This repo does not contain the backend implementation report, so field names were taken from the integration request.
- `failedPoints` is implemented as a list of `pickup`, `dropoff`, and `stop`. Objects with `point`, `role`, `type`, or `code` are also accepted. Any other shape will still show the base out-of-area sentence without a point label.
- The passenger UI still uses the existing stub for the add-stop button (`Multi-stop rides are not available yet.`). Stop validation and the `stop` error label are implemented. The quote and create calls continue to send an empty `stops` array until that UI exists.
- There is no documented client behavior for a US payload with enforcement on and empty geometry. The app does not draw a polygon and does not block locally; the backend quote or create decides.
- Service-area cache is memory-only and is dropped when the process restarts.
