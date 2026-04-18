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
│   │       └── Outro/      Séquence ordonnée du retour avec longues pauses et gong final inclus
│   ├── en/             Structure prête pour les assets localisés
│   ├── es/             Structure prête pour les assets localisés
│   └── de/             Structure prête pour les assets localisés
└── Resources/    Assets.xcassets + localisation UI (`Localization/*.lproj`)
```

## Documentation
- `docs/BrandingGuideline.md` — Identité, ton, territoire visuel
- `docs/cahierCharges-v1.md`  — Spécifications produit complètes
- `docs/2026-04-16-siturem-v2-backlog.md` — backlog V2 priorisé écran par écran, document de référence pour la prochaine phase produit
- `TODO.md`                   — Tâches actionnables
- `PROJECT_STATUS.md`         — État du projet, décisions, points ouverts

## Localisation UI
- Langues UI supportées : `fr`, `en-US`, `es`, `de`
- Au premier lancement, l'interface suit la langue système si elle est supportée, sinon fallback `en-US`
- Un choix explicite dans `Réglages > Langue` prend priorité jusqu'au retour sur `Système`
- La langue UI reste distincte de la langue audio sur le plan architectural, mais l'audio suit désormais la langue UI effective quand des assets existent en `fr`, `en` ou `es`, sinon fallback global `en`

## Audio guidé
- `AudioService` orchestre le séquençage des clips vocaux, le ducking d'ambiance et les rappels, sans déplacer cette logique dans `SessionEngine`
- L'intro guidée FR est jouée dans l'ordre des clips, avec gaps configurés, respiration élargie entre `intro_05_points_de_contact` et `intro_06_conscience_environnement`, et `intro_08_concentration_souffle` maintenu 5 s avant la fin d'intro
- Les rappels restent limités à la phase de méditation guidée, sur paliers d'intervalle, avec reprise correcte après pause
- L'ambiance reste sous la voix, avec un profil pluie plus discret pour rendre la jointure moins perceptible

## HealthKit V1
- Synchronisation optionnelle activée côté app depuis `Réglages`
- Demande d'autorisation contextualisée dans `SettingsView`, jamais au premier lancement
- Écriture tentée silencieusement uniquement pour les séances terminées normalement
- Refus, indisponibilité ou échec d'écriture ne bloquent ni la séance locale ni l'affichage du bilan
