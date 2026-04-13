# Analysis Feature

Core feature of InkSight. Users photograph or upload handwriting samples which are analyzed via the Gemini AI API to reveal personality traits, legibility scores, and emotional state indicators.

## Structure

```
analysis/
  data/
    datasources/
      analysis_remote_data_source.dart       # Abstract interface
      gemini_data_source_impl.dart           # Gemini REST API wrapper
      analysis_local_data_source.dart        # SharedPreferences persistence
    models/
      analysis_model.dart                    # Freezed DTO (JSON ↔ domain)
    parsers/
      analysis_response_parser.dart          # Gemini response → structured map
    repositories/
      analysis_repository_impl.dart          # Orchestrates remote analysis
      analysis_history_repository_impl.dart  # CRUD for saved analyses
  domain/
    entities/
      analysis_entity.dart                   # Freezed domain entities
    repositories/
      analysis_repository.dart               # Abstract: analyze handwriting
      analysis_history_repository.dart       # Abstract: save/load/delete
  presentation/
    screens/
      home_screen.dart                       # Image picker + analyze CTA
      result_screen.dart                     # Analysis results display
      history_screen.dart                    # Saved analyses list
    viewmodels/
      analysis_viewmodel.dart                # Manages single-analysis flow
      history_viewmodel.dart                 # Manages saved-analyses list
    widgets/
      analysis_section_card.dart             # Reusable result card (traits, etc.)
      image_picker_section.dart              # Camera/gallery picker UI
```

## Data Flow

1. User picks/photographs handwriting on `HomeScreen`
2. Optional crop via `ImageCropper`
3. `AnalysisViewModel.analyzeHandwriting(file)` called
4. `AnalysisRepositoryImpl` delegates to `GeminiDataSourceImpl`
5. `GeminiDataSourceImpl` encodes image to base64, POSTs to Gemini REST API
6. Raw JSON text is parsed by `AnalysisResponseParser` (key standardization, validation)
7. Repository wraps parsed data into `AnalysisEntity` via `AnalysisModel.toDomain()`
8. Returns `Result<AnalysisEntity>` → ViewModel maps to `AsyncData` or `AsyncError`
9. `ResultScreen` renders the three analysis sections
10. User can save → `HistoryViewModel.saveAnalysis()` → `SharedPreferences`

## Error Handling

All failures are typed:
- `AnalysisRemoteFailure` — API errors (bad key, quota, network)
- `AnalysisParseFailure` — malformed or incomplete Gemini response
- `AnalysisNoImageFailure` — no image selected
- `StorageReadFailure` / `StorageWriteFailure` — SharedPreferences issues

`FailureMapper` translates these to localized user-facing messages.

## Configuration

Set `GEMINI_API_KEY` in your `.env.dev` / `.env.staging` / `.env.prod` file.
The Gemini model (`gemini-2.5-flash`) is configured in `GeminiDataSourceImpl`.

## Testing

Tests are in `test/features/analysis/`. Coverage includes:
- `AnalysisResponseParser` (valid/invalid JSON, key standardization, validation)
- `AnalysisRepositoryImpl` (success/failure mapping)
- `AnalysisHistoryRepositoryImpl` (CRUD via mock local data source)
- `AnalysisViewModel` (state transitions, clear, setResult)
- `HistoryViewModel` (build, save, delete, error state)
