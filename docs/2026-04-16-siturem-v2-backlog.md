# Siturem — Backlog V2 priorisé

- **Date :** 2026-04-16
- **Statut :** Document de coordination V2
- **Périmètre :** UX/UI + fonctionnalités de la prochaine phase produit
- **Principe directeur :** différencier Siturem par la clarté, la vitesse de lancement, la sobriété, la neutralité, la configurabilité simple et la stabilité d’usage.

---

## 1. Intention produit V2

La V2 doit rendre Siturem plus rapide à lancer, plus lisible et plus simple à régler, sans changer le positionnement produit. Elle doit renforcer le cadre de pratique, pas ajouter de la complexité visible.

### Axes de différenciation
- lancement immédiat
- hiérarchie visuelle plus nette
- configuration simple en surface, précise dans les réglages durables
- interface de séance qui s’efface derrière la pratique
- stats sobres, utiles, non démonstratives
- cadres de pratique neutres et réutilisables
- continuité d’usage utile, sans mise en scène

---

## 2. Principes directeurs V2

- [ ] **HomeView doit rester le point de départ principal** : le lancement doit se faire sans détour.
- [ ] **Une action principale par écran** : l’essentiel doit être lisible immédiatement.
- [ ] **Configuration simple en surface, réglages durables en profondeur**.
- [ ] **L’interface de séance doit pouvoir s’effacer derrière la pratique**.
- [ ] **Les statistiques doivent ressembler à un registre de pratique**, pas à un dashboard fitness.
- [ ] **Apple Watch hors périmètre V2 de base**.
- [ ] **Pas de dérive produit** : pas de gamification, pas de social, pas de contenu éditorial, pas d’abonnement.

---

## 3. Ordre global de priorisation

### V2.0 strict
- [ ] Refonte HomeView
- [ ] SessionView avec temps/progression masquables
- [ ] SessionSummaryView plus utile et plus sobre
- [ ] StatsView essentielle
- [ ] SettingsView enrichi pour préférences durables

### V2.1
- [ ] Cadres de pratique
- [ ] Widgets utiles
- [ ] Haptics légers
- [ ] Export CSV

### V2.2 conditionnel
- [ ] Monétisation sobre
- [ ] Stats par cadre
- [ ] Siri Shortcuts / App Intents

---

# 4. Backlog écran par écran

---

## 4.1 HomeView — cockpit principal

### Objectif produit
Faire de l’accueil un point de départ immédiat, lisible et stable.

### User stories
- [ ] **US-H1** — En tant que pratiquant régulier, je veux relancer mon cadre habituel en un geste.
- [ ] **US-H2** — En tant qu’utilisateur autonome, je veux régler l’essentiel sans quitter l’accueil.
- [ ] **US-H3** — En tant que pratiquant sérieux, je veux une interface d’accueil claire, sans surcharge ni jargon.
- [ ] **US-H4** — En tant qu’utilisateur avancé, je veux retrouver mes favoris sans complexifier l’écran principal.

### Backlog P0
- [ ] Ajouter un bloc **Dernier cadre** avec bouton de démarrage immédiat
- [ ] Ajouter une zone **Réglages rapides** avec :
  - [ ] durée
  - [ ] accompagnement
  - [ ] gong
  - [ ] ambiance
- [ ] Ajouter un accès visible aux **cadres favoris**
- [ ] Réduire la charge visuelle et renforcer la hiérarchie du layout
- [ ] Conserver un unique CTA primaire toujours visible

### Backlog P1
- [ ] Ajouter un accès **Réglages avancés** via sheet ou écran secondaire
- [ ] Permettre le réordonnancement des favoris
- [ ] Ajouter une logique de relance propre du dernier cadre utilisé
- [ ] Préparer une ouverture directe depuis un widget ou un raccourci système

### Backlog P2
- [ ] Ajouter une action de continuité type **Relancer demain**
- [ ] Préparer un point d’entrée futur pour `App Intents` / Siri Shortcut

### Tâches SwiftUI / architecture
- [ ] Créer ou formaliser un modèle `PracticeFrame` ou `SessionFrame`
- [ ] Persister :
  - [ ] dernier cadre utilisé
  - [ ] favoris
  - [ ] ordre d’affichage
- [ ] Découper `HomeView` en sous-vues dédiées :
  - [ ] `QuickStartCard`
  - [ ] `LastFrameCard`
  - [ ] `FavoriteFramesSection`
  - [ ] `QuickSessionSettingsSection`
  - [ ] `AdvancedSettingsEntryPoint`
- [ ] Ajouter un modèle de présentation ou store dédié à l’écran d’accueil
- [ ] Localiser tous les nouveaux libellés
- [ ] Garder les libellés courts et neutres

