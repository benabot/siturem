# Cahier des charges — App iOS de méditation structurée pour pratiquants expérimentés

## 1. Vue d’ensemble

### 1.1 Nom 
Siturem — Méditation structurée


### 1.2 Concept
Un outil minimaliste de pratique structurée pour méditants expérimentés.

### 1.3 Positionnement
L’application permet de lancer rapidement une séance de méditation cadrée, silencieuse ou légèrement guidée, avec une structure fixe en trois phases, des réglages simples, un suivi discret de la pratique, et une intégration native avec HealthKit.

### 1.4 Promesse
Créer un cadre de pratique fiable, discret, rapide à utiliser, sans contenu superflu.

### 1.5 Public cible
- Pratiquants réguliers de pleine conscience
- Utilisateurs autonomes dans leur pratique
- Personnes ne recherchant ni cours, ni coaching, ni programme de découverte
- Utilisateurs Apple sensibles à une interface sobre et native

### 1.6 Non-objectifs
L’application n’est pas :
- une app de découverte de la méditation
- une bibliothèque de contenus audio
- une app de routine matinale complète
- une app de yoga
- une app communautaire
- une app de coaching ou de performance

---

## 2. Objectif produit

Permettre à un utilisateur déjà familier avec la méditation de lancer une séance cadrée, simple et rapide, avec :
- une durée totale choisie à l’avance
- une structure fixe intro / méditation / retour
- des indications optionnelles
- un gong configurable
- une ambiance sonore facultative
- un suivi discret des habitudes et du temps pratiqué
- un enregistrement des séances dans HealthKit

---

## 3. Proposition de valeur

Le cœur du produit n’est pas un simple minuteur.

La valeur du produit repose sur :
- une structure de séance stable
- une mise en route rapide
- une interface minimale
- des repères utiles mais non intrusifs
- un usage fidèle à une pratique autonome
- une intégration propre à l’écosystème Apple via HealthKit

---

## 4. Plateforme

### 4.1 Plateforme cible
- iPhone en priorité
- iOS version récente supportée par SwiftUI et HealthKit

### 4.2 Extension possible après V1
- Apple Watch
- iPad
- widgets
- raccourcis Siri

Ces extensions ne font pas partie du périmètre obligatoire de la V1.

---

## 5. Structure d’une séance

## 5.1 Règle générale
La durée choisie par l’utilisateur correspond à la **durée totale** de la séance.

La séance comprend toujours 3 phases :
1. introduction
2. méditation
3. retour au calme

## 5.2 Phase 1 — Introduction
**Durée fixe : 2 min 30**

### Objectif
Installer la posture, calmer le rythme, poser l’attention et entrer dans la pratique.

### Déroulé
- installation de la posture
- 4 grandes respirations :
  - inspiration par le nez
  - expiration par la bouche
- fermeture des yeux à la 4e expiration
- prise de conscience des points de contact du corps
- prise de conscience de l’environnement :
  - sons
  - odeurs
  - température
  - perception globale
- scan corporel bref
- définition intérieure de l’intention du jour
- observation intérieure de la sensation du moment
- recentrage sur la respiration

## 5.3 Phase 2 — Méditation
**Durée variable**

### Objectif
Temps principal de pratique silencieuse.

### Déroulé
- silence
- éventuels rappels discrets à revenir calmement au souffle lorsque l’esprit s’égare

### Calcul
Durée phase méditation = durée totale - durée intro - durée retour

Soit :
Durée phase méditation = durée totale - 2 min 30 - 1 min 32

## 5.4 Phase 3 — Retour au calme
**Durée fixe : 1 min 32**

### Objectif
Permettre une sortie progressive de la pratique, sans rupture brusque.

### Déroulé
- libération de la concentration sur le souffle
- pause silencieuse de 17 secondes
- prise de conscience des points de contact du corps
- pause silencieuse de 15 secondes
- prise de conscience de l’environnement
- pause silencieuse de 19 secondes
- ouverture progressive des yeux
- pause silencieuse de 3 secondes
- gong final éventuel selon le réglage choisi

---

## 6. Règles métier

### 6.1 Durée minimale
La durée minimale autorisée est de **6 minutes**.

### 6.2 Durée par défaut
La durée par défaut proposée à l’utilisateur est de **10 minutes**.

### 6.3 Durée centrale calculée automatiquement
L’utilisateur ne règle pas séparément la durée des phases fixes.

Les phases intro et retour sont fixes.
La phase centrale s’ajuste automatiquement.

### 6.4 Blocage si durée insuffisante
Si l’utilisateur tente de définir une durée totale inférieure au minimum autorisé, l’application bloque la validation et affiche un message clair.

