---
name: healthkit-integration
description: Add or modify HealthKit integration using native iOS patterns and safe permission handling.
---

When this skill is invoked:
- identify the exact HealthKit data types and use case
- use native Apple frameworks only
- keep HealthKit authorization, reading, and mapping logic explicit
- isolate HealthKit code from unrelated app logic
- handle unavailable, denied, and restricted states clearly
- describe required entitlements, Info.plist usage text, and validation steps
- propose the smallest viable integration path

Output:
- use case
- HealthKit types involved
- files to change
- code
- permission / entitlement requirements
- validation steps
- edge cases

Rules:
- do not assume HealthKit availability
- do not hide authorization logic
- do not couple HealthKit logic to SwiftUI views more than needed
- keep business logic out of views
- do not invent product behavior when docs are missing
