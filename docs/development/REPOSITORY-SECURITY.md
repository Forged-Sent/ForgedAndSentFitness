# Forged & Sent: GitHub governance and administrator checklist

The intent: every change arrives through a pull request; low-risk HTML
prototype iterations are fast, while **every other file is human-reviewed by
default**, including new files nobody anticipated. The server-side ruleset is
the security boundary. AGENTS.md, CODEOWNERS and CI do NOT activate it.

## Live enforcement note (2026-10-31)

GitHub's active Protect main ruleset currently requires pull requests and the ci-gate check, but global required approvals and app-reviewers minimum approvals are BOTH **0**. The one-approval policy documented below is a **stricter recommended target, NOT the current enforcement**. Codex/Claude/Gemini reviews are advisory and do not satisfy GitHub human approval requirements. See docs/development/AI-REVIEW-WORKFLOW.md. Do not treat CODEOWNERS or AI prompts as branch protection.

## 1. Organization team and identities

Create `Forged-Sent/app-reviewers`, add `@Chadillac12` and
`@sfcsmithc-afk`, and grant the **team** repository Write permission or
higher. PR authors cannot count as their own approving reviewer.
Review the install permissions for all AI agent/GitHub Apps, especially the
ChatGPT integration: where possible prefer PR creation without merge
permission, limit installations to the necessary repos, and avoid bot bypasses.
GitHub may not offer distinct PR-create and merge scopes for a given app.
If a write-capable integration can still merge zero-review prototype PRs,
record that as a **known residual risk**. Instructions telling agents not
to merge are not technical enforcement.

## 2. Create an ACTIVE branch ruleset on main

Open: https://github.com/Forged-Sent/ForgedAndSentFitness/settings/rules

- Target **main**; require pull requests. No direct `main` pushes, force
  pushes, branch deletion or standard bypass actors, including admins/bots.
- Require the always-created **`ci-gate`** GitHub Actions check. Never
  individually require conditional Flutter/platform jobs, which can skip.
- Under pull request rules, set general required approval count to **0**.
  Do not enable blanket CODEOWNERS approval, or prototype-only changes would
  lose their fast merge flow.
- Set **Dismiss stale pull request approvals when new commits are pushed**.
  This prevents previously approved code being modified without another
  human review. Unlike required last-push approval, it is not a standing
  requirement for prototype-only PRs; still validate the actual interaction
  with Required reviewers on GitHub before relying on it.
- Under **Required reviewers**, select team **app-reviewers** with
  **1 required approval** and paste EACH pattern below **in this order**.
  GitHub documents that negative patterns cancel earlier matches.
- Prefer squash merging, delete merged working branches and verify required
  reviews are still current immediately before the merge.

### Required reviewers path patterns (canonical list)

These patterns are also defined in `tooling/policy/review_scope.py`, and
checked against this document by `tooling/policy/check.py`.
**Start with the default-protected `**`**. Later `!` patterns carve out
only the low-risk prototype files; unrecognized and newly added files
still need a human reviewer.

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

**Requires review:** `mobile/**`, workflows and agents, all tooling, all
Python preview scripts such as `dev/make_preview.py` and
`dev/patches/*.py`, onboarding `docs/development/**`, rules/score
content such as `seed/db-rules.json`, `seed/tasks.json`,
`dev/firebase/**`, `firebase.json`, `.firebaserc`,
`firestore.indexes.json`, `functions/**` and ANY future path not
explicitly excluded above.

**No review required by default:** changes affecting only
`index.html`, `versions/**`, root `dev/*.html`,
`dev/mock-claude.js`, the explicitly listed low-risk seed data and
`README.md`. A PR mixing exception and protected files requires review.
An agent must still escalate auth, privacy, security or scoring changes
even inside `index.html`; path rules alone cannot inspect semantics.

The `.github/CODEOWNERS` file requests review on known protected paths.
It cannot use `!` negations, so it is **not** a complete mirror of this
fail-closed ruleset and it does not replace it.

## 3. Enable repository security

Repository Settings > Security > Code security and analysis:

- Secret scanning and push protection, where supported
- Dependabot alerts and security updates, where supported
- Check app permissions and audit existing/personal user-scope MCP server
  registrations on both developer machines; project MCP files cannot remove
  user-installed servers

Do not test with real tokens or credentials.

## 4. Validate the actual GitHub enforcement (do not assume!)

After enabling the ruleset and merging PR #3, use harmless test PRs:

1. `prototype/ui-test` edits only `index.html`: `ci-gate` runs,
   `prototype-checks` runs, Flutter jobs may skip, and no approval is
   required.
2. `feature/flutter-test` touches `mobile/`: one `app-reviewers`
   approval must be required.
3. `security/new-file-test` adds a new `firebase.json` or an unfamiliar
   root config: **one approval must be required**. Repeat with
   `dev/firebase/storage-lifecycle.json` and `dev/make_preview.py`.
4. In a protected test PR, approve, then push a new commit; verify the
   approval is dismissed and the merge is blocked until reapproval.
5. Confirm direct/force pushes to `main` are rejected, and a failing
   `ci-gate` blocks merging.
6. Inspect the effective ruleset in GitHub after saving, including pattern
   order and the team member permissions, to detect server-side drift.

Do not deliberately weaken main or expose real secrets to test this.
A separate temporary test PR is sufficient; close it unmerged.

## 5. Daily development

- HTML prototype: `prototype/<topic>` branch -> PR -> lightweight CI ->
  human manually decides when to merge (formal approval optional).
- Flutter: `feature/<topic>` branch -> tests -> PR -> other developer
  approves -> required CI -> merge.
- Security/tooling: `security/<topic>` or `chore/<topic>` branch ->
  focused negative tests -> PR -> other developer approves -> CI -> merge.
- Codex, Claude and Copilot follow the same flow. They must never
  self-approve or self-merge, but app permission controls must also be
  reviewed; instructions alone are not enforcement.

PR #4 covers the full device/emulator/MCP onboarding not completed in PR #3.
