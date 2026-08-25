# Passenger Profile / Account Management Audit Report

**Scope:** Passenger Flutter app only (`Rydu_User`).  
**Mode:** Audit only. No application code was modified.  
**Date:** 19 August 2026

**Implementation constraints (for later work, not this audit):**

- Do not modify working booking, ride history, recording consent, socket lifecycle, or active ride restore.
- Do not add local credential / password-store logic.
- Profile UI must reuse the existing logout path.

---

## Executive summary

The Account tab is a real, routed hub with Figma-style UI. **Almost all header and stats data are local mocks.** A separate **Profile Details** screen exists and is the only surface that calls a live user API (`GET /api/v1/passenger/auth/me`), and even there **phone, rating, membership, and verified-phone are still demo values**.

There is **no wired profile update, avatar upload, or delete-account API**. Field-level “Edit name / phone / email” routes are placeholders. Image picking is not in `pubspec.yaml`. Logout clears tokens, Auth0 credentials, and the socket, but **does not reset in-memory booking or ride-history state**.

Two unused stub screens (`/profile`, `/edit-profile` under `lib/features/profile/`) sit beside the live Account feature and must not be treated as the implementation path.

**Final status:**  
**AUDIT COMPLETE — PASSENGER PROFILE GAPS:** dual mock identities (Account vs Profile Details), Account header not synced to `GET /me`, no update/upload/delete APIs, placeholder edit screens, no image picker, logout does not reset booking/history providers.

---

## 1. Account screen

**Primary surface:** `AccountScreen` (`lib/features/account/presentation/screens/account_screen.dart`)  
**Route:** `/account` (`RouteNames.account`) — bottom-nav index 3.  
**Controller:** `accountControllerProvider` (`AccountController` / `AccountState`).

On tab open: `resetForAccountTab()` then `loadAccountData()`. Reset always restores **hardcoded `AccountState` defaults**, then load replaces them from the **local** account repository.

### 1.1 Displayed fields

| UI field | Source today | Real / mock |
|---|---|---|
| **Name** | `AccountState.userName` ← `AccountLocalDatasourceImpl` | **Mock** `"Mir Efaj"` |
| **Membership** | `membershipName` | **Mock** `"RYD U One"` |
| **Rating** | `rating` | **Mock** `"5.0"` |
| **Ride count** | `rideCount` (header + Ride History card `"View 127 rides"`) | **Mock** `127` |
| **Wallet balance** | `walletBalance` on Wallet quick action | **Mock** `"BDT 250.00"` |
| **Inbox unread dot** | `hasUnreadInbox` | **Mock** `true` |
| **Saved places count** | `savedPlacesCount` | **Mock** `4` |
| **App version footer** | `appVersion` | **Mock** `"v4.629.10001"` (not `pubspec.yaml` `1.0.0+1`) |
| **Avatar** | Generic `Icons.person_rounded` in a gradient circle. **No photo URL field exists anywhere.** | **Placeholder icon** |

`GET /me` is **not** used by the Account hub. Name on Account can disagree with Profile Details (see §2).

### 1.2 Avatar

- **Account header:** tap → `AccountController.openEditProfile()` → `push('/profile-details')`. Not a photo picker.
- **Profile Details hero:** same person icon. Inline TODO: “Show network profile photo when user profile API is ready.” **Not tappable for upload.**
- Legacy `ProfileAvatar` (`lib/features/profile/presentation/widgets/profile_avatar.dart`): unused `CircleAvatar` + person icon.

### 1.3 Edit Profile

There is **no** “Edit Profile” menu row on Account. Avatar tap is the entry to **Profile Details** (read-mostly personal info). See §4.

### 1.4 Settings

`AccountMenuTile` “Settings” → `openSettings()` → `/settings` (`SettingsScreen`).

Real UI for:

- Notifications toggle (local only; snackbar TODOs for FCM)
- Dark Mode (`appThemeModeProvider`)
- Language → `/language-settings`
- Privacy Settings → `/privacy-settings`
- Security → `/security-settings` (**placeholder** “TODO: Password and authentication settings.”)

