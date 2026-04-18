# TODO

## Priorité active

### [S1] Docs — figer le périmètre V2.0 strict

**Statut**
Priorité active de pilotage. Le cadrage documentaire est désormais posé et doit servir de filtre avant toute ouverture de nouveau chantier V2.

**Objectif**
Définir noir sur blanc ce qui entre dans **V2.0 strict** et ce qui est repoussé à **V2.1+**.

**Tâches**
- [x] relire le backlog V2 dans `docs/`
- [x] relire les docs de roadmap / planification déjà présentes dans le repo
- [x] distinguer le scope **V2.0 strict** des extensions **V2.1+**
- [x] valider la liste des chantiers réellement prioritaires
- [x] documenter l’ordre de livraison retenu
- [x] repousser explicitement les extensions non essentielles
- [x] garder un périmètre compatible avec un dev solo et une livraison incrémentale

**Critère de fin**
- [x] le périmètre **V2.0 strict** est défini
- [x] les extensions non essentielles sont repoussées explicitement
- [x] la documentation de pilotage est claire

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
