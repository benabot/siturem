# PROJECT STATUS

## Projet
Siturem — Méditation structurée

## Racine repo
`~/Sites/siturem`

## Dossier code applicatif
`~/Sites/siturem/Siturem`

## État actuel
Base fonctionnelle — UI et logique métier complètes. Audio et intégration HealthKit restent à implémenter pour compléter la V1.

**Chantier en cours : refonte visuelle et UX.**
L'interface actuelle est fonctionnelle mais austère (noir pur, compteur numérique, pas de couleur). Objectif : rendre l'app vivante et chaleureuse tout en restant minimaliste et fidèle au branding (cf. BrandingGuideline §11-12).

## Fonctionnel

| Composant | État |
|-----------|------|
| Architecture (TabView, navigation) | ✅ Complet |
| SessionEngine (phases, timer, états) | ✅ Complet |
| SessionConfiguration / SessionModels / SessionRecord | ✅ Complet |
| PreferencesStore (UserDefaults) | ✅ Complet |
| StatsStore (persistance + streaks) | ✅ Complet |
| HomeView (sélection durée/modes) | ✅ Complet |
| SessionView (séance en cours) | ✅ Complet |
| SessionSummaryView (bilan) | ✅ Complet |
| StatsView (statistiques) | ✅ Complet |
| SettingsView (réglages + HealthKit toggle) | 🔄 À refondre — retirer la duplication session, garder HealthKit + prefs système |
| HealthKitService (service shell) | ⚠️ Partiel — non intégré au flux |
| AudioService | ⚠️ Partiel — arborescence audio créée, assets à fournir |

## Points ouverts

- **Audio** : arborescence `Audio/` en place (Gongs/, Ambiance/, VoiceGuidance/{Intro,Reminders,Outro}) — assets `.caf` à déposer, AudioService à implémenter
- **HealthKit** : service présent mais non appelé à la fin de séance ; entitlements vides
- **Tests** : aucun test unitaire ou UI en place
- **Icône app** : AppIcon manquante dans Assets.xcassets

## Références locales
- `docs/BrandingGuideline.md` — identité visuelle, ton, territoire
- `docs/cahierCharges-v1.md` — spécifications fonctionnelles complètes (source de vérité)

## Contexte produit
Application iOS minimaliste de méditation structurée pour pratiquants autonomes.

## Positionnement
- sobre
- stable
- structurée
- discrète
- non mystique
- non gamifiée

## Décisions prises
- Nom produit : Siturem
- Sous-titre : Méditation structurée
- Racine de coordination : `~/Sites/siturem`
- Code applicatif SwiftUI : `~/Sites/siturem/Siturem`
- Documentation produit : `docs/`
- Suivi partagé (Claude Code + Codex) : `TODO.md` et `PROJECT_STATUS.md`
- Architecture : SwiftUI + @Observable, iOS 17+, pas de dépendances externes
- Persistance : UserDefaults + JSON (local uniquement pour V1)
- Phases de séance fixes : intro 150 s + méditation variable + closing 45 s
- **Refonte visuelle** : palette anthracite + accent bleu ardoise (pas de noir pur), blob animé en séance à la place du compteur, barre de progression globale (pas par phase)
- **Refonte SettingsView** : séparation claire entre configuration de séance (HomeView) et préférences système (SettingsView). SettingsView conservée mais recentrée sur : HealthKit, couleur d'accent de l'interface, voix/langue (futur), version. Les pickers accompagnement/gong/ambiance/rappels sont retirés de SettingsView (ils sont déjà dans HomeView)

## Prochain focus
Refonte visuelle et UX (palette, blob, progression, fusion réglages). Voir TODO.md pour le détail des étapes.
