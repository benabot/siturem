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
│   ├── Gongs/          gong.caf
│   ├── Ambiance/       rain-loop, river-loop, forest-loop, white-noise-loop (.m4a ou .caf)
│   └── VoiceGuidance/  Consignes vocales minutées
│       ├── Intro/      Segments phase intro (2m30)
│       ├── Reminders/  Rappels discrets phase centrale
│       └── Outro/      Segments phase retour (45s)
└── Resources/    Assets.xcassets
```

## Documentation
- `docs/BrandingGuideline.md` — Identité, ton, territoire visuel
- `docs/cahierCharges-v1.md`  — Spécifications produit complètes
- `TODO.md`                   — Tâches actionnables
- `PROJECT_STATUS.md`         — État du projet, décisions, points ouverts
