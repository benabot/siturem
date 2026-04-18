# Siturem — Plan V2 en sprints

**Date :** 2026-04-16  
**Statut :** Plan d’exécution proposé  
**Contexte :** Dev solo, V1.1 validée côté app / intégration / périmètre, avec une réserve qualité limitée sur certains assets d’ambiance
**Rythme cible :** 6 à 10h par semaine  
**Cadence recommandée :** sprints de 1 semaine, extensibles à 2 semaines si nécessaire  

---

## 1. Principe général

La V2 ne doit pas repartir comme un chantier large.
Le premier travail utile consiste à figer un **V2.0 strict** court, exécutable et compatible avec un dev solo.

L’ordre recommandé est :

1. figer le périmètre **V2.0 strict**
2. livrer `HomeView` comme point de départ plus rapide
3. rendre `SessionView` et `SessionSummaryView` plus sobres
4. poser un socle `StatsView` + `SettingsView` sans ouvrir d’extensions

### Règles de conduite
- chaque sprint doit produire un incrément testable
- pas de gros refactor sans livrable visible
- pas d’Apple Watch dans le scope V2 de base
- pas de dérive produit vers gamification, social, dashboard complexe ou abonnement
- priorité à la clarté, à la vitesse d’usage et à la sobriété

### Note de cadrage
Le détail des sprints ci-dessous reste un matériau de planification.
Le scope réellement actif doit désormais suivre la section **18. Scope réel recommandé**.

---

## 2. Critère d’entrée en V2

La V2 ne commence réellement que quand les points suivants sont vrais :

- [x] V1.1 validée côté app / intégration / périmètre
- [ ] réserve qualité sur certains sons d’ambiance documentée et traitée côté assets
- [ ] aucun bug bloquant sur le moteur de séance
- [ ] pause / reprise / fin / annulation testés manuellement
- [x] HealthKit V1 validé en fonctionnement non bloquant
- [x] documentation projet mise à jour après clôture V1.1

---

# 3. Sprint 0 — Clôture V1 audio

## Objectif
Stabiliser la V1 avant toute ouverture de chantier V2.

## Checklists

### Audio
- [ ] déposer tous les assets vocaux FR manquants dans `Audio/fr/VoiceGuidance/...`
- [ ] valider la séquence complète intro / reminders / outro en FR
- [ ] vérifier les fallbacks audio effectifs
- [ ] vérifier le comportement si un asset manque

### Flux de séance
- [ ] tester le mode guidé
- [ ] tester le mode silencieux
- [ ] tester ambiance on/off
- [ ] tester gong on/off
- [ ] tester pause / reprise
- [ ] tester fin normale
- [ ] tester annulation

### Santé / accessibilité / finition
- [ ] tester HealthKit activé
- [ ] tester HealthKit désactivé
- [ ] décider si les haptics légers restent en V1.x ou passent en V2
- [ ] faire une vérification VoiceOver minimale

### Documentation
- [ ] mettre à jour `TODO.md`
- [ ] mettre à jour `PROJECT_STATUS.md`
- [ ] noter explicitement l’état final de l’audio V1

## Livrable
**V1.1 stable avec audio FR validé**

## Critère de sortie
Le flux complet de séance est fiable et publiable sans réserve majeure.

---

# 4. V2.0 strict — sprints cœur produit

## Vision du bloc V2.0 strict
Ce bloc doit produire une V2 objectivement meilleure sur quatre points :
- lancement plus rapide
- accueil plus lisible
- séance plus discrète
- suivi plus utile et plus calme

---

# 5. Sprint 1 — Cadrage exécutable V2

## Objectif
Transformer le backlog V2 en ordre d’implémentation concret.

## Checklists
- [ ] relire `docs/2026-04-16-siturem-v2-backlog.md`
- [ ] classer les éléments en :
  - [ ] différenciation immédiate
  - [ ] valeur secondaire
  - [ ] extension conditionnelle
- [ ] figer le périmètre de **V2.0 strict**
- [ ] décider du sort des haptics : V1.x ou V2
- [ ] définir le modèle conceptuel des cadres de pratique
- [ ] identifier les impacts techniques sur :
  - [ ] `PreferencesStore`
  - [ ] `StatsStore`
  - [ ] navigation
  - [ ] persistance
  - [ ] migration des préférences actuelles
