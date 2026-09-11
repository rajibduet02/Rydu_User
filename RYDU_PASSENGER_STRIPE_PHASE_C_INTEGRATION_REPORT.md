# RYDU Passenger Stripe Phase C Integration Report

Passenger Flutter app (`Rydu_User`) now authorizes card bookings with Stripe PaymentSheet **without changing cash dispatch**. Backend, Driver, and Admin were not modified.

The backend contract file `RYDU_STRIPE_PHASE_C_PASSENGER_AUTHORIZATION_REPORT.md` was not present in this checkout. Implementation followed the Phase C passenger authorization task contract.

---

## Status

**RYDU PASSENGER STRIPE PHASE C COMPLETE — DEVICE QA REQUIRED**

Physical-device QA (cash regression, 4242 success, decline, 3DS, app-restart retry) has not been run on a phone.

---

## Package / version added

| Package | Constraint | Resolved |
|---|---|---|
| `flutter_stripe` | `^12.4.0` | **12.6.0** |

Compatible with current Flutter/Dart (`sdk: ^3.11.5`). No Stripe secret keys are in the app. Only backend `pk_test_` / `pk_live_` publishable keys are accepted.

---

## Files changed

### New

- `lib/core/payments/rydu_payments.dart` — merchant display name `Rydu`
- `lib/features/ride_booking/domain/entities/booking_payment_entities.dart` — payment config, payment status, create-booking result, card UI states
- `lib/features/ride_booking/domain/payments/payment_authorization_poller.dart` — bounded poll schedule
- `lib/features/ride_booking/data/utils/booking_create_request.dart` — POST body (no amount/fare)
- `lib/features/ride_booking/data/services/stripe_payment_gateway.dart` — Stripe SDK wrapper
- `lib/features/ride_booking/presentation/widgets/card_payment_status_panel.dart` — payment-pending / retry panel
- `test/features/ride_booking/stripe_phase_c_test.dart`

### Updated (architecture reused, no duplicate API layer)

- `pubspec.yaml` / `pubspec.lock`
- `lib/core/constants/passenger_api_paths.dart`
- `lib/core/network/passenger_api_error_mapper.dart`
- `lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart`
- `lib/features/ride_booking/data/repositories/ride_booking_repository_impl.dart`
- `lib/features/ride_booking/domain/repositories/ride_booking_repository.dart`
- `lib/features/ride_booking/data/utils/ride_planning_parsers.dart`
- `lib/features/ride_booking/domain/entities/ride_planning_entities.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_controller.dart`
- `lib/features/ride_booking/presentation/providers/ride_booking_dependencies.dart`
- `lib/features/ride_booking/presentation/screens/ride_selection_screen.dart`
- `lib/features/ride_booking/presentation/screens/confirm_pickup_screen.dart`
- `lib/features/ride_booking/presentation/widgets/payment_method_tile.dart`
- `lib/features/payment/presentation/widgets/payment_method_modal.dart`
- `lib/features/home/presentation/widgets/home_active_ride_card.dart`
- Android: `MainActivity.kt`, `styles.xml` (light/night), `app/build.gradle.kts`
- Tests: fake repository stubs + parser/phase coverage

---

## API integration

Authenticated passenger Dio client (existing JWT interceptor). Paths:

| Method | Path | Role |
|---|---|---|
| GET | `/api/v1/config/payments` | Stripe enablement + publishable key |
| GET | `/api/v1/passenger/payment-methods` | Existing. Source of truth for Cash/Card UI |
| POST | `/api/v1/passenger/bookings` | Unchanged payload shape + `paymentMethodCode` |
| GET | `/api/v1/passenger/bookings/{id}/payment` | Payment status + optional `clientSecret` |
| POST | `/api/v1/passenger/bookings/{id}/cancel` | Existing cancel (quoted card included) |
| GET | `/api/v1/passenger/bookings/active` | Existing restore, includes `quoted` |

Create body still sends only: `serviceCategoryId`, `pickup`, `dropoff`, `stops`, `paymentMethodCode`, `schedulingType`. **Never** `amount`, `fare`, `finalFare`, Stripe payment method id, or raw card data.

