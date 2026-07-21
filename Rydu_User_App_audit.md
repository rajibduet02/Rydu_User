# Rydu_User App — Full Project Audit

**Project:** `rydu_user` (RYD U Flutter Passenger App)  
**Package / applicationId:** `com.rydu.user`  
**Version:** `1.0.0+1`  
**Audit date:** 11 July 2026  
**Branch:** `main` (large uncommitted feature set since initial commit)  
**Default API:** `http://103.208.181.253:3000` (QA HTTP — not production HTTPS)

---

## 1. Executive summary

| Area | Status | Notes |
|------|--------|--------|
| Architecture shell | **Done** | Clean Architecture + Riverpod + GoRouter + Dio |
| Auth (email/password) | **Mostly done** | Auth0 + backend JWT; OTP / refresh / social still open |
| Core ride booking → tracking | **Mostly done** | Live passenger APIs + Socket.IO; device QA recommended |
| Home + active-ride card | **Done (recent)** | Restore + minimize without cancel |
| Account / wallet / safety / support | **UI only** | Local mocks & placeholders |
| Payments (add card / wallet) | **Partial** | List methods remote; add-card / voucher TODOs |
| Services (intercity / reserve / rentals) | **UI / local** | Booking confirmation APIs not wired |
| Activity / history / chat / notifications | **Stub** | Empty remotes or local empty lists |
| Production hardening | **Not ready** | Cleartext QA, debug signing, no FCM, docs drift |

**Overall readiness:** Suitable for **device QA of the primary ride flow** against the QA backend. **Not ready for production release.**

---

## 2. Stack & architecture

### Tech stack

- Flutter / Dart `^3.11.5`
- State: `flutter_riverpod`
- Routing: `go_router` (modular route files, ~100+ named paths)
- Network: `dio` + Auth interceptor + passenger error mapper
- Auth: `auth0_flutter` + passenger `/auth/login` token exchange
- Maps: `google_maps_flutter` (Android key from `local.properties`)
- Location: `geolocator` via `LocationService`
- Realtime: `socket_io_client` (`PassengerSocketService`)
- Storage: `flutter_secure_storage` + SharedPreferences

### Layout

```
lib/
  app/          # MaterialApp, theme, router, global providers
  core/         # network, socket, location, maps, storage, constants
  features/     # feature modules (data / domain / presentation)
  shared/       # shared models / enums
```

Convention: presentation → domain → data (Clean Architecture). Documented in `ARCHITECTURE.md`.

---

## 3. Environment & Android

| Item | Value / location |
|------|------------------|
| API base | `API_BASE_URL` → `http://103.208.181.253:3000` |
| Passenger API | `…/api/v1/passenger` |
| Socket | same host as API |
| Cleartext | Domain-scoped allow for `103.208.181.253` (`network_security_config.xml`) |
| Maps key | Required at build; `GOOGLE_MAPS_API_KEY` / Gradle property → manifest placeholder |
| Auth0 | Dev tenant placeholders in Gradle / Info.plist |
| Release signing | Still uses **debug** signing config (TODO) |

---

## 4. Feature module map

| Feature | Screens / role | Backend |
|---------|----------------|---------|
| splash | Session restore → home/auth; quiet active-booking restore | Secure storage + booking API |
| onboarding / welcome | First-run | Local |
| auth | Sign-in, register, forgot password, OTP UIs, terms | Auth HTTP + Auth0 live; OTP stub |
| home | Categories, search, promos, **active-ride card** | Booking restore live; home summary stub |
| services | Catalog grid | Local catalog |
| activity | Trip activity tab | Local empty |
| account | Hub: profile, wallet, safety, inbox, family, help, settings | Almost all local mocks |
| ride_booking | Plan ride → confirm pickup → ride selection → book | **Live** passenger API |
| ride_tracking | Finding driver, driver found / active ride | Socket + booking controller |
| payment | Payment methods, add card | GET methods remote; add card TODO |
| ride_history | History / details | Empty remote |
| map / chat / notifications | Legacy or stub UIs | Stub remotes |
| offers / reserve / intercity / rentals | Marketing / booking UIs | Local / placeholders |
| settings / profile | Settings & profile shells | Local / placeholder remote |

**Shell tabs:** Home · Services · Activity · Account.

---

## 5. Completed tasks

### 5.1 Foundation (earlier refactor)

- [x] Feature-based Clean Architecture
- [x] Modular GoRouter (`auth`, `shell`, `home`, `service`, `account`, `ride`, `payment` routes)
- [x] `AuthSessionNotifier` + splash restore + route guards
- [x] Dio client, interceptors, secure logout patterns
- [x] Auth0 email/password + backend JWT exchange
- [x] Register / logout / forgot-password (email) HTTP paths
- [x] Theme / color system work (multiple color reports in repo)

### 5.2 Passenger ride platform (recent — live against QA API)

