# TODO

## Refonte visuelle et UX (en cours)

### ~~Étape 1 — Palette & thème~~ ✅

`Siturem/Views/Theme.swift` créé. Palette : anthracite `#181820`, surface `#222229`, accent bleu ardoise `#6E7FA3`, blanc cassé `#F0EDE8`. Appliqué dans toutes les vues.

### ~~Étape 2 — BlobView (composant autonome)~~ ✅

`Siturem/Views/BlobView.swift` créé. 3 ellipses superposées, animation `repeatForever easeInOut`, durée modulée par phase (intro 5 s, méditation 7,5 s, closing 3,5 s). Redémarre proprement au changement de phase via `.id(animationKey)`.

### ~~Étape 3 — SessionView refonte~~ ✅

Compteur numérique supprimé. `BlobView` au centre. Barre de progression globale fine (3pt) en bas, calculée sur `totalElapsed / totalDuration`. Label de phase discret en haut. Contrôles inchangés.

### ~~Étape 4 — Refonte SettingsView (préférences système)~~ ✅

Section "SÉANCE PAR DÉFAUT" retirée. `SettingsView` conservée avec : Santé (HealthKit), À propos (version). Placeholders commentés pour interface/voix/langue à venir.

### ~~Étape 5 — Build & vérification~~ ✅

`xcodegen generate` + BUILD SUCCEEDED (iPhone 16 simulator, iOS 18.6).

---

## Critique (V1 bloquée)

- [x] Arborescence audio : créer `Audio/{Gongs,Ambiance,VoiceGuidance/{Intro,Reminders,Outro}}`
- [ ] Déposer les fichiers audio (.caf) dans `Audio/` et les ajouter au target Xcode
- [ ] AudioService : gong aux transitions de phase (GongMode → début, fin, inter-phases)
- [ ] AudioService : ambiance sonore en boucle (AmbientSound)
- [ ] Rappels périodiques phase méditation (ReminderInterval → SessionEngine)
- [ ] Intégrer HealthKit au flux de fin de séance (`SessionView.handleEnd` → `HealthKitService.save`)
- [ ] Activer entitlement HealthKit dans `Siturem/Siturem.entitlements`

## Important

- [ ] Mode "Guidé léger" : guidance audio pour phases intro et closing
- [ ] Haptics légers aux transitions de phase
- [ ] Test end-to-end des flux utilisateur (simulateur Xcode)

## Souhaitable

- [ ] Vérification accessibilité VoiceOver
- [ ] Icône app finale (AppIcon dans Assets.xcassets)