---

## Payment method UI location

Existing ride confirmation UI, not a new booking screen:

1. **Ride Selection** bottom bar (`ride_selection_screen.dart`) — `PaymentMethodTile` + existing Pay-with sheet
2. **Confirm Pickup** (`confirm_pickup_screen.dart`) — same tile
3. **Pay with sheet** (`payment_method_modal.dart`) — options come from GET payment-methods
   - Cash only → Cash only
   - Cash + Card → both
   - Card is **not** force-enabled locally
   - Empty methods → Cash fallback (preserves current default)
4. Card payment states overlay on those screens via `CardPaymentStatusPanel`
5. Home active-ride card shows **Retry Payment** for quoted card bookings

Default remains backend `isDefault`, else first method (typically cash).

---

## Stripe initialization

- `GET /config/payments` during quote load and before card PaymentSheet
- Initializes only when `cardEnabled == true` and `publishableKey` starts with `pk_`
- Cached per key/session (`FlutterStripePaymentGateway`)
- `sk_` keys are ignored
- Init/config failure **does not block cash**
- Failure to init when Card is selected shows a cash-friendly error and does not create a dispatching booking

---

## PaymentSheet integration

After a **card** create that returns `quoted` / payment needing authorization:

1. Read `payment.clientSecret` from the booking wrapper (or GET payment on retry/restore)
2. `Stripe.instance.initPaymentSheet` with **existing PaymentIntent** `clientSecret` only
3. Merchant name: **Rydu**
4. No customer / ephemeral key (backend does not provide them)
5. App never creates PaymentIntents and never uses a secret key
6. Card number/CVC are owned by Stripe PaymentSheet

PaymentSheet success is **not** treated as dispatch-ready. The app polls GET payment until `authorized` / `failed` / `cancelled`.

---

## Cash / card response parsing

`RidePlanningParsers.createBookingResult`:

- **Cash:** flat booking object → `CreateBookingResult(booking, payment: null)`
- Nested `payment: { method: cash }` on a flat booking is **not** treated as a Phase C wrapper
- **Card:** `{ booking, payment }` with `clientSecret` / `paymentIntentId` / `method=card` → both parsed

Cash decoding of the existing flat booking object is unchanged.

---

## Quoted booking restore

`quoted` maps to `RidePlanningPhase.paymentPending`, **not** searching.

On splash/home/auth restore:

1. Active booking with `status=quoted` is restored
2. GET payment is fetched
3. `authorized` → refresh booking; if backend moved to `searching`, existing socket/search flow continues
4. `requires_payment_method` / `requires_action` / `pending` → payment-pending + Retry Payment (same booking / PaymentIntent)
5. `failed` → payment failed + retry if `clientSecret` exists
6. `cancelled` → payment-failed copy; user can cancel the ride via the existing cancel API
7. Driver-search UI is **not** shown until backend status is searching (or later live states)

Quoted is not confused with the route **quote** screen (`quoteLoaded`).

---

## Payment polling

After PaymentSheet `completed`:

- Immediate GET payment
- Then ~0.8s, 1.5s, 2s, 2s, 2s, 3s, 3s, 4s
- Hard timeout **25 seconds**
- Terminal: `authorized` | `failed` | `cancelled`
- `authorized` → GET booking/active → existing search/socket flow
- App **does not** locally set `booking.status = searching` or mark payment paid
- `requires_action` after sheet → stay quoted, show retry, reuse `clientSecret` if present

---

## Retry behavior

If active booking is `quoted` + card:

- GET payment on the **same** booking
- Retry Payment reuses the same `clientSecret` / PaymentIntent
- **No second POST booking** (backend one-active-booking rule)
- User cancel uses existing `POST .../cancel`
- No Stripe cancel/refund API in Flutter
- No capture / transfer / commission

PaymentSheet cancel/fail keeps the quoted booking and does not open driver search.

---

## Android / iOS config

### Android (required for flutter_stripe 12.6.0)

