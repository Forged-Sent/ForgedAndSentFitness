// TC-015, TC-019: reserved family/youth/messaging paths and organizations grant nothing.
import { test, before, after } from 'node:test';
import { assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { makeEnv, as } from './_env.mjs';
let env; before(async () => { env = await makeEnv(); }); after(async () => { await env.cleanup(); });

test('TC-015 households, guardian links and conversations are denied', async () => {
  for (const p of ['households/h1', 'guardianLinks/g1', 'conversations/c1', 'conversations/c1/messages/m1']) {
    await assertFails(setDoc(doc(as(env, 'alice'), p), { x: 1 }));
    await assertFails(getDoc(doc(as(env, 'alice'), p)));
  }
});
test('TC-019 organizations are not client-readable or writable', async () => {
  await assertFails(getDoc(doc(as(env, 'lee'), 'organizations/o1')));
  await assertFails(setDoc(doc(as(env, 'lee'), 'organizations/o1'), { groups: ['groupA'] }));
});
