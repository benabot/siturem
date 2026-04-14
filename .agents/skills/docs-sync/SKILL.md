---
name: docs-sync
description: Update shared project documentation after changes to behavior, architecture, status, or follow-up work.
---

When this skill is invoked:
- identify whether the change affects shared behavior, architecture, or project status
- update PROJECT_STATUS.md and TODO.md when needed
- keep entries short, factual, and action-oriented
- preserve source-of-truth priority across repo docs

Output:
- docs to update
- exact updates
- follow-up items if any

Rules:
- do not duplicate the same note across multiple files unnecessarily
- do not change product docs unless the task requires it
- keep status notes concrete and current
