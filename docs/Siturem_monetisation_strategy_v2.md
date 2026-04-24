# Siturem — Stratégie de monétisation + spécification StoreKit et paywall

_Date : 2026-04-22_

## 1. Résumé exécutif

Siturem doit rester sur une ligne simple : **freemium utile + achat unique Pro**, sans abonnement, sans publicité, sans compte obligatoire.

Cette orientation est cohérente avec :
- le positionnement produit : outil sobre pour pratiquants autonomes
- l’anti-roadmap : pas d’abonnement mensuel, pas de publicité, pas de gamification
- le PRD et la roadmap qui convergent déjà vers un **IAP one-time “Siturem Pro”**

## 2. Contexte projet

### 2.1 Positionnement à préserver

Siturem n’est pas une app de contenu, de coaching ou de relaxation grand public.
Le produit vend un **cadre de pratique** : stabilité, discrétion, structure, répétabilité.

Conséquence directe sur la monétisation :
- ne pas vendre une promesse de transformation
- ne pas multiplier les offres
- ne pas enfermer le cœur du timer derrière un paywall agressif
- ne pas introduire un abonnement qui casserait la cohérence du produit

### 2.2 Concurrence utile à prendre en compte

#### Timefully
Concurrence directe sur le segment du timer sérieux pour pratiquants avancés.
Le produit met en avant un timer riche, des presets, des statistiques, Apple Watch et synchronisation. Une version Pro/lifetime existe déjà.

#### Zenitizer
Concurrence premium directe sur le terrain du minimalisme design. Le produit pratique une monétisation plus lourde avec abonnement et lifetime élevé.

#### Insight Timer
Reste une alternative crédible pour beaucoup d’utilisateurs grâce à la gratuité du timer et à sa notoriété massive, même si l’expérience est plus chargée.

## 3. Offre recommandée

### 3.1 Modèle commercial

**Modèle retenu :**
- version gratuite utile
- une seule offre payante : **Siturem Pro**
- type : **non-consumable in-app purchase**

Cela permet :
- une compréhension immédiate
- une implémentation technique simple
- une cohérence forte avec la marque
- un coût de maintenance réduit

### 3.2 Prix recommandé

#### Recommandation de base
- **US : 6.99 $ ou 7.99 $**
- **Europe : 7,99 €**

#### Arbitrage recommandé
La meilleure base de lancement est **7,99 €**.

Pourquoi :
- assez haut pour signaler de la valeur
- assez bas pour rester très en dessous des références premium lourdes
- compatible avec une cible qui refuse l’abonnement mais accepte un achat unique honnête

#### Ce qu’il faut éviter
- **4,99 €** : trop bas, banalise le produit
- **12,99 € et plus** : trop ambitieux au regard du gratuit concurrent
- **abonnement mensuel ou annuel** : contradictoire avec le positionnement

## 4. Découpage Free / Pro

## 4.1 Ce qui doit rester gratuit

Le gratuit doit être crédible. Il doit permettre de juger la qualité réelle de l’app.

### Inclus dans Siturem Free
- timer complet et fiable
- durée personnalisée
- gong début / fin
- quelques sons de base
- DND / silence automatique
- 2 presets maximum
- statistiques basiques
- historique 7 jours
- HealthKit write basique si déjà livré dans le produit

### Pourquoi
Si le cœur de pratique est trop limité, l’utilisateur revient immédiatement vers :
- le minuteur natif iPhone
- Timefully
- Insight Timer

## 4.2 Ce qui doit être réservé au Pro

### Inclus dans Siturem Pro
- presets illimités
- historique complet
- statistiques avancées
- heatmap 90 jours
- stats mensuelles et annuelles
- tous les sons disponibles
- export CSV
- widgets iOS
- futures vues avancées liées à la régularité de pratique

### Règle produit
Le Pro doit vendre un **usage installé et approfondi**, pas le simple droit d’utiliser le produit.

## 5. Positionnement de l’offre

## 5.1 Message principal

**Siturem Pro débloque les fonctions avancées d’un outil sobre et durable.**

## 5.2 Message à éviter

À éviter absolument :
- promesses de bien-être vagues
- rhétorique spirituelle
- langage de transformation personnelle
- logique de rareté artificielle
- culpabilisation par le streak

## 5.3 Promesse paywall recommandée

Formulation simple :

> Débloquez les fonctions avancées de Siturem.
> Achat unique. Pas d’abonnement.

## 6. Spécification StoreKit

## 6.1 Type de produit

