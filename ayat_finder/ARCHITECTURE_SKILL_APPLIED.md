# Flutter-Dart Skill Applied

This project now follows a feature-first Clean Architecture baseline with Cubit.

## What was applied

- `flutter_bloc` state management with `HomeCubit` + immutable `HomeState`
- `get_it` dependency injection
- Domain-driven structure under `lib/features/recognition/`
- Repository pattern with typed `DataState<T>` results
- Typed exception hierarchy (`AppException`)
- Domain entities with `copyWith`, `==`, and `hashCode`

## New structure

```text
lib/
├── core/
│   ├── di/service_locator.dart
│   ├── error/app_exception.dart
│   ├── network/app_config.dart
│   └── state/data_state.dart
└── features/
    └── recognition/
        ├── data/
        │   ├── datasources/recognition_remote_data_source.dart
        │   ├── models/
        │   └── repositories/recognition_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   ├── repositories/recognition_repository.dart
        │   └── usecases/
        └── presentation/
            └── cubit/
```

## Runtime wiring

- `main.dart` now initializes DI via `setupDependencies()`.
- `src/app.dart` provides `HomeCubit` using `BlocProvider`.
- Existing UI in `src/home_page.dart` is now rebuilt via `BlocBuilder`.

## Notes

- Legacy files were removed:
  - `lib/src/home_controller.dart`
  - `lib/src/recognition_api.dart`
  - `lib/src/models.dart`
- Current app flow is fully routed through `core/` + `features/recognition/`.
