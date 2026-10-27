# 03 · Devotional Workout Experience Engine

Status: **Accepted (ADR-0008)**. Implementation: `packages/fs_domain/lib/experience/` (pure Dart), with UI in `app/lib/features/workout_experience/`. State machine: `diagrams/07-devotional-workout-state-machine.mmd`.

## Purpose

Let each man choose how faith and training fit his day, while the system stays testable, safe and private. The engine is **independent of navigation**: screens render whatever the engine says is available.

## Concepts

| Concept | Definition | Stored |
|---|---|---|
| **Stage** | A unit of experience. `type ∈ {scripture, reflection, prayer, application, workout, rest_prompt, accountability_share, cooldown}` | In the template |
| **Experience Template** (versioned content) | Ordered stages with `contentRef` (package + key), `anchor`, `safety`, `completion`, `optional` | `content/experience-templates@vN` |
| **Experience Plan** (user preference) | `mode` + per-stage overrides + schedule times + reminder prefs | `users/{uid}/settings/experiencePlan` |
| **Experience Run** (per local day) | Materialized from the template version and a plan snapshot; holds stage states | Drift `experience_runs`, mirrored to `users/{uid}/days/{localDate}` |
| **Workout state stream** | `idle → warming_up → active_set → resting(remainingSec) → timed_interval → finished` | Emitted by the training module |

### Modes (FS-DWE-001)

| Mode | Stage placement |
|---|---|
| `full_before` | scripture → reflection → prayer → **workout** → cooldown → accountability |
| `full_after` | **workout** → cooldown → scripture → reflection → prayer → application |
| `rest_prompts` | **workout** with `rest_prompt` stages offered during rests; full devotional optional afterwards |
| `split_day` | Each stage anchored to a scheduled time (e.g., 06:00 scripture, 17:30 workout, 21:00 reflection) with local reminders |
| `workout_only` | Workout and cooldown; devotional stages `skipped(by_plan)`; no penalty language |
| `devotional_only` | Faith stages only; the workout is `skipped(by_plan)` (rest days, injury, travel) |

### Anchors

- `before_workout`
- `after_workout`
- `during_rest`
- `at_time(HH:mm)`
- `standalone`

## Stage state machine

```text
pending ──(anchor satisfied)──► available ──(open)──► in_progress ──(criteria met)──► completed
   │                                │                     │
   │                                └──(user skips)──► skipped(by_user)
   └──(plan excludes)──► skipped(by_plan)          (deferred) ◄──(user postpones / mode change)
```

**Invariants:**

- **I1, monotonic completion:** `completed` is terminal. Re-planning never changes a completed stage or its `completedAt` (FS-DWE-002).
- **I2, re-plan scope:** a mode or time change re-derives anchors **only** for `pending`, `available` and `deferred` stages. `in_progress` stages are kept, and the user resumes them.
- **I3, safety gate (FS-DWE-003):** a stage with `safety.noReadingDuringExertion` (every scripture, reflection, prayer, application and accountability stage) cannot become `available` while the workout state is `active_set` or `timed_interval`. If a stage is `in_progress` when exertion begins, it is suspended and the UI collapses it.
- **I4, rest prompts (FS-DWE-004):** a `rest_prompt` is offered only when the state is `resting` and `remainingSec ≥ 20`. It is text-light (one verse or one question to think about), has **no input fields**, dismisses in one tap, and never pauses, extends or hides the timer. Audio is an optional later feature.
- **I5, completion criteria (FS-DWE-007):** `opened | acknowledged | completed_workout`. Never minimum dwell time, scroll position or word count. This replaces the prototype's scroll-to-bottom gate.
- **I6, privacy (FS-DWE-006):** reflection and prayer text goes **only** to `users/{uid}/journal`. The run stores just `{stageId: {state, at}}`, never the content.
- **I7, pinning (FS-DWE-005):** a run pins `templateId@version` and the plan snapshot at materialization. A content update applies from the next run.

## Engine API (Dart, illustrative contract)

```dart
abstract interface class ExperienceEngine {
  ExperienceRun materialize({required ExperienceTemplate template, required ExperiencePlan plan,
                             required LocalDate day, required ZoneId tz});
  ExperienceRun onEvent(ExperienceRun run, ExperienceEvent event); // pure, deterministic
  List<StageView> available(ExperienceRun run, WorkoutState state, Instant now);
  ExperienceRun replan(ExperienceRun run, ExperiencePlan newPlan, Instant now); // honours I1, I2
}
sealed class ExperienceEvent { /* StageOpened, StageAcknowledged, StageSkipped, StageDeferred,
                                  WorkoutStateChanged(WorkoutState), ClockTick(Instant) */ }
```

`onEvent` is pure, so the same run plus the same events always gives the same state. Tests (TC-012, TC-029, TC-030) replay event logs.

## Persistence and sync

- Drift tables `experience_runs` and `experience_stage_states`; every state change is a local transaction.
- Outbox → `users/{uid}/days/{localDate}`, which is owner-only. Conflict policy: per-stage **max-state wins** (`completed > in_progress > available > deferred > pending`), with the earliest `completedAt` kept. Two devices can't undo a completion.

## Scoring interface (bounded, OD-01)

The engine emits optional participation facts (`groups/{gid}/checkins/{uid}_devotion_{localDate}`) **only** when the user's group has a ruleset with non-zero faith weights. No text, timing or quality data leaves the device for scoring.

## Out of scope for v1

Audio devotionals, AI-generated prompts, group-synchronous sessions and youth templates.
