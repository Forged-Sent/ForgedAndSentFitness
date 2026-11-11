---
title: "P04 Design foundation and tab shell"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P04 · Design foundation and tab shell

> [!IMPORTANT] Before you paste
> - [ ] P12 merged
> - [ ] P01 merged
> - [ ] P03 merged
> - [ ] P02 merged if you ran it
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q1==

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

## Your answers right now

Live view of the Decisions page (Obsidian only; on GitHub open the [Decisions](../01-DECISIONS.md) page).

![[01-DECISIONS#Your answers]]

## The prompt

Copy everything in the box.

```text
Read first, in this order:
1. AGENTS.md (and mobile/AGENTS.md for any Flutter work).
2. docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md
   - The "Your answers" table holds my decisions. Use them exactly as written.
   - Any answer that still contains TODO is unanswered. If this task needs
     it, stop and ask me. Do not choose for me.
   - The "Run settings" table holds the SDK version, branches and paths.
3. docs/reviews/2026-11-10-prototype-to-flutter/06-SCREENS-AND-UI.md (token tables, components, F1 to F12)
4. docs/reviews/2026-11-10-prototype-to-flutter/02-BUILD-PLAN.md, step S0

Use the flutter-vertical-slice skill, and flutter-platform-parity for the
prototype comparison. Name them in the PR description.

Goal a user can see: the app opens looking like the prototype. Brand bar,
hero header, six-tab bottom bar, dark and light themes. Tabs other than
Today show a titled placeholder. The six tabs come from my Q1 answer.

Build:
- mobile/lib/src/design/: colors for both themes and text styles taken from
  the token tables. Explicit ColorSchemes, not ColorScheme.fromSeed.
- Bundle Saira Condensed, Saira Stencil One, IBM Plex Sans and Merriweather
  italic as assets. Confirm each licence and say where you checked. No
  runtime font fetching.
- The hero photograph as an image asset (extract it from the prototype's
  --mtn-photo data URI), with 2x and 3x variants if the source allows.
- FsShell using go_router StatefulShellRoute with six branches, so each tab
  keeps its own stack and scroll position.
- FsHeroHeader, FsCard, FsButton, FsLabelCaps. Nothing else yet.
- docs/design/DESIGN-SYSTEM.md: change the status of everything you built
  from Planned to Implemented and fill in the real file for each row.
  docs/knowledge/PROTOTYPE-PARITY.md: update the app-shell row.

Acceptance (each needs evidence):
1. Golden tests at 390x844, dark and light. Show me each golden image next
   to the matching prototype screenshot in the review's reference/ folder.
   I approve the match by eye; a Flutter render cannot pixel-match a
   browser render. Once I approve, the golden is the locked baseline.
2. No overflow at 1.3x text scale.
3. Android back from a nested page returns to its tab.
4. Each tab keeps its scroll position when I switch away and back.
5. flutter analyze clean, flutter test green, debug APK builds.

Out of scope: any feature logic, Drift, Firebase, sign-in. Do not restyle
today_screen.dart from the Today demo branch; the next PR replaces it.

First give me a plan and the file list, and wait for my go-ahead.

Rules for this task:
- One focused branch and one PR. Never commit to main. Do not push; tell me
  when it is ready and I will authorize the push.
- No new tooling, checkers, templates, ADRs or status pages unless listed
  under Deliver.
- Docs are part of done. In this same PR, update your row in
  docs/knowledge/WORK.md and every page AGENTS.md lists under "Docs are
  part of done" for what you changed, each written as it will be true once
  the PR merges. Never hand-write PR or CI state.
- When the PR is open or updated, run
  python3 tooling/knowledge/live_status.py --pull
  so my Obsidian dashboard is current.
- Report: files changed, every command you ran with its real output, and
  anything you did not run labelled NOT VERIFIED.
```

## When it comes back, check

- [ ] Golden images are shown beside the prototype reference and you approve the match
- [ ] Theme uses explicit colors, no `fromSeed`
- [ ] Fonts are bundled assets with licences named
- [ ] No feature logic slipped in
- [ ] `docs/design/DESIGN-SYSTEM.md` and the parity row say what is now implemented
