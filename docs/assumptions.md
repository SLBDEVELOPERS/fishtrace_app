# Assumptions

Demo mode is the default because no backend, imagery, map tiles, or service keys were
provided. API mode requires `--dart-define=DATA_SOURCE_MODE=api` plus a valid
`API_BASE_URL`. All demo accounts use `FishTrace@2026`. Maps use an illustrative grid and the
scanner has a manual-entry fallback for desktop and test environments.

The completed application already uses `go_router`; the integration preserves it as
required instead of migrating working routes to GetPage. GetX remains the only state
management and dependency-injection solution. Real API/Firebase runtime validation
requires Laravel credentials and Firebase platform configuration, which were not
provided with the UI project.
