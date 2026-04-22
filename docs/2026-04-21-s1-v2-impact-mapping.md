# S1 — Cartographie technique V2

- **Date** : 2026-04-21
- **Issue** : `#7`
- **Objet** : lister les impacts techniques de l'introduction des cadres V2 sans ouvrir de refactor large

## Home

### `Siturem/Views/ContentView.swift`
- **Rôle actuel** : routeur racine entre onboarding, `HomeView`, `SessionView`, `StatsView` et `SettingsView`
- **Impact attendu** : devra injecter un futur store de frames ou un modèle de lancement pour que `HomeView` ne dépende plus seulement de `PreferencesStore`
- **Risque** : moyen
- **Pourquoi** : point de raccord central du flux `Home -> Session`
- **Ordre probable** : 3

### `Siturem/Views/HomeView.swift`
- **Rôle actuel** : configuration rapide V1 et lancement d'une séance via `SessionConfiguration`
- **Impact attendu** : devra afficher le dernier cadre, les favoris et garder des réglages rapides sans mélanger cadre enregistré et réglage transitoire
- **Risque** : élevé
- **Pourquoi** : zone la plus exposée à une confusion UX et à une duplication de source de vérité
- **Ordre probable** : 4

### `Siturem/Services/PreferencesStore.swift`
- **Rôle actuel** : persistance V1 des réglages actifs, dérivation de la locale audio, snapshot vers `PracticeFrame`
- **Impact attendu** : restera la source des réglages actifs; devra coexister proprement avec un futur `PracticeFrameStore`
- **Risque** : élevé
- **Pourquoi** : risque direct de duplication entre réglages courants et frame persistant
- **Ordre probable** : 1

### `Siturem/Models/PracticeFrame.swift`
- **Rôle actuel** : façade conceptuelle V2 au-dessus de `SessionConfiguration`
- **Impact attendu** : restera le point d'entrée métier des cadres; son mapping avec `SessionConfiguration` devra rester unique et explicite
- **Risque** : moyen
- **Pourquoi** : toute divergence de structure contaminerait Home, Session et Summary
- **Ordre probable** : 1

## Session

### `Siturem/Models/SessionConfiguration.swift`
- **Rôle actuel** : modèle d'exécution de séance, consommé par le moteur, l'audio et le lancement V1
- **Impact attendu** : doit rester le contrat d'exécution même si le lancement part d'un cadre V2
- **Risque** : moyen
- **Contrainte** : ne pas y enfouir d'identité de cadre si elle n'est pas strictement nécessaire au runtime

### `Siturem/Services/SessionEngine.swift`
- **Rôle actuel** : moteur de timing et de transitions de phase
- **Impact attendu** : aucun impact direct attendu si le mapping `PracticeFrame -> SessionConfiguration` reste en amont
- **Risque** : faible
- **Contrainte** : garder `SessionEngine` centré sur le timing et l'état, sans responsabilité frame

### `Siturem/Views/SessionView.swift`
- **Rôle actuel** : exécution de séance, orchestration audio, stats, HealthKit et bascule vers le summary
- **Impact attendu** : devra probablement recevoir ou conserver la référence du cadre utilisé pour l'écran de fin et un futur historique par cadre
- **Risque** : moyen
- **Contrainte** : ne pas mélanger logique de cadre, audio et HealthKit dans la vue

### `Siturem/Views/SessionSummaryView.swift`
- **Rôle actuel** : bilan minimal d'une séance terminée
- **Impact attendu** : devra afficher le cadre réalisé et proposer sa réutilisation
- **Risque** : moyen
- **Contrainte** : garder une clôture sobre, sans élargir la surface UX trop tôt

### `Siturem/Models/SessionRecord.swift`
- **Rôle actuel** : trace persistée d'une séance terminée pour les stats V1
- **Impact attendu** : futur point d'accroche si l'historique ou les stats deviennent frame-aware
- **Risque** : moyen
- **Contrainte** : éviter une migration de données prématurée avant stabilisation du store de frames

## Summary / Stats / Settings

### `Siturem/Services/StatsStore.swift`
- **Concerné maintenant** : seulement de façon indirecte, via un éventuel enrichissement futur de `SessionRecord`
- **Hors scope** : stats par cadre, agrégations nominatives, migration de persistance
- **Peut casser si mal migré** : historique local, calculs de streak, compatibilité JSON existante

### `Siturem/Views/StatsView.swift`
- **Concerné maintenant** : non, tant que les stats restent uniquement session-centric
- **Hors scope** : vues par cadre, répartition par cadre, UI d'analyse avancée
- **Peut casser si mal migré** : lisibilité du flux V2 si la vue tente d'exposer des cadres avant stabilisation de la donnée

### `Siturem/Views/SettingsView.swift`
- **Concerné maintenant** : seulement comme frontière produit; la vue ne doit pas devenir un doublon de `HomeView`
- **Hors scope** : CRUD de frames, favoris, dernier cadre utilisé
- **Peut casser si mal migré** : séparation actuelle entre préférences durables et configuration rapide de séance

## Dépendances critiques

- **Métier** : `PracticeFrame -> SessionConfiguration -> SessionEngine`
- **Lancement** : `PreferencesStore -> HomeView -> SessionConfiguration -> ContentView -> SessionEngine`
- **Fin de séance** : `SessionView -> SessionRecord -> StatsStore`
- **Audio** : `PreferencesStore.audioLocale -> SessionConfiguration.audioLocale -> AudioService`
- **HealthKit** : `SessionView -> HealthKitService`
- **Documentation** : `PROJECT_STATUS.md`, `TODO.md`, `docs/2026-04-16-siturem-v2-backlog.md`, `docs/2026-04-16-siturem-v2-sprint-plan.md`

## Risques principaux

- duplication entre `PreferencesStore` et un futur `PracticeFrameStore`
- divergence entre `PracticeFrame` et `SessionConfiguration`
- confusion entre réglage actif V1 et cadre enregistré V2
- difficulté à relier l'historique existant à des frames nommés si le lien est ajouté trop tôt
- surcharge de `HomeView` si configuration rapide et sélection de cadre sont fusionnées sans hiérarchie claire
- refactor prématuré du flux `HomeView -> SessionView -> SessionSummaryView`

## Ordre recommandé

1. introduire un `PracticeFrameStore` minimal, limité au dernier cadre, aux favoris et à l'ordre
2. définir la règle de coexistence entre `PreferencesStore` et `PracticeFrameStore`
3. raccorder `ContentView` et `HomeView` au store sans casser le lancement V1
4. propager le cadre utilisé jusqu'à `SessionView` puis `SessionSummaryView`
5. décider ensuite seulement si `SessionRecord` et `StatsStore` doivent porter une identité de cadre
6. étendre `StatsView` et `SettingsView` uniquement quand les contrats métier et de persistance sont stables
