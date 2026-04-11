# Project Claude Instructions

## Project goals
- privilégier les changements simples et robustes
- préserver le comportement existant sauf demande contraire
- éviter les modifications larges non justifiées

## Workflow
- proposer un plan court avant un changement structurel
- valider les commandes de build, test et lint avant de conclure
- documenter les hypothèses quand l'intention du code existant n'est pas certaine

## Project conventions
- lire la documentation locale du projet avant les changements larges
- respecter la structure et les conventions déjà établies si elles sont cohérentes
- considérer `~/Sites/siturem` comme racine du repo et du projet
- considérer `~/Sites/siturem/Siturem` comme dossier principal du code applicatif SwiftUI
- préserver autant que possible la structure actuelle du code dans `Siturem/`

## Local project documentation
- un dossier `docs/` est présent à la racine du repo
- ce dossier contient notamment :
  - `docs/BrandingGuideline.md`
  - `docs/cahierCharges-v1.md`
- considérer ces documents comme sources de référence produit, UX, ton, périmètre et priorités fonctionnelles
- les consulter avant toute modification structurelle, décision d’architecture UI, wording produit ou implémentation métier

## Shared project tracking
- maintenir `TODO.md` à la racine du repo
- maintenir `PROJECT_STATUS.md` à la racine du repo
- `TODO.md` sert à suivre les tâches concrètes, priorisées et actionnables
- `PROJECT_STATUS.md` sert à suivre l’état global du projet, les décisions structurantes, les points ouverts et le prochain focus
- lors d’un changement significatif, mettre à jour ces fichiers si nécessaire

## Collaboration rules for multiple AIs
- considérer que le projet est travaillé conjointement par Claude Code et Codex
- éviter d’écraser inutilement une structure déjà posée
- expliciter les choix structurants dans `PROJECT_STATUS.md`
- ajouter les prochaines étapes concrètes dans `TODO.md`
- en cas d’ambiguïté entre plusieurs options valides, choisir la plus simple et documenter le choix
