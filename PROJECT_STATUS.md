# PROJECT STATUS

## Projet
Siturem — Méditation structurée

## Racine repo
`~/Sites/siturem`

## Dossier code applicatif
`~/Sites/siturem/Siturem`

## État actuel
Base fonctionnelle — UI et logique métier complètes. L'interface est désormais localisée en fr / en-US / es / de avec un switcher persistant dans `SettingsView`, une option `Système`, et une locale SwiftUI appliquée au niveau racine. Règle actuelle : au premier lancement, l'UI suit la langue système / scheme Xcode si elle est supportée (`fr`, `en-US`, `es`, `de`), sinon fallback anglais ; dès qu'un utilisateur choisit explicitement une langue, cet override prend priorité jusqu'à retour sur `Système`. L'audio suit maintenant la langue UI effective si des assets audio existent pour cette langue (`fr`, `en`, `es`), sinon fallback global vers `en`. Les assets partagés (`gong`, ambiances) sont désormais résolus depuis `Audio/Shared`, tandis que `VoiceGuidance` reste localisée par langue. Si un asset vocal manque dans la langue audio résolue, le resolver tente `en`, puis silence. `de` reste prêt structurellement côté bundle mais n'est pas considéré comme une locale audio disponible. Le séquençage vocal est ordonné, avec gaps configurés, une intro FR complète incluant `intro_07_scan_corporel`, un gap renforcé entre `intro_05_points_de_contact` et `intro_06_conscience_environnement`, et un ancrage de fin de phase durci pour `intro_08_concentration_souffle`. Le mix ambiance / voix a été abaissé et le ducking renforcé, avec un profil plus discret pour la pluie afin de rendre sa boucle moins perceptible. La phase de closing a été portée à `92 s` pour couvrir la séquence réelle de retour avec gong final. L'intégration HealthKit V1 est maintenant branchée au flux de fin de séance, avec écriture silencieuse uniquement pour les séances terminées normalement et permission contextualisée depuis `SettingsView`. Le socle V2 introduit maintenant `PracticeFrame` comme façade nommée au-dessus de `SessionConfiguration`, sans modifier le flux `HomeView` → `SessionView` → `SessionSummaryView`.

**V1.2 livrée.**
La V1.2 clôture les dernières réserves `V1.x` : sons d’ambiance repris et revalidés, packs audio localisés bornés clairement, haptics de transition discrets en place, et flux complet revalidé. La réserve qualité précédemment maintenue sur certaines ambiances est levée.

**Refonte visuelle et UX terminée.**
Palette anthracite + accent bleu ardoise, blob animé irrégulièrement, barre de progression (6pt) + contrôles ancrés via `.safeAreaInset`, SettingsView recentrée avec section PRINCIPES, splash animée et renforcée. Système `LayoutMetrics` (φ ≈ 1.618). Logo géométrique (`SituremMark` / `SituremLogo`) décliné sur splash et HomeView.

**Identité projet mise à jour.**
Le bundle identifier Xcode est désormais `fr.beabot.siturem` dans `project.yml` et dans le projet généré. Les entitlements et `Info.plist` continuent d'hériter de `$(PRODUCT_BUNDLE_IDENTIFIER)`.

## Fonctionnel

| Composant | État |
|-----------|------|
| Architecture (TabView, navigation) | ✅ Complet |
| SessionEngine (phases, timer, états) | ✅ Complet |
| SessionConfiguration / SessionModels / SessionRecord | ✅ Complet |
| PracticeFrame | ✅ Introduit — façade nommée sur `SessionConfiguration`, persistée via `PracticeFrameStore` |
| PracticeFrameStore | ✅ Stable — persistance locale `UserDefaults + JSON`, CRUD, dernier cadre utilisé, favoris, ordre d'affichage et chargement tolérant aux états partiels |
| PreferencesStore (UserDefaults) | ✅ Complet |
| StatsStore (persistance + streaks) | ✅ Complet |
| HomeView (sélection durée/modes) | ✅ Sélecteur 6–60 min, 3 options, accompagnement simplifié à `Guidé` / `Silencieux`, logo nav bar, padding φ |
| SessionView (séance en cours) | ✅ Complet |
| SessionSummaryView (bilan) | ✅ Sobre et utile — durée réalisée, cumul aujourd'hui, relance simple |
| StatsView (statistiques) | ✅ Registre essentiel + repères mensuels / hebdo + heatmap 90 jours + détail de séance |
| SettingsView (préférences système) | ✅ Refondue — sections PRINCIPES + INTERFACE (langue UI), SÉANCE (rappels, progression, haptics), HealthKit + À propos |
| Localisation UI | ✅ fr / en-US / es / de, switcher persistant dans SettingsView avec option `Système`, fallback anglais pour locale non supportée |
| OnboardingView (4 pages, premier lancement) | ✅ Textes refondus et localisés — 4 phrases sobres, délai synchronisé avec nouvelle durée splash |
| AppIcon | ✅ Intégrée — 5 tailles PNG via `scripts/generate-icons.swift`, `Assets.xcassets` correctement référencé |
| HealthKitService | ✅ Intégré — état d'autorisation explicite, demande contextuelle, écriture silencieuse en fin de séance |
| AudioService | ✅ Implémenté — intro/outro vocaux séquencés dans l'ordre avec gaps configurés, intro FR complète, closing long avec gong final intégré à la séquence guidée, reminder phase centrale robuste par bucket, voix guidée poussée devant une ambiance maîtrisée avec ducking renforcé, pause/reprise, langue audio dérivée de l'UI avec fallback global `en`, silence si assets absents partout |
| Haptics | ✅ Légers et discrets — feedback natif limité aux transitions `intro -> méditation` et `méditation -> closing`, sans logique ajoutée dans `SessionEngine` |

