# InkSight

An AI-powered handwriting analysis app built with Flutter, demonstrating clean architecture principles.

## Architecture

MVVM with feature-based folder structure. Each feature has **Data**, **Domain**, and **Presentation** layers.

```
lib/
  app/           → App shell, routing, theme setup
  core/          → Shared infrastructure (errors, theme, env, logging, etc.)
  features/      → Feature modules (auth, analysis, history, settings)
  shared/        → Cross-feature widgets and utilities
```

See [docs/architecture.md](docs/architecture.md) for the full architecture guide.

## Tech Stack

| Category | Tool |
|---|---|
| State Management | Riverpod (with codegen) |
| Routing | GoRouter |
| Models | Freezed + json_serializable |
| Auth Backend | Supabase |
| Localization | easy_localization |
| Testing | mocktail |
| Linting | very_good_analysis + riverpod_lint |
| CI/CD | GitHub Actions |

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (**stable** channel matches [CI](.github/workflows/ci.yml))
- **Dart SDK** `^3.8.0` as declared in [`pubspec.yaml`](pubspec.yaml) (`environment.sdk`)
- A [Supabase](https://supabase.com) account and project (optional for local dev without cloud auth; see bootstrap)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/AlpKarky/inksight.git
   cd inksight
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up environment files. Copy the example and fill in your values:
   ```bash
   cp .env.example .env.dev
   ```

   Edit `.env.dev` with your Supabase project URL and publishable key:
   ```
   ENV=dev
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_PUBLISHABLE_KEY=sb_publishable_your-key-here
   ```

   The Gemini API key lives **server-side** as a Supabase Edge Function
   secret — see [docs/supabase-setup.md](docs/supabase-setup.md) for
   how to deploy the function and set the secret.

4. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run -t lib/main_dev.dart
   ```

### Running per Environment

```bash
# Development
flutter run -t lib/main_dev.dart

# Staging
flutter run -t lib/main_staging.dart

# Production build
flutter build apk -t lib/main_prod.dart
```

### Running Tests

```bash
flutter test

# With coverage
flutter test --coverage
```

### Code Generation

When modifying freezed models or riverpod providers, run:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Project Conventions

- **No hardcoded strings** in UI. Use `context.tr('key')`.
- **No hardcoded colors/spacing**. Use `context.appColors.*` and `context.dimensions.*`.
- **No business logic in widgets**. Screens are thin shells; logic lives in ViewModels.
- **No try-catch outside data sources**. Repositories return `Result<T>`.
- **Abstract + Impl** pattern for all service boundaries.

## License

MIT
