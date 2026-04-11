# Repository Guidelines

## Project Structure & Module Organization
`Siturem/` contains the app source. Keep app entry code in `Siturem/App/`, data types in `Siturem/Models/`, SwiftUI screens in `Siturem/Views/`, and business logic in `Siturem/Services/`. Assets live in `Siturem/Resources/Assets.xcassets`; audio content, if added, should follow the existing `Siturem/Audio/` organization. Product and branding references are in `docs/`, while `project.yml` is the source of truth for the generated Xcode project.

## Build, Test, and Development Commands
- `xcodegen generate` regenerates `Siturem.xcodeproj` after changes to `project.yml` or when files are added or removed under `Siturem/`.
- `open Siturem.xcodeproj` opens the app in Xcode for day-to-day development.
- `xcodebuild -project Siturem.xcodeproj -scheme Siturem -destination 'platform=iOS Simulator,name=iPhone 16' build` runs a command-line simulator build.

There is currently no committed XCTest bundle, so add a test target before relying on `xcodebuild test`.

## Coding Style & Naming Conventions
Use standard Swift formatting with four-space indentation. Follow Swift naming norms: `PascalCase` for types, `camelCase` for properties, methods, and enum cases, and file names that match the primary type, such as `SessionEngine.swift`. Keep SwiftUI views small and composable, and prefer the existing `@Observable`-based patterns already used in the app. No repository-specific SwiftLint or SwiftFormat configuration is present.

## Testing Guidelines
Tests are not configured yet. When you add them, place unit tests in a `SituremTests/` target, name files `SomethingTests.swift`, and use `test...` method names. Focus coverage on session timing, statistics persistence, and configuration logic.

## Commit & Pull Request Guidelines
This clone has no commit history yet, so there is no established project-specific commit convention. Use short, imperative commit subjects and keep pull requests focused on a single change. Include a clear summary, mention any `xcodegen generate` step you ran, and add screenshots for visible UI changes.

## Source of Truth
For product behavior, prefer `README.md`, `docs/cahierCharges-v1.md`, and `docs/BrandingGuideline.md` over assumptions. Update `PROJECT_STATUS.md` or `TODO.md` when you change shared project decisions or follow-up work.
