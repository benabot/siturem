# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

```bash
# Régénérer le projet Xcode après toute modification de project.yml
xcodegen generate

# Ouvrir dans Xcode
open Siturem.xcodeproj

# Build en ligne de commande (simulateur)
xcodebuild -project Siturem.xcodeproj -scheme Siturem -destination 'platform=iOS Simulator,name=iPhone 16' build
```

> `xcodegen generate` est requis après tout changement de `project.yml` ou ajout/suppression de fichiers Swift dans `Siturem/`.

## Architecture

SwiftUI + `@Observable` (iOS 17+, Swift 5.10). Pas de dépendances externes.

### Services principaux

- **`SessionEngine`** — moteur de séance : gère le timer, les phases (`intro → meditation → closing`) et les transitions. Callbacks `onPhaseChange` / `onSessionEnd` pour brancher l'audio.
- **`StatsStore`** — persistance `UserDefaults` (`siturem.sessions`) + calcul de streak / statistiques. Encode `[SessionRecord]` en JSON.
- **`PreferencesStore`** — préférences utilisateur persistées.
- **`HealthKitService`** — écriture des séances dans HealthKit (droits déclarés dans `project.yml`).

### Assets audio

Les fichiers audio sont dans `Siturem/Audio/`, organisés par locale puis par catégorie :
- **`fr/`** — première locale alimentée
- **`en/`**, **`es/`**, **`de/`** — structure prête pour l'extension
- sous-dossiers par locale :
  - **`Gongs/`** — `gong.caf`
  - **`Ambiance/`** — `rain-loop`, `river-loop`, `forest-loop`, `white-noise-loop` (`.m4a` ou `.caf`)
  - **`VoiceGuidance/Intro/`** — séquence ordonnée de l'intro, clips joués dans l'ordre avec gaps configurés; le dernier clip est ancré 5 s avant la fin de phase
  - **`VoiceGuidance/Reminders/`** — rappels discrets pour la phase centrale
  - **`VoiceGuidance/Outro/`** — séquence ordonnée du retour, puis silence jusqu'à la fin réelle de la séance

Format recommandé : `.caf` (Core Audio Format, lecture native AVAudioPlayer). Ambiances longues possibles en `.m4a` pour réduire la taille du bundle.
La résolution audio est centralisée par `AudioLocale` avec fallback vers `fr` si la locale demandée n'est pas encore alimentée. `project.yml` déclare `Siturem/Audio` explicitement pour préserver cette hiérarchie dans le bundle. Des `.gitkeep` gardent visibles les dossiers de locales encore vides.
Le séquençage vocal ne repose plus sur des timestamps fixes : `AudioService` calcule une timeline ordonnée à partir de l'ordre des clips, des gaps configurés et des durées attendues ou mesurées.

### Modèles clés

- **`SessionConfiguration`** — paramètres d'une séance (durée totale, mode d'accompagnement, gong, ambiance, rappel). Phases fixes : intro = 150 s, closing = 45 s.
- **`SessionRecord`** — enregistrement d'une séance terminée (Codable, persisté dans StatsStore).
- Enums principaux : `SessionDuration`, `AccompanimentMode`, `GongMode`, `AmbientSound`, `ReminderInterval`, `SessionPhase`, `SessionState`.

### Flux de navigation

`SituremApp` → `ContentView` → `HomeView` (lancement) → `SessionView` (séance active) → `SessionSummaryView` (bilan). `StatsView` et `SettingsView` accessibles depuis `HomeView`.

## Références produit

- `docs/cahierCharges-v1.md` — spécifications fonctionnelles (source de vérité)
- `docs/BrandingGuideline.md` — identité visuelle, ton, territoire
- `TODO.md` / `PROJECT_STATUS.md` — suivi partagé Claude Code + Codex
