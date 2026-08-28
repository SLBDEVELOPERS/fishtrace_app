# FishTrace

FishTrace is a single, role-aware, offline-first Flutter application for seafood
traceability. It contains the Fisher, Processor, Transporter and Retailer workflows
shown in the supplied design boards.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://192.168.1.120:8002/api/v1 \
  --dart-define=FIREBASE_ENABLED=true
flutter analyze
flutter test
```

The local Laravel development accounts use `FishTrace@2026`:

- `fisher@fishtrace.demo`
- `processor@fishtrace.demo`
- `transporter@fishtrace.demo`
- `retailer@fishtrace.demo`

FishTrace is API-only. `DATA_SOURCE_MODE=mock` and other non-API modes are
rejected at startup. Enable Firebase only after adding the platform configuration
and configuring the backend service account. Production API URLs must use HTTPS.

All runtime repositories use the Laravel API. Successful Processor, Transporter,
and Retailer directory responses are cached per authenticated user, while mutations
from every role use the durable Drift/SQLite queue with controlled backoff and
idempotency keys. API tokens are stored securely; live sensors use REST
for latest/history and authorized Firebase Realtime Database `/liveTrips/{tripId}`
streams for updates. When Firebase is disabled, live monitoring polls permanent
Laravel telemetry without generating simulated readings.
Endpoint expectations are in
[`docs/api_contract.md`](docs/api_contract.md). The scanner intentionally includes a
manual/simulated route so it works on desktop and without camera permission.
