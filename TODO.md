# TODO

## Priorité active

### [S5] Session — contrôles stables

**Statut**
Pause / reprise / arrêt sont maintenant stabilisés dans `SessionView` avec un garde-fou local pendant la confirmation d'arrêt.

**Objectif**
Éviter les états intermédiaires incohérents entre timer, audio et UI sans changer le rôle de `SessionEngine`.

**Tâches**
- [x] figer la séance pendant l'alerte d'arrêt si elle était en cours
- [x] reprendre proprement sur annulation seulement si la séance tournait avant l'alerte
- [x] conserver un arrêt confirmé simple, sans refactor du moteur
- [x] revalider pause, reprise, arrêt annulé, arrêt confirmé et fin normale

**Critère de fin**
- [x] pause / reprise restent fiables
- [x] l'arrêt confirmé quitte proprement la séance
- [x] l'annulation d'arrêt ne laisse pas l'UI dans un état ambigu
- [x] la fin normale arrive toujours sur le bilan
- [x] le build local passe

**Suites identifiées**
- [ ] revisiter les contrôles seulement si une future V2 de `SessionView` change leur hiérarchie visuelle
- [ ] ne pas étendre ce ticket à une refonte audio ou à un changement de rôle de `SessionEngine`

### [S3] Home — hiérarchie simplifiée

**Statut**
`HomeView` revient à une hiérarchie plus simple: `Séance` reste dominante avec `Dernier cadre`, `Durée` et `Commencer`, tandis que `Signaux` reste secondaire et léger.

**Objectif**
Rendre l’accueil plus lisible sans changer le runtime de séance ni réintroduire un écran trop chargé.

**Tâches**
- [x] garder le bloc `Dernier cadre` en tête du bloc Séance
- [x] regrouper durée et CTA dans le bloc Séance
- [x] reléguer accompagnement, gong, ambiance et rappels dans le bloc Signaux
- [x] supprimer le bloc `Accès` redondant avec la tab bar
- [x] conserver un seul CTA primaire

**Critère de fin**
- [x] la hiérarchie visuelle est nette
- [x] l’écran reste lisible sur petit iPhone
- [x] le CTA principal reste unique
- [x] aucun bloc `Accès` redondant n'est affiché
- [x] le build local passe

**Suites identifiées**
- [ ] décider si un accès futur aux cadres favoris mérite un bloc dédié
- [ ] ne réétendre `HomeView` que si un nouveau point d'entrée apporte une vraie valeur au lancement

### [S2] Infra — stratégie de migration des préférences

**Statut**
La stratégie de migration entre réglages actifs V1 et cadres persistés V2 est cadrée et déjà appelée au premier accès réel aux frames dans `HomeView`, sans refonte large de l'accueil.

**Objectif**
Éviter une rupture entre `PreferencesStore` et `PracticeFrameStore` au moment du premier raccord UI.

**Tâches**
- [x] cartographier les préférences V1 et leur destination
- [x] définir ce qui migre dans un premier cadre
- [x] définir ce qui reste dans `PreferencesStore`
- [x] définir le moment d'exécution de la migration
- [x] rendre la migration idempotente et sûre face aux états partiels

**Critère de fin**
- [x] une stratégie claire existe
- [x] les cas principaux sont couverts
- [x] la migration ne change pas encore l'UX ni le runtime de séance

**Suites identifiées**
- [x] appeler la migration au premier accès réel aux frames lors du raccord `HomeView`
- [x] fournir le nom initial du cadre seedé au point d'appel UI
- [x] garder `PreferencesStore` comme source de vérité des réglages actifs tant que Home n'est pas migrée
- [x] confirmer que le premier lancement absolu n'affiche pas `Dernier cadre`
- [x] documenter que la migration lazy ne seed un cadre que depuis de vraies préférences V1 persistées
- [x] noter que le faux positif observé venait d'un état résiduel du simulateur
- [ ] revisiter le nom seedé si l'édition ou la localisation complète des cadres évolue

### [S2] V2.0 — persistance du dernier cadre et des favoris

**Statut**
Le store de cadres couvre maintenant le dernier cadre utilisé, les favoris, l'ordre d'affichage et les cas d'initialisation partiels, avec un premier raccord contrôlé dans `HomeView`.

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
- [x] raccorder `HomeView` au store sans mélanger réglages actifs et cadres enregistrés
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
- [x] raccorder `ContentView` puis `HomeView` au store
- [x] définir comment un réglage actif devient un cadre enregistré sans ambiguïté
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
- [x] définir la frontière exacte entre réglages actifs V1 et cadres persistés V2
- [x] raccorder `HomeView`
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
- [x] brancher `HomeView` sur ce store
- [ ] brancher `SessionSummaryView` sur ce store

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
