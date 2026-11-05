---
description: Run checks before opening a draft PR.
---
Verify a non-main feature branch, run flutter analyze and flutter test,
then explain any failures. If checks pass and the user explicitly asks
you to share, invoke the project's fs-share workflow to create a draft PR.
Never force-push, deploy Firebase or merge on behalf of the user.
