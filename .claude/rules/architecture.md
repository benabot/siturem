paths:
  - "Siturem/**/*.swift"
---

# Architecture

## Stack
SwiftUI + `@Observable` — iOS 17+, Swift 5.10. Pas de dépendances externes.

## Services
- `SessionEngine` — timer, phases (intro → meditation → closing), callbacks `onPhaseChange` / `onSessionEnd`
- `StatsStore` — UserDefaults (`siturem.sessions`), streak, stats, encode `[SessionRecord]` JSON
- `PreferencesStore` — préférences utilisateur
- `HealthKitService` — écriture séances dans HealthKit

## Modèles
- `SessionConfiguration` — durée totale, mode, gong, ambiance, rappel. Phases fixes : intro = 150 s, closing = 45 s
- `SessionRecord` — Codable, persisté dans StatsStore
- Enums : `SessionDuration`, `AccompanimentMode`, `GongMode`, `AmbientSound`, `ReminderInterval`, `SessionPhase`, `SessionState`

## Navigation
`SituremApp` → `ContentView` → `HomeView` → `SessionView` → `SessionSummaryView`
`StatsView` et `SettingsView` accessibles depuis `HomeView`

## Assets audio
`Siturem/Audio/`
- `Gongs/` — gong-start, gong-transition, gong-end (`.caf`)
- `Ambiance/` — rain, river, forest, white-noise (`.caf` ou `.m4a`)
- `VoiceGuidance/Intro/` — segments intro (150 s)
- `VoiceGuidance/Reminders/` — rappels phase centrale
- `VoiceGuidance/Outro/` — segments closing (45 s)
