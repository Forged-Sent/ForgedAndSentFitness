---
status: archived
updated: 2026-11-05
owner: Codex research team
source_ref: main
source_sha: 60b9f5de11b1a1074b921ee26ae68fb3c3e7228d
superseded_by: docs/knowledge/CURRENT.md
original_sha256: 66c500d2075c13069005cc5772a93217c496dc147720107c9a7d7ad76e5e4ea3
---

> Historical snapshot; recommendations remain proposals. Operational successor: [CURRENT](../../CURRENT.md). Original body follows unchanged.

# Live GitHub and engineering infrastructure audit

Evidence collected 2026-11-05 (America/Phoenix). Read-only GitHub connector calls succeeded; authenticated `gh` 2.96.0 REST reads supplied ruleset and checks capabilities absent from connector. No GitHub changes made. Local workspace changes preserved.

## Exact baseline

- Local branch `pr4-workstation-test`, HEAD `c8e1267832e686206166a545a78dcbff5839c0ac`; dirty GEMINI.md plus untracked skills, notes, logs and Obsidian state. These are not committed architecture.
- Local origin still `https://github.com/sfcsmithc-afk/ForgedAndSentFitness.git`. Live canonical repository is public organization repository `Forged-Sent/ForgedAndSentFitness` (ID1432641234).
- Live main `60b9f5de11b1a1074b921ee26ae68fb3c3e7228d`, PR4 merge 2026-11-05 09:24:19Z / 02:24:19 Phoenix.
- GitHub compare says main is three commits ahead of local, zero behind. Eight changed paths only: README.md; docs/development/MACBOOK-QUICKSTART.md; launchers/mac/more/Run app on iPhone simulator.command; tooling/macos/common.sh, first-run.sh, run-ios.sh, verify.sh; tooling/onboarding/test_beginner.py. Thus local mobile and prototype source match audited main; local Mac onboarding misses latest fixes.
- Workflow and review.py blob equality independently checked against main via API and git hash-object.