Settings data from `AccountSettingsLocalDatasourceImpl` (notifications, language label, version). **No profile API.**

### 1.5 Ride History

`AccountFeatureCard` “Ride History” and rating chip both call `openRideHistory()` → `/ride-history`.

This is the **existing ride-history feature**. Do not replace it as part of profile work. The **count in the card is still mock `127`**, independent of the history list API.

### 1.6 Logout

Last menu tile, red styling, confirmation dialog. See §7.

### 1.7 Delete Account

**None** on Account, Settings, Privacy & Data, or Security.

### 1.8 Other Account hub items (not profile identity)

Help, Wallet, Safety, Inbox, Saved Places, Business Travel, Family — present and out of profile-identity scope. Saved Places hold **addresses**; they are not a profile `address` field.

---

## 2. Profile state

There are **two live controllers** plus a **dead stub stack**.

### 2.1 Account hub (what the tab shows)

| Layer | Location | Notes |
|---|---|---|
| **Riverpod** | `accountControllerProvider` | `NotifierProvider<AccountController, AccountState>` |
| **Use case** | `getAccountProfileUsecaseProvider` → `GetAccountProfileUsecase` | |
| **Repository** | `accountRepositoryProvider` → `AccountRepositoryImpl` | Get-only |
| **Datasource** | `AccountLocalDatasourceImpl` | 250ms delay, hardcoded model |
| **API** | **None** | TODO in datasource: “Load from API / cache when backend is ready.” |
| **Model / entity** | `AccountProfileModel` / `AccountProfileEntity` | name, membership, rating, rideCount, wallet, inbox, savedPlacesCount, appVersion. **No email, phone, avatar.** |

**Refresh:** every Account tab visit. `resetForAccountTab()` **wipes state to mocks first**. Any future `GET /me` sync into this controller must not be discarded by that reset, or the header will keep flashing demo names.

### 2.2 Profile Details (personal info)

| Layer | Location | Notes |
|---|---|---|
| **Riverpod** | `profileDetailsControllerProvider` | `NotifierProvider<ProfileDetailsController, ProfileDetailsState>` |
| **Use case** | `getProfileDetailsUsecaseProvider` → `GetProfileDetailsUsecase` | |
| **Repository** | `profileRepositoryProvider` (in `account_dependencies.dart`) → `ProfileRepositoryImpl` | **Get-only** — no update method |
| **Datasources** | Local demo **plus** `GetMeUsecase` | |
| **API** | `GET /api/v1/passenger/auth/me` via auth remote | Overlay name + email only |
| **Model / entity** | `ProfileDetailsModel` / `ProfileDetailsEntity` | name, phone, email, rating, membership, `isPhoneVerified` |

**Merge rules** (`ProfileRepositoryImpl.getProfileDetails`):

1. Load `ProfileDemoData` from local (always).
2. Call `GET /me`.
3. If user is null → demo entity.
4. Else: **name** and **email** from `/me` when non-empty; **phone, rating, membership, isPhoneVerified stay demo**.
5. `401` rethrown (controller marks session unauthenticated). Other errors → demo fallback. **No `errorMessage` set on Profile Details for network failure.**

**Initial UI state is already demo** (`Afshara Tasnim`, `+8801724536187`, `afsharatasnim@example.com`, rating `5.0`, membership `RYD U ONE MEMBER`, phone verified `true`). Loading spinner only if `isLoading && userName.isEmpty` — which **never happens** with current defaults.

**Refresh:** `loadProfile()` on Profile Details `initState` only. No pull-to-refresh. Account header is **not** updated after this call.

**Logout reset:** `resetForLogout()` restores **the same demo constants**, not empty/unauthenticated blanks.

### 2.3 Session user (auth, not Account UI)

| Layer | Location | Notes |
|---|---|---|
| **Riverpod** | `authSessionProvider` | `AuthSessionState` + optional `UserEntity` |
| **Cold start** | `RestoreSessionUsecase` → `hasValidSession()` (JWT in secure storage + `JwtValidator`) then **`GetCurrentUserUsecase` (local storage only)** | **Does not call `GET /me`** |
| **Login** | `LoginUsecase` → Auth0 password grant → `POST /api/v1/passenger/auth/login` → persist session user | `UserEntity`: `id`, `email`, `displayName`, `role` |
| **Entity / model** | `UserEntity` / `UserModel` | **No phone, avatar, address, verified flags** |

