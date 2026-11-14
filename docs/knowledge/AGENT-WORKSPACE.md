# Obsidian-guided development — recommended rollout

> **For the current beginner workflow, start with [Project 101](../development/PROJECT-101.md) and [Obsidian 101](../development/OBSIDIAN-101.md).** This page is a coordination rollout proposal, not a list of installed automations. [WORK](WORK.md) owns the current plan; CURRENT is superseded. The handoff Base and the generated WORK board are different views.

Status: historical coordination proposal from November 5, 2026. The implemented note workspace and its UI test evidence are in [Obsidian setup](OBSIDIAN-SETUP.md); embedded agent integrations remain proposals. A less technical collaborator can follow work **and run agent sessions** using existing repository skills, contracts, worktrees and review tooling. This note does not authorize plugin installation, new subscriptions or paid API routes.

## The experience to build

Open HOME → choose a ready task → start or resume the coordinator → follow a plain-language progress update → answer a concrete product question if needed → inspect the result and evidence. A user should not need to write prompts, choose reviewers, interpret Git commands or maintain YAML to run an ordinary task.

Obsidian holds durable tasks/decisions/history. Coding agents operate on a real local Git checkout and tools. A dashboard alone cannot provide a compiler, credentials or isolated execution. Workstation setup happens once and its readiness is visible before starting work.

## Earlier tool proposal (see the current setup guide)

| Purpose | Choice | Adoption boundary |
|---|---|---|
| Human dashboard | Core Bases + Properties | One task note per handoff; views read its properties instead of a second task database. Start with table/cards; core Kanban requires Obsidian 1.14+. |
| Easy navigation | Core Bookmarks, Workspaces, Reading view | Bookmark HOME and save a simple layout. This is local UI configuration, not shared authorization. |
| Consistent task notes | Existing handoff template + core Templates | Agents fill metadata; humans edit ordinary text or property controls. |
| Faster capture | QuickAdd, optional after core pilot | Consider only for a tested New idea/New task form; no shell/AI macro on capture. |
| Coding sessions | Existing supported agent app/CLI first; Agent Client as a controlled embedded pilot | The pilot must select the exact code worktree outside the docs vault and demonstrate permission prompts, cancellation and restart. See integration research. |
| Non-author review | Existing `tooling/review/review.py` | Separate authenticated provider, exact diff, deterministic tests first. Chat-pane names do not prove independence. |
| Extra querying/task plugins | Defer Tasks/Dataview/separate Kanban unless a demonstrated gap remains | Avoid multiple systems owning the same status or duplicate task records. |

