---
name: swiftui-feature
description: Implement a focused SwiftUI feature with minimal impact on stable code.
---

When this skill is invoked:
- identify the requested user-facing behavior
- find the smallest existing SwiftUI surface to extend
- respect current app structure: App, Models, Views, Services
- keep views small and composable
- use existing state and observable patterns when possible
- consider localization before adding user-facing strings
- list local validation steps

Output:
- goal
- files to change
- implementation plan
- code
- validation steps
- assumptions if any

Rules:
- prefer extension of current patterns over new abstractions
- avoid broad UI rewrites
- do not introduce hardcoded user-facing strings casually
- keep accessibility and localization in scope
- if the feature changes shared behavior, update PROJECT_STATUS.md and TODO.md
