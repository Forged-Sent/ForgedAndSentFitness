# 09 · Collaborative Planning Hub specification

| | |
|---|---|
| Status | **Proposed** (ADR-0020, workshop W12). The hub page v4 is built and published; the GitHub side is in this branch. |
| Purpose | Help two collaborators, and the friends they invite, make informed, documented decisions together, with a clear path from idea to verified software |
| Not | The Forged & Sent fitness app. Not a project-management platform. |
| Diagrams | `docs/diagrams/17-planning-workflow.mmd` (workflow), `18-planning-hub-context.mmd` (context) |

## 1. Requirements (from the owners' brief)

| # | Capability | Where it's met |
|---|---|---|
| R1 | Idea submissions (feature, improvement, alternative, concern, question) | Hub *Ideas* form · GitHub `idea` issue form |
| R2 | Voting on decisions and ideas; advisory only | Hub option picks (decisions) and Support / Unsure / Oppose (ideas) |
| R3 | Comments and discussion | Hub comment threads per card (claude.ai comments) plus visible notes · GitHub issue threads |
| R4 | Decision alternatives with pros, cons, consequences and a default | Hub decision cards (options, "Why recommended", technical detail, reconciliation) |
| R5 | Statuses New → Discussing → Needs decision → Approved / Deferred / Rejected → Implemented | Hub status model §4 · GitHub `status:*` labels |
| R6 | Owner decisions with rationale and who decided | Hub owner rulings (owner list enforced in the page) → `decision-log.yaml` `decided_by` |
| R7 | Traceability to ADRs, requirements, diagrams, issues, PRs | Ruling link fields (DEC, ADR, FS, issue, PR) → decision-log `links` |
| R8 | Change history: authorship, discussion, previous outcomes, reasons | Hub per-person append logs · decision-log `history` · git history |
| R9 | Dashboard: blocking decisions, outstanding votes, new ideas, development-ready work | Hub *Dashboard* |
| R10 | Exports and portability outside any AI tool | Hub JSON and Markdown export → `import_hub_export.py` → repo files |

## 2. Platform evaluation

Scores run 1 (poor) to 5 (strong) and are my judgment. The weights reflect your brief: genuine collaboration, reliable persistence, easy access, and the smallest practical build.

| Criterion (weight) | A. Claude Blueprint only | B. GitHub only | C. Custom Firebase portal | **D. Hybrid: Blueprint + GitHub** |
|---|---|---|---|---|
| Genuine collaboration (3) | 4: votes, notes, comments, plain-words cards | 3: threads are good; voting is reactions; options UI is clumsy | 5: anything we build | **5** |
| Reliable persistence and history (3) | 3: shared database in one person's claude.ai account | 5: git and issue history | 4: our Firestore and backups | **5**: git is the record; hub snapshots committed |
| Easy access for both developers (2) | 3: needs claude.ai accounts and an Editor invite for outside-org users | 5: both have GitHub | 4: our own sign-in | **4** |
| Friendly for non-developer friends (1) | 5 | 2 | 4 | **5** |
| AI-tool neutral; agents bound by it (3) | 2: agents can't be held to page data | 5 | 3: needs an export to the repo anyway | **5**: agents read the repo only |
| Build and maintenance cost (2) | 5: exists | 4: templates, labels, one script | 1: a second product to build and secure | **4** |
| **Weighted total (max 70)** | 48 | 59 | 50 | **66** |

**Why not the portal (C):** it would mean auth, rules, hosting, backups and UI for a tool used by two people plus a few friends. That's weeks of work before the real app, and it duplicates what the hub and GitHub already do.

**Why not GitHub only (B):** it is the fallback and is complete on its own. But the plain-words option cards and one-click voting make the workshop usable for your non-developer friends, and that already exists.

**Limits that would trigger a rethink:**
- More than about 10 regular participants.
- Owners needing push notifications for votes.
- Rulings left out of GitHub for more than two weeks.
- claude.ai access becoming a barrier for either owner.

