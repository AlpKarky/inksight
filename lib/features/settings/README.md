# Settings Feature

App preferences: **theme mode** (system / light / dark), **language** (en / es / fr via Easy Localization), and **profile** summary from auth state.

## Structure

```
settings/
  data/
    datasources/
      settings_local_data_source.dart       # Abstract
      settings_local_data_source_impl.dart  # SharedPreferences (theme)
    repositories/
      settings_repository_impl.dart
  domain/
    repositories/
      settings_repository.dart
  presentation/
    screens/
      settings_screen.dart
    viewmodels/
      theme_mode_viewmodel.dart             # ThemeMode + settingsRepository provider
```

## Data flow

1. `ThemeModeViewModel` loads/saves `ThemeMode` through `SettingsRepository` → `SettingsLocalDataSource` (prefs key `inksight_settings_theme_mode`).
2. `App` watches `themeModeViewModelProvider` and sets `MaterialApp.themeMode`.
3. Language uses `context.setLocale` with `saveLocale: true` on `EasyLocalization` (persisted by easy_localization).
4. Profile reads `authStateViewModelProvider` (`UserEntity`: email, `createdAt`).

## Testing

Override `settingsRepositoryProvider` in tests with a fake repository; widget tests can pump `SettingsScreen` with provider overrides.