- [ ] préparer les tickets des sprints 2 à 5

## Livrable
**Plan d’implémentation V2.0 strict figé**

---

# 6. Sprint 2 — Fondations des cadres de pratique

## Objectif
Créer la brique fonctionnelle centrale de la V2.

## Checklists

### Modèle et persistance
- [ ] créer le modèle `PracticeFrame`
- [ ] créer `PracticeFrameStore`
- [ ] définir la persistance locale
- [ ] gérer :
  - [ ] cadre par défaut
  - [ ] dernier cadre utilisé
  - [ ] favoris
  - [ ] ordre d’affichage

### Migration et structure
- [ ] préparer la migration depuis les préférences actuelles
- [ ] créer des données de preview SwiftUI
- [ ] localiser les premiers libellés liés aux cadres
- [ ] vérifier que le flux actuel de lancement n’est pas cassé

## Livrable
**Fondation technique des cadres prête, sans UI complète**

---

# 7. Sprint 3 — HomeView V2, part 1

## Objectif
Faire de `HomeView` le cockpit principal de l’app.

## Checklists

### Structure de l’écran
- [ ] refondre `HomeView` en 3 blocs :
  - [ ] Séance
  - [ ] Signaux
  - [ ] Accès secondaires
- [ ] garder un CTA principal unique et visible

### Démarrage rapide
- [ ] ajouter un bloc **Dernier cadre**
- [ ] permettre le démarrage immédiat depuis ce cadre
- [ ] brancher `HomeView` sur `PracticeFrameStore`

### Réglages visibles
- [ ] n’afficher que les réglages rapides :
  - [ ] durée
  - [ ] accompagnement
  - [ ] gong
  - [ ] ambiance
- [ ] réduire la charge visuelle globale

## Livrable
**Accueil V2 exploitable avec démarrage immédiat**

---

# 8. Sprint 4 — HomeView V2, part 2 + favoris

## Objectif
Rendre l’accueil vraiment utile pour un usage récurrent.

## Checklists

### Favoris
- [ ] afficher 1 à 3 cadres favoris sur l’accueil
- [ ] permettre d’épingler / désépingler un cadre
- [ ] permettre le réordonnancement des favoris

### Profondeur maîtrisée
- [ ] ajouter un accès **Réglages avancés** via sheet ou écran secondaire
- [ ] vérifier que l’accueil ne redevient pas une console

### Cadres natifs
- [ ] préparer les cadres natifs :
  - [ ] Zazen 25 min
  - [ ] Vipassana 45 min
  - [ ] MBSR 20 min
  - [ ] Libre

## Livrable
**HomeView V2 quasi finalisée**

---

# 9. Sprint 5 — SessionView V2

## Objectif
Renforcer le principe d’interface qui disparaît derrière la pratique.

## Checklists

### Affichage
- [ ] ajouter l’option **afficher / masquer le temps**
- [ ] ajouter l’option **afficher / masquer la progression**
- [ ] garder un label de phase discret et stable

### Contrôles
- [ ] consolider pause / reprise / arrêt
- [ ] confirmer que les contrôles restent toujours à la même place

### Préférences et accessibilité
- [ ] persister les préférences de rendu de séance
- [ ] valider VoiceOver de base sur l’écran
- [ ] vérifier que la simplicité reste intacte malgré les options

## Livrable
**SessionView V2 plus sobre, configurable sans complexité excessive**

---

# 10. Sprint 6 — SessionSummaryView + continuité d’usage

## Objectif
Faire de la fin de séance une clôture utile, sans célébration artificielle.

## Checklists

### Informations affichées
- [ ] afficher le cadre utilisé
- [ ] afficher la durée réalisée
- [ ] afficher un cumul simple :
  - [ ] aujourd’hui
  - [ ] 7 jours

### Continuité
- [ ] ajouter les CTA sobres :
  - [ ] Terminer
  - [ ] Réutiliser ce cadre
- [ ] proposer l’ajout en favori si usage répété

### Santé
- [ ] rendre l’état HealthKit encore plus discret
- [ ] maintenir un comportement non bloquant

## Livrable
**Écran de fin aligné avec la logique V2 des cadres**

