# TODO

## Localisation UI V1 ✅

Phase dédiée à la localisation de l'interface uniquement. La langue audio reste hors scope pour ce ticket et conserve sa matrice propre.

### Étape 1 — Cartographie i18n

- [x] Externaliser toutes les chaînes utilisateur visibles dans les vues SwiftUI et les textes exposés par les enums utilisés par l'UI.
- [x] Normaliser les clés / ressources de traduction par écran et par domaine.
- [x] Vérifier les chaînes dans l'onboarding, le splash, l'accueil, la séance, le bilan, les statistiques, les réglages et les messages d'erreur.

### Étape 2 — Langue UI

- [x] Ajouter un réglage persistant de langue d'interface dans `PreferencesStore`.
- [x] Appliquer la langue UI au niveau racine de l'app SwiftUI.
- [x] Ajouter le sélecteur de langue UI dans `SettingsView` avec les choix Français, English (US), Español et Deutsch.

### Étape 3 — Ressources localisées

- [x] Ajouter les ressources de traduction fr, en-US, es et de pour l'interface.
- [x] Ajouter les chaînes de permissions système nécessaires pour HealthKit.
- [x] Vérifier que les labels d'interface restent séparés des noms de fichiers audio et de la future langue audio.

### Étape 4 — Validation

- [x] Régénérer le projet si nécessaire avec `xcodegen generate`.
- [x] Recompiler l'app et corriger toute régression de signature ou de localisation.
- [x] Mettre à jour `PROJECT_STATUS.md` et les autres notes partagées une fois l'état final stabilisé.
- [x] Corriger la règle de premier lancement : aucun défaut UI interne forcé, priorité `override utilisateur > système supporté > anglais`.

## Refonte visuelle et UX (en cours)

### ~~Étape 1 — Palette & thème~~ ✅

`Siturem/Views/Theme.swift` créé. Palette : anthracite `#181820`, surface `#222229`, accent bleu ardoise `#6E7FA3`, blanc cassé `#F0EDE8`. Appliqué dans toutes les vues.

### ~~Étape 2 — BlobView (composant autonome)~~ ✅

`Siturem/Views/BlobView.swift` créé. 3 ellipses + 5 états indépendants (scale×3 + offset×2), chacun animé à durée incommensurable (×1.00, ×1.37, ×0.79, ×1.19, ×0.91) pour mouvement organique irrégulier jamais périodique. Redémarre au changement de phase.

### ~~Étape 3 — SessionView refonte~~ ✅

