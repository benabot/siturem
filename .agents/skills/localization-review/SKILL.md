---
name: localization-review
description: Review or implement multilingual user-facing strings and localization readiness.
---

When this skill is invoked:
- identify user-facing strings introduced or modified
- check whether strings should be localized
- keep display labels decoupled from asset names and internal identifiers
- flag locale-sensitive formatting needs
- preserve branding and terminology from project docs
- propose the smallest change that keeps the app localization-ready

Output:
- strings affected
- localization risks
- files to change
- recommended implementation
- follow-up items if needed

Rules:
- do not leave new user-facing strings hardcoded without reason
- do not couple localized labels to file names
- do not translate blindly when terminology should stay brand-consistent
- defer tone and terminology to branding and market docs