---

# 11. Sprint 7 — StatsView V2, socle

## Objectif
Poser une base de statistiques utile, calme et crédible.

## Checklists

### Vue essentielle
- [ ] afficher clairement :
  - [ ] temps total
  - [ ] nombre de séances
  - [ ] 7 jours
  - [ ] 30 jours
  - [ ] streak actuel
  - [ ] meilleur streak

### Structure de vue
- [ ] refondre la hiérarchie visuelle de `StatsView`
- [ ] créer les sections de vue dédiées
- [ ] nettoyer les projections et calculs côté `StatsStore`

### Préparation de la suite
- [ ] préparer la compatibilité future avec les stats par cadre

## Livrable
**StatsView essentielle lisible et stable**

---

# 12. Sprint 8 — Heatmap 90 jours + détail de séance

## Objectif
Ajouter la première profondeur d’analyse utile sans alourdir l’app.

## Checklists
- [ ] implémenter la heatmap 90 jours
- [ ] ajouter les totaux mensuels
- [ ] ajouter la moyenne hebdomadaire
- [ ] ajouter une vue détail d’une séance
- [ ] vérifier le rendu sur petits écrans
- [ ] vérifier que la vue reste calme visuellement

## Livrable
**Stats avancées V2 utiles et encore sobres**

---

# 13. Sprint 9 — SettingsView V2 + préférences durables

## Objectif
Finaliser la séparation entre réglages de lancement et préférences longues.

## Checklists

### Préférences durables
- [ ] ajouter les préférences persistantes :
  - [ ] temps visible
  - [ ] progression visible
  - [ ] haptics activés

### Structure de l’écran
- [ ] clarifier les sections :
  - [ ] Interface
  - [ ] Séance
  - [ ] Santé
  - [ ] À propos

### Réglages complémentaires
- [ ] ajouter les réglages avancés de signaux si nécessaires
- [ ] ajouter des rappels sobres opt-in si conservés dans le scope
- [ ] vérifier la localisation complète des nouveaux textes

## Livrable
**SettingsView nettoyée, durable et cohérente avec HomeView**

---

# 14. Sprint 10 — Cadres natifs + polishing V2.0

## Objectif
Donner au produit sa personnalité finale sans ajouter de bruit.

## Checklists

### Cadres natifs
- [ ] livrer les cadres natifs
- [ ] permettre la duplication d’un cadre
- [ ] permettre le réordonnancement
- [ ] ajouter une signature visuelle légère par cadre

### Finition
- [ ] corriger les derniers défauts UX sur Home / Session / Summary
- [ ] faire une relecture produit complète
- [ ] mettre à jour la documentation projet après arbitrages

## Livrable
**V2.0 strict candidate**

---

# 15. V2.1 — extensions utiles mais non centrales

---

# 16. Sprint 11 — Export CSV + gating éventuel

## Objectif
Ajouter les éléments de valeur secondaire sans perturber le cœur produit.

## Checklists
- [ ] implémenter l’export CSV
- [ ] ajouter les stats par cadre si la fondation est prête
- [ ] définir le gating éventuel seulement si la stratégie de monétisation est décidée
- [ ] préparer `ProGateView` si nécessaire
- [ ] garder toute la monétisation discrète et non intrusive

## Livrable
**V2.1 candidate avec export et approfondissement mesuré**

---

# 17. Sprint 12 — Widget utile + QA générale

## Objectif
Ajouter une extension réellement utile et terminer proprement le cycle.

## Checklists

### Widget
- [ ] créer un widget **Démarrer ma séance favorite**
- [ ] ou créer un widget **Dernière séance / régularité**
- [ ] ajouter les deep links nécessaires

### QA
- [ ] tester sur plusieurs tailles d’écran
- [ ] valider la localisation
- [ ] valider les interactions post-V2 avec l’audio
- [ ] relire les flows complets

### Documentation et release
- [ ] mettre à jour `TODO.md`
- [ ] mettre à jour `PROJECT_STATUS.md`
- [ ] mettre à jour le backlog V2 si nécessaire
- [ ] rédiger des release notes propres

## Livrable
**V2.1 stabilisée**

---

# 18. Scope réel recommandé