## 3. Roles and permissions

| Role | Who | Hub (claude.ai sharing level) | GitHub |
|---|---|---|---|
| **Page owner** | The account that published the hub (Chad) | Owner: everything, plus sets the owner list | Repo collaborator |
| **Project owner** (two) | Chad and the second developer | Editor (an outside-org invite needs Editor to write). Listed in *Who decides*; only listed owners' rulings count. | Collaborator; **CODEOWNER** of the decision log and protected zones |
| **Participant** | Invited friends, pastor, fitness reviewer | Contributor in the org, or Editor if invited from outside it: vote, note, add ideas, comment | Optional: open `idea` issues |
| **Viewer** | Anyone shared read-only | Read and comment | — |
| **AI agent** | Claude Code, Codex | None: agents never use the hub | Read the decision log; PRs only; **cannot edit the log** (zone guard + CODEOWNERS) |

**Enforcement, honestly stated:**

- On the hub, the page rules make each person's votes, ideas and history writable only by that person (`{self}` paths), and only the page owner can change the owner list.
- The page itself enforces "only owners' rulings count": a non-owner's ruling is written to their own log, shown as ignored in history, and never counted.
- Because outside-org friends also need Editor access to write, the hub alone can't fully restrict rulings. That is why **binding authority lives in GitHub**, where branch protection and CODEOWNERS do enforce it.

## 4. Workflow and statuses

`Idea → Discussion → Vote → Owner decision → Decision log / ADR → Backlog → Implementation → Verification` (diagram 17)

| Status | Definition | Set by | Exit condition |
|---|---|---|---|
| **New** | Submitted; nobody has responded yet | Anyone (on submit) | First discussion or vote |
| **Discussing** | Being talked through; questions open | Author or owner | Options are clear |
| **Needs decision** | Options and trade-offs written; an owner ruling is requested | Author or owner | An owner rules |
| **Approved** | An owner ruled yes, with a rationale. Advisory on the hub, **binding once in the decision log** | Owners | DEC entry merged; a task opened if it's to be built |
| **Deferred** | Good, not now; the rationale names the revisit trigger | Owners | Trigger met → Discussing |
| **Rejected** | Ruled no, with a rationale | Owners | — (a new idea can reopen it) |
| **Implemented** | Merged PR(s) linked and the acceptance tests verified | Owners | — |

**When an ADR is required:** any approved decision that materially affects architecture, a data contract (collections, payloads, rules), security or privacy, or long-term product behavior (scoring, content model, tenancy). Ideas marked *Architecture / data / security* show a "Needs ADR if approved" flag, and the validator rejects an approved `architecture`, `data-contract` or `security` decision-log entry without an ADR. Small product choices (copy, a default value, ordering) need only the DEC entry.

**Amendments:** anyone, an agent included, who finds a conflict with an approved decision opens an `amendment` issue that cites the DEC id. It goes back to *Needs decision*. Nobody reverses a decision in code.

## 5. Data model

### 5.1 Hub (claude.ai artifact database)

| Collection / doc | Shape | Write rule |
|---|---|---|
| `votes/{uid}` | `{ picks: {W01: {opt, note, discuss, at}}, ideaVotes: {"I-…": {v: up\|unsure\|down, at}}, updatedAt }` | Only that person |
| `ideas/{uid}` | `{ items: [{id, type, title, area, impact, problem, proposal, stage, at, upd}], updatedAt }` | Only that person (author) |
| `log/{uid}` | `{ entries: [{id, at, item, act: submit\|stage\|rule\|withdraw, status?, outcome?, rationale?, links?{dec,adr,fs,issue,pr}}], updatedAt }`, append-only by convention, last 600 | Only that person |
| `config/owners` | `{ ids: [uid…], github: {uid: handle}, updatedAt }` | Page owner only |

**Derived values:**