- `MainActivity` → `FlutterFragmentActivity`
- Themes → `Theme.AppCompat` / `Theme.MaterialComponents` (light + night)
- Dependencies: `androidx.appcompat:appcompat:1.7.0`, `com.google.android.material:material:1.12.0`
- Maps / Auth0 / Firebase manifest entries untouched
- `minSdk` still `flutter.minSdkVersion` (already ≥ 21)

### iOS

- Deployment target already **13.0** (package requirement met; not lowered/raised)
- No Podfile in repo; Flutter generates it on iOS build
- PaymentIntent-only PaymentSheet does not need extra URL schemes
- Google Maps / Auth0 / Firebase iOS config untouched
- **iOS build not run** (this workspace is Windows)

---

## Tests / build results

| Item | Result |
|---|---|
| A Cash booking parsing unchanged | Pass |
| B Card wrapper parses | Pass |
| C Card hidden when backend omits it | Pass |
| D Publishable key initializes Stripe | Pass |
| E No hardcoded `sk_` / `pk_` in `lib/` | Pass |
| F Card create sends `paymentMethodCode=card` | Pass |
| G No client amount sent | Pass |
| H Quoted card is not searching before authorized | Pass |
| I PaymentSheet uses backend `clientSecret` | Pass |
| J PaymentSheet success polls backend | Pass |
| K `authorized` → refresh / existing search flow | Pass |
| L `requires_action` does not mark searching | Pass |
| M failed does not mark searching | Pass |
| N PaymentSheet cancel retains quoted booking | Pass |
| O Retry uses existing booking/payment | Pass |
| P App restart restores quoted payment-pending | Pass |
| Q Cash still dispatches through existing path | Pass |
| R No capture/transfer/commission | Pass |
| S `flutter analyze` | **No issues found** |
| T Android debug APK | **Pass** (`build/app/outputs/flutter-apk/app-debug.apk`) |
| U iOS build | **Not run** (Windows host) |

Focused suite: `test/features/ride_booking/stripe_phase_c_test.dart` plus parser/active-booking/consent/pickup tests — all passed.

---

## Physical device QA status

**Not executed.** Required on a physical device after this build:

### TEST 1 — Cash regression

Cash → create ride → driver receives offer. Must match pre-Stripe behavior.

### TEST 2 — Successful card

Card → booking create → PaymentSheet → `4242 4242 4242 4242` → backend `authorized` → booking `searching` → driver offer.

Stripe Dashboard: PaymentIntent = **`requires_capture` / uncaptured**, not succeeded/captured.

### TEST 3 — Declined card

`4000 0000 0000 0002` → booking stays `quoted` → no driver offer → Retry available.

### TEST 4 — 3DS

`4000 0025 0000 3155` → Stripe auth UI → no driver offer before authorization → after 3DS + backend `authorized` → dispatch.

### TEST 5 — App restart

Create card booking → close app before payment → reopen → quoted restored → Retry Payment → **same booking / PaymentIntent**.

Use any valid future expiry and CVC accepted by Stripe test mode. **Never use real cards in sandbox.**

---

## Error handling

User-safe mapping (no raw Stripe/server dumps):

- `CARD_PAYMENTS_NOT_ENABLED`
- `STRIPE_MODE_MISMATCH`
- `STRIPE_NOT_CONFIGURED`
- `STRIPE_CURRENCY_UNSUPPORTED`

Debug logs may include Stripe failure **codes** only. Never logged: `clientSecret`, card number, CVC, Stripe secrets.

---

## Blockers

None for code integration.

Remaining:

1. Physical-device QA (required)
2. iOS compile/signing not verified on this Windows environment
3. Backend Phase C must be live (`cardEnabled`, publishable key, card create wrapper, GET payment reconciliation)

---

## Exact recommended next step

Install the debug APK on a physical Android device, confirm GET `/api/v1/config/payments` returns `cardEnabled` + `pk_test_...`, then run **TEST 1–5** above. After TEST 2, confirm the PaymentIntent in Stripe Dashboard is **uncaptured** (`requires_capture`). Then repeat TEST 2–5 on iOS when a Mac is available.
