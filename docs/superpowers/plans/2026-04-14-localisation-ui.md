# UI Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a localized Siturem interface in fr / en-US / es / de, with a persistent UI language switcher, while keeping audio localization separate.

**Architecture:** Keep `PreferencesStore` as the single persistence point for UI preferences, add a distinct `AppLanguage` setting for interface language, and apply it at the SwiftUI root via `environment(\.locale, ...)`. Use localized resources for visible strings and keep audio locale logic untouched.

**Tech Stack:** SwiftUI, `@Observable`, `UserDefaults`, XcodeGen, `.strings` localization resources, iOS 17+, Swift 5.10.

---

### Task 1: Document the new localization phase

**Files:**
- Modify: `TODO.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CLAUDE.md`
- Modify: `README.md`

- [x] **Step 1: Add a dedicated UI localization phase to TODO**
- [x] **Step 2: Update project status and repo guidance to mention UI/audio separation**
- [x] **Step 3: Regenerate or refresh any generated project metadata if needed**
- [x] **Step 4: Verify the documentation matches the shipped behavior**

### Task 2: Add UI language persistence and root locale wiring

**Files:**
- Create: `Siturem/Models/AppLanguage.swift`
- Modify: `Siturem/Services/PreferencesStore.swift`
- Modify: `Siturem/App/SituremApp.swift`
- Modify: `Siturem/Views/ContentView.swift`

- [x] **Step 1: Add a codable `AppLanguage` enum with a locale mapping**
- [x] **Step 2: Persist the selected UI language in `PreferencesStore`**
- [x] **Step 3: Apply the selected UI locale at the app root**
- [x] **Step 4: Pass the shared preferences store into the root content view**

### Task 3: Localize all visible UI strings

**Files:**
- Modify: `Siturem/Models/SessionModels.swift`
- Modify: `Siturem/Views/HomeView.swift`
- Modify: `Siturem/Views/Onboarding/OnboardingView.swift`
- Modify: `Siturem/Views/SessionView.swift`
- Modify: `Siturem/Views/SessionSummaryView.swift`
- Modify: `Siturem/Views/SettingsView.swift`
- Modify: `Siturem/Views/StatsView.swift`
- Modify: `Siturem/Views/SplashView.swift`
- Modify: `Siturem/Views/SituremMark.swift`

- [x] **Step 1: Replace enum-derived raw string labels with localized display labels**
- [x] **Step 2: Convert helper signatures that receive labels to localized resources**
- [x] **Step 3: Add the Settings language switcher with explicit UI/audio separation**
- [x] **Step 4: Keep the audio logic and audio asset names unchanged**

### Task 4: Add localization resources and validate the build

**Files:**
- Create: `Siturem/Resources/Localization/fr.lproj/Localizable.strings`
- Create: `Siturem/Resources/Localization/en.lproj/Localizable.strings`
- Create: `Siturem/Resources/Localization/es.lproj/Localizable.strings`
- Create: `Siturem/Resources/Localization/de.lproj/Localizable.strings`
- Create: `Siturem/Resources/Localization/fr.lproj/InfoPlist.strings`
- Create: `Siturem/Resources/Localization/en.lproj/InfoPlist.strings`
- Create: `Siturem/Resources/Localization/es.lproj/InfoPlist.strings`
- Create: `Siturem/Resources/Localization/de.lproj/InfoPlist.strings`
- Modify: `project.yml`

- [x] **Step 1: Add translation resources for all shipped UI locales**
- [x] **Step 2: Add localized HealthKit permission strings**
- [x] **Step 3: Set the development language to French in XcodeGen**
- [x] **Step 4: Regenerate the project and verify the app builds**
