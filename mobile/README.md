# Fasol Doctor — Mobile (Flutter)

Hand-authored project skeleton (no Flutter SDK available in the scaffolding
environment). To turn this into a runnable app on your machine:

```bash
cd mobile
flutter create . --org com.brac.fasoldoctor --platforms android   # generates android/, ios/ if needed, merges with existing lib/
flutter pub get
flutter run
```

`flutter create .` run inside this directory will not overwrite `lib/`,
`pubspec.yaml`, or this README — it only fills in the missing native
scaffolding (`android/`, build files) around the existing Dart source.

## Layout

```
lib/
  main.dart                 entrypoint, Hive init, ProviderScope
  app.dart                   MaterialApp.router + go_router routes
  core/
    theme/app_theme.dart      colors + ThemeData (single source of truth)
    network/api_client.dart   FastAPI client (POST/GET /diagnoses)
  features/
    onboarding/                permissions + language screen
    home/                       primary "ছবি তুলে রোগ দেখুন" / "কথা বলে জানান" CTAs
    camera/                     capture + image-quality retry state
    voice/                      Bangla speech_to_text + editable transcript
    diagnosis/                  analyzing (loading) + result (high/low confidence)
    treatment/                  numbered steps, organic vs chemical split
    history/                    status-chip list
    profile/                    farmer settings
    offline/
      offline_banner.dart        connectivity-aware banner shown app-wide
      offline_cache.dart         Hive cache of disease/treatment reference data
```

## Wiring still needed

- `analyzing_screen.dart` currently fakes a 2s delay — replace with a real
  `ApiClient.createDiagnosis()` call and route to `/diagnosis/:id` using the
  returned diagnosis id.
- `diagnosis_result_screen.dart` takes its content as constructor params —
  wire it to read the API response (`status == 'NEEDS_REVIEW'` → low-confidence
  branch) instead of the hardcoded demo defaults.
- On-device offline inference (`tflite_flutter`) is declared as a dependency
  but not yet integrated — bundle a small pilot-crop model under
  `assets/models/` per the offline vision plan in `IMPLEMENTATION_PLAN.md`.
- Bangla locale strings are inlined per-screen for now; move to
  `core/l10n/` with `intl` ARB files once copy is finalized.