**Type recommandé : Non-Consumable In-App Purchase**

Nom produit :
- `Siturem Pro`

Product identifier recommandé :
- `fr.beabot.siturem.pro`

Pourquoi ce type :
- achat définitif
- restaure automatiquement le droit d’usage sur les appareils du même compte Apple
- correspond au positionnement “outil acheté une fois”

## 6.2 API recommandée

Utiliser **StoreKit 2**.

Raison :
- API moderne Swift
- transactions signées par l’App Store
- support des entitlements actuels
- meilleure intégration avec Swift concurrency
- adaptée au minimum iOS 17 du projet

## 6.3 Configuration App Store Connect

Créer un produit IAP non-consumable :
- reference name : `Siturem Pro`
- product id : `fr.beabot.siturem.pro`
- pricing : palier proche de 7,99 €
- localisation minimale : FR + EN

## 6.4 Architecture app recommandée

Créer un service isolé, par exemple :
- `Siturem/Services/Billing/StoreKitService.swift`

Responsabilités :
- charger les produits
- déclencher l’achat
- écouter les mises à jour de transactions
- calculer l’état d’entitlement Pro
- exposer un booléen testable du type `isProUnlocked`
- supporter la restauration explicite des achats

## 6.5 Flux fonctionnels obligatoires

### A. Chargement des produits
Au démarrage des écrans concernés :
- récupérer `Product.products(for:)`
- afficher le prix localisé du produit
- gérer l’absence réseau sans casser l’interface

### B. Achat
Au tap sur “Passer à Pro” :
- appeler `purchase()` sur le produit
- gérer les cas : succès, annulation, pending, échec
- ne débloquer Pro qu’après transaction vérifiée

### C. Vérification d’entitlement
Au lancement de l’app et au retour au foreground :
- parcourir `Transaction.currentEntitlements`
- si la transaction vérifiée contient `fr.beabot.siturem.pro`, activer Pro

### D. Écoute des transactions
Maintenir une tâche qui écoute `Transaction.updates`
- utile pour tenir l’état à jour
- requis pour refléter les achats ou restaurations venant d’un autre appareil

### E. Restore purchases
Prévoir un bouton explicite **Restaurer les achats**
- dans le paywall
- dans Réglages

Comportement :
- appeler la synchronisation App Store / restauration adaptée au flux StoreKit 2
- recalculer ensuite les entitlements
- afficher un message neutre : “Achats restaurés” ou “Aucun achat à restaurer”

## 6.6 Règles de robustesse

- ne jamais supposer Pro actif sans transaction vérifiée
- ne jamais bloquer l’app si StoreKit est indisponible
- stocker en cache local l’état Pro, mais toujours le recroiser avec l’entitlement StoreKit
- prévoir mode offline lisible : l’utilisateur garde l’accès si entitlement déjà connu
- journaliser les états critiques en debug

## 6.7 États UI à prévoir

### États produit
- `loadingProducts`
- `productsLoaded`
- `purchaseInProgress`
- `purchaseSucceeded`
- `purchaseCancelled`
- `purchasePending`
- `purchaseFailed`
- `restoreInProgress`
- `restoreCompleted`
- `restoreEmpty`

### États entitlement
- `free`
- `proUnlocked`
- `unknown` au tout début du chargement

## 6.8 Feature gating

Créer une couche claire de feature flags internes :

Exemple :
- `canCreateUnlimitedPresets`
- `canAccessFullHistory`
- `canUseAllSounds`
- `canAccessAdvancedStats`
- `canExportSessions`
- `canUseWidgets`

Ne pas disperser des `if isPro` bruts partout dans les vues.

## 6.9 Tests à prévoir

### Tests locaux
- StoreKit configuration file en développement
- achat réussi
- achat annulé
- achat pending
- app relancée après achat
- restore depuis un “nouvel appareil” simulé

### Sandbox
- test via App Store Connect sandbox
- vérification du texte localisé
- vérification du bon prix
- vérification de restore purchases

## 7. Spécification paywall

## 7.1 Objectif du paywall

Le paywall ne doit pas “forcer”. Il doit :
- expliquer clairement ce que Pro ajoute
- rappeler qu’il s’agit d’un achat unique
- rassurer sur la restauration
- rester fidèle au ton de Siturem

## 7.2 Moments d’affichage recommandés

### Moment 1 — accès à une fonctionnalité Pro
Exemple :
- création d’un 3e preset
- ouverture de l’historique complet
- accès heatmap 90 jours
- export CSV

