# PROJECT STATUS

## Projet
Siturem — Méditation structurée

## Racine repo
`~/Sites/siturem`

## Dossier code applicatif
`~/Sites/siturem/Siturem`

## État actuel
Base fonctionnelle — UI et logique métier complètes. L'interface est désormais localisée en fr / en-US / es / de avec un switcher persistant dans `SettingsView`, une option `Système`, et une locale SwiftUI appliquée au niveau racine. Règle actuelle : au premier lancement, l'UI suit la langue système / scheme Xcode si elle est supportée (`fr`, `en-US`, `es`, `de`), sinon fallback anglais ; dès qu'un utilisateur choisit explicitement une langue, cet override prend priorité jusqu'à retour sur `Système`. L'audio suit maintenant la langue UI effective si des assets audio existent pour cette langue (`fr`, `en`, `es`), sinon fallback global vers `en`. Si un asset manque dans la langue audio résolue, le resolver tente `en`, puis silence. `de` reste prêt structurellement côté bundle mais n'est pas considéré comme une locale audio disponible. Le séquençage vocal est ordonné, avec gaps configurés et un ancrage de fin de phase pour `intro_08_concentration_souffle`. Intégration HealthKit reste à finaliser pour compléter la V1.

**Refonte visuelle et UX terminée.**
Palette anthracite + accent bleu ardoise, blob animé irrégulièrement, barre de progression (6pt) + contrôles ancrés via `.safeAreaInset`, SettingsView recentrée avec section PRINCIPES, splash animée et renforcée. Système `LayoutMetrics` (φ ≈ 1.618). Logo géométrique (`SituremMark` / `SituremLogo`) décliné sur splash et HomeView.

**Identité projet mise à jour.**
Le bundle identifier Xcode est désormais `com.beabot.siturem` dans `project.yml` et dans le projet généré. Les entitlements et `Info.plist` continuent d'hériter de `$(PRODUCT_BUNDLE_IDENTIFIER)`.

## Fonctionnel

| Composant | État |
|-----------|------|
| Architecture (TabView, navigation) | ✅ Complet |
| SessionEngine (phases, timer, états) | ✅ Complet |
| SessionConfiguration / SessionModels / SessionRecord | ✅ Complet |
| PreferencesStore (UserDefaults) | ✅ Complet |
| StatsStore (persistance + streaks) | ✅ Complet |
| HomeView (sélection durée/modes) | ✅ Sélecteur 6–60 min, 3 options, accompagnement simplifié à `Guidé` / `Silencieux`, logo nav bar, padding φ |
| SessionView (séance en cours) | ✅ Complet |
| SessionSummaryView (bilan) | ✅ Complet |
| StatsView (statistiques) | ✅ Complet |
| SettingsView (préférences système) | ✅ Refondue — sections PRINCIPES + LANGUE (UI), SÉANCE (ReminderInterval), HealthKit + À propos |
| Localisation UI | ✅ fr / en-US / es / de, switcher persistant dans SettingsView avec option `Système`, fallback anglais pour locale non supportée |
| OnboardingView (4 pages, premier lancement) | ✅ Textes refondus et localisés — 4 phrases sobres, délai synchronisé avec nouvelle durée splash |
| AppIcon | ✅ Intégrée — 5 tailles PNG via `scripts/generate-icons.swift`, `Assets.xcassets` correctement référencé |
| HealthKitService (service shell) | ⚠️ Partiel — non intégré au flux |
| AudioService | ✅ Implémenté — gong unique de début/fin, intro/outro vocaux séquencés dans l'ordre avec gaps configurés, reminder phase centrale, ambiance en boucle, pause/reprise, fin de séance, langue audio dérivée de l'UI avec fallback global `en`, silence si assets absents partout |

## Points ouverts

- **Assets audio** : arborescence `Audio/{fr,en,es,de}/...` en place, `Siturem/Audio` déclaré explicitement dans `project.yml`. Les locales audio actuellement traitées comme disponibles sont `fr`, `en`, `es`. `de` reste incomplet côté voix et n'est pas sélectionné automatiquement.
- **Localisation audio** : la langue audio suit désormais la langue UI effective avec fallback global `en`. La séparation d'architecture UI / audio reste conservée ; seule la règle de résolution a changé.
- **HealthKit** : service présent mais non appelé à la fin de séance ; entitlements vides
- **Tests** : aucun test unitaire ou UI en place

## Références locales
- `docs/BrandingGuideline.md` — identité visuelle, ton, territoire
- `docs/cahierCharges-v1.md` — spécifications fonctionnelles complètes (source de vérité)

## Contexte produit
Application iOS minimaliste de méditation structurée pour pratiquants autonomes.

## Positionnement
- sobre
- stable
- structurée
- discrète
- non mystique
- non gamifiée

## Décisions prises
- Nom produit : Siturem
- Sous-titre : Méditation structurée
- Racine de coordination : `~/Sites/siturem`
- Code applicatif SwiftUI : `~/Sites/siturem/Siturem`
- Documentation produit : `docs/`
- Suivi partagé (Claude Code + Codex) : `TODO.md` et `PROJECT_STATUS.md`
- Architecture : SwiftUI + @Observable, iOS 17+, pas de dépendances externes
- Persistance : UserDefaults + JSON (local uniquement pour V1)
- Phases de séance fixes : intro 150 s + méditation variable + closing 45 s
- **Refonte visuelle** : palette anthracite + accent bleu ardoise (pas de noir pur), blob animé en séance à la place du compteur, barre de progression globale (pas par phase)
- **Ajustements récents du layout** : barre de progression centrée avec largeur plafonnée, positionnée plus bas ; blob redimensionné avec canevas et padding internes pour éviter l'effet de bloc carré
- **Refonte SettingsView** : séparation claire entre configuration de séance (HomeView) et préférences système (SettingsView). SettingsView recentrée sur : langue UI, rappels, HealthKit, version. La langue audio n'est pas exposée en réglage dédié à ce stade.
- **Règle de langue UI** : priorité `choix explicite utilisateur > langue système supportée > anglais`. Au premier lancement, aucune langue UI n'est forcée côté app.
- **Accompagnement simplifié** : deux modes seulement, `Guidé` et `Silencieux`. Le mode guidé couvre les consignes intro/outro et les interventions de méditation, dont la fréquence est réglée dans SettingsView.
- **Audio XcodeGen** : `Siturem/Audio` est déclaré explicitement dans `project.yml` pour garantir la présence de la hiérarchie par langue dans le projet généré et dans le bundle
- **Locale audio** : point unique de résolution dans `PreferencesStore`, dérivé de la langue UI effective via `AudioLocale`
- **Fallback audio** : si la langue UI n'a pas d'audio disponible, fallback global vers `en`. Si un asset manque dans la langue résolue, tentative en `en`, puis silence si absent partout
- **Séquençage voix** : intro/outro reposent sur une séquence ordonnée, des gaps configurés et des durées attendues ou mesurées. `intro_08_concentration_souffle` est ancré 5 s avant la fin de l'intro, et le gong initial reste inséré après `intro_01_bonjour`.
- **Bundle identifier** : migration vers `com.beabot.siturem`

## Prochain focus
Déposer et valider les assets vocaux `fr`, puis alimenter `en` / `es` / `de` selon la matrice de disponibilité audio. Intégrer ensuite `HealthKitService` au flux de fin de séance.
