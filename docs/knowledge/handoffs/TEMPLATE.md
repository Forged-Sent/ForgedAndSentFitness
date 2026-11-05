# Task handoff template (copy to a new task-specific file)

Do not commit a note with placeholder SHA or claim tests were run. Required YAML metadata in active notes:

```yaml
---
status: active
updated: YYYY-MM-DD
owner: agent-or-maintainer
source_ref: feature/task-branch
source_sha: full-40-character-git-commit
---
```

## Goal and acceptance conditions
What the user requested, relevant issue/PR, and specific measurable behavior.

## Verified observations
Exact paths/lines or test outputs at source_sha. Separate facts from proposed design.

## Work performed
Diff/commit/PR links, design choices, rejected alternatives.

## Test and platform matrix
Commands executed and results, plus every check NOT VERIFIED and why.

## Risks, blockers and decisions
Credentials/data safety, platform gaps, unapproved product decisions.

## Next action
One precise executable next step; include ownership and links.

After merge set status: completed and include merged PR. When replaced set status: superseded with successor link.