- [x] `PassengerRideRemoteDatasource` — places, reverse-geocode, autocomplete, place details, pickup spots, route preview, quote, create/active/cancel booking, payment methods, nearby drivers
- [x] `PassengerSocketService` — booking status + driver location
- [x] Plan Your Ride: GPS default pickup, reverse-geocode, manual pickup/destination search
- [x] Pickup resolution rules (GPS without `placeId`, programmatic text guard, field-specific validation)
- [x] Route preview + service quotes before Ride Selection
- [x] Confirm pickup spots API
- [x] Finding Driver (event-driven — no fake 3s timer navigation)
- [x] Driver Found / active ride map with socket phases
- [x] Cancel booking with **Idempotency-Key**, double-tap guard, 429 handling
- [x] Minimize Finding Driver (Back keeps searching; does **not** cancel)
- [x] Home persistent **active-ride card** + View ride / Cancel
- [x] Active booking restore on splash, login, Home open, app resume (`navigate: false` prefers card)
- [x] Expired / no-drivers terminal UI (Try again / Change service / Return Home)
- [x] Android Maps key injection + host-scoped cleartext for QA IP
- [x] Promotion parsing safety (no Map `.toString()` overflow in Ride Selection)

### 5.3 Tests (automated)

- [x] Route guards
- [x] JWT validator, auth error mapper, passenger session parser
- [x] Ride planning parsers, plan-ride search, pickup resolution controller
- [x] Active ride phase mapping + Finding Driver source guards
- [x] Active booking UX (minimize, cancel idempotency, restore, Home card)
- [x] Widget smoke (`RyduUserApp` splash)
- [x] Last full run: **analyze clean**, **108 tests passed**, **debug APK built** (11 Jul 2026)

### 5.4 Documentation already in repo

- `ARCHITECTURE.md`
- `CLEAN_ARCHITECTURE_REFACTOR_REPORT.md`
- `BACKEND_API_REQUIREMENTS.md` / checklists (partially stale — see §9)
- Color / theme reports (`COLOR_*`, `FIGMA_*`, `SEED_*`, etc.)

---

## 6. Remaining tasks (prioritized)

### P0 — Blockers for production / next QA confidence

| # | Task | Why |
|---|------|-----|
| 1 | Device QA of full ride loop (plan → book → socket → cancel / complete) | Code ready; live proof still required |
| 2 | Switch production to **HTTPS**; remove/restrict cleartext | Security |
| 3 | Release keystore + proper signing (stop using debug keys for release) | Store / install security |
| 4 | Auth0 production tenant, callbacks, dart-define secrets | Auth reliability |
| 5 | JWT **refresh** (or short-session re-login UX) | Sessions expire with no rotation today |
| 6 | Wire or remove OTP flows (`sendOtp` / `verifyOtp` are no-ops) | Dead UI paths confuse QA |

### P1 — Core product gaps after ride works

| # | Task | Notes |
|---|------|------|
| 7 | `GET /auth/me` + profile sync into Account (replace local “Mir Efaj” mocks) | `GetMeUsecase` exists; profile still largely local |
| 8 | Ride history / Activity from real booking history API | Remotes empty |
| 9 | In-ride chat + notifications (FCM) | Stub remotes; settings mention FCM TODO |
| 10 | Trip share / SOS / emergency contacts (real APIs) | Placeholders / “coming soon” |
| 11 | Schedule / Reserve / Intercity / Rentals booking APIs | Screens exist; confirmation TODOs |
| 12 | Multi-stop rides | Explicitly snackbar “not available yet” |
| 13 | City search + set location on map | Placeholder routes |
| 14 | Nearby drivers visualization on map | Deferred in ride routes comments |
| 15 | Post-trip rating / receipt | Not fully productized |

### P2 — Account, wallet, payments polish

| # | Task | Notes |
|---|------|------|
| 16 | Wallet balance / add money / send money / transactions | Local + placeholders |
| 17 | Add card / vouchers with real payment provider (PCI) | Simulated delays + TODOs |
| 18 | Saved places CRUD + map preview | Local TODOs / placeholders |
| 19 | Family profiles / teen invites | Local TODOs |
| 20 | Support live chat, report issue, lost item (backend + pickers) | `image_picker` / `file_picker` TODOs |
| 21 | Privacy center, MFA, change password, recovery phone | Placeholders |
| 22 | Membership / business travel hubs | `AccountHubPlaceholderScreen` |
| 23 | Legal content (privacy policy, terms body, SOS guide) | Placeholder copy |
| 24 | Google / Apple sign-in | TODOs in auth controller |
| 25 | Persist display name / terms acceptance to API | Controller TODOs |

### P3 — Engineering hygiene

| # | Task | Notes |
|---|------|------|
| 26 | Refresh `PRODUCTION_READINESS_CHECKLIST.md` / API docs (Maps + Location are **not** missing anymore) | Docs drift |
| 27 | Remove or archive legacy ride screens that only redirect | Reduces confusion |
| 28 | Replace remaining stub remotes (`home`, `map`, `chat`, `notifications`, draft booking remote) | Consistency |
| 29 | Broader widget / integration / E2E tests (auth screens, payments, account) | Unit-heavy today |
| 30 | iOS Maps / Auth0 / cleartext parity check | Android farther along in recent work |
| 31 | Commit / PR the large uncommitted ride + auth delta on `main` | Still mostly uncommitted vs `f94b41f` |
| 32 | Branded assets instead of emoji service icons | TODO on service cards |

