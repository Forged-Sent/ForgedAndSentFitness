# S4a tasks: sign-in, his own data on his account, sign-out, account deletion

Tasks for [FNS-005](requirements.md), to be carried out once the maintainer approves the contract. **Nothing here is started.** The [design](design.md) says how; the open items (O1 to O5) are on the [requirements page](requirements.md#open-items-in-s4a).

## Before any code

- [ ] The known problems H1 to H4 on the [requirements page](requirements.md#known-problems-in-this-draft) are fixed or set aside by the maintainer, and the contract is reviewed again.
- [ ] The maintainer approves this contract, changing any default under O1 to O5 he does not want. `status` and `approved_by` on the requirements page are changed by him or on his recorded decision, not by an agent.
- [ ] The maintainer records on the Decisions page the answers this contract marks "Decided 2026-11-19": the split, rule R2, keep both, the question "Are these yours?", the kept file with "Sign out and erase", account deletion in S4a with the erase on that phone.
- [ ] The maintainer says whether the [sign-in design](../../design/sign-in.md) is approved by him. Until then tasks 2 and 7 are not started.
- [ ] A prompt for building S4a exists. [P09](../../reviews/2026-11-10-prototype-to-flutter/prompts/P09-S4-implement-identity-groups-board.md) was written for the whole of S4 and must not be run as written.
- [ ] `firebase-security-review` is run on the rules table and the two Functions' checks before they are implemented, and again on the implementation.

## Order of work

Each step is its own small pull request, with its tests. Rules and Functions run in the emulator only (ADR-0002).

1. **Rules and their tests.** Write `firebase/firestore.rules` from the [rules table](design.md#firestore-rules-as-a-table). Every row gets a positive and a negative test under `tooling/firebase/tests/`. Keep the developer smoke path out of anything but the emulator.
2. **Session.** `SessionRepository` and its Firebase Auth adapter; the sign-in, create-account and email sign-in screens; the agreement record with its placeholder text.
3. **Rule R2 on the phone.** The chain length column, its migration tested on a real file, the three states, and the day state worked out from them. This step needs no server and comes before sync.
4. **The signed-out profile and adoption.** The question "Are these yours?", the move after Yes with its record, and what No leaves in place.
5. **Outbox and upload.** The send state on the event row, the sync worker, the server read-back on a denied create.
6. **Download.** A second device fetches its owner's events and works out day state.
7. **Sign-out.** "Sign out of this phone", "Sign out and erase this phone" with its erase record, account switching, and the Function for "Sign out everywhere". This adds the `functions/` folder: TypeScript on the Node version CI already uses.
8. **Account deletion.** The request, the worker, the marker, the sweep, the erase on the phone, and the test that lists every path.

## Positive tests

- Sign in with each provider the emulator supports, using mock ID tokens for Apple and Google; the session survives a restart.
- The agreement is recorded once per version with the server's time; a new version prompts again.
- A man with days in the signed-out profile signs in and answers Yes: every event is in the outbox with its original id, his days read the same before and after, the journal is in his account's file and has not left the phone, and the old signed-out profile is gone, replaced by a new, empty one with a new id.
- A man signs in on a phone whose signed-out profile is empty: he is asked nothing.
- A man signs in to an account that already has days, answers Yes for the phone's days: both sets are held, each box follows R2, and he is asked about no box.
- A man signs out, uses the app signed out, signs in again and answers Yes: the days from the signed-out profile are in his account's file once.
- Two moves to the same account, from two signed-out profiles one after the other, with the second killed before its copy commits: on the next start the second profile's rows are copied. Nothing is lost and nothing is copied twice.
- A box checked in airplane mode is created on the server after reconnect, once.
- A create whose acknowledgement is lost, then replayed and denied: the server read-back finds the same event and the phone marks it uploaded.
- A second device signs in and shows the same boxes as the first. Two devices given the same events in different orders show the same boxes.
- An event downloaded before the one it replaces is provisional and does not change the box; when the missing event arrives, the box follows.
- An event that becomes visible on the server with a time older than the overlap is still stored: by its id when another event waits for it, and by the full pass when nothing does.
- After "Sign out of this phone" and signing in again as the same man, his days and his journal are there, and unsent events are sent.
- After "Sign out and erase this phone" his file and its side files are gone from the phone, he is signed out, and the erase record is gone. Signing in again brings back the days that had been sent, and not the journal.
- A lost acknowledgement replayed at a later server time: the read-back still finds the same event, because `receivedAt` is not compared.
- After "Sign out everywhere" a second phone's next write is refused at once, although its token has not run out.
- After account deletion, a walk of every path in the rules table finds no document of his, including a nested document seeded under the emulator's smoke path, and after the sweep the marker is gone too. Running the deletion twice gives the same result.
- After account deletion on a phone, his file on that phone is gone. If the server refuses the request, his file is untouched.

## Negative tests

Rules, in the emulator. Each must be refused.

**Another signed-in man**

- Reads another man's events, agreements or account state.
- Creates an event under another man's path, or under his own path with another man's uid in `owner`.
- Runs a collection-group query over events.

**A signed-out client**

- Reads or writes any path in the rules table.

**Events**

- Creates an event whose document id differs from its `id`, or whose id is not a lowercase UUID (uppercase letters, no hyphens, another length).
- Creates an event with a field that is not allowed (for example a text note), with a wrong type, with a value over its length bound, or with a `receivedAt` that is not the server's time.
- Updates an event. Deletes an event.
- Changes an agreement record, or creates one with a time that is not the server's.
- Writes `account/state`, with any field.

**Anything outside his own path**

- A signed-in man reads or writes `groups/` anything, any other top-level path, or anything in Storage. The emulator's smoke path is asserted on its own, as the one exception, and asserted denied in a ruleset without it.

**Sessions and deletion**

- A session that began before "Sign out everywhere" reads or writes his own path, including with a token it refreshed between the cutoff being written and the refresh tokens being revoked. A session that began in the same second as the cutoff.
- Either Function called from a session that began before the cutoff.
- Any token of his reads or writes his path while the deletion marker is set. An event created during deletion is refused and no document is left afterwards.
- A write with a still-valid token after the data has been deleted and before the marker is removed.
- Deletion interrupted after the tokens are revoked, and again after the Authentication user is deleted: the worker finishes both with no second request from a phone.
- The deletion Function called with a sign-in older than the limit, with a revoked token, or with no sign-in.
- The deletion Function called by one man with another man's uid in the request.

**The outbox**

- A denied create whose read-back gets no answer from the server: the event stays pending. It is not marked uploaded and not marked refused.
- A read-back answered from a local cache is not accepted as an answer.
- A denied create with no document on the server: the event is marked refused and is not sent again unchanged. Today is unchanged.
- A document with the same id and different fields: marked refused with "id in use" and reported.
- A refused first event followed by a valid tap that replaces it: the second is marked blocked and is never sent. The box on the phone is unchanged, Settings says the other devices will not show it, and the erase warning counts it.
- An event is never sent before the event it replaces is uploaded.

**Rule R2 on the phone**

- The tests listed under the rule on the [architecture page](../../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md): a forged chain length, an event that names itself, two events that name each other, a link to another date's or item's event, the D, B, A order.

**A shared phone**

- One man uses the phone signed out and writes days and a journal entry. Another signs in and answers No: his account's file has none of it, none of it is sent, and nothing of it can be reached while he is signed in. After he signs out, all of it is there, unchanged.
- After that No, he signs out, adds a day of his own while signed out, and signs in again: he is asked nothing, and neither the old data nor the new day is moved or sent. The same for any other account that signs in.
- The question cannot be closed without an answer. The app is killed while it shows: nothing is recorded, and it is asked at the next sign-in.
- The app is killed after the rows are copied and before the signed-out profile's file is removed, then a different account signs in: the data is not moved again, and the first account's file holds its rows once.

**Sign out and erase, cut short**

- The app is killed after the erase record is written; after the sign-out; and after the file is deleted and before the record is removed. In each case the next start ends with no file of his, no session, no record, and nothing downloaded into a new file.
- The file cannot be deleted: the record stays, his file is not opened, and he is told.
- Account deletion, the answer is lost after the server recorded the deletion: the record stays, the phone asks again, is told "already recorded", and the file is erased. The same when the app is killed after the request is sent and started again within the hour.
- Account deletion, a definite refusal: the record is removed and the file is untouched.
- Account deletion, no definite answer before the phone's sign-in stops working: the record is removed, nothing is erased, the file is left closed, and he is told.
- The warnings before "Sign out and erase" and before account deletion say that the phone's own backup may still hold a copy.

**The phone**

- A second account on the same phone sees none of the first account's days or journal, including after the app is killed and reopened.
- After sign-out nothing of his is returned by any repository, and the Firestore SDK holds none of his documents.
- No table but the events table is read by the sync worker. A journal entry written before sign-in is in no request the phone makes.
- A send that fails leaves the event pending; neither a failed nor a refused send changes what Today shows.

## Platform evidence

To record in the pull request that implements each step, with the command and its output:

- Rules tests: `firebase emulators:exec` with the tests under `tooling/firebase/tests/`, as CI's `firebase-rules` job does.
- Function tests in the emulator.
- `flutter analyze`, `flutter test`, and the debug Android build.
- One run on an Android emulator and one on an iPhone simulator of: sign in, check a box offline, reconnect, see the event on the server; sign out; sign in; see the day. Label whichever was not run NOT VERIFIED.
- One two-device run (two emulators, one account).
- Apple and Google sign-in against real providers: NOT VERIFIED until a cloud project exists.

## Docs that change when this is built

`docs/architecture/SYSTEM.md` (the first server boundary: Authentication, a man's own path, two Functions move from planned to implemented), `docs/knowledge/PROTOTYPE-PARITY.md` (Sign-in, Settings), `docs/architecture/CODE-MAP.md` by its generator, ADR-0005 (the event table's new column and the first migration), this contract's `implementation_paths`, `verified_tests` and `verification`, and the work board.

## Rollback

S4a runs in the emulator only. Rolling back a step is reverting its pull request. The Drift migration adds columns and tables and removes none, so an older build's data is not lost by it; going back from the new schema to the old one is not supported and is not needed while nothing is released. No cloud data exists to undo.
