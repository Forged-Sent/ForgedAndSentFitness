# Forged & Sent repository governance and administrator setup

This public repository uses a single protected `main`, short-lived feature branches,
required pull requests, a mandatory `ci-gate`, and **path-specific human reviews**.
The HTML prototype is a fast iteration surface; the Flutter application and security
policy are subject to stricter review.

**Important:** Code and `CODEOWNERS` files do not activate GitHub rulesets or
secret scanning. A repository administrator must do the GitHub UI setup below.
Do not claim the repository is protected until the live GitHub settings show it.

## 1. GitHub organization team

In the `Forged-Sent` organization, create a team named **app-reviewers**.
Add `@Chadillac12` and `@sfcsmithc-afk`. Both accounts currently have
repository administrator rights (confirmed 2026-10-31); ensure the team
itself has **Write** or higher permission on `ForgedAndSentFitness`.

An author cannot approve their own PR. For two-person development, the other
developer supplies the review when GitHub requires one.

## 2. Protect main with a repository branch ruleset

Open: https://github.com/Forged-Sent/ForgedAndSentFitness/settings/rules

Create an **active branch ruleset** targeting the default branch `main`.
Configure the following:

- Require a pull request before merging. No direct push to `main`.
- Keep **general required approvals at 0**, not 1. Otherwise ordinary HTML
  prototype PRs would be blocked waiting for a reviewer.
- Under **Required reviewers**, choose the organization team `app-reviewers`,
  require **1 approval**, and add the protected file patterns below.
- Require status check **`ci-gate`** from **GitHub Actions**. That named job
  is always created. Do not require individually path-skipped Flutter jobs.
- Block force pushes and branch deletion. No normal bypass, including admins.
  Never bypass the rule for AI-generated changes.
- Prefer squash merges and delete the merged feature branch. A strict
  up-to-date requirement is optional: it reduces stale builds but makes
  concurrent prototype PRs refresh more often.
- Do not also turn on global **1 approval**, global **code owner approval**,
  or an extra latest-push approval rule if your goal is zero-review
  prototype-only PRs. GitHub's Required reviewers rule is the path gate.

### File patterns for 1 required team approval

Enter these patterns for the single `app-reviewers` team, each as a
separate pattern. GitHub uses `.gitignore`-style path matching:

```gitignore
mobile/**
tooling/**
.github/**
.codex/**
.claude/**
.agents/**
.vscode/**
docs/architecture/**
firebase/**
.mcp.json
.gitignore
.gitattributes
AGENTS.md
CLAUDE.md
*.cmd
*.command
*.rules
seed/db-rules.json
seed/tasks.json
seed/weekly-challenges.json
seed/movement-standards.json
```

The patterns intentionally **exclude** ordinary `index.html`,
`versions/**`, `dev/**`, `seed/lifts.json`, `seed/devotionals.json`,
`README.md`, and prototype documentation. PRs changing only those files
can merge after mandatory CI without a required approval. Voluntary review
is always welcome. PRs spanning protected and prototype files require approval.

The `.github/CODEOWNERS` file lists the same protected areas to request
reviews from the two named people. CODEOWNERS is helpful for routing, but
**do not use a wildcard owner**: it would bring the prototype into the
protected group if code-owner reviews are later made mandatory.

Security-critical edits inside `index.html` (auth, privacy or scoring logic)
cannot be reliably detected just by filename. The agent instructions require
human escalation for such decisions; ultimately they must be moved to
reviewed, server-enforced code before production. Agent instructions are
guidance, not a security boundary.

## 3. Repository security switches

Open repository **Settings > Security > Code security and analysis**.
Enable secret scanning, secret push protection, Dependabot alerts and
Dependabot security updates where available. Do not use a real secret
to test any protection.

## 4. Check the intended behavior

After the ruleset is active and the governance changes from PR #3 are merged:

1. Open a `prototype/sample-ui` PR changing only `index.html`. It should
   run `policy`, `prototype-checks` and `ci-gate`, skip expensive Flutter
   builds, and **not** require a reviewer.
2. Open a `feature/sample-flutter` PR that touches `mobile/`. It should
   require one `app-reviewers` approval and the relevant Flutter CI.
3. Open a PR touching `.github/workflows/ci-gate.yml`. It should require
   approval and run all relevant CI lanes.
4. Verify direct pushes and force pushes to `main` are rejected.
5. Verify a deliberately failing test prevents merge via `ci-gate`.
6. Confirm there is no bypass by a bot, agent, or routine administrator.

Do not perform destructive or credential-bearing "tests". Use a harmless
unmerged PR for negative checks.

## 5. Daily workflow

- Prototype: `prototype/<short-topic>` -> edit `index.html` and/or
  `dev/`, `seed/` -> run `python3 dev/make_preview.py` -> open a PR ->
  wait for required CI -> merge if no blocked reviews or risky changes.
- Flutter: `feature/<short-topic>` -> one feature slice -> Dart analyze
  and widget tests -> PR -> other human approves -> green CI -> merge.
- Security/tooling: `chore/<short-topic>` or `security/<short-topic>` ->
  evidence and negative tests -> PR -> other human approves -> green CI.
- AI Codex/Claude/Copilot changes use the same branch and PR policy. AI
  reviewers never satisfy the human approval requirement and may not merge.

This policy leaves PR #4 device/emulator and live MCP integration work separate.
