# Architecture

FishTrace is one Flutter application with four authenticated roles. `app` owns
environment configuration, bootstrap and routing. `core` owns domain models, Drift
persistence, validation, networking boundaries, design tokens and reusable widgets.
Role workflows live under `features`.

The presentation layer uses GetX observable controllers. Screens invoke repository-backed
controller methods and never access SQLite or Dio directly. `go_router` protects each
role prefix and redirects authenticated users away from another role's routes.

Mock and API modes are selected with
`--dart-define=DATA_SOURCE_MODE=mock|api`. Authentication,
common, Fisher, Processor, Transporter, Retailer and sync boundaries all have mock and
Laravel implementations. Organized GetX bindings select exactly one implementation per
interface, including the narrower feature contracts exposed by each role aggregate.
API paths are centralized, and snake_case DTO mappers isolate backend JSON from
domain/controller state. API mode uses Firebase Realtime Database for authorized live updates plus
Laravel REST latest/history fallback through the sensor repository interfaces.
Device-facing capabilities remain isolated behind package-specific presentation
adapters so camera, location and notification permissions can be tested independently.

The screen catalogue exposes 40 dedicated primary screens. Role routes use
explicit typed paths and no generic workflow fallback. Shared/common, fisher,
processor, transporter and retailer features each own their domain entities,
repository contracts, mock data, controllers and presentation screens.

Offline Fisher domain data and mutations are written to typed Drift tables with
idempotency metadata. Connectivity
changes update the global offline state and trigger retry when the network
returns. API authentication stores tokens with secure storage and Dio injects
the bearer token, refreshes on 401 and replays the original request once; an
unrefreshable 401 performs a local-only session expiry to prevent logout loops. External
backend and sensor-hardware availability remain
deployment concerns rather than presentation-layer dependencies.
