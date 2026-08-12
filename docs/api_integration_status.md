# API integration status

Updated 2026-08-09.

`DATA_SOURCE_MODE=mock` uses mock repositories and never requires Laravel or
Firebase. `DATA_SOURCE_MODE=api` selects Laravel repositories, Sanctum bearer
authentication, multipart uploads, and Firebase live monitoring when
`FIREBASE_ENABLED=true`.

| Feature | Controller / binding | API path(s) | Status |
|---|---|---|---|
| Authentication | `AuthenticationController` / `AuthenticationBinding` | `/auth/*`, `/firebase/session` | Integrated |
| Fisher | `FisherController` / `FisherBinding` | boats, trips, catches, batches | Integrated with Drift sync |
| Processor | `ProcessorController` / `ProcessorBinding` | intake, records, steps, inspections, split | Integrated |
| Transporter | `TransporterController` / `TransporterBinding` | vehicles, trips, checklist, device, delivery | Integrated |
| Live monitoring | `LiveMonitoringController` / `LiveMonitoringBinding` | REST readings + Firebase live path | Integrated |
| Retailer | `RetailerController` / `RetailerBinding` | receipts, inventory, stock, sales, alerts | Integrated |
| Retail reports | no dedicated controller yet | `/retailer/reports/*` | Pending |
| Files | `UploadController` / `FileBinding` | multipart `/files` | Integrated |

Focused validation has passed `flutter analyze`, API integration tests, offline
tests, and interaction tests. The unscoped full `flutter test` command timed
out in this environment and needs rerun in a normal local/CI runner.
