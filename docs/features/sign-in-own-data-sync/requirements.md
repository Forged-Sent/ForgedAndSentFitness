---
kind: feature-spec
feature_id: FNS-005
status: proposed
risk: high
owner: maintainer
source_ref: claude/s4a-contract
source_sha: 1c1339b25dad47a5760ea7b7eb4ab12fb260c4c4
approved_by: none
test_plan: emulator rules tests for every row of the rules table with the negative cases listed under Negative tests, outbox tests for send-once and retry and replay and server read-back, ordering rule R2 tests on the phone, adoption and sign-out and erase and account-switch tests on a real SQLite file, account deletion test that lists every owned path, one two-device run on emulators
verified_tests: none
implementation_paths: none
verification: none
---

# S4a: sign-in, his own data on his account, sign-out, account deletion

The first half of build step S4 of the [prototype-to-Flutter review](../../reviews/2026-11-10-prototype-to-flutter/02-BUILD-PLAN.md). This is a **proposed** contract drafted by Claude. Only the maintainer can approve it. **Nothing in it is built.** There is no code under `mobile/`, `firebase/` or `functions/` for any of it, no `functions/` folder, and no cloud Firebase project.

Companion pages: [design](design.md) and [tasks](tasks.md). The second half, groups, teams, scoring and the board, is the [S4b stub](../groups-teams-board/requirements.md).

## Why there are two halves

On 2026-11-19 the maintainer split S4:

- **S4a** (this contract): sign-in, his own data kept on his account, sign-out, account deletion.
- **S4b**: groups, teams, scoring, the board.