Current official documentation supports [Bases](https://obsidian.md/help/bases), including [core Kanban in 1.14+](https://obsidian.md/help/bases/views/kanban). Local installed version and visual behavior remain NOT VERIFIED. Community plugins inherit Obsidian access; directory listing or a permission dialog is not a strong filesystem sandbox. Use a dedicated project vault with public/synthetic engineering material. [Plugin security](https://obsidian.md/help/plugin-security)

## Coordinator routing

The coordinator is a role, not one fixed model. The user authorized multiple possible coordinators (including Astra, Opus, Sol and Sonnet) selected for the task. These are configurable candidate families, not claims about benchmark superiority, account availability or guaranteed pricing. The default profile is **auto**: classify the task below, then choose from actually available, already-authorized options. A person may name a preferred model/profile explicitly.

| Profile | Use when | Candidate coordinators | Worker strategy |
|---|---|---|---|
| Routine | Accepted requirements, localized implementation, documentation, ordinary tests/refactors with known boundaries | Sol or Sonnet; other explicitly configured capable models | One implementer; non-author review after deterministic checks |
| Deep | New architecture/boundaries, Auth/privacy/scoring, destructive migration design, ambiguous cross-feature work or repeated unexplained failures | Astra or Opus; another explicitly verified deep-task model if selected | One lead, focused implementation writer, architecture/security specialists as required |
| Research | A concrete unresolved technical/product question prevents a sound decision | Sol/Sonnet for bounded fact-finding; Astra/Opus when synthesis or competing design constraints warrant it | Parallel read-only research agents on distinct questions, one lead synthesizes evidence |
| Named model | Human deliberately selects a particular coordinator | Exactly that model, if available | Follow the task's risk-based worker/review requirements; model choice does not lower them |

**Open:** retained as a user-requested candidate label, not assumed to mean Opus, OpenAI, an open-weight model or a specific vendor. Configure an exact provider/model and verify access before selecting it. Until then auto routing skips it and records the unresolved alias; it does not block other available choices.

Selection checks: required reasoning/tool capabilities, actual model/account access, enough context for the scoped packet, known authorized usage limits and task risk. Record the reason and actual host-reported model ID/provider. No hardcoded latest model IDs, invented cost ranking or assumed plugin model access. Listed availability is not proof of successful invocation. If the current host cannot switch coordinators, keep the actual current model disclosed and prepare a handoff to the chosen session; do not claim a prompt changed the model.

For auto mode, select an available candidate without asking the user to make every routine allocation. If an explicitly requested exact model is unavailable, surface that exception instead of silently substituting. Escalate to deep reasoning after repeated inconclusive fixes, newly discovered architectural/security scope or unresolved conflicting evidence; preserve the original task scope and budget. At a quota/tool failure, checkpoint and choose an authorized available alternative or report the specific blocker—never purchase access automatically.

Multiple coordinators may run **different independent tasks**. Each task has one active lead and one writer per file; shared schemas/rules/ADRs have explicit ownership. Switching a task from Sol to Opus, Astra to Sonnet, or any other pair requires a checkpoint, stop of old-lead dispatch, and new-lead verification. Parallel co-leads on the same task are not the default.

## Orchestration and responsibility

Invoke the repository [task-coordinator skill](../../.agents/skills/task-coordinator/SKILL.md) (mirrored for Claude). The coordinator selects implementation agents separately from itself; the preferred coordinator need not be the writer or the reviewer.

1. **Coordinator:** verifies task dependencies/base SHA, inspects current code/contracts, identifies consequential decisions, chooses skill(s) and one implementation writer. Reports a short plan and expected working outcome.
2. **Implementer:** works on one isolated branch/worktree, owns the task files, adds meaningful tests and actual evidence. Use Codex or Claude according to verified access and task fit, not an unsupported claim that one vendor always wins.
3. **Deterministic checks:** run before spending tokens on review. A failure returns the task to implementation.
4. **Non-author reviewer:** reads the exact proposed diff and relevant contract/context; reports severity, file/line, impact and suggested fix. Auth/privacy/scoring/data migrations receive a second independent specialist under the requested team workflow.
5. **Author fixes, coordinator verifies:** rerun affected checks and review for changed code. Never treat a stale reviewed SHA as the final head.
6. **Human evaluates:** see a working demonstration, acceptance results, remaining risks and PR. Agent policy still prohibits agent merge/approval; pushes require the existing conditions.
7. **Knowledge closeout:** update the task's WORK row and relevant feature/architecture pages in the same change. Use the PR as the handoff once it exists; close a pre-PR handoff note when replaced by the PR. Do not update superseded CURRENT. Archive research with a question-specific index entry.

Roles are reusable across vendors. A second Codex conversation is not an independent provider in the existing runner; use the truthful author identity. Same-provider research agents are useful but do not become independent security approval. If another reviewer is unavailable, continue authorized local implementation, checks and handoff preparation; mark review coverage NOT VERIFIED and surface the process exception for the maintainer. Do not claim the review stage passed or silently waive it. Separate Git push/release constraints still apply. Paid review eligibility is checked before launch.

Example allocations (conditional on verified access): Sol coordinator → Codex implementation → Claude review; Sonnet coordinator → Claude implementation → Codex review; Astra coordinator → Codex writer plus read-only research specialists → non-author Claude review. An Opus coordinator may direct a Codex writer and an uninvolved Claude reviewer only if the coordinator did not author the proposed code and the reviewer receives a fresh independent packet. Record every actual author. If both providers authored code, neither is eligible as independent under provider-exclusion policy; choose another verified provider or record a review exception for the maintainer. Two unavailable reviewers are not replaced by two labels on the same author.

These are role recipes, not automatically executed model-switch configurations. The host's delegation tools do the dispatch; when unavailable the coordinator prepares the task packet for a separate session and reports that limitation. Reuse the existing review runner rather than starting a custom orchestration service.

## Familiar software delivery process

Use a lightweight Kanban flow: **Inbox → Ready → Implementing → Checking → Review → Human check → Complete**, with **Blocked** available at any stage. One active implementation per writer; limit parallel work to independent file/interface ownership.

Ready means: concrete outcome, acceptance tests, owner, dependencies, permitted scope, relevant contract, and product decisions resolved. Complete means: working behavior tested with the appropriate real persistence/permissions/recovery, final review evidence recorded, and integration status clear. A card dragged to Complete is a claim to verify, not a permission to bypass tests. GitHub owns live PR/CI state; task status is the human work summary.

Use existing skills by task: `flutter-vertical-slice`, `flutter-architecture-review`, `firebase-security-review`, `independent-code-review`, `knowledge-steward`, and relevant adopted Dart/widget test skills. Context7/official docs support API questions. Research is a bounded subtask only when uncertainty affects a decision: specific question, primary sources, candidate recommendation, cost/time limit, and stop condition. Store its short conclusion in the task and detailed evidence behind HISTORY; never require rereading all research on startup.

## Git and sharing when both people run agents

Each developer needs a real checkout; each implementation needs a branch/worktree. Share accepted code/notes through Git. Do not point two writers at the same synced checkout or sync multiple branch worktrees into one writable Obsidian vault: branch versions and live edits can overwrite each other independently of review.

Obsidian Sync can support a stable coordination copy if explicitly approved and operated by one designated publisher, but it does not synchronize Git branches, toolchains or review state. It requires subscriptions for collaborators and lacks fine-grained permissions/live coediting. It is not needed for this initial agent pilot. [Shared vault limits](https://obsidian.md/help/sync/collaborate)

For the friend's first sessions, use the prepared checkout and [session card](START-SESSION.md). A supported external agent app is the fallback if embedded integration fails. The goal is a simple user workflow; installing an experimental bridge is not itself progress toward a working app.

## Rollout and acceptance

1. **Core navigation:** enable/view the prepared task Base on a supported Obsidian version; friend finds an assigned task, understands its outcome and sees its blocker without Markdown instructions. Verify Windows and Mac separately.
2. **One bounded session:** a documentation-only task in an isolated checkout; coordinator selects one writer, runs checks, records a handoff. Restart with a fresh session and resume from those files only.
3. **One embedded integration trial:** compare exact plugin release, supported provider/account and permission behavior. Verify selected worktree, file changes, terminal prompts, denial, cancellation, disconnected service and resume. Never use bypass-permission mode. Reject the integration if scope/evidence is unclear.
4. **Independent review:** use an authenticated non-author provider through the existing runner. Demonstrate that author reuse, missing coverage and a changed diff cannot be reported as a valid existing review.
5. **Small real application task:** only after its product/dependency approvals. Friend follows progress and explains what was tested versus unverified. Then adopt proven settings and document a repeatable setup.

No custom orchestration service or new auto-push plugin is needed. Exact plugin pins, installed platform compatibility, accounts and billing remain decisions to verify at installation, not assumptions from research.

Detailed dated source evidence is indexed in [HISTORY](HISTORY.md). The two research notes are archived reference, not required startup reading. Agent Client's embedded buttons do not document a worktree-directory field: configure and verify the chat directory explicitly in the pilot. Claudian is a researched alternative, not a second plugin to install alongside it. Current Gemini account access must be checked rather than assuming the older consumer/free-login workflow still works.