`GET /me` does **not** write back to secure storage. After restore, session user is whatever was saved at last login, not a fresh `/me`.

### 2.4 Dead stub: `lib/features/profile/`

| Layer | Location | Notes |
|---|---|---|
| **Riverpod** | `profileRepositoryProvider` in `features/profile/presentation/providers/profile_provider.dart` | **Name collision** with Account’s provider (different libraries; unused by Account UI) |
| **Repository** | `ProfileRepositoryImpl` | `getProfile` + `updateProfile` |
| **Remote** | `ProfileRemoteDatasourceImpl` | **No Dio.** `fetchProfile()` → `userId: 'user_placeholder'`. `saveProfile()` empty. |
| **Screens** | `ProfileScreen`, `EditProfileScreen` | Centered text `"Profile"` / `"Edit Profile"` |
| **Routes** | `/profile`, `/edit-profile` | Registered in `ride_routes.dart`. **No in-app navigation found.** |

`BACKEND_API_REQUIREMENTS.md` lists `GET/PUT /api/v1/passenger/profile` as the intended contract for this stub. **Those paths are not called in current Dart code.**

---

## 3. Existing profile APIs

Search covered: `profile`, `me`, `users/me`, `customers/me`, `passenger/profile`, and `AuthConstants`.

### 3.1 Paths actually used (HTTP)

From `lib/core/constants/auth_constants.dart` and `AuthRemoteDatasourceImpl`:

| Method | Exact path | Called from | Used for profile UI? |
|---|---|---|---|
| **GET** | `/api/v1/passenger/auth/me` | `AuthRemoteDatasourceImpl.currentUser()` → `GetMeUsecase` | **Yes** — Profile Details name/email overlay only |
| **POST** | `/api/v1/passenger/auth/login` | Auth0 token exchange | Session user at login |
| **POST** | `/api/v1/passenger/auth/register` | `{ name, email, password }` | Account creation, not edit |
| **POST** | `/api/v1/passenger/auth/logout` | Logout | Session end |
| **POST** | `/api/v1/passenger/auth/forgot-password` | `{ email }` | Password reset **email**, not profile edit |

No `users/me`, `customers/me`, or `passenger/profile` string exists in Dart sources.

### 3.2 Paths documented but **not** implemented as HTTP

| Suggested (docs / stub) | Reality in this repo |
|---|---|
| `GET /api/v1/passenger/profile` | Stub method only; **no Dio call** |
| `PUT /api/v1/passenger/profile` | Stub method only; **no Dio call** |
| `POST .../auth/otp/send` and `.../otp/verify` | Empty methods |
| `GET /auth/me` as “stub returning null” (`BACKEND_API_REQUIREMENTS.md`, `PRODUCTION_READINESS_CHECKLIST.md`) | **Stale.** Code performs a real GET and parses `user` |

### 3.3 `GET /me` payload parsed today

`PassengerSessionParser.parseUser`:

- `id` or `userId` (required; missing → null user)
- `email`
- `name` or `displayName`
- `role`

**Not parsed:** phone, avatar/photo URL, address, rating, membership, email/phone verified, Auth0 `sub`. Extra backend fields would be ignored.

---

## 4. Edit Profile

### 4.1 Screens that exist

| Route | Screen | Status |
|---|---|---|
| `/profile-details` | `ProfileDetailsScreen` | **Real UI.** Personal Info list. Security / Privacy tabs **navigate away** (do not switch in-place). |
| `/edit-profile-name` | `SupportFlowPlaceholderScreen(title: 'Edit name')` | **Placeholder** |
| `/edit-phone` | `SupportFlowPlaceholderScreen(title: 'Edit phone')` | **Placeholder** |
| `/edit-email` | `SupportFlowPlaceholderScreen(title: 'Edit email')` | **Placeholder** |
| `/edit-profile` | `EditProfileScreen` | **Unused stub** `"Edit Profile"` |
| `/profile` | `ProfileScreen` | **Unused stub** `"Profile"` |
| `/security` | `SecurityScreen` | Local mock security status; Password / authenticator / 2SV / recovery phone → more placeholders |
| `/privacy-and-data` | `PrivacyAndDataScreen` | Download Data is **local delay**, not HTTP |

