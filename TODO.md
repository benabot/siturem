# TODO

## Priorité active

### [S2] V2.0 — persistance du dernier cadre et des favoris

**Statut**
Le store de cadres couvre maintenant le dernier cadre utilisé, les favoris, l'ordre d'affichage et les cas d'initialisation partiels, sans raccorder encore la refonte `HomeView`.

**Objectif**
Durcir la persistance du socle V2 avant le premier branchement UI.

**Tâches**
- [x] confirmer où persister le dernier cadre utilisé
- [x] confirmer où persister les favoris
- [x] prévoir l'ordre d'affichage
- [x] couvrir les cas sans cadre existant ou avec état persisté incohérent
- [x] garder `PreferencesStore` séparé des cadres persistés

**Critère de fin**
- [x] le dernier cadre est conservé
- [x] les favoris sont persistés
- [x] l'ordre d'affichage est prévu proprement
- [x] l'initialisation retombe sur un état sain

**Suites identifiées**
- [ ] raccorder `HomeView` au store sans mélanger réglages actifs et cadres enregistrés
- [ ] propager le cadre utilisé vers `SessionView` et `SessionSummaryView` si nécessaire
- [ ] ne reconsidérer `SessionRecord` / `StatsStore` qu'après stabilisation du raccord Home

### [S2] V2.0 — store minimal des cadres

**Statut**
Le store local des cadres V2 est maintenant en place avec une persistance simple, lisible et séparée des réglages actifs V1.

**Objectif**
Persister les `PracticeFrame` sans refactor large, avec CRUD de base, favoris et dernier cadre utilisé.

**Tâches**
- [x] choisir une stratégie de persistance cohérente avec le repo
- [x] rendre `PracticeFrame` persistant de façon propre
- [x] créer `PracticeFrameStore`
- [x] couvrir CRUD, favoris et dernier cadre utilisé
- [x] documenter la frontière avec `PreferencesStore`

**Critère de fin**
- [x] le store compile et persiste localement
- [x] `PreferencesStore` reste la source de vérité V1 pour les réglages actifs
- [x] aucun raccord UI large n'est introduit

**Suites identifiées**
- [ ] raccorder `ContentView` puis `HomeView` au store
- [ ] définir comment un réglage actif devient un cadre enregistré sans ambiguïté
- [ ] propager le cadre utilisé vers `SessionView` et `SessionSummaryView`
- [ ] reconsidérer `SessionRecord` / `StatsStore` seulement après stabilisation de l'identité de cadre

### [S1] V2.0 — cartographie d'impact des cadres

**Statut**
La fondation conceptuelle `PracticeFrame` est en place. La cartographie technique Home / Session / Stats / Settings est maintenant posée pour préparer la suite sans refactor large.

**Objectif**
Identifier les zones à raccorder et l'ordre d'implémentation réaliste avant d'introduire le store minimal des cadres.

**Tâches**
- [x] cartographier les impacts côté Home
- [x] cartographier les impacts côté Session
- [x] cartographier les impacts côté Summary / Stats / Settings
- [x] documenter les dépendances critiques
- [x] documenter les risques de migration
- [x] proposer un ordre d'implémentation par petits diffs

**Critère de fin**
- [x] les zones de code touchées sont identifiées
- [x] les dépendances et risques sont documentés
- [x] l'ordre de raccord V2 est exploitable

**Suites identifiées**
- [ ] définir la frontière exacte entre réglages actifs V1 et cadres persistés V2
- [ ] raccorder `HomeView`
- [ ] propager le cadre utilisé vers `SessionView` et `SessionSummaryView`
- [ ] reconsidérer `SessionRecord` / `StatsStore` seulement après stabilisation du contrat de persistance

### [S1] V2.0 — fondation des cadres

**Statut**
La V1.2 est livrée. Le socle V2 des cadres de pratique est maintenant stabilisé autour de `PracticeFrame`, sans migration de persistance ni changement de flux V1.

**Objectif**
Définir le socle minimal des cadres de pratique avant d’ouvrir les écrans V2.

**Tâches**
- [x] définir le modèle `PracticeFrame`
- [x] borner les propriétés réellement nécessaires pour `V2.0 strict`
- [x] vérifier la compatibilité avec `HomeView`, `SessionView`, `SessionSummaryView` et les préférences existantes
- [x] documenter les impacts techniques immédiats sans ouvrir de refactor large

**Critère de fin**
- [x] le modèle conceptuel est stabilisé
- [x] les impacts techniques directs sont connus
- [x] l’ordre d’implémentation du socle V2 reste séquentiel et réaliste

**Suites identifiées**
- [x] créer `PracticeFrameStore`
- [x] persister le dernier cadre utilisé par identifiant
- [x] persister les favoris
- [x] persister l'ordre d'affichage
- [ ] brancher `HomeView` et `SessionSummaryView` sur ce store

## V1.2 — livrée

La V1.2 clôture les dernières réserves V1.x. Elle est considérée comme livrée côté app, audio, intégration et validation manuelle.

### Clos
- [x] refaire et valider les sons d’ambiance
- [x] borner les packs audio localisés `en` / `es` / `de`
- [x] ajouter des haptics légers aux transitions
- [x] revalider le flux complet après les derniers ajustements
- [x] synchroniser `TODO.md` et `PROJECT_STATUS.md`

## Cadrage V2 — prêt

Le cadrage documentaire V2 est posé. Il sert de filtre pour éviter d’ouvrir trop de sujets en parallèle et reste la base de référence pour le redémarrage séquentiel de la V2.

### Acté
- [x] le périmètre **V2.0 strict** est défini
- [x] les extensions **V2.1+** sont repoussées explicitement
- [x] l’ordre de livraison retenu est documenté

## V1.1 — validée

### Clos
- [x] base applicative V1.1 stable
- [x] refonte visuelle et UX validée
- [x] localisation UI `fr` / `en-US` / `es` / `de`
- [x] audio intégré avec règle `langue UI -> langue audio` et fallback global `en`
- [x] phase de closing fixée à `92 s`
- [x] intégration HealthKit V1 non bloquante
- [x] documentation de statut partagée remise à jour

## Référence V2

Le cadrage V2 actif est maintenu dans :
- `docs/2026-04-16-siturem-v2-backlog.md`
- `docs/2026-04-16-siturem-v2-sprint-plan.md`

Règle de pilotage :
- ne pas rouvrir les extensions V2.1+ tant que le bloc **V2.0 strict** n’est pas livré proprement
- garder un seul lot principal actif à la fois
