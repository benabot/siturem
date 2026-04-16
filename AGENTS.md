# Repository Guidelines

## Project Structure & Module Organization
`Siturem/` contains the app source.

- Keep app entry code in `Siturem/App/`
- Keep data types in `Siturem/Models/`
- Keep SwiftUI screens in `Siturem/Views/`
- Keep business logic and external integrations in `Siturem/Services/`

Assets live in `Siturem/Resources/Assets.xcassets`.

Audio content should follow `Siturem/Audio/`.

HealthKit-related code should be isolated in `Siturem/Services/Health/` or the closest dedicated service area rather than mixed into views or unrelated services.

Product, marketing, branding references, and the active V2 backlog live in `docs/`.

`project.yml` is the source of truth for the generated Xcode project.

## Skills Available in This Repo
Use the smallest relevant skill for the task.

- `project-kickoff`: start-of-task framing only
- `swift-test-cycle`: short implementation or fix loop with local validation
- `swift-bugfix`: diagnose and patch a bug with minimal safe diff
- `swiftui-feature`: implement a focused SwiftUI feature
- `healthkit-integration`: add or adjust HealthKit integration
- `localization-review`: review or implement localization-ready changes
- `ios-marketing`: produce marketing copy aligned with product and brand
- `app-store-copy`: write App Store metadata and release copy
- `docs-sync`: update shared status and follow-up documentation

Prefer a focused skill over a general one.

## Task Routing
- Start with `project-kickoff` for new feature, bug, refactor, or product-scope requests.
- Use `docs/2026-04-16-siturem-v2-backlog.md` first for V2 UX/UI and feature evolution.
- Use `swift-bugfix` for regressions, crashes, incorrect behavior, or compiler fixes.
- Use `swiftui-feature` for user-facing UI work.
- Use `swift-test-cycle` when implementing or validating a contained Swift change.
- Use `healthkit-integration` for permissions, HealthKit types, queries, or syncing health data.
- Use `localization-review` whenever user-facing strings, locale-sensitive formatting, or multilingual rollout are involved.
- Use `ios-marketing` or `app-store-copy` for product messaging, ASO, or store-facing content.
- Use `docs-sync` when shared behavior, architecture, status, or follow-up work changes.

## Build, Test, and Development Commands
- `xcodegen generate` regenerates `Siturem.xcodeproj` after changes to `project.yml` or when files are added or removed under `Siturem/`.
- `open Siturem.xcodeproj` opens the app in Xcode for day-to-day development.
- `xcodebuild -project Siturem.xcodeproj -scheme Siturem -destination 'platform=iOS Simulator,name=iPhone 16' build` runs a command-line simulator build.

There is currently no committed XCTest bundle, so add a test target before relying on `xcodebuild test`.

## Coding Style & Naming Conventions
Use standard Swift formatting with four-space indentation.

Follow Swift naming norms:
- `PascalCase` for types
- `camelCase` for properties, methods, and enum cases
- file names that match the primary type

Keep SwiftUI views small and composable.

Prefer the existing `@Observable`-based patterns already used in the app.

No repository-specific SwiftLint or SwiftFormat configuration is present.

## Testing Guidelines
Tests are not configured yet.

When you add them:
- place unit tests in a `SituremTests/` target
- name files `SomethingTests.swift`
- use `test...` method names

Focus coverage on:
- session timing
- statistics persistence
- configuration logic
- HealthKit mapping and permission-state handling when HealthKit support is added

## Commit & Pull Request Guidelines
This clone has no commit history yet, so there is no established project-specific commit convention.

Use short, imperative commit subjects.

Keep pull requests focused on a single change.

Include:
- a clear summary
- any `xcodegen generate` step you ran
- screenshots for visible UI changes
- note of localization or HealthKit impact when relevant

## Project-Specific Guardrails
- Keep `SessionEngine` focused on session timing and session state only. Do not add audio playback logic to it.
- Prefer minimal, localized diffs over broad refactors.
- Do not modify stable SwiftUI views unless the requested task directly requires it.
- Treat `project.yml` as the source of truth for the Xcode project; do not hand-edit generated project files.
- When changing shared behavior, architecture, or implementation status, update `PROJECT_STATUS.md` and `TODO.md`.
- Keep integrations such as HealthKit isolated from presentation code.
- Prefer native Apple frameworks over third-party dependencies unless explicitly required.
- Do not add unsupported marketing claims or product promises to code comments, docs, or copy.

## HealthKit
- Treat HealthKit as an optional capability that requires explicit authorization handling.
- Do not assume HealthKit is available on every device or in every runtime context.
- Keep HealthKit entitlements, permissions, and data-type decisions explicit.
- Isolate HealthKit read/write logic in dedicated services.
- Do not bury permission or failure-state handling inside SwiftUI views.
- When behavior depends on HealthKit authorization state, make the state visible in code and testable.

## Localization & Multilingual
- Do not introduce new user-facing hardcoded strings without considering localization.
- Keep code ready for future multilingual expansion, including meditation content and audio guidance assets.
- Do not couple asset filenames to displayed UI labels.
- Preserve product terminology and tone across locales.
- Watch for locale-sensitive formatting such as dates, durations, numbers, and units.
- For localization decisions, defer to `docs/meditation-market-priorities.md` and branding documents.

## Marketing & App Store Content
- Treat product docs and branding docs as source of truth for marketing copy.
- Keep claims accurate, specific, and supportable by the product.
- Prefer clear user benefit over vague inspirational phrasing.
- When producing App Store or marketing content, consider localization and market priorities from the docs.
- Keep store-facing copy reusable across future multilingual rollout.

## Source of Truth Priority
When documents differ, use this order:
1. `docs/cahierCharges-v1.md` for product behavior
2. `docs/BrandingGuideline.md` for tone and terminology
3. `docs/2026-04-16-siturem-v2-backlog.md` for V2 UX/UI and feature priorities
4. `docs/meditation-market-priorities.md` for language, market, localization, and messaging priorities
5. `PROJECT_STATUS.md` and `TODO.md` for shared implementation status and next steps
6. `README.md` for general repository context

## Documentation Updates
Update `PROJECT_STATUS.md` or `TODO.md` when you change:
- shared behavior
- architecture
- implementation status
- major follow-up work
- HealthKit integration scope
- multilingual rollout decisions
- V2 UX/UI or feature priorities

Update `docs/2026-04-16-siturem-v2-backlog.md` when V2 UX/UI or feature priorities change.

## Source of Truth
For product behavior, prefer `README.md`, `docs/cahierCharges-v1.md`, and `docs/BrandingGuideline.md` over assumptions.
Update `PROJECT_STATUS.md` or `TODO.md` when you change shared project decisions or follow-up work.
