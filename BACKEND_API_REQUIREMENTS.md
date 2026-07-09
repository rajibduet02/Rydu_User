# Backend API Requirements

API contract reference for the RYD U passenger app. Base URL is configured via `--dart-define=API_BASE_URL` (see `lib/core/constants/api_constants.dart`).

All authenticated endpoints expect:

```
Authorization: Bearer <backend_jwt>
```

The JWT is stored under key `backend_jwt` (`lib/core/constants/auth_constants.dart`) and attached by `lib/core/network/auth_interceptor.dart`.

---

## Implemented — Auth (`lib/features/auth/`)

These endpoints are called from `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart`.

| Method | Path | Purpose | Request body | Response | Auth |
|--------|------|---------|--------------|----------|------|
| POST | `/api/v1/passenger/auth/register` | Create passenger account | `{ name, email, password }` | Success envelope or error | No |
| POST | `/api/v1/passenger/auth/login` | Exchange Auth0 token for backend session | `{ auth0Token, deviceId?, deviceInfo? }` | `{ token/accessToken/jwt, sessionId?, user: { id, email, name } }` — parsed by `PassengerSessionParser` | No (token in body) |
| POST | `/api/v1/passenger/auth/logout` | Invalidate server session | `{ sessionId? }` | Void; 404/501 tolerated | Optional |
| POST | `/api/v1/passenger/auth/forgot-password` | Email password reset | `{ email }` | Void | No |

### Auth0 (SDK, not REST)

Handled by `lib/features/auth/data/datasources/auth0_datasource.dart`:

- `Auth0.api.login(usernameOrEmail, password, connectionOrRealm, audience)` → Auth0 access token
- Credentials stored/cleared via Auth0 credentials manager

### Auth stubs (interface exists, no HTTP yet)

Defined in `lib/features/auth/data/datasources/auth_remote_datasource.dart`, implemented as no-ops in `auth_remote_datasource_impl.dart`:

| Method | Suggested path | Purpose | Status |
|--------|----------------|---------|--------|
| POST | `/api/v1/passenger/auth/otp/send` | Send phone OTP | **Stub** — `sendOtp()` empty |
| POST | `/api/v1/passenger/auth/otp/verify` | Verify phone OTP | **Stub** — `verifyOtp()` empty |
| GET | `/api/v1/passenger/auth/me` | Fetch current user profile | **Stub** — `currentUser()` returns null |

> UI note: `forgot_password_screen.dart` uses a phone/OTP flow; the email `forgot-password` API exists but may not be wired in that screen.

---

## Missing — by feature

Suggested REST paths follow passenger API conventions. Adjust to match your backend. Stub datasource files are cited for each area.

### Home — `lib/features/home/data/datasources/home_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET | `/api/v1/passenger/home/summary` | Banners, shortcuts, active ride summary | `fetchSummary()` → empty model |

### Ride booking — `lib/features/ride_booking/data/datasources/ride_booking_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| POST | `/api/v1/passenger/rides/drafts` | Create ride draft (pickup/dropoff) | `createDraft()` |
| GET | `/api/v1/passenger/rides/drafts/{id}/estimate` | Fare estimate | `estimateFare(draftId)` |
| POST | `/api/v1/passenger/rides/drafts/{id}/confirm` | Confirm and request driver | `confirm(draftId)` |
| GET | `/api/v1/passenger/rides/vehicles` | Vehicle options & pricing | Used by presentation layer (local state) |
| POST | `/api/v1/passenger/rides` | Submit ride request | Booking flow screens |

### Ride tracking — `lib/features/ride_tracking/data/datasources/ride_tracking_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET (SSE/WS) | `/api/v1/passenger/rides/{rideId}/driver-location` | Live driver position stream | `driverLocation(rideId)` |
| GET | `/api/v1/passenger/rides/{rideId}` | Ride status (searching, arrived, in-trip) | Controllers use local state |
| POST | `/api/v1/passenger/rides/{rideId}/cancel` | Cancel active ride | UI present |

### Ride history — `lib/features/ride_history/data/datasources/ride_history_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET | `/api/v1/passenger/rides/history` | Paginated past rides | `fetchRides()` |
| GET | `/api/v1/passenger/rides/history/{id}` | Single ride receipt/detail | `fetchRide(id)` |

### Payment — `lib/features/payment/data/datasources/payment_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET | `/api/v1/passenger/payment-methods` | List saved methods | `fetchMethods()` |
| POST | `/api/v1/passenger/payment-methods` | Add card/wallet method | Add payment screens |
| DELETE | `/api/v1/passenger/payment-methods/{id}` | Remove method | UI present |
| POST | `/api/v1/passenger/payments/charge` | Charge for completed ride | Payment flow |

### Profile — `lib/features/profile/data/datasources/profile_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET | `/api/v1/passenger/profile` | User profile | `fetchProfile()` |
| PUT | `/api/v1/passenger/profile` | Update name, photo, phone | `saveProfile(model)` |

