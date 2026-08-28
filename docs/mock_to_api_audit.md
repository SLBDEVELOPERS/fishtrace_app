# API runtime audit

Updated 2026-08-09.

## Architecture verified

- `go_router` remains the existing role-protection router; GetX remains the
  only state management and dependency-injection system.
- `InitialBinding` registers only Laravel implementations for active runtime
  repository interfaces. Test doubles are not reachable through app configuration.
- Views do not call Dio or Firebase. Controllers receive backend-neutral
  repositories and expose domain entities plus `AppException` state.
- The durable Drift sync queue retains endpoint, HTTP method, client record ID,
  payload, local files, retry state, and server-ID mapping.

## Active integration coverage

| Area | Runtime source | Offline / live behavior |
|---|---|---|
| Auth and common | Sanctum API and bundled help documentation | Session restoration and local 401 expiry |
| Fisher | Laravel boat/trip/catch/batch repositories | Typed Drift drafts, idempotent sync, attachment upload |
| Processor | Laravel intake, processing, inspection, and split endpoints | User-scoped cached directories and ordered queued transitions |
| Transporter | Laravel vehicle/trip/device/checklist/delivery endpoints | User-scoped cached directories, queued writes, RTDB live data |
| Retailer | Laravel receipt/inventory/sale/alert/report endpoints | User-scoped cached reads and endpoint-aware mutation queue |
| Live sensors | Firebase or permanent Laravel telemetry polling | No simulated runtime readings |

## Confirmed remaining work

- Retail reports retain placeholder chart series until report endpoints have a
  dedicated repository/controller contract.
- Production validation requires a deployed Laravel API, Firebase platform
  configuration, custom-token authentication, and restrictive RTDB rules.
- The full Flutter runner timed out in this environment without output; focused
  API, offline, interaction, and analysis checks are the current evidence.