Tiles always show a chevron (`ProfileInfoTile.onTap` required). Tapping Name / Phone / Email **looks editable** but lands on “will appear here.”

### 4.2 Fields: real vs mock

| Field | Shown? | Real backend? | Editable in app? |
|---|---|---|---|
| **Name** | Account + Profile Details | **Partial** — Profile Details only, from `/me` `name`/`displayName` when present; else demo. Account always mock `"Mir Efaj"`. | Placeholder screen. **No update API.** |
| **Email** | Profile Details only | **Partial** — from `/me` when present; else demo. | Placeholder. **No change-email API.** Login identity is Auth0 email. |
| **Phone** | Profile Details only | **Mock** (`ProfileDemoData`). Not on `UserEntity` / `/me` parser. | Placeholder. OTP send/verify are empty. |
| **Avatar** | Icon only | **None** — no URL in models or parser | No picker, no upload |
| **Address** | **Not on profile** | Saved Places are a **separate** local-mock feature | N/A for profile |

Phone “verified” checkmark is **always true from demo**, not from backend.

---

## 5. Image picker

### Dependencies (`pubspec.yaml`)

**Not present:** `image_picker`, `file_picker`, `image_cropper`, `flutter_image_compress`, camera plugins, compressor packages.

Present (unrelated): `google_maps_flutter`, `geolocator`, `auth0_flutter`, `dio`, `flutter_secure_storage`, `socket_io_client`.

### Code TODOs only

| Location | Behavior |
|---|---|
| `report_ride_issue_controller.dart` | Sets `demo://camera-photo` / `demo://gallery-photo`; snackbar “Camera/Gallery picker coming soon. (TODO: image_picker)” |
| `live_chat_controller.dart` | `demo://camera-preview`; TODOs for `image_picker` / `file_picker` |
| `email_support_controller.dart` | TODO `file_picker` |
| `upload_photo_box.dart` | UI chrome for camera/gallery/preview; **no I/O** |

### Platform

`android/app/src/main/AndroidManifest.xml`: INTERNET + location only. **No CAMERA / READ_MEDIA_IMAGES / READ_EXTERNAL_STORAGE.**  
iOS: **no** `NSCameraUsageDescription` / `NSPhotoLibraryUsageDescription` found.

`android/app/src/profile/` is a **build flavor named “profile”**, not user-profile code.

**Capability: none.** Avatar upload would need new packages, permissions, and an upload API that does not exist in this client.

---

## 6. Auth0 / email / phone

**Do not add local credential logic.** Current auth already delegates secrets to Auth0 + backend JWT.

### 6.1 How passenger auth works

1. **Register:** `POST /api/v1/passenger/auth/register` with `{ name, email, password }` (backend/Auth0 user create).
2. **Login:** Auth0 Resource Owner (`Auth0.api.login`) with `Username-Password-Authentication`, audience `https://api.drivewize.com` (overridable via dart-define).
3. **Exchange:** `POST /api/v1/passenger/auth/login` with `{ auth0Token, deviceInfo }`.
4. **Store:** `backend_jwt`, `session_id`, `user_id`, `user_email`, `user_name` in secure storage.
5. **API calls:** `AuthInterceptor` reads `backend_jwt` per request.

### 6.2 Email — Auth0-managed

**Yes, for the live login path.** Connection is `Username-Password-Authentication`. Sign-in screen is email + password (`AuthScreen`). Forgot-password screen calls **backend** `POST /api/v1/passenger/auth/forgot-password` with `{ email }` (Auth0 reset email, not a local password DB).

There is **no** in-app “change email” API. Treat email as **identity**, not a free-edit profile field, unless backend later documents a verified change flow.

### 6.3 Phone — verified?

**Not by this client.** Evidence:

