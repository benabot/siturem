# TODO

## Priorité active

### [S0] V1.2 — Polish & stability

**Statut**
Sprint courant de reprise avant réouverture effective de la V2.

**Objectif**
Fermer proprement les réserves audio et stabilité encore ouvertes, puis revalider le flux complet avant de remettre la V2 au premier plan.

**Tâches**
- [ ] refaire et valider les sons d’ambiance encore en réserve qualité
- [ ] finaliser les assets localisés `en` / `es` / `de` selon la matrice réellement retenue
- [ ] ajouter des haptics légers aux transitions
- [ ] revalider le flux complet après les derniers ajustements
- [ ] resynchroniser la documentation partagée si l’état réel change

**Critère de fin**
- [ ] le rendu audio résiduel est jugé propre
- [ ] les langues audio effectivement supportées sont bornées clairement
- [ ] le flux complet est revalidé
- [ ] `TODO.md` et `PROJECT_STATUS.md` reflètent l’état final de la reprise V1.x

## Cadrage V2 — prêt

Le cadrage documentaire V2 est posé. Il sert de filtre pour éviter d’ouvrir trop de sujets en parallèle, mais il n’est plus la priorité active tant que la reprise `V1.2` n’est pas terminée.

### Acté
- [x] le périmètre **V2.0 strict** est défini
- [x] les extensions **V2.1+** sont repoussées explicitement
- [x] l’ordre de livraison retenu est documenté

## V1.1 — validée avec réserve

La V1.1 est considérée comme validée côté app, intégration et périmètre fonctionnel.
La réserve restante porte sur la qualité finale de certains sons d’ambiance, à refaire côté assets pour obtenir un rendu plus propre.

### Clos
- [x] base applicative V1.1 stable
- [x] refonte visuelle et UX validée
- [x] localisation UI `fr` / `en-US` / `es` / `de`
- [x] audio intégré avec règle `langue UI -> langue audio` et fallback global `en`
- [x] phase de closing fixée à `92 s`
- [x] intégration HealthKit V1 non bloquante
- [x] documentation de statut partagée remise à jour

### Réserve assets
- [ ] refaire certains sons d’ambiance pour obtenir un rendu plus propre
- [ ] redéposer puis revalider les assets d’ambiance concernés dans le bundle
- [ ] finaliser et valider les packs audio localisés `en`, `es`, `de` selon la matrice UI / audio retenue

## Référence V2

Le cadrage V2 actif est maintenu dans :
- `docs/2026-04-16-siturem-v2-backlog.md`
- `docs/2026-04-16-siturem-v2-sprint-plan.md`

Règle de pilotage :
- ne pas rouvrir les extensions V2.1+ tant que le bloc **V2.0 strict** n’est pas livré proprement
- garder un seul lot principal actif à la fois
