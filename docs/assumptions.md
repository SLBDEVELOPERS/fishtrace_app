# Assumptions

The application is API-only and requires a valid `API_BASE_URL`. Non-API data-source
modes are rejected at startup. Local Laravel seed accounts use `FishTrace@2026`.
The scanner retains a manual-entry fallback for desktop and test environments.

The completed application already uses `go_router`; the integration preserves it as
required instead of migrating working routes to GetPage. GetX remains the only state
management and dependency-injection solution. Real API/Firebase runtime validation
requires Laravel credentials and Firebase platform configuration, which were not
provided with the UI project.