---

## 4.2 SessionView — interface qui s’efface

### Objectif produit
Renforcer la disparition de l’interface pendant la séance, tout en gardant des repères fiables.

### User stories
- [ ] **US-S1** — En tant que méditant, je veux pouvoir masquer le temps pour ne pas être distrait.
- [ ] **US-S2** — En tant qu’utilisateur silencieux, je veux recevoir des repères tactiles discrets aux transitions.
- [ ] **US-S3** — En tant que pratiquant autonome, je veux un écran stable, sans animation décorative inutile.
- [ ] **US-S4** — En tant qu’utilisateur avancé, je veux des contrôles fiables, toujours à la même place.

### Backlog P0
- [ ] Ajouter une option **Afficher / masquer le temps**
- [ ] Ajouter une option **Afficher / masquer la progression**
- [ ] Consolider les contrôles :
  - [ ] pause / reprise
  - [ ] arrêt avec confirmation
- [ ] Stabiliser encore la hiérarchie visuelle pendant les phases
- [ ] Garder le label de phase discret et constant

### Backlog P1
- [ ] Ajouter des **haptics légers** aux transitions de phase
- [ ] Ajouter un **haptic de fin** si le son est coupé
- [ ] Ajouter une option de contraste renforcé si nécessaire

### Backlog P2
- [ ] Permettre une personnalisation légère de l’affichage de séance
  - [ ] temps visible ou non
  - [ ] progression visible ou non
  - [ ] label de phase visible ou non

### Tâches SwiftUI / architecture
- [ ] Ajouter dans `PreferencesStore` :
  - [ ] `showRemainingTime`
  - [ ] `showProgressBar`
  - [ ] `enableTransitionHaptics`
- [ ] Créer un composant `SessionChromeView`
- [ ] Isoler l’habillage de séance de la logique de session
- [ ] Ajouter un service ou une couche dédiée pour les haptics
- [ ] Brancher les haptics sur les changements de phase sans charger `SessionEngine`
- [ ] Vérifier l’accessibilité VoiceOver sur l’écran de séance

---

## 4.3 SessionSummaryView — clôture sobre et utile

### Objectif produit
Faire de la fin de séance un point de clôture propre, sans félicitations artificielles.

### User stories
- [ ] **US-SU1** — En tant qu’utilisateur, je veux voir immédiatement ce que j’ai réellement pratiqué.
- [ ] **US-SU2** — En tant que pratiquant régulier, je veux pouvoir réutiliser facilement ce cadre.
- [ ] **US-SU3** — En tant qu’utilisateur HealthKit, je veux une intégration silencieuse, non bloquante.

### Backlog P0
- [ ] Afficher le **cadre réalisé**
- [ ] Afficher la **durée réalisée**
- [ ] Afficher un **cumul simple** :
  - [ ] aujourd’hui
  - [ ] ou 7 jours
- [ ] Ajouter des CTA sobres :
  - [ ] Terminer
  - [ ] Réutiliser ce cadre

### Backlog P1
- [ ] Rendre le statut HealthKit plus discret
- [ ] Proposer d’épingler en favori si usage répété
- [ ] Ajouter un accès secondaire vers les statistiques

### Backlog P2
- [ ] Permettre de créer un cadre à partir de cette séance
- [ ] Préparer un export ponctuel futur d’une séance

### Tâches SwiftUI / architecture
- [ ] Enrichir le modèle d’affichage de fin de séance avec le cadre utilisé
- [ ] Centraliser les calculs de cumul affichés
- [ ] Garder une hiérarchie visuelle austère, sans ton de célébration
- [ ] Maintenir le comportement HealthKit non bloquant

---

## 4.4 StatsView — registre de pratique

### Objectif produit
Séparer la lecture essentielle de l’analyse avancée, sans dérive “dashboard fitness”.

### User stories
- [ ] **US-ST1** — En tant que pratiquant régulier, je veux voir rapidement ma régularité et mon temps total.
- [ ] **US-ST2** — En tant qu’utilisateur régulier, je veux comprendre mes habitudes sans graphes agressifs.
- [ ] **US-ST3** — En tant que pratiquant discret, je veux exporter mes données sans dimension sociale.

### Backlog P0
- [ ] Construire une **vue essentielle** :
  - [ ] temps total
  - [ ] nombre de séances
  - [ ] temps sur 7 jours
  - [ ] temps sur 30 jours
  - [ ] streak actuel
  - [ ] meilleur streak
- [ ] Refaire la hiérarchie visuelle de `StatsView` pour un rendu plus calme

