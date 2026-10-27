// TC-010, TC-046 (rules part): proof media access and upload limits.
import { test, before, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { ref, uploadBytes, getBytes } from 'firebase/storage';
import { makeEnv, G } from './_env.mjs';
let env; before(async () => { env = await makeEnv(); }); after(async () => { await env.cleanup(); });
const path = `proof/${G}/s1/open/alice/a1/f1.mp4`;
const st = (uid) => env.authenticatedContext(uid).storage();

test('TC-046 owner can upload small mp4 to own path', async () => {
  await assertSucceeds(uploadBytes(ref(st('alice'), path), new Uint8Array(1024), { contentType: 'video/mp4' }));
});
test('TC-046 wrong content type is rejected', async () => {
  await assertFails(uploadBytes(ref(st('alice'), `proof/${G}/s1/open/alice/a1/f2.exe`), new Uint8Array(10), { contentType: 'application/octet-stream' }));
});
test('TC-010 another member and a leader cannot read proof directly', async () => {
  await assertFails(getBytes(ref(st('bob'), path)));
  await assertFails(getBytes(ref(st('lee'), path)));
});
test('TC-010 non-member cannot upload into the group path', async () => {
  await assertFails(uploadBytes(ref(st('zed'), `proof/${G}/s1/open/zed/a9/f1.mp4`), new Uint8Array(10), { contentType: 'video/mp4' }));
});
