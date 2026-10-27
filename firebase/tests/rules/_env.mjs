// Shared test environment for Forged & Sent rules tests (emulator required; see package.json "test").
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { readFileSync } from 'node:fs';
import { doc, setDoc, Timestamp } from 'firebase/firestore';

export const G = 'groupA', G2 = 'groupB';
export async function makeEnv() {
  const env = await initializeTestEnvironment({
    projectId: 'demo-forged-sent',
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
    storage: { rules: readFileSync(new URL('../../storage.rules', import.meta.url), 'utf8') },
  });
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const m = (gid, uid, role) => setDoc(doc(db, `groups/${gid}/members/${uid}`), { role, state: 'active' });
    await setDoc(doc(db, `groups/${G}`), { name: 'A', tz: 'America/Phoenix' });
    await setDoc(doc(db, `groups/${G2}`), { name: 'B', tz: 'America/Phoenix' });
    await m(G, 'alice', 'member'); await m(G, 'bob', 'member'); await m(G, 'lee', 'leader'); await m(G, 'rita', 'reviewer');
    await m(G2, 'zed', 'member');
    await setDoc(doc(db, `users/alice/journal/j1`), { body: 'private prayer' });
    await setDoc(doc(db, `groups/${G2}/posts/p1`), { authorUid: 'zed', body: 'hi' });
    const now = Date.now();
    await setDoc(doc(db, `groups/${G}/seasons/s1`), { practice: true });
    await setDoc(doc(db, `groups/${G}/seasons/s1/challenges/open`), {
      opensAt: Timestamp.fromMillis(now - 3600e3), closesAt: Timestamp.fromMillis(now + 3600e3), graceMinutes: 0 });
    await setDoc(doc(db, `groups/${G}/seasons/s1/challenges/closed`), {
      opensAt: Timestamp.fromMillis(now - 7 * 86400e3), closesAt: Timestamp.fromMillis(now - 86400e3), graceMinutes: 120 });
    await setDoc(doc(db, `groups/${G}/prayerRequests/pr_private`), { authorUid: 'alice', audience: 'private', audienceUids: [] });
    await setDoc(doc(db, `groups/${G}/prayerRequests/pr_partner`), { authorUid: 'alice', audience: 'partners', audienceUids: ['bob'] });
  });
  return env;
}
export const as = (env, uid) => env.authenticatedContext(uid).firestore();