## V2.0 strict
- [ ] `HomeView` recentrée sur le lancement immédiat
- [ ] réglages rapides sur l’accueil
- [ ] relance de la dernière configuration utilisée
- [ ] `SessionView` avec temps / progression masquables
- [ ] `SessionSummaryView` utile et sobre
- [ ] `StatsView` essentielle uniquement
- [ ] `SettingsView` limitée aux préférences durables directement nécessaires

## V2.1+
- [ ] cadres de pratique complets (`PracticeFrame`, CRUD, favoris, cadres natifs)
- [ ] `heatmap` 90 jours et stats avancées
- [ ] export CSV
- [ ] widget utile
- [ ] haptics légers
- [ ] stats par cadre si la fondation est prête
- [ ] monétisation sobre si la stratégie est décidée

## Ordre de livraison retenu
1. `HomeView`
2. `SessionView`
3. `SessionSummaryView`
4. `StatsView`
5. `SettingsView`

---

# 19. Hors scope tant que la traction n’est pas prouvée

- [ ] Apple Watch
- [ ] Siri Shortcuts / App Intents avancés
- [ ] synchronisation multi-device
- [ ] multiplication des thèmes
- [ ] dashboard complexe
- [ ] paywall agressif
- [ ] tout ajout qui imite un concurrent sans renforcer la vision produit

---

# 20. Outil de suivi recommandé

## Recommandation principale
**GitHub Projects**

### Pourquoi
- il vit au même endroit que le code, les issues et les PR
- GitHub Projects permet des vues **table**, **board** et **roadmap**, avec des champs personnalisés et des itérations pour gérer des sprints. citeturn872238search5turn872238search8turn872238search16
- GitHub Milestones permet de regrouper les issues par version ou sprint. citeturn872238search13turn872238search19
- Codex se connecte à GitHub, peut travailler sur un repo et proposer des PR ; OpenAI indique aussi des workflows GitHub plus poussés autour des revues de code. citeturn872238search6turn872238search1turn872238search17
- `AGENTS.md` est déjà une convention repo utile pour guider Codex sur un projet. citeturn872238search15

### Pourquoi c’est le meilleur choix pour toi
Pour un dev solo, c’est plus simple qu’un Jira correctement configuré, et bien plus cohérent avec un flux ChatGPT / Codex / GitHub centré repo.

### Configuration minimale recommandée
Créer un **GitHub Project** avec :
- vue `Backlog`
- vue `This Sprint`
- vue `In Progress`
- vue `Review / Validate`
- vue `Done`

### Champs recommandés
- `Priority` : P0 / P1 / P2
- `Area` : Home / Session / Summary / Stats / Settings / Audio / Docs
- `Sprint` : Sprint 0, Sprint 1, etc.
- `Type` : Feature / Bug / Tech / Docs
- `Estimate` : S / M / L
- `Release` : V1.1 / V2.0 / V2.1

### Règle simple de gestion
- 1 issue = 1 résultat concret
- 1 sprint = 4 à 7 issues maximum en solo
- toute issue ouverte doit avoir un critère de fin explicite
- toute tâche de doc ou d’architecture qui impacte le repo doit référencer `docs/2026-04-16-siturem-v2-backlog.md`

## Alternative si tu veux encore plus simple
**Linear** est excellent en solo et plus léger que Jira côté UX, mais il est moins naturel que GitHub Projects pour un projet où Codex et le code vivent déjà autour de GitHub.

## Ce que je ne recommande pas ici
- **Jira** : trop lourd pour ton niveau de complexité actuel
- **Trello** : trop léger si tu veux garder un vrai lien sprint / code / doc / PR
- **Notion seul** : bon pour la doc, moins bon comme source opérationnelle du travail de dev

---

# 21. Cadence recommandée de pilotage

## Rituel hebdomadaire minimal
- [ ] début de sprint : choisir 4 à 7 issues max
- [ ] en cours de sprint : ne pas ouvrir de nouveau chantier sans fermer un item actif
- [ ] fin de sprint : tester, documenter, décider du report ou de la fermeture
- [ ] après chaque sprint : mettre à jour `TODO.md` et `PROJECT_STATUS.md` si l’état partagé change

## Règle produit
Si un sprint n’aboutit pas à un incrément testable, le sprint est trop gros.