- `UserEntity` / `UserModel` have no phone.
- `/me` parser has no phone.
- `sendOtp` / `verifyOtp` are **empty**.
- Phone sign-in / register / reset-OTP on `AuthLocalDatasourceImpl` are **delays only**.
- Profile “verified” badge is **demo `true`**.

Do not display a verified checkmark as backend truth until `/me` (or a dedicated endpoint) returns a real flag.

### 6.4 Password reset

| Flow | Status |
|---|---|
| **Forgot password (email)** | **Real HTTP** + snackbar “Check your email…” |
| **`/reset-password` screen** | Calls `resetPassword` → **local 650ms delay**. Navigates **home** without establishing a session. Not Auth0. |
| **Security → Change password** | Placeholder |
| **Settings → Security** | Placeholder |

Do not invent a second password store. Reuse forgot-password / Auth0; do not wire the local `resetPassword` delay as production profile security.

### 6.5 Social login vs editing

`AuthController.continueWithGoogle` / `continueWithApple` are TODOs (Firebase / `google_sign_in` / `sign_in_with_apple` **not in pubspec**). **Auth screens do not show Google/Apple buttons.**

**No current social-login impact on profile editing.** If social is added later, email/name may become IdP-owned; do not assume they stay patchable.

---

## 7. Logout

**UI path (reuse this):** Account → Logout tile → `showLogoutConfirmationDialog` → `AccountController.logout()` → on success `go(RouteNames.auth)`.

Busy state: dialog spinner; Account `AbsorbPointer` while `isLoading`. Failure: SnackBar, stay logged in.

### 7.1 What logout does today

`AccountController.logout()`:

1. `LogoutUsecase` → `AuthRepository.signOut()`
   - `POST /api/v1/passenger/auth/logout` (empty body; **does not send `sessionId`** despite older docs).
   - On `401`/`403`, still clears local auth.
   - Other API errors **rethrow** — local tokens **kept**.
2. `_clearLocalAuth()`: delete `backend_jwt`, `session_id`, `user_id`, `user_email`, `user_name`. **Does not** `deleteAll()` on secure storage.
3. `Auth0Datasource.clearCredentials()` (best-effort).
4. `passengerSocketService.disconnect()` (`preserveActiveBooking: false` → clears socket’s `_activeBookingId`).
5. `authSessionProvider.markUnauthenticated()`.
6. `profileDetailsController.resetForLogout()` → **demo profile**, not empty.
7. `state = const AccountState()` → **demo Account header**.

Dio will not attach a Bearer token after step 2 (interceptor reads storage).

### 7.2 What logout does **not** do

| Concern | Status |
|---|---|
| **Tokens cleared** | **Yes** (JWT + session user keys + Auth0 credentials manager) |
| **Socket disconnected** | **Yes** |
| **Active booking Riverpod state reset** | **No.** `rideBookingControllerProvider` is not invalidated; `resetPlanningSession()` is not called. In-memory booking can survive until process death. **Do not change booking restore logic in this audit; flag for a later logout hook that only resets state, without touching restore-on-login/splash.** |
| **Ride history state reset** | **No.** `RideHistoryController` has no logout reset. Previous user’s list can remain in memory. |
| **Profile state reset** | **Partial.** Reset to **demo people**, so a brief flash of “Afshara Tasnim” / “Mir Efaj” is possible after logout or before next load. |
| **Wallet / inbox / settings / privacy providers** | **Not reset.** |
| **`AuthController.signOut()`** | Alternate path: logout + socket only; **does not** mark session unauthenticated or reset profile. **Account UI does not use it.** Keep a single path. |

Route guards send unauthenticated users to `/auth` for protected routes. That does **not** wipe booking/history Notifiers.

**Profile work must call `AccountController.logout()` (or extract the same sequence), not a new sign-out.**

---

## 8. Account delete

Searched: `delete account`, `deleteAccount`, `deactivate`, `close account` (and closeAccount) in Dart.

**No UI, no repository method, no HTTP path.**

Closest related:

