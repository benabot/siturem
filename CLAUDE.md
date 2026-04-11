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

Les fichiers audio sont dans `Siturem/Audio/`, organisés par catégorie :
- **`Gongs/`** — gong-start, gong-transition, gong-end (`.caf`)
- **`Ambiance/`** — rain, river, forest, white-noise (`.caf` ou `.m4a`)
- **`VoiceGuidance/Intro/`** — segments minutés de la phase intro (2m30), un fichier par consigne
- **`VoiceGuidance/Reminders/`** — rappels discrets pour la phase centrale
- **`VoiceGuidance/Outro/`** — segments minutés du retour (45s)

Format recommandé : `.caf` (Core Audio Format, lecture native AVAudioPlayer). Ambiances longues possibles en `.m4a` pour réduire la taille du bundle.

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