#### Exemple de message
> Durée minimale : 6 minutes pour conserver une phase de pratique centrale utile.

### 6.5 Sensation du jour
Dans la V1, la sensation du jour et son évolution sont des **consignes intérieures**.

Aucune saisie n’est obligatoire dans l’application.

---

## 7. Paramètres configurables

## 7.1 Durée totale
Choix rapides proposés :
- 6 min
- 10 min
- 15 min
- 20 min
- 30 min
- personnalisé

## 7.2 Mode d’accompagnement
Trois niveaux :

### 7.2.1 Silencieux
- pas de guidage verbal
- seulement les repères sonores éventuels selon le réglage du gong

### 7.2.2 Structuré
- indications discrètes des phases
- transitions claires intro / méditation / retour
- pas de guidage détaillé en continu

### 7.2.3 Guidé léger
- consignes courtes pendant l’introduction
- phase centrale majoritairement silencieuse
- retour au calme brièvement accompagné
- rappels optionnels pendant la méditation

## 7.3 Gong
Choix possibles :
- off
- début / fin
- début / transitions / fin

## 7.4 Ambiance sonore
Choix possibles :
- off
- pluie
- rivière
- forêt
- bruit blanc doux

### Contrainte produit
L’ambiance sonore est une option secondaire.
Elle ne doit jamais devenir l’élément principal du produit.

## 7.5 Rappels pendant la phase centrale
Choix possibles :
- off
- toutes les 3 min
- toutes les 5 min

---

## 8. Suivi de pratique

## 8.1 Statistiques
L’application doit afficher les statistiques suivantes :
- temps total médité
- nombre total de séances
- temps pratiqué sur 7 jours
- temps pratiqué sur 30 jours
- streak actuel
- meilleur streak

## 8.2 Streak
Le streak doit être présent, mais discret.

### Contraintes UX
- pas d’affichage culpabilisant
- pas de gamification infantilisante
- pas de badges
- pas de mise en avant excessive sur l’écran principal

---

## 9. Intégration HealthKit

## 9.1 Objectif
Permettre l’enregistrement des séances de méditation dans l’écosystème Santé d’Apple, afin de centraliser les minutes de pleine conscience.

## 9.2 Exigence produit
L’intégration HealthKit fait partie du périmètre de la V1.

## 9.3 Fonction principale
Après une séance terminée avec succès, l’application doit pouvoir enregistrer la séance dans HealthKit comme donnée de pleine conscience, selon les types de données appropriés disponibles dans l’API HealthKit.

## 9.4 Comportement attendu
- l’utilisateur peut autoriser ou refuser l’accès à HealthKit
- l’application fonctionne même sans autorisation HealthKit
- si l’autorisation est accordée, les séances terminées sont enregistrées dans HealthKit
- l’utilisateur peut désactiver cette synchronisation depuis les réglages

## 9.5 Conditions d’écriture
Une séance est enregistrée dans HealthKit uniquement si :
- elle a été réellement démarrée
- elle a été menée jusqu’à son terme ou suffisamment complétée selon la règle définie
- elle n’a pas été annulée immédiatement

### Règle V1 recommandée
Écrire dans HealthKit uniquement les séances terminées normalement.

## 9.6 Gestion des permissions
La demande de permission HealthKit ne doit pas apparaître sans contexte au premier lancement.

### Règle UX
La demande doit être faite :
- soit après la première séance terminée
- soit lors d’un écran de réglages dédié
- avec un texte simple expliquant l’intérêt :
  - enregistrer les minutes de pleine conscience dans l’app Santé
  - conserver un historique cohérent dans l’écosystème Apple

## 9.7 Échec d’écriture
Si l’écriture HealthKit échoue :
- la séance reste valide dans l’application
- l’échec ne bloque pas l’expérience utilisateur
- une gestion d’erreur silencieuse ou un message simple peut être prévue selon le contexte

## 9.8 Lecture HealthKit
En V1, la lecture de données HealthKit n’est pas obligatoire.

### Priorité V1
- écriture dans HealthKit : oui
- lecture avancée / agrégation complexe : non obligatoire

---

## 10. Écrans de l’application

## 10.1 Écran 1 — Accueil / lancement
### Contenu
- durée
- accompagnement
- gong
- ambiance
- bouton démarrer

### Objectif
Permettre de lancer une séance en 2 à 3 actions maximum.

### Contraintes UX
- écran lisible immédiatement
- réglages compréhensibles
- pas de surcharge d’informations
- pas de tunnel d’onboarding bloquant

## 10.2 Écran 2 — Séance en cours
### Contenu
- phase en cours
- temps restant
- bouton pause
- bouton arrêter