## Points ouverts

- **Assets audio** : arborescence `Audio/Shared/...` + `Audio/{fr,en,es,de}/VoiceGuidance/...` en place, `Siturem/Audio` déclaré explicitement dans `project.yml`. Les locales audio effectivement traitées comme disponibles sont `fr`, `en`, `es`. `de` reste borné côté bundle mais n'est pas sélectionné automatiquement.
- **Localisation audio** : la langue audio suit désormais la langue UI effective avec fallback global `en`. La séparation d'architecture UI / audio reste conservée ; seule la règle de résolution a changé.
- **HealthKit** : synchro V1 optionnelle activée côté app. Permission demandée seulement depuis `SettingsView`. Écriture tentée uniquement pour les séances terminées normalement ; refus, indisponibilité et échec restent silencieux et non bloquants
- **Flux UI** : `HomeView` affiche maintenant le dernier cadre persistant via `PracticeFrameStore`. Le bloc `Dernier cadre` reste un point de chargement honnête vers les réglages visibles, tandis que `Commencer` lance toujours le runtime via `SessionConfiguration`. `SessionView` reste session-centric et `SessionSummaryView` conserve un rôle de clôture discret
- **Contrôles de séance** : l'alerte d'arrêt suspend désormais la séance et l'audio si l'utilisateur était en cours d'exécution, puis restaure proprement cet état sur `Continuer`. `SessionEngine` reste inchangé et centré sur le timing / l'état
- **Écran de fin** : `SessionSummaryView` affiche maintenant la durée réalisée, un cumul simple `Aujourd'hui`, puis une relance directe de la même configuration. Le ton reste neutre et l'écran évite toujours les stats avancées
- **StatsView** : la vue est recentrée sur un registre essentiel unique. `Temps total` porte l'entrée de lecture, puis `Séances`, `7/30 jours` et les streaks restent groupés dans une hiérarchie calme, sans logique fitness ni effet dashboard. Des repères secondaires ajoutent maintenant deux totaux mensuels récents et une moyenne hebdomadaire sobre, avant une heatmap 90 jours binaire intégrée de façon discrète. Une zone `Séances récentes` ouvre désormais un détail de séance réduit à l'information utile
- **Stats / persistance** : `StatsStore` et `SessionRecord` restent inchangés. Les stats par cadre attendront un identifiant de cadre persistant dans un futur `PracticeFrameStore` ou dans une évolution ciblée de `SessionRecord`
- **HealthKit** : aucun ajustement frame n'est écrit dans Santé. La couche HealthKit reste strictement session-centric
- **Tests** : aucun test unitaire ou UI en place
- **Cartographie V2** : les impacts techniques Home / Session / Stats / Settings sont maintenant documentés dans `docs/2026-04-21-s1-v2-impact-mapping.md` pour préparer l'introduction d'un futur `PracticeFrameStore` sans refactor large
- **PracticeFrameStore** : store V2 local avec persistance `UserDefaults + JSON`, CRUD, favoris, dernier cadre utilisé et ordre d'affichage porté par l'ordre du tableau persisté. `PreferencesStore` reste inchangé et conserve les réglages actifs V1
- **Migration V1 -> V2** : stratégie lazy et idempotente préparée. Si aucun cadre n'existe encore, un futur premier accès aux frames pourra seed un cadre unique depuis les réglages de séance V1 persistés; si aucun héritage V1 n'existe, aucune création automatique n'est faite
- **Home V2** : le raccord minimal est en place. `HomeView` revient à une hiérarchie plus calme centrée sur `Séance`, avec `Dernier cadre`, `Durée` et `Commencer` comme noyau principal. `Signaux` reste présent sous forme secondaire et légère. Aucun bloc `Accès` redondant n'est affiché au-dessus de la tab bar
- **Premier lancement** : le bloc `Dernier cadre` n'apparaît pas sur un vrai premier lancement absolu. La migration lazy ne seed un cadre que pour un utilisateur V1 dont au moins une vraie préférence de séance est déjà persistée. Le faux positif observé pendant les vérifications venait d'un état résiduel du simulateur, pas d'un bug de logique

