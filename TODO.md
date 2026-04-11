# TODO

## Refonte visuelle et UX (en cours)

### ~~Étape 1 — Palette & thème~~ ✅

`Siturem/Views/Theme.swift` créé. Palette : anthracite `#181820`, surface `#222229`, accent bleu ardoise `#6E7FA3`, blanc cassé `#F0EDE8`. Appliqué dans toutes les vues.

### ~~Étape 2 — BlobView (composant autonome)~~ ✅

`Siturem/Views/BlobView.swift` créé. 3 ellipses + 5 états indépendants (scale×3 + offset×2), chacun animé à durée incommensurable (×1.00, ×1.37, ×0.79, ×1.19, ×0.91) pour mouvement organique irrégulier jamais périodique. Redémarre au changement de phase.

### ~~Étape 3 — SessionView refonte~~ ✅

Compteur numérique supprimé. `BlobView` centré verticalement (`.frame(maxHeight: .infinity)`). Barre de progression (5pt, opacité 0.80) + contrôles groupés en bas (padding 72pt via nombre d'or). Label de phase discret en haut. Progression globale `totalElapsed / totalDuration`. Mise en page basée sur φ ≈ 1.618.

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