### Backlog P1
- [ ] Ajouter une **heatmap 90 jours**
- [ ] Ajouter la **moyenne hebdomadaire**
- [ ] Ajouter les **totaux mensuels**
- [ ] Ajouter une **vue détail d’une séance**
- [ ] Ajouter une **répartition par durée**

### Backlog P2
- [ ] Ajouter l’**export CSV**
- [ ] Ajouter un **récapitulatif annuel**
- [ ] Ajouter une **vue par cadre**

### Tâches SwiftUI / architecture
- [ ] Créer des sous-sections dédiées :
  - [ ] `StatsOverviewSection`
  - [ ] `PracticeConsistencySection`
  - [ ] `PracticeHistorySection`
  - [ ] `ExportSection`
- [ ] Étendre `StatsStore` avec les agrégations nécessaires
- [ ] Introduire un modèle de projection dédié aux stats
- [ ] Implémenter une heatmap SwiftUI simple et lisible
- [ ] Prévoir une structure de données claire pour les agrégations longue durée
- [ ] Garder les écrans de stats calmes et peu denses

---

## 4.5 SettingsView — préférences durables uniquement

### Objectif produit
Réserver les réglages aux préférences longues et système, sans doubler `HomeView`.

### User stories
- [ ] **US-SE1** — En tant qu’utilisateur, je veux que les réglages durables soient séparés du lancement de séance.
- [ ] **US-SE2** — En tant qu’utilisateur international, je veux une langue UI claire et stable.
- [ ] **US-SE3** — En tant qu’utilisateur discret, je veux contrôler rappels, haptics et Health sans confusion.

### Backlog P0
- [ ] Ajouter des préférences persistantes :
  - [ ] langue UI
  - [ ] durée par défaut
  - [ ] accompagnement par défaut
  - [ ] gong par défaut
  - [ ] ambiance par défaut
  - [ ] temps visible ou non
  - [ ] progression visible ou non
  - [ ] haptics activés ou non
- [ ] Ajouter des réglages avancés de signaux
- [ ] Clarifier la structure de l’écran :
  - [ ] Interface
  - [ ] Séance
  - [ ] Santé
  - [ ] À propos

### Backlog P1
- [ ] Ajouter des rappels sobres opt-in
- [ ] Ajouter un point d’entrée vers la gestion des cadres si nécessaire
- [ ] Ajouter la gestion de l’export
- [ ] Prévoir la réinitialisation des préférences durables

### Backlog P2
- [ ] N’ajouter un réglage supplémentaire que s’il est durable et réellement utile

### Tâches SwiftUI / architecture
- [ ] Créer des sous-vues dédiées :
  - [ ] `InterfacePreferencesSection`
  - [ ] `SessionPreferencesSection`
  - [ ] `HealthPreferencesSection`
  - [ ] `AboutSection`
- [ ] Garder la logique métier hors des vues
- [ ] Localiser toutes les nouvelles chaînes

---

## 4.6 Cadres de pratique — nouvelle brique V2

### Objectif produit
Faire des cadres de pratique une brique réutilisable, neutre et rapide à choisir.

### User stories
- [ ] **US-F1** — En tant que pratiquant, je veux enregistrer ma configuration habituelle comme cadre réutilisable.
- [ ] **US-F2** — En tant qu’utilisateur avancé, je veux épingler mes cadres préférés.
- [ ] **US-F3** — En tant qu’utilisateur régulier, je veux choisir un cadre neutre sans explication supplémentaire.
- [ ] **US-F4** — En tant que pratiquant, je veux partir d’un cadre crédible sans subir un produit dogmatique.

### Backlog P0
- [ ] Créer le modèle de données **cadre**
- [ ] Permettre :
  - [ ] créer un cadre
  - [ ] modifier un cadre
  - [ ] supprimer un cadre
- [ ] Permettre d’épingler en favori
- [ ] Permettre de choisir un cadre depuis `HomeView`

### Backlog P1
- [ ] Livrer les cadres natifs sobres avec l’app
- [ ] Permettre de dupliquer un cadre
- [ ] Permettre le réordonnancement
- [ ] Ajouter une signature visuelle légère par cadre
- [ ] Prévoir quelques cadres de départ neutres et lisibles

### Backlog P2
- [ ] Ajouter une vue **stats par cadre**
- [ ] Ajouter une suggestion du cadre le plus utilisé

### Tâches SwiftUI / architecture
- [ ] Créer `PracticeFrameStore`
- [ ] Créer les vues :
  - [ ] `FramesListView`
  - [ ] `FrameEditorView`
  - [ ] `FrameRowView`
- [ ] Gérer une migration propre depuis les préférences actuelles si nécessaire
- [ ] Garder des libellés neutres et courts pour les cadres natifs

---

## 4.7 Monétisation sobre

