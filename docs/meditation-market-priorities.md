# Siturem — Priorités pays et langues pour la localisation

## Objet

Ce document fixe une **priorisation pragmatique** des pays et des langues à considérer pour la localisation de Siturem, à partir des signaux de marché les plus crédibles disponibles sur les apps de méditation.

Il ne s'agit pas d'un classement absolu des téléchargements mondiaux par pays. Ce type de classement global, public et fiable, est rarement disponible sans données payantes de type App Intelligence. En revanche, plusieurs signaux convergent suffisamment pour guider une feuille de route produit.

---

## Conclusion opérationnelle

### Pays à cibler en premier

**Tier 1**
1. États-Unis
2. Royaume-Uni
3. Canada
4. Australie
5. France

**Tier 2**
6. Allemagne
7. Nouvelle-Zélande
8. Espagne
9. Inde
10. Japon

### Langues à cibler en premier

**Ordre recommandé pour Siturem**
1. Anglais
2. Français
3. Allemand
4. Espagnol
5. Portugais
6. Mandarin chinois
7. Japonais
8. Coréen

---

## Ce que disent les signaux de marché

### 1. L'anglais domine encore clairement

Les grands acteurs du secteur confirment que l'anglais reste la langue pivot.

- Headspace propose officiellement l'anglais, le français, l'allemand, l'espagnol, le portugais et le mandarin.
- Headspace précise aussi que ses prochaines extensions linguistiques suivent les langues les plus importantes là où se trouvent ses membres.
- Calm propose aujourd'hui un jeu de langues encore plus large : anglais, espagnol, allemand, français, coréen, portugais, japonais, italien, mandarin chinois et polonais.

Conséquence produit : toute stratégie de localisation sérieuse doit commencer par **l'anglais**, puis couvrir les langues européennes majeures avant d'ouvrir l'Asie de l'Est.

### 2. L'Amérique du Nord reste le cœur du marché

Les rapports de marché récents convergent sur un point : **l'Amérique du Nord est la première région** pour les apps de méditation en part de marché ou en revenus.

Cela rend le bloc suivant prioritaire :
- États-Unis
- Canada

Le Royaume-Uni et l'Australie suivent logiquement comme extensions naturelles du même marché linguistique et culturel, avec un coût de localisation très faible une fois la base anglaise produite.

### 3. L'Europe occidentale est la zone suivante la plus rationnelle

Les langues les plus cohérentes après l'anglais sont celles qui reviennent chez les leaders du secteur et dans les zones à forte adoption du bien-être numérique :
- français
- allemand
- espagnol
- portugais

Pour Siturem, la **France** a une priorité particulière :
- cohérence avec le contexte produit actuel
- facilité d'itération UX writing
- capacité à lancer et affiner l'expérience sans dette de traduction initiale

### 4. L'Asie-Pacifique est surtout une zone de croissance

Les signaux de marché indiquent que l'Asie-Pacifique est une zone de forte progression. Cela justifie de préparer plus tard :
- Japonais
- Coréen
- Mandarin chinois

Mais ce n'est pas le point d'entrée le plus simple pour une V1, surtout pour un produit sobre, très dépendant du ton, du microcopy et de la cohérence UX.

---

## Lecture produit spécifique à Siturem

Siturem n'est pas une app de relaxation grand public. Le produit vise une pratique autonome, structurée, discrète et peu bavarde.

Ce positionnement entraîne plusieurs conséquences :

1. **Le texte compte beaucoup.**
   Même avec peu de copy, chaque mot doit être juste. Une mauvaise localisation affaiblit immédiatement la crédibilité du produit.

2. **La voix future complexifie le sujet.**
   Le cahier des charges prévoit à terme une logique de voix/langue et de guidage léger. Chaque nouvelle langue implique alors :
   - traduction UI
   - adaptation du ton
   - enregistrement audio éventuel
   - validation native de la terminologie

3. **Il faut éviter de disperser la V1.**
   Une base solide en 2 ou 3 langues vaut mieux qu'un support superficiel en 8 langues.