- Privacy & Data → **Download Data** (`PrivacyLocalDatasourceImpl` 300ms stub).
- Logout (session only).
- Auth0 `clearCredentials` (device credentials, not Auth0 user deletion).

**Gaps:** confirmation UI, backend delete/deactivate contract, Auth0 user deletion vs app-only deactivate, impact on active booking (must remain untouched until product defines it), and post-delete navigation (likely same as logout).

---

## 9. Profile image UI (recommendation only)

**Do not implement yet.** There is no picker, cropper, compressor, permission, or upload endpoint in this app.

Recommended later flow, reusing existing SnackBar + `isLoading` patterns:

1. **Avatar tap** on Profile Details (and optionally Account header after photo exists) → source sheet: Camera / Gallery / Cancel. Account header tap today opens Profile Details; keep that unless product wants picker on the hub.
2. **Select image** via `image_picker` (new dependency). Add Android/iOS photo + camera permissions.
3. **Crop / preview:** **no cropper in repo.** Either skip crop for v1 (preview sheet only) or add `image_cropper` when implementing. Do not pretend crop exists.
4. **Upload** only after backend documents multipart/URL. **Do not** write a guessed `PUT /profile` against the empty stub. Prefer extending `/me` or a documented passenger media endpoint.
5. **Progress:** overlay `CircularProgressIndicator` (same pattern as Privacy download / logout dialog).
6. **Refresh:** on success, update Profile Details + Account header from **`GET /me`** (once avatar is in the parser). Do not keep a second local photo cache as source of truth.

Until an upload API exists, keep the person icon and do not add a dead picker.

---

## 10. Read-only vs editable

**No assumptions beyond this client and the APIs it actually calls.** There is **no update-profile HTTP** in the app, so **nothing is persistable as editable today.**

### 10.1 Treat as display / identity (read-only until backend contract is added)

| Field | Why |
|---|---|
| **User id** | `/me` + session; not shown in UI |
| **Email** | Auth0 username-password identity; login + forgot-password; `/me` returns it; **no change-email API** |
| **Role** | Parsed from `/me`; not shown |
| **Password** | Auth0; use existing forgot-password; **no local credential store**; in-app reset screen is a stub |
| **Phone verified** | Demo only — hide or unlabeled until `/me` includes it |
| **Rating, membership, ride count, wallet** | Account mocks; not `/me` |

### 10.2 Candidate editable **only if** backend adds a documented passenger profile update

| Field | Evidence today |
|---|---|
| **Display name** | Sent at **register**; returned on `/me` as `name`/`displayName`. **No PATCH in client.** If backend supports updating name without Auth0 email change, this is the only plausible first field. |
| **Avatar** | Not in parser or models. Needs new API + picker. |
| **Phone** | Not in `/me`. OTP APIs empty. Do not ship phone edit as verified. |
| **Address** | Not a profile field. Use Saved Places separately; do not fold into Edit Profile without a backend profile-address field. |

### 10.3 Implementation rule

Do not make Name/Phone/Email tiles look saved while they push placeholders. Until update APIs exist: **read-only personal info** (no chevron, or chevron only for copy), and **do not** write values into `ProfileDemoData` as if they were the user.

Do not implement email/password/phone-credential editing locally.

---

## 11. Error / loading patterns

**`AsyncValue` is not used** in `lib/features/` (no matches). Pattern is custom `Notifier` state: `isLoading` + `errorMessage` (+ occasional `snackMessage`).

| Surface | Loading | Error | Retry | Validation |
|---|---|---|---|---|
| **Account** | `AbsorbPointer` while loading; **no spinner** | Inline red text `"Could not refresh account."` / logout errors | Re-enter tab (reload). **No retry control.** | N/A |
| **Profile Details** | Spinner **only if name empty** (dead with demo defaults) | Network errors **swallowed**; 401 → unauthenticated | Re-open screen | N/A |
| **Logout dialog** | Button spinner | SnackBar | User taps Logout again | N/A |
| **Settings** | No blocking spinner on first paint | Inline error | Re-open | N/A |
| **Auth login / register / forgot-password** | Button submitting flag | Inline `AuthException.message` | Resubmit | Email regex, password ≥ 6, name ≥ 2, confirm match |
| **Privacy download** | Full-screen dim + spinner | SnackBar | Tap card again | N/A |
| **Ride history** (do not change) | Initial / refresh / load-more flags | `errorMessage` | Existing refresh | N/A |

