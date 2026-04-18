# PROJECT STATUS

## Projet
Siturem — Méditation structurée

## Racine repo
`~/Sites/siturem`

## Dossier code applicatif
`~/Sites/siturem/Siturem`

## État actuel
Base fonctionnelle — UI et logique métier complètes. L'interface est désormais localisée en fr / en-US / es / de avec un switcher persistant dans `SettingsView`, une option `Système`, et une locale SwiftUI appliquée au niveau racine. Règle actuelle : au premier lancement, l'UI suit la langue système / scheme Xcode si elle est supportée (`fr`, `en-US`, `es`, `de`), sinon fallback anglais ; dès qu'un utilisateur choisit explicitement une langue, cet override prend priorité jusqu'à retour sur `Système`. L'audio suit maintenant la langue UI effective si des assets audio existent pour cette langue (`fr`, `en`, `es`), sinon fallback global vers `en`. Si un asset manque dans la langue audio résolue, le resolver tente `en`, puis silence. `de` reste prêt structurellement côté bundle mais n'est pas considéré comme une locale audio disponible. Le séquençage vocal est ordonné, avec gaps configurés, une intro FR complète incluant `intro_07_scan_corporel`, un gap renforcé entre `intro_05_points_de_contact` et `intro_06_conscience_environnement`, et un ancrage de fin de phase durci pour `intro_08_concentration_souffle`. Le mix ambiance / voix a été abaissé et le ducking renforcé, avec un profil plus discret pour la pluie afin de rendre sa boucle moins perceptible. La phase de closing a été portée à `92 s` pour couvrir la séquence réelle de retour avec gong final. L'intégration HealthKit V1 est maintenant branchée au flux de fin de séance, avec écriture silencieuse uniquement pour les séances terminées normalement et permission contextualisée depuis `SettingsView`.

**V1.1 validée côté app / intégration / périmètre.**
La réserve restante porte sur certains sons d’ambiance qui doivent être refaits côté assets pour obtenir un rendu plus propre. Cette réserve n’invalide pas le périmètre fonctionnel V1.1.

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
| SettingsView (préférences système) | ✅ Refondue — sections PRINCIPES + LANGUE (UI), SÉANCE (ReminderInterval aligné sur ses vraies cadences 1m30 / 2m30), HealthKit + À propos |
| Localisation UI | ✅ fr / en-US / es / de, switcher persistant dans SettingsView avec option `Système`, fallback anglais pour locale non supportée |
| OnboardingView (4 pages, premier lancement) | ✅ Textes refondus et localisés — 4 phrases sobres, délai synchronisé avec nouvelle durée splash |
| AppIcon | ✅ Intégrée — 5 tailles PNG via `scripts/generate-icons.swift`, `Assets.xcassets` correctement référencé |
| HealthKitService | ✅ Intégré — état d'autorisation explicite, demande contextuelle, écriture silencieuse en fin de séance |
| AudioService | ✅ Implémenté — intro/outro vocaux séquencés dans l'ordre avec gaps configurés, intro FR complète, closing long avec gong final intégré à la séquence guidée, reminder phase centrale robuste par bucket, voix guidée poussée devant une ambiance légèrement remontée avec ducking renforcé, pause/reprise, langue audio dérivée de l'UI avec fallback global `en`, silence si assets absents partout |

## Points ouverts

- **Assets audio** : arborescence `Audio/{fr,en,es,de}/...` en place, `Siturem/Audio` déclaré explicitement dans `project.yml`. Les locales audio actuellement traitées comme disponibles sont `fr`, `en`, `es`. `de` reste incomplet côté voix et n'est pas sélectionné automatiquement.
- **Réserve qualité V1.1** : certains sons d’ambiance doivent encore être refaits puis redéposés côté assets. Cette réserve reste limitée à la qualité finale des fichiers et ne remet pas en cause la validation fonctionnelle de la V1.1.
- **Localisation audio** : la langue audio suit désormais la langue UI effective avec fallback global `en`. La séparation d'architecture UI / audio reste conservée ; seule la règle de résolution a changé.
- **HealthKit** : synchro V1 optionnelle activée côté app. Permission demandée seulement depuis `SettingsView`. Écriture tentée uniquement pour les séances terminées normalement ; refus, indisponibilité et échec restent silencieux et non bloquants
- **Tests** : aucun test unitaire ou UI en place