---

## 7. Primary ride flow — status detail

### Implemented path

```
Home / category
  → Plan Your Ride (GPS pickup + destination autocomplete)
  → Route preview + quotes
  → Ride Selection
  → Confirm pickup spot (optional API)
  → Create booking (Idempotency-Key)
  → Finding Driver (socket; Back = minimize)
  → Driver Found / in progress (map + driver location)
  → Cancel (idempotent) or terminal (expired / completed)
```

Home shows **active-ride card** when booking is live; restore uses `GET .../bookings/active`.

### Known residual risks in this flow

- Device QA must confirm `pickupResolved=true` + `destinationResolved=true` before route preview on real GPS
- Socket auth depends on stored backend JWT
- Cancel rate-limits (429) must be verified against backend
- Multi-stop / schedule / trip-share still out of scope

---

## 8. Stub / placeholder inventory (high level)

**Placeholder screens / routes:** schedule ride; city search; set location on map; many account wallet/safety/family/edit-profile routes; reserve/intercity/rentals booking confirmation; privacy/SOS guide/request callback; inbox detail; saved place detail.

**Legacy redirects:** `/map`, `/search-destination` → plan ride; `/select-vehicle`, `/confirm-ride` → ride selection; `/searching-driver` → finding driver; `/ride-tracking` → driver found.

**Stub / empty remotes:** home summary, ride history, chat, notifications, map, profile placeholder, legacy ride draft remote, OTP, `currentUser` stub paths where still present.

**Local mocks:** account wallet/inbox/family/support/help/settings/saved places; activity; offers; services catalog; rentals/reserve/intercity locals.

---

## 9. Documentation drift

| Document | Issue |
|----------|--------|
| `PRODUCTION_READINESS_CHECKLIST.md` | May still claim Maps SDK / LocationService missing — **outdated** |
| `BACKEND_API_REQUIREMENTS.md` | Partially stale vs live `passenger_ride_remote_datasource.dart` |
| `CLEAN_ARCHITECTURE_REFACTOR_REPORT.md` | Accurate for July 3 refactor; predates ride socket / Maps / active-ride UX |

Treat this audit as the current product completeness source of truth.

---

## 10. Test matrix (current)

| Suite | Focus |
|-------|--------|
| `test/app/router/route_guards_test.dart` | Auth redirects |
| `test/features/auth/*` | JWT, errors, session parse |
| `test/features/ride_booking/ride_planning_parsers_test.dart` | API parsers |
| `test/features/ride_booking/plan_ride_search_test.dart` | Autocomplete / UI contracts |
| `test/features/ride_booking/pickup_*` | Pickup resolution |
| `test/features/ride_booking/active_ride_flow_test.dart` | Phases / Finding Driver guards |
| `test/features/ride_booking/active_booking_ux_test.dart` | Minimize, cancel, restore, Home card |
| `test/widget_test.dart` | App boot |

**Missing:** E2E, payment/account widgets, socket integration tests, golden UI tests.

---

## 11. Suggested roadmap (soon)

### Sprint A — Ship ride QA confidently
1. Device QA Flows A/B/C (pickup, permission deny, use current location)
2. Device QA active-ride minimize → Home card → resume → cancel / expire
3. Fix any QA bugs; commit the ride platform delta

### Sprint B — Session & profile truth
4. Refresh tokens + `/auth/me` → Account header
5. Remove or finish OTP / social auth
6. HTTPS staging endpoint

### Sprint C — Post-trip & retention
7. Activity / ride history API
8. Notifications (FCM) + basic inbox
9. Rating / receipt

### Sprint D — Monetization & safety
10. Real payments + wallet
11. SOS / trip share
12. Release signing + store checklist

---

## 12. Verdict

| Question | Answer |
|----------|--------|
| Can we QA the main ride product on device now? | **Yes — READY FOR DEVICE QA** (ride + auth core) |
| Is the full app store-ready? | **No** |
| Biggest incomplete surface? | Account / wallet / safety / support / secondary services (local mocks) |
| Biggest engineering debt? | Uncommitted large delta on `main`, cleartext QA, no refresh token, docs drift |

---

## 13. Quick reference — completed vs remaining

### Completed (highlights)
Architecture · Router · Auth email login · Live ride planning/booking/socket · Maps/GPS pickup · Active booking minimize + Home card · Cancel idempotency · Expired UI · Unit tests for ride/auth · Debug APK build path

### Remaining (highlights)
Device QA sign-off · HTTPS + release signing · JWT refresh · Profile/me sync · History/activity · Chat/FCM · Payments/wallet · SOS/trip share · Schedule/reserve/intercity/rentals APIs · Multi-stop · Legal/privacy content · Social/OTP · Broader tests · Commit & doc refresh

---

*Generated as `Rydu_User_App_audit.md` for the RYD U passenger codebase. Update this file after major milestones (device QA results, HTTPS cutover, account API wiring).*
