// TC-002, TC-020, TC-021: journals, prayer audiences, private personal data.
import { test, before, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, collection, getDocs, query, where } from 'firebase/firestore';
import { makeEnv, as, G } from './_env.mjs';
let env; before(async () => { env = await makeEnv(); }); after(async () => { await env.cleanup(); });

test('TC-002 leader cannot read a member journal entry', async () => {
  await assertFails(getDoc(doc(as(env, 'lee'), 'users/alice/journal/j1')));
});
test('TC-002 other member and reviewer cannot read or write a journal', async () => {
  await assertFails(getDoc(doc(as(env, 'bob'), 'users/alice/journal/j1')));
  await assertFails(getDoc(doc(as(env, 'rita'), 'users/alice/journal/j1')));
  await assertFails(setDoc(doc(as(env, 'bob'), 'users/alice/journal/j2'), { body: 'x' }));
});
test('TC-002 owner can read own journal', async () => {
  await assertSucceeds(getDoc(doc(as(env, 'alice'), 'users/alice/journal/j1')));
});
test('TC-020 private prayer request hidden from leader and members', async () => {
  await assertFails(getDoc(doc(as(env, 'lee'), `groups/${G}/prayerRequests/pr_private`)));
  await assertFails(getDoc(doc(as(env, 'bob'), `groups/${G}/prayerRequests/pr_private`)));
  await assertSucceeds(getDoc(doc(as(env, 'alice'), `groups/${G}/prayerRequests/pr_private`)));
});
test('TC-020 partner-scoped request visible only to listed partner', async () => {
  await assertSucceeds(getDoc(doc(as(env, 'bob'), `groups/${G}/prayerRequests/pr_partner`)));
  await assertFails(getDoc(doc(as(env, 'rita'), `groups/${G}/prayerRequests/pr_partner`)));
  await assertSucceeds(getDocs(query(collection(as(env, 'bob'), `groups/${G}/prayerRequests`), where('audienceUids', 'array-contains', 'bob'))));
  await assertFails(getDocs(collection(as(env, 'bob'), `groups/${G}/prayerRequests`))); // unconstrained query denied
});
test('TC-021 nutrition, fasting, health, body data are owner-only', async () => {
  for (const p of ['foodEntries/f1', 'fasting/plan', 'healthDays/2026-10-27_steps', 'bodyMetrics/b1', 'progressPhotos/x']) {
    await assertSucceeds(setDoc(doc(as(env, 'alice'), `users/alice/${p}`), { v: 1 }));
    await assertFails(getDoc(doc(as(env, 'lee'), `users/alice/${p}`)));
  }
});
