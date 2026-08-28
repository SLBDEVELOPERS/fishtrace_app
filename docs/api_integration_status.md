# API integration status

Updated 2026-08-22.

Runtime data is always provided by Laravel repositories. Non-API modes are rejected.
Firebase live monitoring is used when `FIREBASE_ENABLED=true`; otherwise permanent
Laravel telemetry is polled without simulated readings.

| Feature | Controller / binding | API path(s) | Status |
|---|---|---|---|
| Authentication | `AuthenticationController` / `AuthenticationBinding` | `/auth/*`, `/firebase/session` | Integrated |
| Fisher | `FisherController` / `FisherBinding` | boats, trips, catches, batches | Integrated with Drift sync |
| Processor | `ProcessorController` / `ProcessorBinding` | intake, records, steps, inspections, split | Integrated with cached reads and queued writes |
| Transporter | `TransporterController` / `TransporterBinding` | vehicles, trips, checklist, device, delivery | Integrated with cached reads and queued writes |
| Live monitoring | `LiveMonitoringController` / `LiveMonitoringBinding` | REST readings + Firebase live path | Integrated |
| Retailer | `RetailerController` / `RetailerBinding` | receipts, inventory, stock, sales, alerts | Integrated with cached reads and queued writes |
| Retail reports | `RetailReportsController` / `RetailerBinding` | `/retailer/reports/*` | Integrated with cached reads |
| Files | `UploadController` / `FileBinding` | multipart `/files` | Integrated |

Static analysis passes. Focused API-only configuration and user-scoped offline
cache regression tests are included. The Flutter test runner timed out without
output in this environment and must be rerun in a normal local/CI runner.
