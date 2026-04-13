# Siturem

App iOS minimaliste de méditation structurée pour pratiquants autonomes.

## Stack
- SwiftUI + @Observable
- iOS 17+, Swift 5.10
- HealthKit (écriture séances)
- XcodeGen (génération .xcodeproj)

## Démarrage rapide

```bash
# Générer le projet Xcode
cd /Users/benoitabot/Sites/siturem
xcodegen generate

# Ouvrir dans Xcode
open Siturem.xcodeproj
```

## Structure
```
Siturem/
├── App/          Point d'entrée (@main)
├── Models/       Types de données (enums, structs)
├── Views/        Vues SwiftUI
├── Services/     Logique métier (SessionEngine, AudioService, StatsStore, PreferencesStore, HealthKitService)
├── Audio/        Assets audio
│   ├── fr/             Locale audio par défaut
│   │   ├── Gongs/          gong.caf
│   │   ├── Ambiance/       rain-loop, river-loop, forest-loop, white-noise-loop (.m4a ou .caf)
│   │   └── VoiceGuidance/  Consignes vocales séquencées
│   │       ├── Intro/      Séquence ordonnée de l'intro, gong après Bonjour, dernier clip ancré 5 s avant la fin
│   │       ├── Reminders/  Rappels discrets phase centrale
│   │       └── Outro/      Séquence ordonnée du retour, puis silence jusqu'à la fin réelle
│   ├── en/             Structure prête pour les assets localisés
│   ├── es/             Structure prête pour les assets localisés
│   └── de/             Structure prête pour les assets localisés
└── Resources/    Assets.xcassets
```

## Documentation
- `docs/BrandingGuideline.md` — Identité, ton, territoire visuel
- `docs/cahierCharges-v1.md`  — Spécifications produit complètes
- `TODO.md`                   — Tâches actionnables
- `PROJECT_STATUS.md`         — État du projet, décisions, points ouverts
