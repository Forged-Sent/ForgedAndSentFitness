# Forged & Sent

A men's fitness and accountability app for the Forged in Faith men's group. Men follow a shared daily checklist, track food, water and training, post check-ins, and compete on weekly standings. The foundation is 1 Corinthians 16:13-14 and the Great Commission (Matthew 28:19): care for the body so a man can lead his family and do kingdom work.

**Status: two apps, neither store-ready yet.**

- **The production app** is being rebuilt in Flutter for Android and iOS, in [`mobile/`](mobile/), with Firebase as the backend (local emulators only for now). Today it has the Today page, the day's devotional saved on the device, and the six-tab shell; the other tabs are placeholders. What is built and what is next: the [work board](docs/knowledge/WORK.md) and [prototype parity](docs/knowledge/PROTOTYPE-PARITY.md).
- **The HTML prototype** (`index.html`) is the visual and behavioral reference. It runs as a [claude.ai Artifact](https://claude.ai) (a private hosted page), not as a plain static site, because its database, user identity and file storage come from the claude.ai runtime (`window.claude`). Most of this README describes the prototype; see "Running it".

## New here? Start here

You only need to double-click files. No typing commands, no cloud accounts.

> Web pages cannot run programs, so clicking a launcher link below on GitHub only shows its text.
> Click links to *find* the right file, then double-click that file inside your own copy of the
> project in **File Explorer** (Windows) or **Finder** (Mac).

**Step 0: get the project onto your computer (once).** Follow the first section of the
[Windows quickstart](docs/development/WINDOWS-QUICKSTART.md) or the
[Mac quickstart](docs/development/MACBOOK-QUICKSTART.md). A ZIP download will not work; you need a Git clone.

**Easiest way:** double-click the one start file for your computer and pick from the menu.

| Windows | Mac |
|---|---|
| [`START-WINDOWS.cmd`](START-WINDOWS.cmd) | [`START-MAC.command`](START-MAC.command) |

**Or go step by step.** Open the `launchers` folder, then `windows` or `mac`, and double-click the files in number order:

| Step | What it does | Windows | Mac |
|---|---|---|---|
| 1 | Installs everything you need to edit, test and share changes, then offers a 2-minute **Try it now** walkthrough (practice Firebase + the app) and a checklist. The first run can take a while; it is safe to rerun. | [1 - Set up this computer.cmd](launchers/windows/1%20-%20Set%20up%20this%20computer.cmd) | [1 - Set up this computer.command](launchers/mac/1%20-%20Set%20up%20this%20computer.command) |
| 2 | Opens the app in Chrome. | [2 - Run the app.cmd](launchers/windows/2%20-%20Run%20the%20app.cmd) | [2 - Run the app.command](launchers/mac/2%20-%20Run%20the%20app.command) |
| 3 | Starts the practice Firebase database on your computer only. Leave its window open. | [3 - Start practice Firebase.cmd](launchers/windows/3%20-%20Start%20practice%20Firebase.cmd) | [3 - Start practice Firebase.command](launchers/mac/3%20-%20Start%20practice%20Firebase.command) |
| 4 | Runs the app connected to the practice database (after step 3 says *All emulators ready*). | [4 - Run app with practice Firebase.cmd](launchers/windows/4%20-%20Run%20app%20with%20practice%20Firebase.cmd) | [4 - Run app with practice Firebase.command](launchers/mac/4%20-%20Run%20app%20with%20practice%20Firebase.command) |
| 5 | Checks your setup and explains how to fix anything missing. | [5 - Check my setup.cmd](launchers/windows/5%20-%20Check%20my%20setup.cmd) | [5 - Check my setup.command](launchers/mac/5%20-%20Check%20my%20setup.command) |

Optional extras live in [`launchers/windows/more`](launchers/windows/more) and [`launchers/mac/more`](launchers/mac/more):
preview-only setup (view the app without editing tools), Android tools (Windows), the iPhone simulator (Mac), the Architecture Atlas, the knowledge workspace preview, and an optional AI code review.

**Then make your first change:** [Your first contribution](docs/development/FIRST-CONTRIBUTION.md).
Stuck? Run step 5, then see [First-run troubleshooting](docs/development/FIRST-RUN-TROUBLESHOOTING.md).

**First time on a Mac:** if macOS says the file "cannot be opened", right-click it, choose **Open**, then **Open** again (once per file).
**First time on Windows:** if SmartScreen appears, choose **More info**, then **Run anyway**.

## Repo layout

| Path | What it is |
|---|---|
| `mobile/` | The Flutter app (Android, iOS; Chrome for preview). Rules for agents: `mobile/AGENTS.md`. |
| `firebase/`, `firebase.json`, `.firebaserc` | Firestore and Storage rules and the local `demo-forgedandsent` emulator setup. Nothing is deployed. |
| `tooling/` | Setup scripts (`windows/`, `macos/`), CI policy, the knowledge and review tools. |
| `docs/` | The knowledge home ([`docs/HOME.md`](docs/HOME.md), opened in Obsidian), architecture, feature contracts, developer guides. |
| `index.html` | The HTML prototype's current version. A single self-contained file: HTML, CSS and JS. |
| `versions/app-v1.html` ... `app-v238.html` | Every earlier iteration, kept for rollback. A new version file is created for each iteration; never overwrite old ones. |
| `seed/` | Starting data: `tasks.json` (standard daily list), `lifts.json` (core lifts), `devotionals.json` (366 daily devotionals, one per calendar date, also embedded in `index.html`), `db-rules.json` (access rules and runtime capabilities the page declares). `weekly-challenges.json` (52-week challenge program: one Family, one Iron and one Endure challenge per week, with the 0-100 age-bracket scoring rules, injury-friendly alternates and season metadata) and `movement-standards.json` (what counts as a rep). |
| `START-WINDOWS.cmd`, `START-MAC.command`, `launchers/` | Double-click setup and run launchers (see "New here? Start here"). The scripts they call are in `tooling/`. |
| `dev/` | Local preview. `mock-claude.js` is an in-memory stand-in for `window.claude`; `make_preview.py` builds `dev/preview.html`. |
| `docs/architecture-notes.md` | Architecture and store-readiness notes. |
| `docs/health-integration.md` | Apple Health and Health Connect plan, bridge contract and store requirements. |

## Working together

All changes use short-lived branches and pull requests to protected `main`.
The solo maintainer is not required to obtain a second human or independent AI approval.
GitHub requires the deterministic `ci-gate` check. For Flutter database, Firebase
rules, Auth, scoring or private-data changes, consider an optional non-author AI
security review, alongside mandatory tests. AI agents must not self-merge.

See [repository security and review rules](docs/development/REPOSITORY-SECURITY.md)
for the exact path patterns and GitHub administrator setup. Those rules
must be enabled in GitHub; documentation alone does not enforce them.

## Running it

**Locally (for development):**

```
python3 dev/make_preview.py
# open dev/preview.html in a browser (a phone-width window shows the real layout)
```

The mock keeps data in memory only, shows one fake user, and cannot display uploaded photos (real media is served by the claude.ai runtime). It is for UI work, not for testing sharing or persistence.

**On claude.ai:** publish `index.html` with the Artifact tool, declaring the capabilities in `seed/db-rules.json` (`db` with rules, `user` with the `profile` scope, `assets` with `upload: "interact"`, `sample` for the food estimate). Then load `seed/tasks.json` and `seed/lifts.json` into the `tasks` and `lifts` collections (as the developer; both are admin-write).

## Architecture

- **One file, five pages plus Profile and Settings.** Today (checklist), Fuel (macros, water, 7-day strip), Train (Monday-Sunday calendar strip, PR bonuses), Board (standings), Check-in (community thread), Profile (banner, picture, motto, core-lift PRs), Settings (profile, body and goal calculator, targets, reminders, theme, blocked users, delete my data).
- **App shell:** the page never scrolls. `#scroll` scrolls vertically; the tab bar is a fixed row below it. Safe-area insets are respected for phones.
- **Backend adapter `B`.** Every call to the database, user profiles and file storage goes through the `B` object near the top of the script. This is the migration boundary: replace `B` with a client for a real backend and the rest of the app is unchanged.
- **Data model** (Firestore-style documents):
  - `tasks/{id}` standard daily list, developer-controlled (`title, sub, points, kind, mandatory`). Kinds: `check`, `devo`, `water`, `workout`, `calories`, `checkin`.
  - `lifts/{id}` core lifts, developer-controlled (`name, order`).
  - `checkins/{date}_{uid}` shared: `done` flags and `prs {w, v}`.
  - `habits/{uid}` the man's three custom habits.
  - `profiles/{uid}` shared: `motto, avatarId, bannerId, prs {liftId: {w, reps, date}}`.
  - `posts/{id}`, `likes/{postId}_{uid}`, `reports/{id}` community thread.
  - Campaigns (team battles): `camps/current` (owner-only: campaign number, sign-up and start dates, weekly double box) and `camps/hist_<id>` (closed campaign results); `teams/{captainUid}` (captain-only: name, banner, invites); `tmembers/{uid}` (each man: which team he joined, or invites he declined). Team score = average Kingdom Warrior points per man per week + 25 when every man checks every daily box all 7 days. Team chat: `tposts/{id}` (team id on each post; replies and reactions reuse Rally's). On claude.ai the app hides other teams' chats, but storage can't restrict reads by team; enforce with Firebase security rules after the move.
  - PRIVATE per user: `data/users/<id>/log/days/<date>` (water oz, calories, protein, fat, carbs totals, plus `meals` {breakfast, lunch, dinner, snack: [{id, name, kcal, p, f, c}]}) and `data/users/<id>/settings` (targets, body stats, reminder times, blocked users).
- **Access rules** (see `seed/db-rules.json`): standard list and lifts are admin-write; each man writes only his own habits and profile; personal health data lives in the private subtree. A real backend must enforce the same rules server-side.

## Scoring and behavior

- Points = task points + 1 per custom habit done + PR bonus (+2 per weight PR, +1 per volume PR; assumed values, easy to change via `PR_W` and `PR_V`).
- Week runs Monday to Sunday. Streak = consecutive days with the devotional done.
- Auto-checked boxes: Workout (from Train), Water (3 L = 101.4 oz, from Fuel), Calories (within 90-110% of target), Daily Check-In (posting in the thread). The devotional box checks after the man confirms he read it.
- Logging a new weight record on a core lift adds one weight PR to that day.
- Targets calculator: Mifflin-St Jeor resting burn x activity factor, minus 500 kcal per lb/week to lose, plus 250 to build, with a 1,500 kcal floor. Reference: https://pubmed.ncbi.nlm.nih.gov/2305711/

## Path to the App Store and Google Play

The decided path (October 2026): a native Flutter app with a Firebase backend, built in `mobile/` ([ADR-0005](docs/architecture/ADR-0005-flutter-client-stack.md)). The checklist below still applies to it.

1. **Real backend:** accounts, database, media storage, push notifications (Firebase). Implement a new `B` against it and enforce the access rules server-side.
2. **Native app:** the Flutter rebuild, not a wrapped web page. Apple guideline 4.2 rejects apps that are just a repackaged website, so add real native features (push, camera, health integrations).
3. **Account deletion:** an in-app "Delete my data" exists in Settings (Apple 5.1.1(v)). Google Play also requires a web link for deletion requests and a Data safety form.
4. **User-generated content (Apple 1.2):** report and block exist. Still needed: content filtering, a moderation queue, and published support contact info.
5. **Health data (Apple 5.1.3 and 1.4.1):** disclose what is collected, no ads or data mining, medical disclaimers (present in Settings).
6. Privacy policy and terms.

Sources: [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [Google Play account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en-GB).

## Devotionals

The Daily Devotional box opens a full-screen devotional for today's date (Open in Prayer, Reading, Reflect, Act). The man must scroll to the bottom before "Mark as read" enables; marking it read checks the box and returns to Today. Scripture is the Berean Standard Bible (public domain per the source document); verify each verse against the official text at berean.bible before launch. Content source: `Daily Devotional: 365 Days for Men` (366 entries incl. Feb 29). Some verses may overlap with the Steel & Scripture book; compare lists if zero overlap is wanted.

## Health data

Steps, Weigh-In and Workout can be filled from Apple Health or Health Connect once the app is wrapped natively. The page reads a `window.ForgedHealth` bridge; see `docs/health-integration.md`.

## Open items

- Food log is in (breakfast, lunch, dinner, snack; manual entry of calories and macros, recent foods). Still to do: food search or barcode scan with a nutrition database, micronutrients.
- AI-generated workouts on the Train calendar.
- Final core lift list (placeholders seeded), profile photo cropping, public support email.
- Name clearance: trademark, app store, domain and social handle checks for "Forged & Sent" ("Forged" is common in men's ministry names).
- Large video uploads: 20 MiB cap in the prototype; needs external storage. Photos are resized in the browser (JPEG, long edge 2048 px for posts, 1600 banner, 640 profile picture) so size is no longer an issue.

## License

Private, unreleased. No license granted yet.


## First-time developer onboarding

See [New here? Start here](#new-here-start-here) above. Details: [Windows Quickstart](docs/development/WINDOWS-QUICKSTART.md), [Mac Quickstart](docs/development/MACBOOK-QUICKSTART.md) and [First Contribution](docs/development/FIRST-CONTRIBUTION.md). Use Git and a feature branch; no Firebase cloud account is needed for the local practice database. AI coding assistants are optional; sign in only to the ones you pick during setup. iOS/Android device provisioning is a separate manual step.

## Shared agents, local code reviews and architecture

- [Beginner AI-review walkthrough](docs/development/AI-REVIEW-WORKFLOW.md): Optional Codex, Claude, and Gemini reviews, especially for Flutter database changes.
- [Living system architecture](docs/architecture/SYSTEM.md): current implementation, planned system and review pipeline diagrams.
- [Generated Flutter code map](docs/architecture/CODE-MAP.md): actual Dart imports, classes and methods. CI checks drift.
- Checked-in Codex `.agents/skills/` and Claude `.claude/skills/` workflows must match exactly.
- Windows: `launchers/windows/more/AI code review.cmd`. Mac: `launchers/mac/more/AI code review.command`. Try `--dry-run` before making paid AI requests.

## Explore the engineering architecture as a webpage

- **Windows:** double-click `launchers/windows/more/Architecture Atlas.cmd` in the cloned repository.
- **Mac:** double-click `launchers/mac/more/Architecture Atlas.command`.
- **Any OS:** run `python3 tooling/architecture/build_explorer.py --write` and open `build/architecture-explorer/Architecture-Atlas.html` (a single standalone webpage).

The [Architecture Atlas guide](docs/architecture/explorer/README.md) covers keyboard shortcuts, interactive component ownership, source functions and reverse dependencies, independent AI reviewer models, and the full tracked-file index. CI also produces an offline `forged-sent-architecture-atlas` artifact for every PR.

### Mentor feature readiness

Paul & Timothy currently provides Scripture and explanatory content only. Pairing,
weekly check-ins and nudges are deferred until server-side private access is
enforced. Existing mentor documents mix pair metadata with sensitive requests,
so the active prototype does not read or write that collection. The v227
capability manifest no longer grants mentor access. Historical `versions/` files
and patch scripts are reference snapshots, not safe deployment configurations.
Previously stored runtime data has not been deleted or verified by this change;
the maintainer must revoke any previously deployed mentor grant in that runtime.
