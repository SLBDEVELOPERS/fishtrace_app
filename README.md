# FishTrace

FishTrace is a single, role-aware, offline-first Flutter application for seafood
traceability. It contains the Fisher, Processor, Transporter and Retailer workflows
shown in the supplied design boards.

## Run

```bash
flutter pub get
flutter run --dart-define=DATA_SOURCE_MODE=mock
flutter analyze
flutter test
```

Mock-mode demo accounts use `FishTrace@2026`:

- `fisher@fishtrace.demo`
- `processor@fishtrace.demo`
- `transporter@fishtrace.demo`
- `retailer@fishtrace.demo`

Mock mode is default. API mode can be started with:

```bash
flutter run --dart-define=DATA_SOURCE_MODE=api \
  --dart-define=API_BASE_URL=http://192.168.1.120:8002/api/v1 \
  --dart-define=FIREBASE_ENABLED=false
```

The local Laravel development accounts use the backend-documented password
`FishTrace@2026`. Enable Firebase only after adding the platform configuration
and configuring the backend service account. Production API URLs must use HTTPS.

Every feature controller resolves a mock repository in mock mode and a Dio repository
in API mode. Offline Fisher domain data and mutations are persisted in typed
Drift/SQLite tables and replayed with original timestamps, controlled backoff and
idempotency keys. API access/refresh tokens are stored securely; live sensors use REST
for latest/history and authorized Firebase Realtime Database `/liveTrips/{tripId}`
streams for updates. API mode requires platform Firebase configuration supplied by the
deployment environment.
Endpoint expectations are in
[`docs/api_contract.md`](docs/api_contract.md). The scanner intentionally includes a
manual/simulated route so it works on desktop and without camera permission.