### Notifications — `lib/features/notifications/data/datasources/notifications_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET | `/api/v1/passenger/notifications` | In-app notification list | `fetch()` |
| PATCH | `/api/v1/passenger/notifications/{id}/read` | Mark read | UI present |
| POST | `/api/v1/passenger/devices` | Register FCM/APNs token | Not implemented |

### Chat — `lib/features/chat/data/datasources/chat_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET (WS) | `/api/v1/passenger/rides/{rideId}/chat` | Message stream | `listen(rideId)` |
| POST | `/api/v1/passenger/rides/{rideId}/chat` | Send message | `send(rideId, text)` |

### Map — `lib/features/map/data/datasources/map_remote_datasource.dart`

| Method | Suggested path | Purpose | Stub method |
|--------|----------------|---------|-------------|
| GET | `/api/v1/passenger/maps/config` | Map provider keys, style URLs | `warmup()` |

> Maps SDK (Google/Mapbox) is not in `pubspec.yaml`. Location is stubbed in `lib/core/location/location_service.dart`.

---

## Missing — account sub-features (local datasources only)

Account has no `*_remote_datasource.dart` files. Data comes from `lib/features/account/data/datasources/*_local_datasource.dart` with seed/mock data.

| Area | Local datasource | Suggested endpoints |
|------|------------------|---------------------|
| Wallet | `wallet_local_datasource.dart` | `GET /wallet`, `GET /wallet/transactions`, `POST /wallet/top-up`, `POST /wallet/transfer` |
| Saved places | `saved_places_local_datasource.dart` | `GET/POST/PUT/DELETE /saved-places` |
| Inbox | `inbox_local_datasource.dart` | `GET /inbox`, `GET /inbox/{id}`, `PATCH /inbox/{id}/read` |
| Family | `family_local_datasource.dart` | `GET/POST/DELETE /family/members`, `POST /family/invites` |
| Support / Help | `help_center_local_datasource.dart`, `support_local_datasource.dart` | `GET /support/faqs`, `POST /support/tickets`, `POST /support/callback` |
| Safety | `security_local_datasource.dart` | `GET/PUT /safety/contacts`, `POST /safety/sos` |
| Profile (account) | `profile_local_datasource.dart` | Overlap with `profile` feature — consolidate on `/profile` |
| Privacy | `privacy_local_datasource.dart` | `GET/PUT /privacy/settings`, `POST /privacy/data-export` |
| Settings | `account_settings_local_datasource.dart` | `GET/PUT /settings` |

---

## Missing — service flows (local datasources only)

| Feature | Local datasource | Suggested endpoints |
|---------|------------------|---------------------|
| Intercity | `intercity_local_datasource.dart` | `GET /intercity/destinations`, `POST /intercity/quotes`, `POST /intercity/bookings` |
| Rentals | `rentals_local_datasource.dart` | `GET /rentals/config`, `GET /rentals/vehicles`, `POST /rentals/bookings` |
| Reserve | `reserve_local_datasource.dart` | `POST /rides/scheduled`, `GET /rides/scheduled` |
| Offers | `offers_local_datasource.dart` | `GET /offers`, `POST /offers/{id}/apply` |
| Activity | `activity_local_datasource.dart` | `GET /activity` (feed of rides, promos, alerts) |
| Services hub | `services_local_datasource.dart` | `GET /services/catalog` |
| Onboarding | `onboarding_local_datasource.dart` | Optional `GET /config/onboarding` or fully client-side |
| Settings (app) | `settings_local_datasource.dart` | `GET/PUT /settings/app` |

---

## Response envelope

`lib/core/network/api_response_parser.dart` unwraps responses shaped as:

```json
{ "data": { ... } }
```

Login/token responses are parsed by `lib/features/auth/data/utils/passenger_session_parser.dart`, which accepts token fields: `token`, `accessToken`, `jwt`, `backendJwt`, `backendToken`.

## Error format

Auth errors are mapped in `lib/features/auth/data/utils/auth_error_mapper.dart`. Preferred backend error shape:

```json
{
  "error": {
    "message": "Human-readable message",
    "code": "OPTIONAL_CODE"
  }
}
```

Dio errors with `response.data` are converted to `AuthException` for the auth UI.

---

## Implementation priority (suggested)

1. **Auth stubs** — OTP, `/me`, token refresh
2. **Ride lifecycle** — draft, estimate, confirm, track, cancel, history
3. **Payment methods** — list, add, charge
4. **Profile & account** — wallet, saved places, inbox
5. **Real-time** — driver location WebSocket, in-ride chat
6. **Secondary flows** — intercity, rentals, reserve, offers

See [PRODUCTION_READINESS_CHECKLIST.md](PRODUCTION_READINESS_CHECKLIST.md) for release tracking.