The split and the answers marked "2026-11-19" below were given in conversation. They are not yet on the [Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page or in the build plan, which still describe one S4. Only the maintainer edits the Decisions page.

**No points exist anywhere in S4a.** No Cloud Function reads a man's events, nothing is scored, and no other man can read anything of his. Today stays as decision Q5 leaves it: point values hidden, with the "preview, not official" switch.

## How to read this page

- **Decided** means the maintainer's answer is on the Decisions page or in an accepted record, and it is quoted or cited.
- **Decided 2026-11-19** means the maintainer answered it in conversation that day, and has not yet recorded it on the Decisions page.
- **Proposed** means Claude's draft. It is not a decision. Approving this contract approves the proposals in it.
- **Parked** means it belongs to S4b. It is listed in the [S4b stub](../groups-teams-board/requirements.md) and is not asked here.

## Decisions this rests on

| Decision | The answer | Status |
|---|---|---|
| Q10, use before sign-in | A man may use the app before signing in, with a local profile adopted at first sign-in | Decided ([Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md)) |
| Q9, day boundary | The device's local date at the moment of the action, stamped on the event with the UTC offset | Decided |
| Q8, journal | "Device-only with manual export for the pilot. But architect for future case of sync and encrypted" | Decided |
| Q5, points on screen | Hidden until server scoring exists; a Settings switch shows the prototype's values labelled "preview, not official" | Decided |
| The completion event's key | Option A: the event id is the only key (2026-11-11) | Decided ([Architecture](../../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md), journey J1) |
| Standing rules | Private prayers, reflections, nutrition, injuries and body measurements never appear in group queries. Emulator-first, no cloud project on contributor devices. Firebase's cache alone is not durable enough for offline work | Decided (`AGENTS.md`, ADR-0002) |
| Faith participation is private | No leader, admin client or Function reads a journal. Which box a man did on which day is his own | Decided (Q4; the record is ADR-0009 once pull request #80 merges, Phase 0 ADR-0012 before that) |
| The split into S4a and S4b | As above | Decided 2026-11-19 |
| Which unreplaced completion event wins (was B1) | Rule R2: longest chain, then event id | Decided 2026-11-19. The rule is written out in [Architecture](../../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md), journey J1 |
| The account and the phone both have days (was B9) | Keep both. Never ask him about any of them | Decided 2026-11-19 |
| A signed-out profile that holds something when he signs in | Ask once, "Are these yours?". "No" leaves that data untouched as a signed-out profile; it is never deleted or merged. An empty profile is not asked about | Decided 2026-11-19 |
| After a "No" | That signed-out profile is never offered again, to any account. It stays signed-out only | Decided 2026-11-20 |
| What stays on the phone at sign-out (was B10) | His file stays on the phone, locked to his account. There is also a separate "Sign out and erase this phone" | Decided 2026-11-19 |
| Account deletion (was B14) | It is part of S4a. He is warned, then his file on that phone is erased. An export is offered only if the app already has one; S4a adds none | Decided 2026-11-19 |
| Per-device sign-out (was B15) | Build "Sign out of this phone" and "Sign out everywhere". Decide per-device sign-out later | Decided 2026-11-19 (the earlier draft's default) |
| Server language and cloud project (was B19) | TypeScript on the Node version CI already uses, in the emulator only. No cloud project | Decided 2026-11-19 (the earlier draft's default) |
| Sign-in: Apple, Google, or email and password, behind the 18+ terms checkbox; no app lock; the security baseline | As written in the [sign-in design](../../design/sign-in.md) | **Proposed.** That page says "Approved by Curtis" (2026-11-01). The maintainer has said to treat that as not his approval. Every rule this contract takes from it is a proposal until he approves it |

## Outcome to approve

Nothing in this section is approved yet. It is what the maintainer is asked to approve.

**What a man can see when S4a is done**

1. **Sign in.** He ticks the 18+ terms box and continues with Apple, with Google, or with email and password. He stays signed in on that phone until he signs out. (Proposed: sign-in design.)
2. **His days come with him, if they are his.** When he signs in on a phone that was used signed out, he is asked once, "Are these yours?". Yes moves those days and that journal into his account's data on the phone. No leaves them where they were, untouched, and that data is never offered to an account again. If nothing was there he is not asked. (Decided: Q10; decided 2026-11-19.) If his account already has days, both sets are kept and he is never asked to choose between them. (Decided 2026-11-19.)
3. **His completions are kept on his account, once each.** A box he checks offline is sent when the phone is back online. Sending it twice changes nothing. (Decided: the event id is the only key. Proposed: the outbox in [design](design.md).)
4. **A second phone shows the same days.** He signs in on another device and his days are there. If two devices changed the same box without seeing each other, rule R2 settles it, the same way on both. (Decided 2026-11-19: R2.)
5. **Sign out.** His data stays on the phone and can be opened again only by signing in to his account. A second account on the same phone sees none of it. (Decided: build plan S4 "Done when"; decided 2026-11-19: the file is kept.)
6. **Sign out and erase this phone.** A separate, explicit action removes his data from that phone. (Decided 2026-11-19.)
7. **Sign out everywhere.** Every phone signed in to his account is signed out. (Proposed: sign-in design. Decided 2026-11-19: it is in S4a.)
8. **Delete his account.** Everything of his on the server is deleted, and the sign-in itself. He is warned, and then his data on that phone is erased, journal included. (Decided 2026-11-19. Proposed: how.)

**Not in S4a**

- Groups, teams, points, the board, hiding from the ranking, owner tools, the "ask the brothers to pray" action: all S4b.
- Any sync of the journal or of body data (Q8). Households and youth. A cloud deployment.
- Sync of workout logs: see open item O2.

**Acceptance**

From the build plan's "Done when", the parts that belong to S4a:

- Rules tests: a man cannot read or write another man's events. A signed-out client reads and writes nothing.
- Airplane-mode completions reach his account after reconnect, once each. ("Appear on the board" belongs to S4b.)
- A second account on the same phone sees none of the first account's data.

Added by this contract:

- After account deletion, no document of his is left on the server. The test lists every path in the rules table.
- Two devices given the same events show the same day state, in any order of arrival.

The build plan's "a member cannot read another group" and "cannot write totals" belong to S4b. In S4a every path outside a man's own is denied to every client, and the tests check that.

## Authorization, privacy and data ownership

### Actors

| Actor | Who |
|---|---|
| Signed-out client | No Firebase Auth user |
| The man (self) | Authenticated; the uid in the path is his |
| Another signed-in man | Authenticated; a different uid. There are no groups in S4a, so he is a stranger to every other account |
| Cloud Function | Server code using the Admin SDK. S4a has two: "Sign out everywhere" and account deletion. Neither reads the content of an event. Rules do not apply to Functions; their own checks are in [design](design.md) |

### Data, and who owns it

| Data | Owner | Leaves the phone in S4a? |
|---|---|---|
| His email address, display name and sign-in provider | The man | **Yes**, to Firebase Authentication. This is the first step that holds an identity for him |
| Completion events (which box, which local date, done or not done, when, what it replaces, chain length) | The man | **Yes**, to his own private path. Only he can read them |
| His acceptance of the terms (version and server time) | The man | **Yes**, to his own private path |
| The time he last chose "Sign out everywhere", and a marker while his account is being deleted | The server, about him | Stored on the server; he can read the first |
| Day state (what each box shows) | The man | **No.** Each device works it out from his events with rule R2 |
| Journal entries (Q8) | The man | **No** |
| Fasting (Q3) | The man | **No** |
| Weight, body measurements, injuries, nutrition | The man | **No** |
| Workout logs (build step S3) | The man | **No** in this contract; see O2 |

### Rules that follow from decisions

- **Only he reads his events.** An event says which box he did on which day; for the devotional that is his faith participation. No other client can read it, and no Function reads it in S4a.
- **Events are create-only, and the document id equals the event id** (decided: P08, journey J4).
- **Clients write facts and nothing else.** A client can create its own events and its own agreement record. It can write nothing else, anywhere.
- **The journal never leaves the phone** (decided: Q8). No table but the events table is read by the sync worker.
- **Everything outside `users/{his uid}` is denied to every client.** There is no group path in S4a. The one exception is the emulator's smoke path, which exists today and is not part of this contract: it is removed before any ruleset is used with a cloud project.

The full rules table, by actor and resource, is in [design](design.md#firestore-rules-as-a-table). The negative tests are in [tasks](tasks.md#negative-tests).

### Abuse cases the design must stop

- A man reads another man's events, agreement or anything else under another uid.
- A man writes an event under another man's path, or with another man's uid inside it.
- A man changes or deletes an event after it was sent.
- A man sends a field the event does not allow, such as journal text.
- A signed-out client reads or writes anything.
- A man sends the same event many times: it is stored once.
- A faulty or altered client sends an event with a false chain length or a link that loops: rule R2 rejects it on every device.
- Someone holding his unlocked phone deletes his account or changes his password: both need a recent sign-in.
- A second account on his phone reaches his file.
- A man signs in on a phone another man used signed out, and that man's days or journal end up in his account without anyone choosing it.
- "Sign out and erase this phone" is cut short by the app being killed, and leaves him signed in, or his file half there, or his days downloaded again into a new file.
- A phone signed out by "Sign out everywhere" goes on writing to his account until its token runs out, or refreshes its token to get past the cutoff: the rules refuse it at once, by the time the session began.
- An event arrives while his account is being deleted and is left behind afterwards.

Five cases are **not** stopped, and are listed so they are not mistaken for solved:

- **A man can check a box he did not do.** Events are self-reported. Nothing in S4a turns them into points.
- **A signed-in man can fill his own path with well-formed events.** It costs storage and touches nobody else's data. No rate limit is designed here.
- **A man who answers "Yes" to days and a journal that are not his takes them.** The question prevents an accident, not a theft. He could already read them: a signed-out profile is open to whoever holds the phone (Q10).
- **An erase cannot reach the phone's own backup.** Android and iOS include the database in the phone's backup. "Sign out and erase" and account deletion remove his file from this installation only.
- **"Locked to his account" is not encryption.** The app will not open his file without his sign-in. Someone who can read the phone's storage directly, or a backup of it, can read the file. Q8 leaves encryption for later.

## Failure, offline and migration behavior

| Case | Behavior | Status |
|---|---|---|
| No network when he checks a box | Saved on the phone at once, as today; queued in the outbox; sent when online. The box never waits for the network | Proposed |
| The send is retried, or the acknowledgement is lost | The event id is the document id, so a second create cannot make a second event. The phone confirms by reading that id back **from the server** | Proposed |
| The read-back gets no answer | The event stays pending and is tried again later. A read answered from the phone's own cache does not count as an answer | Proposed |
| The server refuses an event | The event stays on the phone, marked refused with the reason, and is not sent again unchanged. Later taps on that box for that day are held back as blocked, because no other device could count them. Today is unchanged: his day is saved on this phone. Settings tells him his other devices will not show those taps | Proposed |
| Two of his devices change the same box | Rule R2. Both devices show the same result once they hold the same events | Decided 2026-11-19 |
| An event arrives before the one it replaces | It is provisional under R2: it does not count until its chain is held. It is not rejected for arriving early | Decided 2026-11-19 |
| He is offline for days, then syncs old dates | The events are stored whatever their date. Whether a late event earns points is S4b's question | Proposed for S4a; parked for scoring |
| Sign-in fails or is cancelled | He stays where he was, with the signed-out profile untouched. Nothing is asked or moved until sign-in has succeeded | Proposed |
| The move after "Yes" is interrupted (app killed) | The signed-out profile is marked for one account before anything moves. On the next start the app finishes that move before it offers any sign-in, so no other account can take the same data. Each profile has its own id, used once, so the record of an earlier move is never taken for this one | Proposed |
| The account already has days and so does the phone | Both sets of events are kept. R2 settles each box. He is not asked about any box | Decided 2026-11-19 |
| He signs out with events not yet sent | He is told how many, and can go back. If he continues, they stay in his file and are sent at his next sign-in | Proposed; see O3 |
| He chooses "Sign out and erase this phone" with events not yet sent, or with a journal | He is told what will be lost, in words: unsent days, and his journal, which is on no server. He is told that the phone's own backup may still hold a copy. He must confirm | Proposed |
| "Sign out and erase this phone" is interrupted (app killed) | The erase is recorded outside his file before anything is touched. On every start the app finishes a recorded erase before it restores a session, opens a file or syncs. It always ends with no file and no session | Proposed |
| "Sign out everywhere" | His other phones are refused by the rules at once, and show the signed-out state when they next reach the server. Their files stay, locked | Proposed |
| Account deletion with no network | Refused with a message. Deletion needs the server | Proposed |
| Account deletion is interrupted | The server finishes it without the phone: the request is recorded before anything is deleted, and a worker carries on from that record. An event that arrives during deletion is refused, not left behind | Proposed |
| His file on the phone when his account is deleted | On the phone where he deletes: warned, then erased, by the same safe erase, once the server has recorded the deletion. A definite refusal erases nothing. If the answer is lost the phone asks again; if its sign-in stops working before a definite answer comes, the file is left closed, not erased, and he is told | Decided 2026-11-19; the steps are proposed |
| His files on his other phones when his account is deleted | Not erased. They stay closed and can no longer be opened. Removing the app removes them | Proposed; see O1 |
| Accessibility | Every new screen works with a screen reader and with large text. Sign-in buttons meet the providers' own rules for labels | Proposed |
| Database migration | S4a adds a chain length to each event, an outbox state, and the record of a move. The migration is tested on a real file against the frozen schema of each earlier version, as the journal's migration is | Proposed |
| Rollback | Rules and Functions exist only in the emulator in S4a. Rolling back is reverting the pull request. No cloud data exists to migrate back | Decided (ADR-0002: emulator-first) |

## Open items in S4a

These are not groups questions, so they stay here. Each has the default this draft takes. Approving the contract approves the defaults unless the maintainer changes one.

| # | Question | Default taken in this draft | Why it needs a look |
|---|---|---|---|
| **O1** | **His files on his other phones when he deletes his account.** Decided for the phone where he deletes: warned, then erased. Not stated: the others. A file locked to an account that no longer exists can never be opened again | They are not erased. They stay closed, and removing the app removes them. S4a adds no button for it | Erasing a journal on a phone he is not holding, on a signal from the server, is not something to do by default. The cost is a file that sits unreachable on that phone |
| **O2** | **Do workout logs sync in S4a?** Build step S3 is not on `main` as this is written, so this draft cannot say what it stores | No. S4a syncs completion events only. Workout logs sync in a later step, with their own contract | "His own data on his account" could be read to include them |
| **O3** | **Two parts of the sign-out answer that were not ruled on.** Unsent events at sign-out, and what the app shows after sign-out | Unsent events: warn him, keep them in his file, send them at his next sign-in. After sign-out: the phone's signed-out profile, which he can use without signing in, as Q10 allows | The maintainer's answer named the kept file and "Sign out and erase", not these two |
| **O4** | **A "No" cannot be taken back.** Decided: after a No the profile is never offered again. Not stated: what if he tapped No by mistake | The question has two answers and cannot be closed without one. A No is final in S4a: his days stay in the signed-out profile, visible when nobody is signed in, and are never sent | A way to undo a No is a new screen, and nothing asked for one |
| **O5** | **The terms text.** Which text and version the checkbox shows is parked with S4b (was B16). S4a still has to show something | S4a builds the checkbox and records a version and the server's time. The text is a marked placeholder. S4a runs in the emulator only, so no real man agrees to a placeholder | S4a cannot go to real users until the text is decided |

## Review history

Advisory reviews by Codex, all on 2026-11-19. None is an approval.

| Pass | Verdict | What happened |
|---|---|---|
| First | Changes required: 5 High, 3 Medium | All eight addressed in the first fix round |
| Second | Changes required: 2 High, 3 Medium (F1 to F5) | The maintainer answered F1 and the account-deletion question and allowed one more fix round. All five addressed: F1 by the question "Are these yours?"; F2 by an erase that is recorded first and finished on start; F3 by leaving `receivedAt` out of the comparison; F4 by deleting the emulator's smoke documents too; F5 by requiring lowercase UUIDs and comparing ids exactly |
| Third | Changes required: 4 High, 3 Medium (G1 to G7) | The maintainer allowed one last fix round. All seven addressed: G1 by giving every signed-out profile its own id, used once, and recording that id with the move; G2 by the maintainer's rule that a declined profile is never offered again; G3 by keeping the erase record unless the server definitely refuses; G4 by asking again while the token is accepted and otherwise leaving the file closed, with no receipt on the server; G5 by saying what an erase cannot reach; G6 and G7 on the architecture page |
| Fourth, 2026-11-20 | Changes required: 3 High, 1 Medium, and 2 Medium reported again (H1 to H4 below) | **Not fixed, and no further round.** The maintainer said to run one review, record what it found as open, and stop |

### Known problems in this draft

From the fourth review. The contract should not be approved until each is fixed or set aside by the maintainer. "Pick" is Claude's proposal, not a decision.

| # | Severity | Problem | Pick |
|---|---|---|---|
| H1 | High | **Account deletion can leave his file on the phone where he asked for it.** This draft keeps no receipt on the server. If the server records the deletion, the answer is lost, and the phone's sign-in has stopped working by the time it asks again, the phone cannot tell, and leaves the file closed instead of erasing it. The review reported this from both halves | The maintainer chooses. Either accept that rare case, or add the receipt: a random id made on the phone, and a small document under it, with nothing personal in it, that can be read without a sign-in for 30 days |
| H2 | High | **A retry can be refused while the first request is still on its way.** The retry finds no marker and fails the recent-sign-in check; the first request then succeeds. The phone has already dropped its erase record on the refusal | Put a request id made on the phone on every request, record it with the marker, and answer a retry by that id. A refusal is final only for the id it was given to. This needs no read without a sign-in |
| H3 | High | **After a "No", nothing made on that signed-out profile can ever reach an account**, his own later days included | This is the maintainer's rule of 2026-11-20, kept as written. The review's alternative is to set the declined profile aside and start a fresh signed-out profile; that brings back a second profile to track |
| H4 | Medium | **Working out states again after a download looks only at the box the new event belongs to.** An event of another box that was waiting for it can be left provisional when it should be rejected | Also work out again every event that names a newly arrived id, whatever box it belongs to |

The review also reported G6 and G7 again. Both fixes are in the text of the architecture page and of the full report (the clock test, and "The Rejected checks come first"), so those two reports are read as mistaken.

## Evidence and traceability

- **Baseline:** `main` at `1c1339b25dad47a5760ea7b7eb4ab12fb260c4c4` (see the front matter).
- **Decisions:** [Decisions page](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md), rows Q4, Q5, Q8, Q9, Q10. The answers marked 2026-11-19 are from conversation with the maintainer and are not on that page yet.
- **Sign-in:** [sign-in design](../../design/sign-in.md), treated as proposed.
- **Records:** ADR-0002 (emulator-first Firebase) and ADR-0005 (Riverpod, go_router, Drift) on `main`. ADR-0009 (faith participation and privacy) is in pull request #80 and not on `main` as this is written.
- **Review:** [Architecture](../../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md) 5.6, 5.7 and journeys J1, J4 and J5; [Findings](../../reviews/2026-11-10-prototype-to-flutter/04-FINDINGS.md) L4 (one deletion routine with a test listing every owned path).
- **Prompts:** [P08](../../reviews/2026-11-10-prototype-to-flutter/prompts/P08-S4-contract-identity-groups-board.md) and [P09](../../reviews/2026-11-10-prototype-to-flutter/prompts/P09-S4-implement-identity-groups-board.md) were written for one S4. They have not been rewritten for the split. P09 must not be run as written: it would build groups and a board.
- **ADR-0008** (membership documents authorize) stays Proposed until S4b starts (decided 2026-11-19). S4a has no membership documents and does not depend on it.
- **Earlier draft:** one contract for the whole of S4 was drafted on 2026-11-19 and never published. Its review left six findings. How each is dealt with is in [design](design.md#the-earlier-drafts-six-review-findings).
- **Prototype:** not used as a source of rules.
- **Today's rules:** `firebase/firestore.rules` denies everything except a developer smoke path. That path is for the emulator and must not reach a cloud project; guarding it is listed in [tasks](tasks.md).
- **Firebase behavior checked against current documentation on 2026-11-19:** revoking refresh tokens ends every session of a user, not one device's, and a token already issued stays valid for up to an hour unless rules compare it with a stored revocation time; the Authentication emulator accepts mock Google and Apple ID tokens; deleting a document does not delete its subcollections; Firestore's offline persistence is on by default on Android and iOS and can be turned off. Nothing was run.
- **Checks actually run on this contract:** `python3 tooling/knowledge/check.py` only. No rule, Function or app code exists to test.

## Design and task files

- [design.md](design.md): sign-in and the local profile, the outbox, download and rule R2 on the phone, the rules table, sign-out, account deletion, the six findings, options considered.
- [tasks.md](tasks.md): the order of work, positive and negative tests, platform evidence, rollback.
