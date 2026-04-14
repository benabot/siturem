---
name: swift-bugfix
description: Diagnose a Swift or SwiftUI bug and apply the smallest safe fix.
---

When this skill is invoked:
- identify the root cause before changing code
- locate the smallest affected surface
- preserve existing architecture and project conventions
- prefer a minimal localized patch over refactor
- explain how to verify the fix locally
- if relevant, add or suggest one targeted test

Output:
- root cause
- affected files
- smallest valid fix
- validation steps
- follow-up only if necessary

Rules:
- do not change stable views unless required by the bug
- keep SessionEngine limited to session timing and session state
- do not edit generated Xcode project files manually
- update PROJECT_STATUS.md and TODO.md if shared behavior changes
- do not rewrite working code without a clear reason
