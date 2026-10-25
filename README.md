# Forged & Sent

A men's fitness and accountability app for the Forged in Faith men's group. Men follow a shared daily checklist, track food, water and training, post check-ins, and compete on weekly standings. The foundation is 1 Corinthians 16:13-14 and the Great Commission (Matthew 28:19): care for the body so a man can lead his family and do kingdom work.

**Status: working prototype, not yet store-ready.** It runs today as a [claude.ai Artifact](https://claude.ai) (a private hosted page). It does **not** run as a plain static site, because its database, user identity and file storage come from the claude.ai runtime (`window.claude`). See "Running it" and "Path to the App Store and Google Play".

## Repo layout

| Path | What it is |
|---|---|
| `index.html` | Current version. A single self-contained file: HTML, CSS and JS. |
| `versions/app-v1.html` ... `app-v101.html` | Every earlier iteration, kept for rollback. A new version file is created for each iteration; never overwrite old ones. |
| `seed/` | Starting data: `tasks.json` (standard daily list), `lifts.json` (core lifts), `devotionals.json` (366 daily devotionals, one per calendar date, also embedded in `index.html`), `db-rules.json` (access rules and runtime capabilities the page declares). |
| `dev/` | Local preview. `mock-claude.js` is an in-memory stand-in for `window.claude`; `make_preview.py` builds `dev/preview.html`. |
| `docs/architecture-notes.md` | Architecture and store-readiness notes. |
| `docs/health-integration.md` | Apple Health and Health Connect plan, bridge contract and store requirements. |

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
  - PRIVATE per user: `data/users/<id>/log/days/<date>` (water oz, calories, protein, fat, carbs totals, plus `meals` {breakfast, lunch, dinner, snack: [{id, name, kcal, p, f, c}]}) and `data/users/<id>/settings` (targets, body stats, reminder times, blocked users).
- **Access rules** (see `seed/db-rules.json`): standard list and lifts are admin-write; each man writes only his own habits and profile; personal health data lives in the private subtree. A real backend must enforce the same rules server-side.

## Scoring and behavior

- Points = task points + 1 per custom habit done + PR bonus (+2 per weight PR, +1 per volume PR; assumed values, easy to change via `PR_W` and `PR_V`).
- Week runs Monday to Sunday. Streak = consecutive days with the devotional done.
- Auto-checked boxes: Workout (from Train), Water (3 L = 101.4 oz, from Fuel), Calories (within 90-110% of target), Daily Check-In (posting in the thread). The devotional box checks after the man confirms he read it.
- Logging a new weight record on a core lift adds one weight PR to that day.
- Targets calculator: Mifflin-St Jeor resting burn x activity factor, minus 500 kcal per lb/week to lose, plus 250 to build, with a 1,500 kcal floor. Reference: https://pubmed.ncbi.nlm.nih.gov/2305711/

## Path to the App Store and Google Play

1. **Real backend:** accounts, database, media storage, push notifications (for example Firebase or Supabase). Implement a new `B` against it and enforce the access rules server-side.
2. **Native wrapper:** package the front end with Capacitor, or rebuild in React Native or Flutter. Apple guideline 4.2 rejects apps that are just a repackaged website, so add real native features (push, camera, health integrations).
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