### Objectif produit
Si la V2 inclut une monétisation, elle doit rester simple, lisible et hors du flux de séance.

### User stories
- [ ] **US-P1** — En tant qu’utilisateur régulier, je veux comprendre clairement ce qui est inclus.
- [ ] **US-P2** — En tant qu’utilisateur méfiant envers les abonnements, je veux un achat unique simple si une version payante existe.
- [ ] **US-P3** — En tant qu’utilisateur, je veux que l’app reste utile sans pression commerciale.

### Backlog P0
- [ ] Définir clairement le modèle retenu : gratuit complet ou achat unique
- [ ] Définir le périmètre exact de ce que l’unlock autorise
- [ ] Prévoir `Restore purchases` si une vente in-app est conservée

### Backlog P1
- [ ] Ajouter une seule surface de présentation dans `SettingsView`
- [ ] Garder la copie neutre, courte et non insistante
- [ ] Éviter tout déclencheur dans le flux de séance
- [ ] Garder la vente optionnelle, jamais intrusive

### Tâches SwiftUI / StoreKit
- [ ] Ajouter un état de monétisation minimal si le modèle est retenu
- [ ] Créer ou formaliser `PurchaseManager` uniquement si l’unlock est livré
- [ ] Localiser tous les messages liés à l’achat
- [ ] Éviter tout paywall intrusif dans le flux principal

---

## 4.8 Widgets — continuité d’usage

### Objectif produit
Proposer seulement des widgets réellement utiles au retour à la pratique.

### User stories
- [ ] **US-W1** — En tant qu’utilisateur régulier, je veux démarrer ma séance favorite depuis l’écran d’accueil iPhone.
- [ ] **US-W2** — En tant que pratiquant discret, je veux voir ma continuité d’usage sans injonction.
- [ ] **US-W3** — En tant qu’utilisateur, je veux repartir vite vers la séance précédente.

### Backlog P0
- [ ] Ajouter un widget **Démarrer ma séance favorite**

### Backlog P1
- [ ] Ajouter un widget **Dernier cadre**
- [ ] Ajouter un widget **Dernière séance / régularité**

### Backlog P2
- [ ] Prévoir des deep links propres vers `HomeView` et la séance en cours

### Tâches SwiftUI / WidgetKit
- [ ] Créer une extension WidgetKit
- [ ] Permettre la lecture du cadre favori
- [ ] Ajouter des deep links propres
- [ ] Garder des libellés courts et localisés

---

# 5. Anti-V2

## Ce qui ne doit pas entrer dans ce backlog
- [ ] Pas d’Apple Watch dans le scope V2 de base
- [ ] Pas de social
- [ ] Pas de badges
- [ ] Pas de gamification
- [ ] Pas de contenu éditorial
- [ ] Pas de bibliothèque de contenu
- [ ] Pas de multiplication des thèmes
- [ ] Pas de dashboard complexe
- [ ] Pas d’abonnement
- [ ] Pas de modèle d’abonnement déguisé
- [ ] Pas d’écrans marketing agressifs
- [ ] Pas de notifications culpabilisantes

---

# 6. Lots recommandés

## Lot A — Différenciation immédiate
- [ ] Refonte HomeView
- [ ] Dernier cadre
- [ ] Favoris
- [ ] Réglages rapides
- [ ] Accès réglages avancés

## Lot B — Séance invisible
- [ ] Temps masquable
- [ ] Progression masquable
- [ ] Contrôles consolidés
- [ ] Haptics légers

## Lot C — Clôture et registre
- [ ] SessionSummaryView utile et sobre
- [ ] Stats essentielles
- [ ] Heatmap
- [ ] Export CSV

## Lot D — Cadres et réglages durables
- [ ] Modèle cadre
- [ ] CRUD
- [ ] Favoris
- [ ] Cadres natifs

## Lot E — Widgets et monétisation sobre
- [ ] Widget de démarrage favori
- [ ] Widget dernier cadre
- [ ] Modèle de monétisation simple
- [ ] Restore purchases si nécessaire

---

# 7. Critères de réussite V2

- [ ] Un utilisateur peut relancer une séance habituelle en quelques secondes
- [ ] L’accueil est plus lisible et plus rapide qu’en V1
- [ ] L’écran de séance peut devenir presque invisible
- [ ] Les stats restent utiles sans effet “fitness app”
- [ ] Les cadres renforcent l’usage régulier sans complexifier l’app
- [ ] La monétisation reste sobre, optionnelle et sans abonnement
- [ ] Le produit reste minimaliste, configurable avec simplicité, neutre et visuellement clair
- [ ] Aucune promesse hors scope ne s’ajoute à la V2 de base