---

## Recommandation de feuille de route

### Phase 1 — Base produit
- Français
- Anglais

**Objectif** : couvrir le marché de départ, préparer l'App Store, structurer l'architecture i18n, tester les contraintes UX writing.

### Phase 2 — Europe élargie
- Allemand
- Espagnol

**Objectif** : ouvrir les langues à fort rendement avec une complexité encore raisonnable.

### Phase 3 — Expansion structurée
- Portugais
- Mandarin chinois

**Objectif** : élargir la portée sans attaquer tout de suite les marchés les plus coûteux en adaptation produit.

### Phase 4 — Asie de l'Est avancée
- Japonais
- Coréen

**Objectif** : expansion ciblée quand l'app, l'audio et le support qualité sont déjà solides.

---

## Décisions à implémenter dans le produit

### 1. Préparer l'internationalisation dès maintenant
À faire côté code :
- externaliser toutes les chaînes UI dans un système de localisation
- éviter les chaînes en dur dans les vues SwiftUI
- normaliser les clés de traduction par écran et par domaine
- prévoir des libellés courts compatibles avec des langues plus longues que le français

### 2. Séparer clairement texte UI et contenu audio
À faire côté architecture :
- distinguer les labels UI des scripts de guidage vocal
- versionner les scripts audio indépendamment des chaînes d'interface
- prévoir qu'une langue puisse être disponible en UI avant d'être disponible en voix

Note d'implémentation actuelle :
- l'UI de Siturem est déjà livrée en fr / en-US / es / de
- le switcher de langue UI est dans `SettingsView`
- la langue audio reste séparée et hors scope de cette phase

### 3. Définir une matrice de disponibilité par langue
Exemple recommandé :
- **UI uniquement** : langues secondaires au démarrage
- **UI + audio** : langues principales validées

### 4. Prévoir une terminologie stricte
Le positionnement de Siturem impose une rédaction stable et non marketing. Il faut figer un lexique de base pour chaque langue, notamment pour :
- séance
- durée
- phase
- gong
- ambiance
- retour
- pratique
- régularité
- statistiques

### 5. Prioriser les stores et métadonnées en conséquence
À faire plus tard mais à anticiper :
- App Store metadata en anglais et français en premier
- déclinaisons localisées ensuite pour allemand et espagnol
- cohérence stricte entre branding, screenshots et microcopy

---

## Priorité finale recommandée

### Priorité pays
1. États-Unis
2. France
3. Royaume-Uni
4. Canada
5. Allemagne
6. Australie
7. Espagne
8. Nouvelle-Zélande
9. Inde
10. Japon

### Priorité langues
1. Français
2. Anglais
3. Allemand
4. Espagnol
5. Portugais
6. Mandarin chinois
7. Japonais
8. Coréen

---

## Arbitrage assumé

Deux lectures sont possibles :

- **lecture purement marché** : anglais d'abord, puis grandes langues internationales
- **lecture produit Siturem** : français + anglais d'abord, car cela réduit le risque de dilution du ton et accélère la qualité d'exécution

Pour Siturem, la seconde lecture est la bonne.

---

## Sources externes utilisées

- Grand View Research — *Meditation Management Apps Market | Industry Report, 2033*  
  Indique que l'Amérique du Nord reste la région dominante du marché.

- Persistence Market Research — *Meditation Management Apps Market Size & Forecast, 2033*  
  Indique que l'Amérique du Nord représente environ 39 % du marché mondial en 2025.

- Headspace Help Center — *Is Headspace offered in other languages?*  
  Confirme la présence officielle des langues : anglais, français, allemand, espagnol, portugais, mandarin.

- Headspace Help Center — *What languages are the Headspace Hub available in?*  
  Précise les cinq langues cœur et le principe d'expansion selon la localisation des membres.

- Calm Support — *Calm in Different Languages*  
  Confirme la disponibilité actuelle de dix langues majeures, dont japonais, coréen et mandarin chinois.
