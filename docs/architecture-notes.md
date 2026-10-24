# Forged & Sent: architecture and store-readiness notes

Name: Forged & Sent (chosen 2026-10-24; earlier working names Roll Call, Forged Men's Health). Foundation: 1 Corinthians 16:13-14 and the Great Commission (Matthew 28:19). Trademark, app store, domain and social handle checks still to do.

Current build: v8, a single-file web app published as a claude.ai Artifact. Earlier versions are kept as app-v1 to app-v7 for rollback.

## Pages
Today (checklist), Fuel (macros, water, 7-day strip), Train (Mon-Sun calendar strip, PR bonuses), Board (standings), Check-in (community thread), Profile (banner, picture, motto, core-lift PRs), Settings (profile, body and goal calculator, targets, reminders, theme, blocked users, delete my data).

## Data model
- `tasks/{id}`: developer-controlled standard list (`title, sub, points, kind, mandatory`). Kinds: check, devo, water, workout, calories, checkin.
- `lifts/{id}`: developer-controlled core lifts (`name, order`). Seeded as placeholders: Back Squat, Bench Press, Deadlift, Overhead Press.
- `checkins/{date}_{uid}`: shared. `done` flags plus `prs {w, v}`.
- `habits/{uid}`: the user's 3 custom habits.
- `profiles/{uid}`: shared. `motto, avatarId, bannerId, prs {liftId: {w, reps, date}}`.
- `data/users/<id>/log/days/<date>`: PRIVATE water, kcal, protein, fat, carbs.
- `data/users/<id>/settings`: PRIVATE targets, body stats, reminder times, blocked users.
- `posts/{id}`, `likes/{postId}_{uid}`, `reports/{id}`: community thread. Media via assets (20 MiB cap).

## Scoring
Task points + 1 per custom habit + PR bonus (+2 weight PR, +1 volume PR; assumed values). Logging a new weight record on a core lift adds one weight PR to today. Calories box checks at 90-110% of target. Water box checks at 3 L (101.4 oz).

## Calculator
Mifflin-St Jeor resting burn x activity factor; lose-fat subtracts 500 kcal per lb/week, build adds 250; 1,500 kcal floor; protein per lb, fat as % of calories, carbs the remainder. Source: https://pubmed.ncbi.nlm.nih.gov/2305711/

## Migration boundary
All db, user and assets calls go through the `B` adapter object in the page. Moving to production means replacing `B` with a client for a real backend (auth, database, media storage, push).

## Store-readiness checklist
- Wrap natively (e.g. Capacitor) or rebuild in React Native/Flutter. Apple 4.2 rejects repackaged websites, so add native features (push, camera, health integrations).
- Real backend: accounts, database, media storage, push notifications.
- Account deletion: in-app "Delete my data" exists (Apple 5.1.1(v)); Google Play also needs a web deletion link and Data safety form.
- User-generated content (Apple 1.2): report and block exist; content filtering, a moderation queue and a public support contact are still needed.
- Health data (Apple 5.1.3, 1.4.1): disclose collection, no ads or data mining, medical disclaimers (present in Settings).
- Privacy policy, terms.

Sources:
- https://developer.apple.com/app-store/review/guidelines/
- https://support.google.com/googleplay/android-developer/answer/13327111?hl=en-GB

## Open items
- Food entry (meals, micros), AI workout generation, real devotional content, external video storage.
- Real core lift list, profile photo cropping, public support email.
