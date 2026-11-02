# HTML/JavaScript prototype to Flutter behavior contract

The current `index.html` is a large working behavioral prototype, not Flutter source or a trusted backend. Its `window.claude` and `B` adapter cannot be copied as Firebase production authorization. Historical HTML files under `versions/` are snapshots; don't ingest them into agent context by default.

Use a traceable screen-by-screen migration. Every future vertical slice links the relevant prototype function or UI state at a source SHA, an approved requirement, a Flutter implementation path, positive/negative tests and platform screenshots as appropriate.

| Existing prototype surface | Flutter target behavior to specify | Highest risk or open decision | Porting status |
|---|---|---|---|
| Today checklist + devotional | Daily checklist, scripture workflow, optional timing | Completion evidence, private reflection | Not implemented/verified |
| Train calendar + PRs | Exercise logging, progress, weekly summaries | Offline outbox and server score authority | Not implemented/verified |
| Fuel + macro tracking | Meal/water entries and personal goals | Privacy, accuracy and health permissions | Not implemented/verified |
| Board | Group scores/standings | Tenant isolation, tamper resistance | Not implemented/verified |
| Check-in | Community posts, reports, blocks | Moderation and access control | Not implemented/verified |
| Profile | Avatar, motto, records | Shared versus private fields | Not implemented/verified |
| Settings | Preferences, reminders, data deletion | Platform permissions, deletion compliance | Not implemented/verified |

These are migration candidates, not a decision to copy every prototype feature or its numeric formulas. Existing details live in `docs/architecture-notes.md`, `seed/` and current `index.html`, with many prior versions preserved.

## Per-feature acceptance contract
1. Record original source commit, explicit source code locations and screenshots/behavior; don't guess functions from an old architecture map.
2. Define a user outcome and failure/offline/accessibility states. Reconcile prototype semantics with accepted ADRs and approved product decisions.
3. Implement using testable Flutter view/view-model/repository boundaries and fakes first.
4. Add unit/widget tests for state, events, error handling, accessibility and meaningful viewport sizes.
5. Run emulator negative authorization tests when data access changes. Verify on Android/iOS first; mark web/desktop gaps precisely.
6. Link PR, test evidence and observed parity in the handoff. Update architecture and status only for implemented behavior.

Do not silently translate unsafe prototype auth, client scoring, private data models or HTML/JS DOM code into Dart.
