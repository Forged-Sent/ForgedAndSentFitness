---
status: archived
updated: 2026-11-11
owner: Chadillac12
source_ref: main
source_sha: 1c26ccd05d11df3c00a6a7824b2027346406bc2f
superseded_by: AGENTS.md
original_path: .github/prompts/ship.prompt.md
original_sha256: 58b514bc86e34e37db16c241c7b00d86e81f38fb1bc7797cc66c8838e5e58ede
description: Run checks before opening a draft PR.
---
Verify a non-main feature branch, run flutter analyze and flutter test,
then explain any failures. If checks pass and the user explicitly asks
you to share, invoke the project's fs-share workflow to create a draft PR.
Never force-push, deploy Firebase or merge on behalf of the user.