C’est le meilleur moment : l’utilisateur comprend immédiatement la valeur.

### Moment 2 — écran réglages
Section sobre “Siturem Pro”.

### Moment 3 — fin de séance
Optionnel et discret, uniquement si déjà cohérent UX.
Pas au premier lancement.

## 7.3 Moments à éviter

- au tout premier écran avant usage
- en popup répétée et intrusive
- après chaque session
- sur des actions gratuites essentielles

## 7.4 Structure du paywall

### Bloc 1 — titre
**Siturem Pro**

### Bloc 2 — sous-titre
**Fonctions avancées pour une pratique installée.**

### Bloc 3 — bénéfices
- Presets illimités
- Historique complet
- Statistiques avancées
- Tous les sons
- Export CSV et widgets

### Bloc 4 — prix
**Achat unique — 7,99 €**

### Bloc 5 — réassurance
- Pas d’abonnement
- Restauration des achats incluse

### Bloc 6 — actions
- bouton principal : **Passer à Pro**
- bouton secondaire : **Restaurer les achats**
- lien discret : **Plus tard**

## 7.5 Microcopy recommandée

### Version FR

**Titre**
Siturem Pro

**Sous-titre**
Débloquez les fonctions avancées de Siturem.

**Bullets**
- Presets illimités
- Historique complet
- Statistiques avancées
- Tous les sons
- Export CSV et widgets

**Prix**
Achat unique — 7,99 €

**Réassurance**
Pas d’abonnement. Restauration des achats incluse.

**CTA principal**
Passer à Pro

**CTA secondaire**
Restaurer les achats

**Fermeture**
Plus tard

### Version EN

**Title**
Siturem Pro

**Subtitle**
Unlock Siturem’s advanced features.

**Bullets**
- Unlimited presets
- Full history
- Advanced statistics
- All sounds
- CSV export and widgets

**Price**
One-time purchase — $7.99

**Reassurance**
No subscription. Restore purchases included.

**Primary CTA**
Unlock Pro

**Secondary CTA**
Restore Purchases

**Dismiss**
Later

## 7.6 Règles UX du paywall

- pas de faux compte à rebours
- pas de comparaison humiliante Free vs Pro
- pas de surcharge visuelle
- prix visible immédiatement
- restore purchases toujours visible
- fermeture simple
- ton neutre et précis

## 7.7 Écrans paywall à prévoir

### A. Full screen sheet
Usage : accès à une feature Pro structurante.

### B. Inline section
Usage : Réglages ou Statistiques.

### C. Locked state card
Usage : feature verrouillée dans une vue existante.

Exemple :
“Historique complet disponible avec Siturem Pro.”

## 8. Plan d’implémentation recommandé

### Étape 1
- créer le produit App Store Connect
- préparer les localisations FR/EN
- ajouter StoreKit configuration file

### Étape 2
- implémenter `StoreKitService`
- récupérer le produit
- calculer `isProUnlocked`
- écouter `Transaction.updates`

### Étape 3
- brancher les gates Pro sur : presets, historique, sons
- ajouter restore purchases dans Réglages

### Étape 4
- intégrer le paywall minimal
- brancher les textes localisés
- tester sandbox

### Étape 5
- ajouter analytics locales minimales ou logs debug internes si nécessaire
- mesurer : vues paywall, taps achat, achats réussis, restores

## 9. KPIs à suivre

### Produit
- taux d’exposition paywall
- taux de tap sur CTA Pro
- conversion achat
- restore rate
- rétention D7 / D30 des users Pro

### Business
- conversion Free → Pro
- revenu mensuel
- revenu cumulé par cohortes
- impact sur la note App Store

## 10. Décision finale

### Recommandation ferme

Implémenter :
- **un seul IAP non-consumable**
- **StoreKit 2**
- **un paywall sobre**
- **un prix de lancement autour de 7,99 €**

### Ne pas implémenter

- abonnement
- bundles complexes
- multi-tier pricing
- paywall intrusive au premier lancement
- gating agressif du cœur du timer

## 11. Références externes à garder en tête

- Apple recommande d’utiliser la version moderne de l’API In-App Purchase / StoreKit 2 sur les systèmes compatibles, l’Original API étant dépréciée.
- Apple met à disposition `Transaction.currentEntitlements`, `Transaction.updates` et les flux de produits/achats pour gérer correctement les droits.
- Apple indique aussi qu’il faut proposer un mécanisme de restauration des achats, sans restauration automatique au lancement qui perturberait l’utilisateur.

