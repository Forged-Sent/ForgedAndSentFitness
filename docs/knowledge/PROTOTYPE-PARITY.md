# HTML/JavaScript prototype to Flutter behavior contract

The current `index.html` is a large working behavioral prototype, not Flutter source or a trusted backend. Its `window.claude` and `B` adapter cannot be copied as Firebase production authorization. Historical HTML files under `versions/` are snapshots; don't ingest them into agent context by default.

This page is the live record of which prototype screens exist in Flutter. Each pull request that builds or changes a screen updates its row here in the same pull request (Not started, In progress, Implemented).

Use a traceable screen-by-screen migration. Every future vertical slice links the relevant prototype function or UI state at a source SHA, an approved requirement, a Flutter implementation path, positive/negative tests and platform screenshots as appropriate.

**Prototype baseline (decision Q1 on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page):** v254 for layout and navigation; `main`'s behavior for saves and privacy. Reconcile once and tag it. v254's Bold Step and Instagram actions are left out until scoring is decided in S4. v254 is `versions/app-v254.html` on branch `app/v241-bold` at commit `3ff4a6f`. `main`'s prototype is `index.html` as last changed in commit `dd35157` (v238 plus hardening). The reconciliation and the tag do not exist yet; they are prompt [P02](../reviews/2026-11-10-prototype-to-flutter/prompts/P02-reconcile-prototype-baseline.md).

Detail for every row, with actions, data and acceptance criteria: [screens and UI](../reviews/2026-11-10-prototype-to-flutter/06-SCREENS-AND-UI.md).

| Prototype view | Flutter status | Planned in | Biggest gap to close |
|---|---|---|---|
| App shell: brand bar, hero header, six-tab bar | Implemented | S0 | The round header buttons do nothing yet, except Today's profile button, which opens Settings; five of the six tabs are titled placeholders; Rally's own compact header is not built; run on one Android emulator (the S1 restart test), not on a phone |
| Legal gate | Not started | Later, not yet scheduled | Prototype stores it in private settings and does not enforce it on writes |
| Setup wizard | Not started | Later, not yet scheduled | Body stats and injuries are sensitive; ADR-0005 defers storing them |
| Today | Implemented | S1 | Shows the date, the streak line, the mission line, the progress ring and the seven daily boxes. Only the devotional box works; the other six are drawn faded and say "Not active yet". Not built: first orders, "Your two" habits, the campaign card, the Stand Firm creed card, the grace and sit-out cards, the Sabbath-only boxes (weigh-in, photos, family report, legacy log) and the mission-complete dialog. Point values are hidden unless the preview switch is on, and no total is shown (decision Q5); the streak counts devotional days, not full days (decision Q6) |
| Devotional | Implemented | S1 | Scroll to the end, Amen, Undo, and the BSB / ESV tab work, and the completion survives a restart. Not built: "Write it down" (S2), and the search and help buttons in the page's bar. Since S1b the reading shows v254's words, headline, tags and "In Jesus" section; what still differs is listed below |
| Journal editor and page | Not started | S2 | Sensitive-field storage and sign-out retention are undecided (ADR-0005) |
| Train | Not started | S3 | Plan-start dead zone (U1) |
| Workout | Not started | S3 | Index-keyed history (U3); midnight (U2); rest timer silent when the phone is locked |
| Exercise detail | Not started | Later, not yet scheduled | Video is an outbound link |
| Weekly challenges | Not started | Later, not yet scheduled | Deadline enforced on the device clock; approved direction requires video capture in the first challenge release |
| Fuel | Not started | Later, not yet scheduled | Fasting rule (R3) |
| Board | Not started | S4 | R1, R2; client-computed totals |
| Campaign and team | Not started | Later, not yet scheduled | Tab placement differs between forks |
| Rally | Not started | Later, not yet scheduled | Report and block unreachable (U7) |
| Profile | Not started | Later, not yet scheduled | Two unrelated PR systems |
| Settings | In progress | S1 for one switch; the rest later, not yet scheduled | Only the preview points switch (decision Q5), the scripture credits and the way to the build status page exist. Reminders and health are stubs in the prototype; delete is incomplete (U8) |
| Owner tools | Not started | Later, not yet scheduled | Owner gating is hidden-flag only |
| Paul & Timothy | Not started | Later, not yet scheduled | The forks disagree; `main` deferred it for privacy |
| Legacy log, family report, junior challenge | Not started | Later, not yet scheduled | Family report sends personal text to a model without saying so |
| Help and Ask | Not started | Later, not yet scheduled |  |
| Sign-in | Not started | S4 | No implementation plan |

