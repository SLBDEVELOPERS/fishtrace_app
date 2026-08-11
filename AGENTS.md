# FishTrace contributor guide

Use feature-first organization under `lib/features` and share visual primitives from
`lib/core`. Use feature-focused GetX controllers (the root session/sync controller is
`AppController`) for presentation state; screens must not
call data sources or Dio directly. Routes belong in `app/router` and route names in
`AppRoute`. Repository interfaces are backend-neutral.

Use lower_snake_case filenames, immutable domain data, semantic naming, and Dart
formatter. Design values belong in `FishTraceTokens`/theme only; do not introduce raw
colors or arbitrary dimensions in feature screens. Every mutation needs validation,
feedback, and an offline-safe mock/repository path. Do not leave TODO-only behaviour.

Before hand-off run:

```
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```
