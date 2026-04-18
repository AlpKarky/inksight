# Architecture Guide

## Overview

InkSight follows **MVVM** (Model-View-ViewModel) with a **feature-based folder structure**. Each feature is divided into three layers: **Data**, **Domain**, and **Presentation**.

## Layer Diagram

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  Screens ← Widgets ← ViewModels        │
│  (Flutter UI)    (@riverpod Notifiers)  │
└──────────────────┬──────────────────────┘
                   │ depends on (abstract)
┌──────────────────▼──────────────────────┐
│             Domain Layer                │
│  Entities (freezed)                     │
│  Repository Abstractions                │
│  (pure Dart, no Flutter imports)        │
└──────────────────┬──────────────────────┘
                   │ implements
┌──────────────────▼──────────────────────┐
│              Data Layer                 │
│  Repository Implementations             │
│  Data Source Abstractions + Impls       │
│  DTOs / Models (freezed)                │
│  (wraps 3rd-party packages)             │
└─────────────────────────────────────────┘
```

## Data Flow

```
Screen
  → watches ViewModel (AsyncValue)
    → ViewModel calls Repository (abstract, injected via Riverpod)
      → RepositoryImpl calls DataSource (abstract)
        → DataSourceImpl calls external service (Supabase, HTTP, etc.)
          → try-catch HERE ONLY → maps exceptions to AppFailure
        ← returns DTO (Model)
      ← maps DTO to Entity, wraps in Result<T>
    ← pattern-matches Result → sets AsyncData or AsyncError
  ← renders based on AsyncValue state
```

## Key Patterns

### Result<T> — Centralized Error Handling

Repositories return `Result<T>` instead of throwing. ViewModels pattern-match on the result.

```dart
// In ViewModel
final result = await repository.signIn(email: email, password: password);
state = switch (result) {
  Success() => const AsyncData(null),
  Failure(:final error) => AsyncError(error, StackTrace.current),
};
```

### Dependency Injection

Every abstraction has a Riverpod provider. Override in tests:

```dart
final container = ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWithValue(mockRepository),
  ],
);
```

### Third-Party Wrapping

External packages are only imported in their wrapper class (DataSourceImpl). The rest of the app depends on abstractions.

```
feature/data/datasources/
  auth_remote_data_source.dart       ← abstract (no imports)
  auth_remote_data_source_impl.dart  ← imports supabase_flutter
```

### FailureMapper — Error to UI Message

Lives in `shared/presentation/`. Maps `AppFailure` subtypes to localized strings. This is a presentation concern, not domain.

### Public API documentation (dartdoc)

The root `analysis_options.yaml` keeps `public_member_api_docs: false` for most of `lib/` (screens and widgets stay lightweight). Nested configs turn **`public_member_api_docs: true`** on for:

- `lib/core/errors/` — `Result`, `AppFailure` hierarchy, and related types
- each feature’s `domain/` — repository interfaces, entities, and shared enums

That matches how many teams document **contracts** (domain + core errors) without requiring `///` on every widget. Run `dart doc` if you want HTML output for those layers.

### `ProviderScope.retry` (no automatic retries)

`bootstrap.dart` passes `retry: (_, __) => null` so Riverpod does **not** automatically retry failed **async** providers for the whole app. Returning `null` means “do not schedule another attempt.”

**Why:** One global policy applies to every async provider under the scope. InkSight mixes **auth** and **remote analysis**—both are poor fits for blind retries (duplicated work, rate limits, confusing UX). Failures are surfaced once; recovery is **explicit** (user action / ViewModel) or can be implemented inside a **data source** for safe, idempotent reads with backoff.

**Reconsider if:** You introduce a subtree or provider category where **only** cacheable GET-style work runs and you want exponential backoff—then prefer **scoped** retry or **per-call** retry in the datasource rather than a blanket `Duration` at `ProviderScope` without auditing all async providers.

## How to Add a New Feature

1. Create `lib/features/<name>/` with `data/`, `domain/`, `presentation/` subdirectories
2. Define domain entity in `domain/entities/` (freezed)
3. Define repository abstraction in `domain/repositories/`
4. Create DTO in `data/models/` with `toDomain()` mapper
5. Create data source abstraction + implementation in `data/datasources/`
6. Implement repository in `data/repositories/` — returns `Result<T>`
7. Create ViewModels in `presentation/viewmodels/` with `@riverpod`
8. Build screens in `presentation/screens/` — thin shells
9. Extract widgets into `presentation/widgets/`
10. Add localization keys to `assets/translations/en.json`
11. Add routes to `app/router/`
12. Write tests mirroring the `lib/` structure
13. Add a `README.md` in the feature folder
14. Run `dart run build_runner build --delete-conflicting-outputs`