## Références locales
- `docs/BrandingGuideline.md` — identité visuelle, ton, territoire
- `docs/cahierCharges-v1.md` — spécifications fonctionnelles complètes (source de vérité)
- `docs/2026-04-16-siturem-v2-backlog.md` — backlog V2 priorisé écran par écran
- `docs/2026-04-21-s1-v2-impact-mapping.md` — cartographie technique S1 avant raccord des cadres V2

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
- Persistance : UserDefaults + JSON (stores locaux simples pour V1 et V2)
- Phases de séance fixes : intro 150 s + méditation variable + closing 92 s
- **Refonte visuelle** : palette anthracite + accent bleu ardoise (pas de noir pur), blob animé en séance à la place du compteur, barre de progression globale (pas par phase)
- **Ajustements récents du layout** : barre de progression centrée avec largeur plafonnée, remontée pour conserver une respiration nette au-dessus des contrôles ; blob redimensionné avec canevas et padding internes élargis, sans rasterisation contrainte, pour éviter l'effet de bloc carré ou de cadre visible
- **Refonte SettingsView** : séparation claire entre lancement rapide (`HomeView`) et préférences durables (`SettingsView`). `HomeView` garde `durée`, `accompagnement`, `gong` et `ambiance`, tandis que `SettingsView` porte la langue UI, les rappels guidés, la visibilité de progression, les haptics de transition, HealthKit et la version. La langue audio n'est pas exposée en réglage dédié à ce stade.
- **HealthKit V1** : le toggle `PreferencesStore.healthKitEnabled` est le garde-fou applicatif. `SessionView.handleEnd` tente l'écriture après persistance locale et affichage du bilan, sans bloquer l'UX et sans logique HealthKit dans `SessionEngine`
- **PracticeFrame** : modèle conceptuel léger et nommé, centré sur les réglages actifs du V1. La locale audio reste hors du cadre et le passage à `SessionConfiguration` se fait via un mapping explicite avec la locale fournie par `PreferencesStore`
- **Règle de langue UI** : priorité `choix explicite utilisateur > langue système supportée > anglais`. Au premier lancement, aucune langue UI n'est forcée côté app.
- **Accompagnement simplifié** : deux modes seulement, `Guidé` et `Silencieux`. Le mode guidé couvre les consignes intro/outro et les interventions de méditation, dont la fréquence est réglée dans SettingsView.
- **Audio XcodeGen** : `Siturem/Audio` est déclaré explicitement dans `project.yml` pour garantir la présence de la hiérarchie `Shared + locales` dans le projet généré et dans le bundle
- **Infra build** : `project.yml` conserve un scheme partagé `Siturem` et la clé HealthKit explicite dans les entitlements pour que `xcodebuild` soit exécutable de façon stable après `xcodegen generate`
- **Locale audio** : point unique de résolution dans `PreferencesStore`, dérivé de la langue UI effective via `AudioLocale`
- **Fallback audio** : si la langue UI n'a pas d'audio disponible, fallback global vers `en`. Les assets partagés restent globaux, tandis que si un asset vocal manque dans la langue résolue, tentative en `en`, puis silence si absent partout
- **Séquençage voix** : intro/outro reposent sur une séquence ordonnée, des gaps configurés et des durées attendues ou mesurées. `intro_07_scan_corporel` est réintégré à l'intro FR, `intro_04_fermer_les_yeux` démarre 3 s plus tard qu'avant, le gap `intro_05 -> intro_06` est élargi à 10 s, `intro_08_concentration_souffle` reste ancré 5 s avant la fin de l'intro avec rattrapage si la frontière de phase approche, et le gong final fait désormais partie de la séquence de closing guidée.
- **Mix audio** : l'ambiance reste volontairement secondaire face à la voix, avec une voix guidée poussée au premier plan, un niveau de base légèrement remonté mais toujours bas, un ducking plus marqué pendant les interventions, une remontée plus douce ensuite, et des ambiances reprises puis revalidées dans la V1.2.
- **Haptics de transition** : un feedback natif léger est déclenché uniquement lors des bascules de phase majeures (`intro -> méditation`, `méditation -> closing`) depuis `SessionView`, sans dérive de responsabilité dans `SessionEngine`
- **Compatibilité V1** : `PreferencesStore` reste la source de vérité pour les réglages actifs. Il peut déjà snapshotter un cadre nommé via `makePracticeFrame(name:isFavorite:)`, sans changer la persistance existante
- **Rappels guidés** : les libellés de réglage sont alignés sur leur cadence réelle, avec `Occasionnelles = 2m30` et `Fréquentes = 1m30`
- **Bundle identifier** : migration vers `fr.beabot.siturem`
- **Validation V1.1** : la V1.1 est considérée comme validée côté app / intégration / périmètre
- **Livraison V1.2** : la V1.2 clôture les dernières réserves audio / stabilité avant reprise de la V2
- **Cadres V2** : le modèle `PracticeFrame` est stabilisé comme couche conceptuelle et `PracticeFrameStore` couvre maintenant la persistance locale du dernier cadre, des favoris et de l'ordre d'affichage. Le prochain chantier est le raccord contrôlé de `HomeView`
- **Raccord Home / frames** : `ContentView` injecte maintenant `PracticeFrameStore` dans `HomeView`. Au premier accès réel au bloc, une migration lazy peut seed un unique cadre nommé depuis les préférences V1 persistées. Si aucun cadre n'est disponible après ce contrôle, l'accueil reste inchangé et n'affiche aucun bloc vide
- **Stabilité pause / reprise / arrêt** : `SessionView` porte maintenant un garde-fou local pour figer la séance pendant la confirmation d'arrêt, éviter qu'une fin naturelle tombe derrière l'alerte, et reprendre proprement seulement si la séance était en cours avant l'annulation
- **Clôture de séance** : le bilan reste volontairement compact. Le seul cumul exposé est `Aujourd'hui`, calculé via `StatsStore`, et `Relancer` recrée une séance avec la configuration runtime existante sans étendre le rôle de `SessionEngine`
- **Registre de pratique** : `StatsView` privilégie désormais une seule carte essentielle, avec `Temps total` comme métrique dominante et le reste des repères en lecture secondaire. Un second niveau compact ajoute deux totaux mensuels récents, une moyenne hebdomadaire et un accès sobre au détail d'une séance récente, sans basculer vers un dashboard. Les enrichissements S8 plus denses (stats par cadre, visualisations supplémentaires) restent explicitement hors périmètre
- **Persistance frames V2** : `PracticeFrameStore` persiste `[PracticeFrame]` en JSON dans `UserDefaults`, conserve le dernier cadre utilisé via un identifiant séparé, et réutilise l'ordre du tableau comme ordre d'affichage. L'initialisation retombe sur un état sain si l'état persisté est vide, partiel ou incohérent. Cette couche ne remplace pas `PreferencesStore` et ne branche pas encore l'UI
- **Migration des préférences** : seuls `durée`, `accompagnement`, `gong`, `ambiance` et `rappels` sont migrables vers un premier `PracticeFrame`. `uiLanguageOverride`, `audioLocale` dérivée, `healthKitEnabled` et l'onboarding restent hors cadre et dans `PreferencesStore` / `AppStorage`
- **Impact mapping S1** : la cartographie confirme que `HomeView` et `PreferencesStore` sont les points de risque principaux, que `SessionConfiguration` doit rester le contrat d'exécution, et que `StatsStore` / `SettingsView` doivent rester découplés tant que la persistance des cadres n'est pas stabilisée
- **Pilotage opérationnel** : le GitHub Project `Siturem — Delivery` (`github.com/users/benabot/projects/2`) est le tableau de pilotage principal du repo
- **Cycle de travail** : lire une issue, la passer en `En cours`, implémenter, valider localement, faire un commit documenté au format `type(area): action concise (#issue)`, commenter / fermer l’issue, puis synchroniser `TODO.md` et `PROJECT_STATUS.md` si nécessaire

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
`[S3] Home — hiérarchie simplifiée`

- `HomeView` recentre l’écran sur `Séance`, avec `Dernier cadre`, `Durée` et `Commencer` dans la zone dominante
- `Charger` conserve un comportement honnête de copie vers les réglages visibles, sans créer de second CTA primaire
- `Signaux` reste en dessous comme bloc secondaire léger, et aucun bloc `Accès` redondant n'est affiché
- les prochaines retouches Home devront préserver cette lecture simple et éviter tout retour à une interface dense
