import { before, after, test } from 'node:test';
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { ref, uploadBytes } from 'firebase/storage';

const PROJECT = 'demo-forgedandsent';
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: {
      host: '127.0.0.1', port: 8080,
      rules: readFileSync('firebase/firestore.rules', 'utf8'),
    },
    storage: {
      host: '127.0.0.1', port: 9199,
      rules: readFileSync('firebase/storage.rules', 'utf8'),
    },
  });
  await env.clearFirestore();
  await env.clearStorage();
});

after(async () => { if (env) await env.cleanup(); });

test('Firestore: user owns their smoke test document', async () => {
  const alice = env.authenticatedContext('alice');
  const path = doc(alice.firestore(), 'developer_smoke', 'alice', 'docs', 'first');
  await assertSucceeds(setDoc(path, { marker: 'local-only' }));
  const snap = await assertSucceeds(getDoc(path));
  assert.equal(snap.data().marker, 'local-only');
});

test('Firestore: unauthenticated and other-user access are denied', async () => {
  const anonymous = env.unauthenticatedContext();
  const bob = env.authenticatedContext('bob');
  await assertFails(getDoc(doc(anonymous.firestore(), 'developer_smoke', 'alice', 'docs', 'first')));
  await assertFails(setDoc(doc(bob.firestore(), 'developer_smoke', 'alice', 'docs', 'new'), { bad: true }));
});

test('Firestore: everything outside developer_smoke is denied', async () => {
  const alice = env.authenticatedContext('alice');
  await assertFails(setDoc(doc(alice.firestore(), 'groups', 'group-1'), { members: ['alice'] }));
  await assertFails(getDoc(doc(alice.firestore(), 'private_prayers', 'secret-1')));
});

test('Storage: owner can write local smoke object, other user cannot', async () => {
  const alice = env.authenticatedContext('alice');
  const bob = env.authenticatedContext('bob');
  const storageA = alice.storage('gs://demo-forgedandsent.appspot.com');
  const storageB = bob.storage('gs://demo-forgedandsent.appspot.com');
  await assertSucceeds(uploadBytes(ref(storageA, 'developer_smoke/alice/photo.txt'), new Uint8Array([1, 2, 3])));
  await assertFails(uploadBytes(ref(storageB, 'developer_smoke/alice/other.txt'), new Uint8Array([4])));
});

test('Storage: anonymous and non-smoke objects are denied', async () => {
  const guest = env.unauthenticatedContext();
  const alice = env.authenticatedContext('alice');
  const bucket = 'gs://demo-forgedandsent.appspot.com';
  await assertFails(uploadBytes(ref(guest.storage(bucket), 'developer_smoke/alice/guest.txt'), new Uint8Array([5])));
  await assertFails(uploadBytes(ref(alice.storage(bucket), 'private_prayers/secret.txt'), new Uint8Array([6])));
});
