---
name: squash
description: Squash this branch's redundant commits
---

Squash the commits in `git log @{upstream}..HEAD` into a small number of clean
commits grouped by topic. Leave anything already on `@{upstream}` alone, it has
been shared. Auto-pushing your branch does not count as sharing.

Rebuild them with `git reset --soft @{upstream}` then recommit.
