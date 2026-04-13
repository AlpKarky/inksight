# Auth Feature

Handles user authentication (sign in, sign up, sign out) and auth state management.

## Structure

```
auth/
  data/
    datasources/
      auth_remote_data_source.dart       # Abstract interface
      auth_remote_data_source_impl.dart  # Supabase wrapper
      auth_local_data_source.dart        # In-memory mock (dev only)
    models/
      user_model.dart                    # Freezed DTO, mirrors Supabase response
    repositories/
      auth_repository_impl.dart          # Maps DTOs → entities, returns Result<T>
  domain/
    entities/
      user_entity.dart                   # Freezed domain entity
    repositories/
      auth_repository.dart               # Abstract interface
  presentation/
    screens/
      login_screen.dart                  # Login form UI
      sign_up_screen.dart                # Registration form UI
    viewmodels/
      auth_state_viewmodel.dart          # Streams auth state for router guards
      login_viewmodel.dart               # Login form logic
      sign_up_viewmodel.dart             # Sign up form logic
    widgets/
      (feature-specific widgets go here)
```

## Data Flow

1. User submits email/password on `LoginScreen`
2. `LoginViewModel.signIn()` validates input via `Validators`
3. Calls `AuthRepository.signIn()` (abstract, injected via Riverpod)
4. `AuthRepositoryImpl` delegates to `AuthRemoteDataSource.signIn()`
5. `AuthRemoteDataSourceImpl` calls Supabase SDK, catches exceptions, maps to `AuthFailure`
6. Repository wraps result in `Result<UserEntity>` and returns
7. ViewModel pattern-matches: `Success` → `AsyncData`, `Failure` → `AsyncError`
8. Screen renders based on `AsyncValue` state
9. Supabase auth state change triggers `AuthStateViewModel` update
10. GoRouter redirect detects authenticated user → navigates to `/home`

## Auth Guard

`AuthStateViewModel` exposes the current `UserEntity?`. The router watches this:
- No user + protected route → redirect to `/login`
- Has user + auth route → redirect to `/home`

## Testing

Tests are in `test/features/auth/`. MockAuthRemoteDataSource is used to test
the repository. MockAuthRepository is used to test ViewModels.
