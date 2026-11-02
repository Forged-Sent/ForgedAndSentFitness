# Forged & Sent: solo-maintainer GitHub governance

One maintainer can deliver changes without independent human approvals. The repository still requires a pull request and the deterministic `ci-gate` on protected `main`. Optional AI security reviews are recommended for Flutter databases, Firebase rules, Auth and sensitive data; they are not mandatory.

## Live protection, observed 2026-11-02
The current GitHub main ruleset requires `ci-gate`, with **zero required approving reviews**. No second-person approval should be configured for ordinary or security changes unless the maintainer separately chooses to change this. Never self-merge as an AI agent. CODEOWNERS routes responsibility but does not itself require approval.

## Solo-maintainer workflow
1. Make a focused branch and pull request. Preserve the existing HTML prototype and historical `versions/` snapshots.
2. Run required CI, unit/widget tests, policy checks, and positive/negative emulator tests for database rules. Report test gaps accurately.
3. For Flutter database/rules/authorization/privacy changes, **offer** a non-author AI review with `tooling/review/review.py`. The maintainer may skip it and document NOT VERIFIED.
4. Only the maintainer decides to merge, after `ci-gate` passes. A green CI does not prove production data safety or manual device acceptance.
5. Never deploy real Firebase credentials or production changes through demo contributor setup.

## Optional ownership routing
The CODEOWNERS file associates changes with the maintainer. It includes `mobile/`, `firebase/`, `.gemini/`, `docs/knowledge/`, tools and agent instructions. No outside person is required to approve. Ruleset settings, not CODEOWNERS or Markdown, determine enforcement.

## Scope classification (advisory)
Keep these patterns synchronized with `tooling/policy/review_scope.py`. They classify changes that deserve scrutiny; **they are not required reviewer rules**.

<!-- BEGIN REQUIRED_REVIEW_RULESET_PATTERNS -->
```gitignore
**
!index.html
!versions/**
!dev/*.html
!dev/mock-claude.js
!seed/devotionals*.json
!seed/lifts.json
!seed/esv-verses.json
!README.md
```
<!-- END REQUIRED_REVIEW_RULESET_PATTERNS -->

Files outside the exceptions, especially executable tooling and data policy, deserve additional care. Even prototype changes to scoring, privacy or access rules may be security-sensitive.

## Security controls to keep
- Require `ci-gate` for protected `main`; avoid force pushes, direct pushes or agent bypass actors.
- Preserve SHA-pinned Actions, dependency lockfiles, secret scanning/push protection where available.
- Keep cloud Firebase MCP and PROD credentials off contributor machines.
- Review and restrict GitHub App access; CODEOWNERS and prompts alone are not security controls.
- Require maintainer approval for production deployment; AI reviewers never count as humans.

## Optional independent AI database review
Example when Codex wrote the Flutter/Firebase change:

```sh
python3 tooling/review/review.py --author codex --reviewers claude --minimum 1
```

Review is advisory, never auto-run by CI, and does not require another person. If unavailable, report NOT VERIFIED and retain deterministic checks. See [AI review workflow](AI-REVIEW-WORKFLOW.md).
