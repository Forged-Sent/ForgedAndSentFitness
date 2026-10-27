// TC-004 (rules part), TC-013 (rules part), TC-037: facts create-only, windows, Functions-only scoring.
import { test, before, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { makeEnv, as, G } from './_env.mjs';
let env; before(async () => { env = await makeEnv(); }); after(async () => { await env.cleanup(); });
const fact = { uid: 'alice', habitId: 'water', localDate: '2026-10-27', tz: 'America/Phoenix', source: 'manual', performedAt: 1, payloadHash: 'h' };

test('TC-004 duplicate check-in cannot be written twice', async () => {
  const ref = doc(as(env, 'alice'), `groups/${G}/checkins/alice_water_2026-10-27`);
  await assertSucceeds(setDoc(ref, { ...fact, receivedAt: serverTimestamp() }));
  await assertFails(setDoc(ref, { ...fact, receivedAt: serverTimestamp() })); // second write is an update -> denied
});
test('TC-004 check-in id must match uid/habit/date and uid must be self', async () => {
  await assertFails(setDoc(doc(as(env, 'alice'), `groups/${G}/checkins/bob_water_2026-10-27`), { ...fact, uid: 'bob', receivedAt: serverTimestamp() }));
  await assertFails(setDoc(doc(as(env, 'alice'), `groups/${G}/checkins/alice_water_2026-10-26`), { ...fact, receivedAt: serverTimestamp() }));
});
test('TC-037 clients cannot write ledger, standings or snapshots', async () => {
  for (const c of ['ledger/x', 'standings/t1', 'snapshots/w1_v1']) {
    await assertFails(setDoc(doc(as(env, 'lee'), `groups/${G}/seasons/s1/${c}`), { points: 999 }));
  }
});
const attempt = { uid: 'alice', status: 'submitted', tier: 'standard', value: 360, performedAt: 1 };
test('TC-013 attempt accepted inside the window (server time)', async () => {
  await assertSucceeds(setDoc(doc(as(env, 'alice'), `groups/${G}/seasons/s1/challenges/open/attempts/a1`), { ...attempt, receivedAt: serverTimestamp() }));
});
test('TC-013 attempt rejected after closesAt + grace', async () => {
  await assertFails(setDoc(doc(as(env, 'alice'), `groups/${G}/seasons/s1/challenges/closed/attempts/a2`), { ...attempt, receivedAt: serverTimestamp() }));
});
test('attempt status cannot be self-approved', async () => {
  const ref = doc(as(env, 'alice'), `groups/${G}/seasons/s1/challenges/open/attempts/a3`);
  await assertSucceeds(setDoc(ref, { ...attempt, receivedAt: serverTimestamp() }));
  await assertFails(updateDoc(ref, { status: 'approved' }));
  await assertSucceeds(updateDoc(ref, { proofIds: ['f1'] }));
});