- **Current ruling** for an item = the latest `rule` entry from a listed owner.
- **Status** = that ruling's status. Otherwise ideas use the author's stage and formal items show *Needs decision*.
- **History** = every person's entries for the item, merged by time.

Storing history in per-person logs means nobody can rewrite someone else's past.

Formal items (W01–W12, D01–D35) are static page content (options, explanations, recommendation). Only people's responses live in the database.

### 5.2 Repository (authoritative)

`docs/planning/decision-log.yaml` (schema `fs-decision-log/1`):

```yaml
- id: DEC-0014                 # next free number
  title: What does a man open the app for each day?
  kind: product                # product | architecture | data-contract | security | process | content
  status: approved             # approved | deferred | rejected | implemented | superseded
  ratified: false              # true only in a PR both owners approve; then decided_by must be handles
  decided_at: '2026-10-28'
  decided_by: [chad-handle, partner-handle]
  source: {hub: W01}           # or {brief: …}, {issue: 12}
  outcome: Training-first Today
  rationale: …
  links: {adr: [], requirements: [FS-TRN-007], issues: ['#12'], prs: []}
  superseded_by: DEC-00xx      # required when status is superseded
  history: [{at, status, by, note}]   # last entry must match status
```

Plus `docs/planning/hub-snapshots/<date>.json`: the full hub export (votes, voters, ideas, rulings, history), committed with each import so the planning history survives outside claude.ai.

### 5.3 GitHub objects

| Object | Purpose |
|---|---|
| Issue form `idea.yml` | Same fields as the hub idea form, for anyone who prefers GitHub |
| Issue form `decision.yml` | Owner decision record (the hub pre-fills it from a ruling) with a follow-up checklist (DEC, ADR, FS/TC, task) |
| Issue form `task.yml` | A buildable slice: DEC id, FS id, acceptance criteria and TC ids, declared paths, milestone |
| Labels (`.github/labels.yml`) | `idea`, `decision`, `task`, `amendment`, `status:*`, `contract-change`, `legacy-change` |
| Project board (optional) | Views grouped by `status:*`: Decisions, Backlog, In progress, Done |

## 6. Screens

The live hub is the reference implementation. These wireframes describe its layout.

**Dashboard**
```text
┌ Dashboard ─────────────────────────────────────────────────────────────────┐
│ [ 3 of 47 ruled ▓░░ ] [ 22 blocking ] [ 41 waiting for you ] [ 2 ideas ]  │
│ [ 1 ruled, not in GitHub ] [ 0 ready for development ] [ 3 people ]       │
│ ┌Blocking, not decided┐ ┌Waiting for your vote┐ ┌New ideas────────────┐   │
│ │W01 Daily open · M1  │ │W02 Pillars          │ │I-… Wives in prayer  │   │
│ │W12 Planning · now   │ │D04 Offline          │ │   · Curtis          │   │
│ └─────────────────────┘ └─────────────────────┘ └─────────────────────┘   │
│ ┌Needs owner decision┐  ┌Ruled, not in GitHub┐  ┌Ready for development┐   │
│ [Ratify the 19 aligned decisions]  (owners only, two-tap confirm)          │
│ Who decides: Chad (@…), Curtis (@…) · [Set owners] (page owner)            │
│ Statuses table · [Export JSON] [Copy summary]                              │
└────────────────────────────────────────────────────────────────────────────┘
```

**Decision card (W or D)**
```text
W04 · BLOCKING · NEEDS DECISION · Needed by M3 exit · OD-01 · ADR-0012
How visible and how heavy is faith participation in scoring?
┃ In plain words: …                                     ▸ Technical detail
( ) Boolean participation, team total only, capped   RECOMMENDED   2 ●●
( ) No faith points; recognition only                               1 ●
( ) Weighted equal to workouts                                       0
Why recommended: …      [Reconciled: Conflict + Open · needs approval: weights]
Your note: [______________________]  ☐ Flag for discussion
[Comment] [Copy link] [Open in GitHub]
  Curtis · prefers: Boolean… · "Ask Pastor Dave after the practice season"
▸ Record an owner ruling (owners): Status ▾ · Option ▾ · Reason · DEC · ADR · FS · Issue · PR · [Save]
▸ History: 28 Oct · Chad ruled Approved (Boolean…): …
```

