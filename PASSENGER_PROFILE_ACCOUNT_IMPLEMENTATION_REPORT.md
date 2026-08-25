# Passenger Profile / Account Implementation Report

**Scope:** Passenger Flutter app only. Backend and Driver Android were not modified.  
**Date:** 19 August 2026

**Final status:** READY FOR PASSENGER PROFILE RETEST

Booking, active-ride restore, ride history, recording consent, Socket.IO connect/lifecycle, FCM, saved places, and logout API semantics were not rewritten.

---

## Shared profile architecture

One Riverpod pipeline: `passengerProfileControllerProvider`.

| Surface | Uses |
|---|---|
| Account header | `PassengerProfile` (avatar, name, email, optional phone) |
| Profile Details | Same state |
| Edit Profile | Same state + PATCH / avatar |
| Deactivate | Same repository + existing `AccountController.logout()` |

State:

- `profile`
- `isLoading`
- `isRefreshing`
- `isSaving`
- `isUploadingAvatar`
- `errorMessage`

There is no second identity. Demo names (`Mir Efaj`, `Afshara Tasnim`) and fake verified/rating/membership identity were removed from `lib/`.

The unused `lib/features/profile/` stub stack was deleted. `/profile` redirects to `/profile-details`. There is no duplicate `profileRepositoryProvider`.

---

## API integration

Uses the existing authenticated `ApiClient` / Dio. No second client.

| Method | Path |
|---|---|
| GET | `/api/v1/passenger/profile` |
| PATCH | `/api/v1/passenger/profile` |
| POST | `/api/v1/passenger/profile/avatar` |
| DELETE | `/api/v1/passenger/profile/avatar` |
| POST | `/api/v1/passenger/profile/deactivate` |

`GET /api/v1/passenger/auth/me` is unchanged for session restore. Account UI does not use it.

---

## Model

`PassengerProfile`: `id`, `name`, `email`, `phone`, `profileImageUrl`, `accountStatus`, `createdAt`.

Not modeled: role editing, Auth0 ids, session ids, device ids, verified phone, rating, membership, wallet.

---

## Mock removal

Account no longer loads local mock identity. `resetForAccountTab()` was removed so the tab does not restore a fake person.

Removed as user-truth:

- Membership badge / “RYD U One”
- Rating `5.0`
- `127 rides`
- Wallet `BDT 250.00`
- Fake inbox unread
- Fake saved-places count
- Fake app version footer
- Phone verified badge

Ride History still opens `/ride-history` (real history feature). The card says **View rides**, not a fake count.

Wallet / Inbox / Saved Places remain as product cards without hardcoded personal stats.

---

## Edit flow

Real `EditProfileScreen` at `/edit-profile`.

- **Editable:** name, phone (optional; add / edit / clear)
- **Read-only:** email (never PATCHed)

PATCH bodies:

```json
{ "name": "..." }
```

```json
{ "phone": { "countryCode": "+880", "number": "1712345678" } }
```

```json
{ "phone": null }
```

Country-code split for the editor is longest-prefix. A `+1` / `+44` number is not treated as Bangladesh.

`AUTH0_ERROR` shows: “Could not update your name right now. Please try again.” Local profile is not updated on failure.

`/edit-profile-name` and `/edit-phone` redirect to `/edit-profile`. `/edit-email` redirects to Profile Details.

---

## Avatar

- Gallery via `image_picker` (JPEG / PNG / WebP, max 5 MB)
- Camera not required
- POST multipart field: `avatar`
- DELETE removes photo; UI falls back to initials / person icon
- Loading overlay on the avatar while uploading/removing

---

## URL resolution

`resolveProfileImageUrl()`:

- `/uploads/avatars/passengers/x.jpg` → `{origin}/uploads/avatars/passengers/x.jpg`
- Origin is scheme + host + port of `API_BASE_URL`, **not** `/api/v1`
- Absolute `http(s)` URLs are left unchanged

---

## Logout cleanup

Still `AccountController.logout()`:

1. `POST /api/v1/passenger/auth/logout`
2. Clear JWT / session keys
3. Auth0 credential clear
4. Socket disconnect (existing service; connect/restore logic not changed)
5. `markUnauthenticated`
6. **Clear `PassengerProfile` to empty/null** (not demo users)
7. Invalidate ride-history provider only (in-memory list). Booking restore code was not changed.

---

## Deactivation

Confirmation copy matches the requested retention / support-reactivation wording.

`POST /api/v1/passenger/profile/deactivate` with `{ "confirm": true }`.

If `RideBookingState.hasActiveBooking`: blocked with “Finish or cancel your active ride before deactivating your account.” Live booking is not cancelled.

On success: reuse `logout()`, then Auth screen (`go`).

`403 ACCOUNT_DEACTIVATED` on login or profile load: clear session, disconnect socket, route to Auth, show deactivated message. `VALIDATION_ERROR` does not log the user out.

---

## Session sync

After a successful name PATCH:

- Shared `PassengerProfile` updates (Account + Profile Details + Edit)
- Secure storage `user_name` updates
- `AuthSessionState.user.displayName` updates
- User id and email are not changed

---

## Settings

Settings route kept. Security “Change password” opens the existing **forgot-password** email flow. No fake password change, email change, OTP, or KYC.

---

## Loading / errors / refresh

- First Account / Profile Details open: load profile
- Pull-to-refresh on Account and Profile Details
- Network failure with no profile: error + Retry (no demo fallback)
- Refresh failure with a loaded profile: keep current data and show the error
- Existing `isLoading` / `errorMessage` / SnackBar pattern

---

## Files changed (high level)

### Added
- Profile API layer, parser, phone split, request bodies, URL helper
- `passengerProfileControllerProvider`
- Edit Profile screen, avatar widget/actions, deactivate dialog
- Tests under `test/features/account/`
- `image_picker` dependency; iOS photo-library usage string

### Updated
- Account screen / header / controller
- Profile Details
- Routes (`/profile`, edit redirects)
- Auth login `ACCOUNT_DEACTIVATED` handling
- Session display-name persistence
- `AuthException.code`, auth + passenger error mappers

### Removed
- `lib/features/profile/` placeholders
- Demo profile data and GET `/me` overlay identity
- Local mock account identity datasource used as profile truth

---

## Tests

New coverage includes GET parse, shared Account/Details identity, no demo names/verified badge, name/phone/null PATCH bodies, email never PATCHed, AUTH0_ERROR keeps old profile, avatar multipart field `avatar`, relative URL resolution, avatar upload/delete, logout clears profile + disconnects socket, deactivate confirmation, active-ride block, deactivate reuses logout, ACCOUNT_DEACTIVATED vs VALIDATION_ERROR, Ride History still `/ride-history`.

Existing booking, restore, recording consent, and ride history tests still pass.

**`flutter analyze`:** No issues found.  
**`flutter test`:** 181 passed.  
**`flutter build apk --debug`:** Built `build/app/outputs/flutter-apk/app-debug.apk`.

---

## Manual QA

A. Account shows real passenger identity (no demo names).  
B. Edit name → Account + Profile Details update; restart should persist via GET profile.  
C. Add/edit/remove phone; restart persists.  
D. Upload avatar; restart persists; remove → fallback.  
E. Logout → empty profile, socket disconnect, Auth screen.  
F. Deactivate with no active ride → confirm → logged out; relogin → ACCOUNT_DEACTIVATED.  
G. Active ride blocks deactivation.  
H. Booking, active restore, ride history, recording consent unchanged.

---

## Final status

**READY FOR PASSENGER PROFILE RETEST**
