// TC-001, TC-016: group isolation and Functions-only membership.
import { test, before, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, collection, getDocs } from 'firebase/firestore';
import { makeEnv, as, G, G2 } from './_env.mjs';
let env; before(async () => { env = await makeEnv(); }); after(async () => { await env.cleanup(); });

test('TC-001 member of A cannot read group B or its posts', async () => {
  await assertFails(getDoc(doc(as(env, 'alice'), `groups/${G2}`)));
  await assertFails(getDoc(doc(as(env, 'alice'), `groups/${G2}/posts/p1`)));
  await assertFails(getDocs(collection(as(env, 'alice'), `groups/${G2}/members`)));
});
test('TC-001 member of A can read group A members', async () => {
  await assertSucceeds(getDocs(collection(as(env, 'alice'), `groups/${G}/members`)));
});
test('TC-001 unauthenticated user can read nothing', async () => {
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), `groups/${G}`)));
});
test('TC-016 clients cannot write membership, even leaders', async () => {
  await assertFails(setDoc(doc(as(env, 'alice'), `groups/${G}/members/alice`), { role: 'owner', state: 'active' }));
  await assertFails(setDoc(doc(as(env, 'lee'), `groups/${G}/members/zed`), { role: 'member', state: 'active' }));
  await assertFails(setDoc(doc(as(env, 'zed'), `groups/${G}/members/zed`), { role: 'member', state: 'active' }));
});