Compteur numérique supprimé. `BlobView` centré verticalement (`.frame(maxHeight: .infinity)`). Barre de progression (5pt, opacité 0.80) + contrôles groupés en bas (padding 72pt via nombre d'or). Label de phase discret en haut. Progression globale `totalElapsed / totalDuration`. Mise en page basée sur φ ≈ 1.618.

### ~~Étape 3b — Ajustements visuels fins~~ ✅

`SessionView` : barre de progression abaissée et recentrée horizontalement avec largeur plafonnée, contrôles conservés à leur position validée visuellement.
`BlobView` : halo rendu sur un canevas plus large avec padding interne pour éviter l'effet de bloc carré et garder le blob lisible dans son espace.

### ~~Étape 4 — Refonte SettingsView (préférences système)~~ ✅

Section "SÉANCE PAR DÉFAUT" retirée. `SettingsView` conservée avec : Santé (HealthKit), À propos (version). Placeholders commentés pour interface/voix/langue à venir.

### ~~Étape 5 — Build & vérification~~ ✅

`xcodegen generate` + BUILD SUCCEEDED (iPhone 16 simulator, iOS 18.6).

### ~~Ajout système Layout (nombre d'or)~~ ✅

`LayoutMetrics.swift` créé avec constantes basées sur φ ≈ 1.618 :
- Base : 40 pt
- Small : 40 / φ ≈ 24.7 pt
- Large : 40 × φ ≈ 64.7 pt
- X-Large : 40 × φ² ≈ 104.7 pt
- Safe area bottom : 24.7 pt

`SessionView` refactorisée :
- `.safeAreaInset(edge: .bottom)` pour ancrer barre + contrôles physiquement au-dessus du home indicator
- Blob remplit l'espace restant, centré verticalement
- Barre de progression épaissie à 6pt
- Tous les espacements appliquent φ (phaseTopOffset, progressToControlsSpacing, hPadding)

### ~~Logo Siturem (SituremMark + SituremLogo)~~ ✅

`SituremMark.swift` créé : 3 capsules horizontales gauche-alignées, largeurs proportionnelles aux phases (intro 55%, méditation 100%, closing 30%), opacités 70/100/45%. Scalable, 2 déclinaisons via `SituremLogo(layout:)` :
- `.vertical` (splash) : mark + wordmark + sous-titre
- `.horizontal` (nav bar) : mark + wordmark côte à côte

`SplashView` : logo vertical taille 56, aligné à gauche, tagline animée.
`HomeView` : grand titre remplacé par `SituremLogo(layout: .horizontal, markSize: 18)` en `.principal` toolbar.

### ~~Retrait Rappels + Splash agrandie~~ ✅

`HomeView` : option "Rappels" retirée (fonctionnalité non encore implémentée). 3 options restantes : Accompagnement, Gong, Ambiance.
`SplashView` : tagline passée en `.subheadline`, animations allongées (0.8 s, délai 1.1 s).

### ~~HomeView : sélecteur de durée 6–60 min + padding φ~~ ✅

`HomeView` : chips fixes remplacées par un bloc durée avec valeur grande (ultraLight monospaced) + wheel picker compact (6–60 min, pas de 1 min) persisté dans `prefs.totalDuration`. Padding uniformisé via `LayoutMetrics` (horizontal 40 pt, rangées options 24.7 pt).

### ~~Splash renforcée + SettingsView Principes~~ ✅

`SplashView` : fond anthracite (Theme), animation séquencée (titre 0.7 s → baseline après 0.9 s), durée totale 3.4 s (était 2.1 s). Baseline : "Le cadre discret de votre pratique."

`SettingsView` : section PRINCIPES ajoutée — 4 entrées : Trois phases fixes, Pour qui, Philosophie, Durée minimale.

`HomeView` : padding bas du bouton "Commencer" porté à LayoutMetrics.sm (24.7 pt, φ).

### ~~Onboarding 4 pages (premier lancement)~~ ✅

### ~~Transition splash → HomeView (fondu enchaîné)~~ ✅

`SituremApp` : remplacement du `if showSplash { .transition(.opacity) }` par deux `opacity` explicites animées en parallèle (`splashOpacity` 1→0, `contentOpacity` 0→1). Fondu enchaîné propre, sans saut de frame. `.allowsHitTesting` désactivé sur la splash une fois invisible.

### ~~Icône app (AppIcon)~~ ✅

`scripts/generate-icons.swift` : script CoreGraphics standalone générant 5 tailles PNG (120/152/167/180/1024 px). Motif SituremMark centré sur fond anthracite `#181820`, capsules bleu ardoise `#6E7FA3`. `Contents.json` mis à jour par Xcode avec les tailles standard iOS.
`project.yml` : correction — suppression du pattern `excludes/resources` cassé ; `Assets.xcassets` maintenant auto-détecté par xcodegen lors du scan `Siturem/`.

### ~~Splash, Onboarding, Réglages — refonte textes et timing~~ ✅

`SplashView` : markSize 80→96, baseline `.body` weight `.light`, opacité 0.85, animations allongées (0.9 s, délai 1.2 s). Durée totale splash : 4.5 s + fade 0.8 s.
`SituremApp` : `asyncAfter` 2.8 s → 4.5 s, fade 0.6 s → 0.8 s.
`OnboardingView` : textes des 4 pages remplacés par le contenu sobre et direct prévu produit. Délai synchronisé sur 5.0 s. Pages 1–3 : phrases épurées, sans titre. Page 4 : dernière phrase + bouton COMMENCER.
`SettingsView` : section SÉANCE ajoutée avec `Picker` segmenté pour `ReminderInterval` (Aucune / Occasionnelles / Fréquentes).
`SessionModels` : `ReminderInterval.settingsLabel` ajouté pour les labels sobres en réglages.

`Siturem/Views/Onboarding/OnboardingView.swift` créé. 4 pages swipeables (TabView `.page`) :
- Page 1 — Identité : "SITUREM" + "Méditation structurée", animation 3.2 s (synchronisée avec splash)
- Page 2 — Promesse : titre + 3 étapes numérotées avec tiret accent, révélation décalée
- Page 3 — Structure : titre + 3 barres de phase proportionnelles (GeometryReader) + labels
- Page 4 — Commencer : titre + sous-titre + bouton "COMMENCER"
Bouton "Continuer" discret (pages 0–2). `@AppStorage("siturem.onboardingCompleted")` dans `ContentView` — affiché une seule fois.

---

## Critique (V1 bloquée)

- [x] Migrer l'arborescence audio vers `Audio/{fr,en,es,de}/{Gongs,Ambiance,VoiceGuidance/{Intro,Reminders,Outro}}`
- [x] Déclarer `Siturem/Audio` explicitement dans `project.yml` pour embarquer la hiérarchie localisée
- [x] Centraliser la résolution des assets audio par `AudioLocale` avec fallback global `en`
- [x] Raccorder automatiquement la langue audio à la langue UI effective, sans réglage audio séparé pour cette phase
- [x] Déposer les fichiers audio (.caf/.m4a) disponibles dans `Audio/fr/` et les ajouter au target Xcode
- [x] AudioService : gong unique en bornes de séance (`gong.caf` après `intro_01_bonjour`, puis à la fin réelle)
- [x] AudioService : ambiance sonore en boucle (AmbientSound)
- [x] AudioService : intro/outro vocaux minutés avec déclenchement par franchissement de seuil
- [x] AudioService : séquençage vocal ordonné (clips dans l'ordre, gaps configurés, `intro_07_scan_corporel` inclus, `intro_08_concentration_souffle` ancré 5 s avant la fin de l'intro)
- [x] Rappels périodiques phase méditation (`ReminderInterval` géré côté `AudioService`, hors `SessionEngine`)
- [ ] Déposer les assets vocaux `fr` dans `Audio/fr/VoiceGuidance/{Intro,Reminders,Outro}`
- [ ] Déposer les assets localisés `en`, `es`, `de` selon la matrice UI/audio
- [ ] Intégrer HealthKit au flux de fin de séance (`SessionView.handleEnd` → `HealthKitService.save`)
- [ ] Activer entitlement HealthKit dans `Siturem/Siturem.entitlements`

## Important

- [x] Accompagnement simplifié : `Guidé` / `Silencieux`, avec guidance audio active en mode guidé
- [ ] Haptics légers aux transitions de phase
- [ ] Test end-to-end des flux utilisateur (simulateur Xcode)

## Souhaitable

- [ ] Vérification accessibilité VoiceOver
- [x] Icône app finale (AppIcon dans Assets.xcassets)

## Dernière livraison

- [x] `AudioService.swift` corrigé : séquençage strict sans chevauchement, intro FR complète avec `intro_07_scan_corporel`, `intro_04_fermer_les_yeux` décalé de +3 s, closing guidé avec longues pauses et gong final inclus
- [x] `AudioAsset.swift` étendu : résolution centralisée par `AudioLocale` et `AudioAssetGroup`, audio dérivé de la langue UI, fallback global `en`, IDs techniques inchangés
- [x] `SessionConfiguration.swift` aligné sur une phase de closing fixe à `92 s` pour couvrir la séquence réelle de fin de séance
- [x] `SessionView.swift` branchée sur `startSessionAudio`, `handleTick`, `handlePhaseChange`, `handleSessionEnd`, `pauseAll`, `resumeAll`, `stopAll`
- [x] `project.yml` mis à jour pour intégrer `Siturem/Audio` comme folder resource et préserver `Audio/<locale>/...` dans le bundle
- [x] Arborescence `Siturem/Audio/` réorganisée en `fr`, `en`, `es`, `de` avec placeholders sur les dossiers non alimentés
- [x] `project.yml` et le projet généré alignés sur le bundle identifier `com.beabot.siturem`
- [x] `SessionView` et `BlobView` ajustés visuellement pour le layout final
- [x] `xcodegen generate`
- [x] Build simulateur revalidé (`xcodebuild ... -destination 'id=9C12A4F4-26F1-45EA-B40A-E54537DE73B1' build`)
