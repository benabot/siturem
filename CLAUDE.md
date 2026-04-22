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
- **`PreferencesStore`** — préférences utilisateur persistées, dont un override optionnel de langue UI pour l'interface. La locale audio active est dérivée de la langue UI effective.
- **`HealthKitService`** — expose disponibilité, état d'autorisation, demande d'accès contextuelle depuis `SettingsView`, et écriture silencieuse des seules séances terminées normalement dans HealthKit.

### Assets audio

Les fichiers audio sont dans `Siturem/Audio/`, séparés entre assets partagés et voix localisées :
- **`Shared/`**
  - **`Gongs/`** — `gong.caf`
  - **`Ambiance/`** — `rain-loop`, `river-loop`, `forest-loop`, `white-noise-loop` (`.m4a` ou `.caf`)
- **`fr/`**, **`en/`**, **`es/`**, **`de/`**
  - **`VoiceGuidance/Intro/`** — séquence ordonnée de l'intro, clips joués dans l'ordre avec gaps configurés; le dernier clip est ancré 5 s avant la fin de phase
  - **`VoiceGuidance/Reminders/`** — rappels discrets pour la phase centrale
  - **`VoiceGuidance/Outro/`** — séquence ordonnée du retour avec longues pauses et gong final intégré à la phase de closing

Format recommandé : `.caf` (Core Audio Format, lecture native AVAudioPlayer). Ambiances longues possibles en `.m4a` pour réduire la taille du bundle.
La résolution audio est centralisée par `AudioLocale` et suit la langue UI effective quand l'audio est disponible (`fr`, `en`, `es`), sinon fallback global vers `en`. Les ambiances et le gong sont résolus depuis `Audio/Shared`, tandis que `VoiceGuidance` reste résolue par locale avec tentative `en` si un asset manque. `project.yml` déclare `Siturem/Audio` explicitement pour préserver cette hiérarchie dans le bundle.
Le séquençage vocal ne repose plus sur des timestamps fixes : `AudioService` calcule une timeline ordonnée à partir de l'ordre des clips, des gaps configurés et des durées attendues ou mesurées. L'intro FR inclut `intro_07_scan_corporel`, `intro_04_fermer_les_yeux` intervient 3 s plus tard qu'avant, et `intro_08_concentration_souffle` reste ancré 5 s avant la fin d'intro.

### Modèles clés

- **`SessionConfiguration`** — paramètres d'une séance (durée totale, mode d'accompagnement, gong, ambiance, rappel). Phases fixes : intro = 150 s, closing = 92 s.
- **`SessionRecord`** — enregistrement d'une séance terminée (Codable, persisté dans StatsStore).
- Enums principaux : `SessionDuration`, `AccompanimentMode`, `GongMode`, `AmbientSound`, `ReminderInterval`, `SessionPhase`, `SessionState`.

### Flux de navigation

`SituremApp` → `ContentView` → `HomeView` (lancement) → `SessionView` (séance active) → `SessionSummaryView` (bilan). `StatsView` et `SettingsView` accessibles depuis `HomeView`. La locale SwiftUI suit `PreferencesStore.uiLanguage` au niveau racine, avec priorité `override utilisateur > langue système supportée > anglais`. En V1, `SessionView.handleEnd` tente ensuite l'écriture HealthKit de façon asynchrone et silencieuse, uniquement pour les séances terminées normalement, si le toggle applicatif est actif et si l'autorisation a déjà été accordée depuis `SettingsView`.

## Références produit

- `docs/cahierCharges-v1.md` — spécifications fonctionnelles (source de vérité)
- `docs/BrandingGuideline.md` — identité visuelle, ton, territoire
- `TODO.md` / `PROJECT_STATUS.md` — suivi partagé Claude Code + Codex