### Contraintes UX
- interface minimale
- pas d’animation inutile
- contraste suffisant
- état de séance lisible en un coup d’œil

## 10.3 Écran 3 — Fin de séance
### Contenu
- durée réalisée
- confirmation de fin
- indication éventuelle de synchronisation HealthKit
- bouton terminer

### Option V1
Aucune note ni saisie obligatoire.

## 10.4 Écran 4 — Statistiques
### Contenu
- temps total
- nombre de séances
- streak actuel
- meilleur streak
- temps 7 jours
- temps 30 jours

## 10.5 Écran 5 — Réglages
### Contenu
- préférences par défaut de séance
- gestion du gong
- gestion de l’ambiance
- gestion des rappels
- réglage HealthKit :
  - état de connexion
  - autorisation activée ou non
  - option d’activation / désactivation de l’écriture

---

## 11. Parcours utilisateur principaux

## 11.1 Premier usage
1. ouverture de l’app
2. réglage rapide de la durée
3. lancement d’une séance
4. fin de séance
5. proposition optionnelle d’activer HealthKit

## 11.2 Usage récurrent
1. ouverture de l’app
2. conservation des derniers réglages utilisés
3. démarrage rapide
4. enregistrement des statistiques
5. écriture HealthKit si activée

## 11.3 Consultation du suivi
1. ouverture de l’écran statistiques
2. consultation du temps pratiqué et du streak
3. aucune injonction ni relance agressive

---

## 12. Exigences UX / UI

## 12.1 Principes
- sobriété
- rapidité
- stabilité
- lisibilité
- ton neutre
- vocabulaire simple
- design natif iOS

## 12.2 À éviter
- animations décoratives
- citations inspirantes
- badges
- effets gamifiés
- notifications culpabilisantes
- écrans marketing internes

## 12.3 Accessibilité minimale
- tailles de texte lisibles
- bon contraste
- commandes simples
- labels clairs pour VoiceOver si possible dès la V1

---

## 13. Exigences techniques de haut niveau

## 13.1 Architecture fonctionnelle
L’application doit gérer :
- le moteur de séance
- le calcul des phases fixes et variables
- la lecture audio éventuelle :
  - gong
  - ambiance
  - guidage léger
- la persistance locale des statistiques
- l’intégration HealthKit

## 13.2 Persistance locale
Doivent être persistés localement :
- préférences de séance
- dernier réglage utilisé
- statistiques
- streak
- état de la préférence HealthKit côté app

## 13.3 Gestion d’état de séance
États minimum :
- prêt
- en cours
- pause
- terminé
- annulé

## 13.4 Audio
L’application doit permettre :
- lecture du gong
- lecture d’une ambiance en boucle si activée
- lecture éventuelle de courtes consignes en mode guidé léger
- transitions propres entre les phases

---

## 14. Notifications

## 14.1 V1
Les notifications ne sont pas indispensables au MVP.

## 14.2 Si ajoutées plus tard
Elles doivent rester sobres :
- rappel de pratique optionnel
- aucune formulation culpabilisante
- aucune logique de pression sur le streak

---

## 15. Contenu de la V1

## 15.1 Inclus dans la V1
- structure fixe intro / méditation / retour
- durée configurable
- 3 niveaux d’accompagnement
- gong configurable
- ambiance facultative
- rappels pendant la phase centrale
- statistiques sobres
- streak discret
- écriture dans HealthKit
- réglages simples

## 15.2 Exclus de la V1
- yoga
- routine matinale complète
- saisie d’objectifs du jour
- communauté
- abonnement complexe
- journal détaillé
- coaching personnalisé
- bibliothèque étendue de contenus
- lecture complexe de données HealthKit

---

## 16. Critères de réussite de la V1

La V1 est considérée comme réussie si :
- une séance peut être lancée en quelques secondes
- la structure des 3 phases est claire et fiable
- les réglages sont simples à comprendre
- le produit reste sobre et cohérent
- le suivi statistique est utile sans être envahissant
- l’écriture dans HealthKit fonctionne proprement pour les utilisateurs qui l’autorisent

---

## 17. Résumé exécutable

### Produit
App iOS minimaliste de méditation structurée pour pratiquants expérimentés.

### Cœur de l’expérience
- intro fixe : 2 min 30
- méditation centrale variable
- retour fixe : 1 min 32

### Réglages
- durée totale
- accompagnement
- gong
- ambiance
- rappels

### Suivi
- stats sobres
- streak discret
- intégration HealthKit

### Discipline produit
Préserver la pureté du concept : une app de pratique structurée, pas une plateforme bien-être généraliste.
