# TODO

## Refonte visuelle et UX (en cours)

### Étape 1 — Palette & thème

- [ ] Créer `Siturem/Views/Theme.swift` avec les couleurs centralisées :
  - fond principal : anthracite profond (`~#1A1A2E` ou similaire, pas de noir pur)
  - fond secondaire : gris minéral plus clair (`~#252540`)
  - accent : bleu ardoise désaturé (`~#5C6B8A`) — unique couleur vive
  - texte principal : blanc cassé (`~#F0EDE8`)
  - texte secondaire : gris clair froid
- [ ] Remplacer `Color.black` et `Color(white: 0.08)` dans toutes les vues (`HomeView`, `SessionView`, `SessionSummaryView`, `StatsView`, `ContentView`) par les couleurs du thème
- [ ] Ajuster les `.tint`, `.foregroundStyle`, `.toolbarBackground` pour utiliser la palette

### Étape 2 — BlobView (composant autonome)

- [ ] Créer `Siturem/Views/Components/BlobView.swift`
  - Forme organique : superposition de 2–3 cercles/ellipses avec offsets animés
  - Animation `.easeInOut` en boucle (`repeatForever`), durée longue (~4–6 s) pour un effet de respiration
  - La couleur d'accent teinte subtilement le blob
  - Paramètre `phase: SessionPhase` pour moduler le rythme :
    - intro : mouvement lent, amplitude réduite
    - meditation : mouvement très lent, presque immobile
    - closing : mouvement qui s'élargit doucement
  - Paramètre `isRunning: Bool` pour figer le blob en pause

### Étape 3 — SessionView refonte

- [ ] Retirer `timerDisplay` (compteur `72pt` + compteur total) — plus aucun chiffre visible
- [ ] Intégrer `BlobView` au centre de l'écran, alimenté par `engine.currentPhase` et `engine.state`
- [ ] Ajouter une barre de progression horizontale fine en bas de l'écran :
  - Progression = `engine.totalElapsed / engine.config.totalDuration` (séance entière, pas par phase)
  - Couleur accent, hauteur ~3pt, coins arrondis
  - Animation fluide (`.linear` sur la progression)
- [ ] Garder `phaseLabel` discret (nom de la phase en cours, petit, en haut)
- [ ] Garder les contrôles pause/stop existants
- [ ] Appliquer les couleurs du thème au fond et aux contrôles

### Étape 4 — Refonte SettingsView (préférences système)

Principe : HomeView = configuration d'une séance. SettingsView = préférences de l'app.

- [ ] Retirer de `SettingsView` la section "SÉANCE PAR DÉFAUT" (accompagnement, gong, ambiance, rappels) — ces options sont déjà dans HomeView et la duplication est source de confusion
- [ ] Conserver dans `SettingsView` :
  - **Santé** : Toggle HealthKit + bouton d'autorisation (inchangé)
  - **Interface** : sélecteur de couleur d'accent (prévu pour plus tard — laisser un placeholder commenté)
  - **À propos** : version de l'app
- [ ] Prévoir les sections vides ou commentées pour les futurs réglages : voix, langue, couleur d'accent
- [ ] Garder l'onglet "Réglages" dans le `TabView` (ContentView inchangé côté navigation)
- [ ] Supprimer `prefs.accompaniment/gong/ambient/reminder` des bindings dans `SettingsView` si inutilisés après retrait

### Étape 5 — Build & vérification

- [ ] `xcodegen generate` (nouveau fichier `Theme.swift` + `BlobView.swift` ajoutés, `SettingsView.swift` supprimé)
- [ ] Build simulateur : `xcodebuild -project Siturem.xcodeproj -scheme Siturem -destination 'platform=iOS Simulator,name=iPhone 16' build`
- [ ] Vérification visuelle : palette cohérente, blob fluide, progression correcte, sheet réglages fonctionnel

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