**Snackbar:** used for logout failure, settings TODOs, support flows. Not used for Profile Details load failure.

**Recommendation for later profile work:** show a real loading flag even when demo/cached name is on screen; surface `/me` failures with retry; do not copy Profile Details’ silent catch.

---

## 12. Tests

### 12.1 Existing (related, not Account UI)

| Test | Covers |
|---|---|
| `test/app/router/route_guards_test.dart` | Splash / auth / protected redirect — **auth restore routing**, not profile |
| `test/features/auth/jwt_validator_test.dart` | Token validity used by `hasValidSession` |
| `test/features/auth/passenger_session_parser_test.dart` | Login envelope + user `id`/`email`/`name` — **not** `/me`-only overlay or phone/avatar |
| `test/features/auth/auth_error_mapper_test.dart` | Auth HTTP errors |
| `test/widget_test.dart` | Splash branding → welcome; unauthenticated session override |
| Ride booking / history tests | Out of profile scope; **do not repurpose** |

**No** `test/features/account/**`. **No** `*profile*test*`. **No** logout widget/controller test.

### 12.2 Missing profile tests (when implementing)

- Account header mapping from `/me` vs leftover mocks (name must not stay `"Mir Efaj"` when session user differs).
- `ProfileRepositoryImpl` overlay: name/email from `/me`, phone **not** invented if `/me` omits it.
- `PassengerSessionParser.parseUser` extras: ignore unknown fields; null when `id` missing.
- Logout: tokens cleared, `markUnauthenticated`, socket `disconnect` invoked; **booking/history providers not asserted as changed until a dedicated reset is added without touching restore.**
- Navigation: avatar → `/profile-details`; Settings → `/settings`; Ride History still `/ride-history`.
- Edit placeholders: do not claim save succeeded.
- 401 on `/me` → unauthenticated.
- Image upload: N/A until picker exists.

---

## 13. Dual-stack and identity mismatch

| Identity | Where | Value |
|---|---|---|
| Account mock | `AccountLocalDatasourceImpl` / `AccountState` defaults | **Mir Efaj** |
| Profile demo | `ProfileDemoData` | **Afshara Tasnim** + fake phone/email |
| Session / `/me` | Login + GET me | Real `name` / `email` when APIs succeed |

Account and Profile Details can show **two different people** in one session. Profile Details can show **demo phone** next to a **real email**.

**Recommendation:** one passenger profile pipeline: `GET /me` (and later update/upload) → shared notifier used by Account header and Profile Details. Keep `lib/features/profile/` stub out of the live path or delete it in a later cleanup. Do not dual-write.

`resetForAccountTab()` currently guarantees mock defaults on every tab open — that is incompatible with a synced header unless changed in the profile implementation (Account controller only; not booking/history).

---

## 14. Suggested implementation order (not started)

1. Sync Account header + Profile Details to `GET /me` (name, email, id). Remove demo name/email when `/me` succeeds; **do not** keep fake phone/verified if `/me` has no phone.
2. Read-only personal info until update APIs are confirmed.
3. Reuse existing logout; add provider invalidation for account/profile (and, separately, booking/history **only** if product requires it — **not** by editing restore/socket/consent).
4. If backend adds name PATCH and/or avatar upload, then edit screens + picker. Not before.
5. Account delete only with an explicit API.
6. Tests in §12.2.

Stale docs to treat as non-authoritative: `BACKEND_API_REQUIREMENTS.md` (`GET /me` stub), `PRODUCTION_READINESS_CHECKLIST.md` (same).

---

## Final status

**AUDIT COMPLETE — PASSENGER PROFILE GAPS:** Account header is local mock (separate demo identity from Profile Details); `GET /me` overlays name/email only; no update/upload/delete APIs; edit/name/phone/email screens are placeholders; no image picker; logout clears tokens and socket but not booking/history memory; no account/profile tests.