[Main commit](https://github.com/Forged-Sent/ForgedAndSentFitness/commit/60b9f5de11b1a1074b921ee26ae68fb3c3e7228d)

## PR reconciliation

| PR | Observed status and exact head | What to reuse | What remains |
|---|---|---|---|
| [3](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/3) | Merged Oct31; head a5c89e9564676f68c6f560f4a2371e928c974c6e; merge d622e5aa95b5f136179cf59d428e48a917991cd0 | Bootstrap, small Flutter scaffold, MCP launcher/policies, locks, CI | Historical body claims required human review; superseded by live ruleset. Do not reinstate old workflow or bootstrap. |
| [4](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/4) | Merged Nov5; head a93407baf700ce19668ed8bd1a527c324f13c5b2 | Emulator Auth/Firestore/Storage smoke, fs helpers, review runner, skills, Atlas, platform CI | Production data/rules, hosts/signing, features, durable outbox absent. Body has accumulated contradictory checkboxes; use dated evidence instead. |
| [26](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/26) | Open draft; head 1c6160c368466d9c5ea814f9c5a1454fffa7fcdb; base main60b9f5d; mergeable at snapshot | Git-first knowledge notes/checker, Gemini config, proposed platform ADR, post-PR4 stale instruction cleanup | Latest CI pending platform lanes; ADR0003 explicitly proposed; live MCP and devices not verified. |
| [30](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/30) | Open draft; head 1ef8ce67ae15f78801e234f71aaad20511a9c913; base #26 branch/head1c6160c | Optional Obsidian HOME, light/high-risk contracts, safe local preview server + tests | Latest CI pending; person-run launch/port collision/Obsidian validation pending. Retarget/revalidate after26. |

Recommended integration order: maintainer review26 then30, preserving ancestry with merge commit if chosen by human. If26 is squash/rebased,30's author must reconcile changed ancestry, recheck complete diff and tests; do not assume GitHub retarget makes contents correct. No automatic merge authorized.

### Existing new paths to extend, not duplicate

PR26 adds `docs/knowledge/{INDEX,CURRENT,AGENT-OPERATIONS,LIFECYCLE,FLUTTER-PLATFORMS,PROTOTYPE-PARITY,FLUTTER-AI-DOCS,RESEARCH-2026-11-02}.md`, `docs/knowledge/handoffs/{TEMPLATE,pr4-foundation}.md`, `docs/architecture/ADR-0003-flutter-targets.md`, mirrored `flutter-platform-parity` and `knowledge-steward` skills, `.gemini/settings.json`, `tooling/knowledge/{check,test_check}.py`. It changes stale PR4 instructions across root/mobile AGENTS, SYSTEM, ADR0002, setup docs and diagnostics. It does not change mobile runtime, Firebase rules or prototype.

ADR0003 is **Proposed, not yet a release commitment**, decision owner project maintainers. Recommends shared Flutter contracts, Android/iOS correctness first, web preview only, future desktop compatibility targets with per-platform evidence; reviewed native hosts only after compatibility audit and milestone approval. Existing ADR0001/0002 stay authoritative. Do not create another competing platform ADR.

PR30 adds `docs/HOME.md`, `docs/development/KNOWLEDGE-WORKSPACE.md`, `docs/features/{README,TEMPLATE-LIGHT,TEMPLATE-HIGH-RISK}.md`, optional Windows/Mac Knowledge workspace launchers, `tooling/preview/{serve_project,test_serve_project}.py`; extends knowledge checks and CI. The preview server is loopback127.0.0.1:43117 with explicit path/Host allowlists and Windows exclusive port binding. It serves actual prototype and generated Atlas; no Obsidian plugin/MCP/sync requirement.

High-risk contracts live at `docs/features/<slug>/requirements.md`, `design.md`, `tasks.md`; light contract at `<slug>/feature.md`. Metadata: kind, feature_id, status, risk, owner, source_ref, source_sha, approved_by, test_plan, verified_tests, implementation_paths, verification. `source_sha` is full40 SHA already on main, not a PR feature commit. Proposed/approved/implemented/superseded have distinct semantics. `approved_by` needs real maintainer decision; implemented needs source/tests and observed run. Checker verifies structure/path/provenance, not correctness or approval authenticity. No duplicate spec for one feature. Offline sync/auth/group/privacy/scoring/health/boundary work is high risk.

PR26 CURRENT records maintainer-reported Windows/Mac Contributor installation success, with app round-trip still requiring visual confirmation. Try-it-now, Mac iPhone, Android, Maestro, MCP tools/list remain NOT VERIFIED there. These are reported evidence, not tests run by this audit.

## Open work outside requested PRs

15 open PRs observed. Prototype chain: #27v227 mentoring -> #28v228 info-scroll -> #31v229 naming -> #32v230 journal -> #33v231 campaign search/info -> #34v232 supersets -> #35v233 bodyweight-volume -> #36v234 labels -> #37v235 effort chips. #27 currently based on app/v226-load-guard; each later prototype PR stacks on preceding branch. These are unmerged behavior, not baseline production requirements. #27 changes mentor DB rule: privacy/authorization semantics need explicit review, despite prototype title. Maintain separate pending-parity delta list.

#29 proposes static design-doc policy-only CI routing; evaluate its actual path classifier tests before adoption, not required to implement features. #5/#6/#7 are major setup-node/checkout/upload-artifact Action dependency upgrades. Review separately with pinned SHA/runtime/artifact compatibility and CI; do not blindly combine with app work.

## Live branch/security protection

[Ruleset26264138](https://github.com/Forged-Sent/ForgedAndSentFitness/rules/26264138), active on default branch, bypass_actors empty:
- Pull request required; deletion and non-fast-forward prohibited.
- ci-gate required, GitHub Actions integration15368.
- Required approving reviews ZERO; team pattern minimum approvals also ZERO; CODEOWNER review false; last-push approval false.
- Dismiss stale reviews true, required review thread resolution false.
- Strict up-to-date required-status policy false. Consequently final merged-base testing is an engineering process need, not currently server enforced.
- Classic branch protection API reports disabled while ruleset is active: do not misread classic endpoint as unprotected.
- Agent push rule requiring all threads closed is stronger than server policy and still applies. Agents never approve, merge, force push or push main.
- API reports secret scanning, secret-scanning push protection, Dependabot security updates enabled. Non-provider secret patterns and validity checks disabled. This is configuration evidence, not proof no secrets exist.

## Actual CI evidence

[Main required workflow42002107363](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/42002107363): success at60b9f5d. [PR4 run41999595970](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/41999595970): all12 named jobs pass including ci-gate, Firebase rules, Flutter, unsigned iOS simulator, Windows/Mac preview, policy, Atlas.

[PR26 current run42003235449](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/42003235449) and [PR30 run42003239835](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/42003239835): pending at audit snapshot. Most jobs passed, iOS and at least one platform job pending; do not report latest ci-gate green. Recheck immediately before any authorized push/human merge.

The checked-in workflow `.github/workflows/ci-gate.yml` is read-only permissions; PR/push-main/manual triggers; path classification; policy always runs; aggregate allows success/skipped but rejects failure/cancelled/unexpected. Platform hosts temporarily generated. Flutter pinned3.47.8, Node22 Windows and24 macOS/Linux, macos26 iOS with Xcode>=26.2 assertion. Workflow runs real Flutter analyze/test/web/APK, unsigned simulator build, Firebase emulator rules positive/negative tests, policy/onboarding/skills/architecture/review tests and Atlas artifact checks. These prove scaffold/build/tooling only, not user feature reliability. No real-device workflow evidence inspected.

## Review tooling

`tooling/review/review.py` already supplies bounded hashed patch slices, trusted-base instruction excerpts, provider author exclusion, schema validation, incomplete coverage NOT_VERIFIED, generated/lock file deterministic exclusion manifest, sanitized subprocess environment and report verification. Codex read-only sandbox/ephemeral; Claude tools disabled and MCP denied; Gemini plan+sandbox. Provider-auth environment/home access remains needed; this is not strong isolation from all machine credentials. Use a clean review account/profile with no production credentials. Configuration does not prove provider auth or review execution; no paid provider reviews invoked in this audit.

Reuse runner, do not replace it with new orchestration service. For user's requested process, independent non-author review is a team execution expectation; existing GitHub gate remains deterministic ci-gate with zero approval requirements. Record missing review coverage and author identity. A second same-vendor agent can be non-author but runner excludes author provider; use separately authenticated other provider through runner, or documented read-only agent evidence outside runner without falsifying author=human.

## Recommended first three work packages

1. Complete evidence/reconciliation of existing26: approve or retain Proposed ADR0003 honestly; final checks; read-only independent architecture review; maintainer merges when ready. Working capability: durable Git-backed handoffs and accurate onboarding, no new app feature.
2. Complete existing30 against integrated26: feature template provenance and preview negative tests, Windows/Mac person-run launch/collision checklist; independent security review of server paths/Host handling; maintainer merge. Working capability: reviewed feature contracts and safe preview entrypoint. Do not wait for optional Obsidian adoption to build app.
3. New focused architecture + first private completion contract PR: choose dependency stack in Proposed ADR0004 and one high-risk contract for owner-scoped durable devotional completion; define event schema/idempotency/account boundary/deletion before implementation. Reuse26/30 canonical docs. This can be drafted now atop30 or as external proposal; implementation waits maintainer decisions. Subsequent runtime PR implements one end-to-end emulator completion with durable local outbox, visible pending/accepted/rejected state and negative ownership/replay tests. Avoid broad Auth+group+invite+scoring walking skeleton.

Application host compatibility audit can proceed independently, but package/bundle IDs and release/signing commitments require approval. Small host PR should preserve emulator-only default and prove Android debug + unsigned iOS build before real-device acceptance.
