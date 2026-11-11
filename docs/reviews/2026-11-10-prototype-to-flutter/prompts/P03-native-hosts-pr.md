---
title: "P03 Publish the Android and iOS hosts"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P03 · Publish the Android and iOS hosts

> [!IMPORTANT] Before you paste
> - [ ] P12 merged: the host projects contain launcher icons

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

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

Task: turn my local branch (Run settings: native hosts branch) into a
focused, reviewable PR. It contains committed Android and iOS host
projects and nothing else that matters.

Deliver:
1. Bring the branch up to date with origin/main.
2. Fix the Android app label: it is "forged_and_sent" in
   mobile/android/app/src/main/AndroidManifest.xml. Make it "Forged & Sent".
3. Leave release signing alone, but state clearly in the PR that the
   release build type still uses the debug signing config and must not be
   distributed.
4. Using the pinned Flutter SDK: flutter pub get, flutter analyze,
   flutter test, flutter build apk --debug. If you are on macOS also run
   flutter build ios --simulator --no-codesign. Otherwise label iOS
   NOT VERIFIED.
5. Update mobile/.gitignore and ADR-0003 wording only as far as needed so
   the docs stop saying hosts are git-ignored.

Out of scope: any Dart feature code, Riverpod, go_router, Drift, the Today
demo, new tooling.

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

- [ ] Only `mobile/android`, `mobile/ios`, `.gitignore` and small doc edits changed
- [ ] Debug APK build output is pasted
- [ ] iOS is either built or clearly marked NOT VERIFIED