### The reading shows v254's words (step S1b)

The maintainer decided on 2026-11-12 that the readings inside v254 are the real readings for the pilot. Step S1b put them in `seed/devotionals.json` and in the app's copy, for all 366 dates, and the reading now shows the parts it had no data for:

| v254 section | Field | In the app |
|---|---|---|
| Headline under the date ("Every gift came from above") | `headline` | Implemented, on all 366 dates. Its lines are balanced as the prototype's are (`text-wrap: balance`) |
| "In Jesus" section, between Reading and Reflect | `jesus` | Implemented, on all 366 dates |
| "Sent: take it to someone" and "Spirit-led" tags | `sent`, `spirit` | Implemented as words to read, on 48 and 55 dates. They do nothing in v254 either |
| Series line | `series` | Implemented in S1: the 29 February readings |

The prayer, the reflection question and the action are v254's too. What still differs from v254 in the reading:

| Difference | Kind | Why |
|---|---|---|
| The verse opens in the BSB, with a BSB / ESV tab and a credit line under it; v254 shows the ESV only | Design change, decided | Decision Q7 |
| The ESV wording is `seed/esv-verses.json`'s, not v254's own. The two differ on 108 dates, mostly in quotation marks, a first capital or a final full stop | Left as it was | Scripture text is copied only from a named source and has not been checked against a published one. On the work board |
| In the light theme the Sent tag is the bright orange of the Spirit-led tag; v254 draws it in the light theme's dark orange | Design change, decided by the maintainer on 2026-11-12 | The dark orange is hard to read on the dark header (about 3 to 1) |
| A verse or a reflection question can break a word earlier than in v254 | Bundled font file | The bundled Merriweather draws 2 to 4% wider than the one the prototype loads from Google Fonts. Body text (IBM Plex Sans) breaks where v254's does since S1b removed a stray letter spacing. See the [design system page](../design/DESIGN-SYSTEM.md) |
| "Write it down" and the search and help buttons are absent | Not built | S2, and later |

Two box titles on Today differ from v254's reference pictures as well: the app shows `seed/tasks.json`'s Rally Call and Hydrate, and the pictures show Daily Check-In and Drink 3 Liters of Water, which are the titles of the mock runtime the prototype is captured with. That belongs to the prototype reconciliation (prompt P02, on the work board).

These are migration candidates, not a decision to copy every prototype feature or its numeric formulas. Existing details live in `docs/architecture-notes.md`, `seed/` and current `index.html`, with many prior versions preserved.

## Per-feature acceptance contract
1. Record original source commit, explicit source code locations and screenshots/behavior; don't guess functions from an old architecture map.
2. Define a user outcome and failure/offline/accessibility states. Reconcile prototype semantics with accepted ADRs and approved product decisions.
3. Implement using testable Flutter view/view-model/repository boundaries and fakes first.
4. Add unit/widget tests for state, events, error handling, accessibility and meaningful viewport sizes.
5. Run emulator negative authorization tests when data access changes. Verify on Android/iOS first; mark web/desktop gaps precisely.
6. Link PR, test evidence and observed parity in the handoff. Update architecture and status only for implemented behavior.

Do not silently translate unsafe prototype auth, client scoring, private data models or HTML/JS DOM code into Dart.