**Idea card**
```text
I-mvr4… · NEEDS DECISION · FEATURE · FAITH · NEEDS ADR IF APPROVED
Scripture memory verse of the week
Problem: … / Proposal: …                     Chad · 27 Oct · Architecture
[Support · 2] [Unsure] [Oppose · 1]
[Comment] [Copy link] [Open in GitHub] [Ready for decision] [Withdraw]
▸ Record an owner ruling   ▸ History
```

## 7. Hosting, persistence and the minimal implementation plan

| Step | What | Who | Status |
|---|---|---|---|
| H0 | Hub v4 page: ideas, statuses, votes, rulings with links, per-person history, owner list, dashboard, workshop W01–W12, ratify, JSON and Markdown export | Claude | **Done.** Published to the existing Blueprint link (votes and comments carried over; the database was empty) |
| H1 | Repo side: decision log (seeded with the 27 Oct direction), validator checks, zone guard + CODEOWNERS on the log, issue forms, labels, import tool, ADR-0020, AGENTS.md decision guard | Claude | **Done on branch `arch/planning-hub`** (not pushed) |
| H2 | Push both branches; open the Phase 0 PR | Owners | To do |
| H3 | Run `tools/planning/bootstrap_github.ps1` on Windows (or `bootstrap_github.sh` on macOS/Linux) to create the labels; add the second handle to CODEOWNERS; enable branch protection (`tools/planning/branch-protection.json`) | Owners | To do (about 15 minutes) |
| H4 | Share the hub: Chad invites the second owner (and friends) by email as Editor, then sets **Who decides** | Chad | To do |
| H5 | First workshop session: rule W12, W01, W02 and W07; ratify the aligned D items; export → import → PR | Both owners | To do |
| H6 | Weekly: export after any rulings; one PR; paste DEC ids back into the rulings | Owners | Ongoing |

**Hosting:** the hub is a claude.ai artifact, which costs nothing extra. Its data lives in the artifact database. Persistence outside the AI tool comes from H6: every export is committed as a snapshot, and every ruling becomes a DEC entry. If claude.ai were unavailable, the repository holds everything decided, and GitHub issues carry on the workflow.

**Operational before agents work independently:** H0–H5 complete, with at least W01, W02, W07 and W12 ruled and recorded (see `07-engineering-collaboration-plan.md`).

## 8. How decisions feed agent instructions and tasks

1. `AGENTS.md` ranks `decision-log.yaml` above ADRs in precedence. It requires reading the log before every task, and stopping with an amendment proposal on any conflict.
2. The **task** issue form requires a DEC id, an FS id and TC ids, so every task an agent picks up names the decision it implements.
3. **architecture-reviewer** checks each PR against the decision log and ADRs (skill `fs-architecture-review`) and escalates conflicts to the owners.
4. Gates: `validate_architecture.py` (log schema, ADR links, history), `check_zones.sh` (log protected, PreToolUse hook and CI), CODEOWNERS (both owners).

**Functional check performed on the hub (27 Oct)** in headless Chromium with a stand-in runtime:

- Set owners.
- Voted on W01.
- Submitted an idea, voted on it and moved it to *Needs decision*.
- Ruled W01 *Approved* with a rationale.
- Ratified 19 aligned decisions.
- Exported JSON and imported it into a scratch copy of the repo: 15 new DEC entries, idempotent on re-run, validator green.
- Confirmed a non-owner sees no ruling editor or owner settings.

After publishing, the page's database rules were checked with lower access levels (see the final report).