## Références locales
- `docs/BrandingGuideline.md` — identité visuelle, ton, territoire
- `docs/cahierCharges-v1.md` — spécifications fonctionnelles complètes (source de vérité)
- `docs/2026-04-16-siturem-v2-backlog.md` — backlog V2 priorisé écran par écran

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
- Phases de séance fixes : intro 150 s + méditation variable + closing 92 s
- **Refonte visuelle** : palette anthracite + accent bleu ardoise (pas de noir pur), blob animé en séance à la place du compteur, barre de progression globale (pas par phase)
- **Ajustements récents du layout** : barre de progression centrée avec largeur plafonnée, remontée pour conserver une respiration nette au-dessus des contrôles ; blob redimensionné avec canevas et padding internes élargis, sans rasterisation contrainte, pour éviter l'effet de bloc carré ou de cadre visible
- **Refonte SettingsView** : séparation claire entre configuration de séance (HomeView) et préférences système (SettingsView). SettingsView recentrée sur : langue UI, rappels, HealthKit, version. La langue audio n'est pas exposée en réglage dédié à ce stade.
- **HealthKit V1** : le toggle `PreferencesStore.healthKitEnabled` est le garde-fou applicatif. `SessionView.handleEnd` tente l'écriture après persistance locale et affichage du bilan, sans bloquer l'UX et sans logique HealthKit dans `SessionEngine`
- **Règle de langue UI** : priorité `choix explicite utilisateur > langue système supportée > anglais`. Au premier lancement, aucune langue UI n'est forcée côté app.
- **Accompagnement simplifié** : deux modes seulement, `Guidé` et `Silencieux`. Le mode guidé couvre les consignes intro/outro et les interventions de méditation, dont la fréquence est réglée dans SettingsView.
- **Audio XcodeGen** : `Siturem/Audio` est déclaré explicitement dans `project.yml` pour garantir la présence de la hiérarchie par langue dans le projet généré et dans le bundle
- **Locale audio** : point unique de résolution dans `PreferencesStore`, dérivé de la langue UI effective via `AudioLocale`
- **Fallback audio** : si la langue UI n'a pas d'audio disponible, fallback global vers `en`. Si un asset manque dans la langue résolue, tentative en `en`, puis silence si absent partout
- **Séquençage voix** : intro/outro reposent sur une séquence ordonnée, des gaps configurés et des durées attendues ou mesurées. `intro_07_scan_corporel` est réintégré à l'intro FR, `intro_04_fermer_les_yeux` démarre 3 s plus tard qu'avant, le gap `intro_05 -> intro_06` est élargi à 10 s, `intro_08_concentration_souffle` reste ancré 5 s avant la fin de l'intro avec rattrapage si la frontière de phase approche, et le gong final fait désormais partie de la séquence de closing guidée.
- **Mix audio** : l'ambiance reste volontairement secondaire face à la voix, avec une voix guidée poussée au premier plan, un niveau de base légèrement remonté mais toujours bas, un ducking plus marqué pendant les interventions, une remontée plus douce ensuite, et un profil pluie un peu plus présent tout en restant discret.
- **Rappels guidés** : les libellés de réglage sont alignés sur leur cadence réelle, avec `Occasionnelles = 2m30` et `Fréquentes = 1m30`
- **Bundle identifier** : migration vers `com.beabot.siturem`
- **Validation V1.1** : la V1.1 est considérée comme validée côté app / intégration / périmètre ; la seule réserve explicitement maintenue concerne la qualité finale de certains assets d’ambiance

## Arbitrage V2

### V2.0 strict
- `HomeView` recentrée sur le lancement immédiat, les réglages rapides et la relance de la dernière configuration
- `SessionView` plus discrète avec temps et progression masquables, contrôles stables
- `SessionSummaryView` plus sobre et plus utile, orientée clôture et relance simple
- `StatsView` recentrée sur une vue essentielle de registre de pratique
- `SettingsView` limitée aux préférences durables directement utiles à ces flux

### V2.1+
- cadres de pratique complets (`PracticeFrame`, CRUD, favoris, cadres natifs)
- stats avancées (`heatmap`, détail de séance, agrégations étendues, export CSV)
- haptics légers, widgets, deep links, rappels opt-in
- monétisation sobre, stats par cadre, Siri Shortcuts / App Intents

## Prochain focus
`[S1] Docs — figer le périmètre V2.0 strict`

- relire le backlog V2 et les docs de pilotage déjà présentes
- distinguer clairement **V2.0 strict** et **V2.1+**
- ne garder que les chantiers réellement essentiels pour un dev solo
- figer un ordre de livraison simple, séquentiel et incrémental
