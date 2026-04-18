# TODO

## Priorité active

### [S1] V2.0 — fondation des cadres

**Statut**
La V1.2 est livrée. Le prochain lot actif repasse sur la fondation V2, avec un seul chantier principal ouvert à la fois.

**Objectif**
Définir le socle minimal des cadres de pratique avant d’ouvrir les écrans V2.

**Tâches**
- [ ] définir le modèle `PracticeFrame`
- [ ] borner les propriétés réellement nécessaires pour `V2.0 strict`
- [ ] vérifier la compatibilité avec `HomeView`, `SessionView`, `SessionSummaryView` et les préférences existantes
- [ ] documenter les impacts techniques immédiats sans ouvrir de refactor large

**Critère de fin**
- [ ] le modèle conceptuel est stabilisé
- [ ] les impacts techniques directs sont connus
- [ ] l’ordre d’implémentation du socle V2 reste séquentiel et réaliste

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
