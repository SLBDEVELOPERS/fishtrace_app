# Mock-to-API audit

Updated 2026-08-09.

## Architecture verified

- `go_router` remains the existing role-protection router; GetX remains the
  only state management and dependency-injection system.
- `InitialBinding` selects one mock or Laravel implementation for every active
  repository interface using `DATA_SOURCE_MODE`.
- Views do not call Dio or Firebase. Controllers receive backend-neutral
  repositories and expose domain entities plus `AppException` state.
- The durable Drift sync queue retains endpoint, HTTP method, client record ID,
  payload, local files, retry state, and server-ID mapping.

## Active integration coverage

| Area | Mock mode | API mode | Offline / live behavior |
|---|---|---|---|
| Auth and common | Mock auth/session/common repositories | Sanctum auth, secure token storage, Firebase custom session | Session restoration and local 401 expiry |
| Fisher | Mock Fisher repository | Laravel boat/trip/catch/batch repositories | Drift drafts, idempotent sync, attachment upload |
| Processor | Mock workflow repository | Laravel intake, processing, inspection, and split endpoints | Ordered queued workflow transitions |
| Transporter | Mock trips/vehicles/devices | Laravel vehicle/trip/device/checklist/delivery endpoints | Delivery photo/signature attachments; RTDB in API mode |
| Retailer | Mock inventory/sales/alerts | Laravel receipt/inventory/sale/alert endpoints | Endpoint-aware mutation queue |
| Live sensors | Bounded mock stream | Authorized Firebase `/liveTrips/{tripId}` with Laravel history fallback | Listener and timer disposal in controller lifecycle |

## Confirmed remaining work

- Retail reports retain placeholder chart series until report endpoints have a
  dedicated repository/controller contract.
- Production validation requires a deployed Laravel API, Firebase platform
  configuration, custom-token authentication, and restrictive RTDB rules.
- The full Flutter runner timed out in this environment without output; focused
  API, offline, interaction, and analysis checks are the current evidence.
