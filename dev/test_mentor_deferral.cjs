const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const html = fs.readFileSync('index.html', 'utf8');
for (const [, script] of html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)) new vm.Script(script);
// Reading a mixed mentor document still discloses check-ins even if the UI hides them.
assert.doesNotMatch(html, /\.\s*(?:collection|doc)\s*\(\s*["']mentor(?:\/|["'])/);
assert.doesNotMatch(html, /function\s+(?:menSave|normMentor|mentorAuto)\s*\(/);
for (const path of ['seed/db-rules.json', 'dev/capabilities/v227.json']) {
 const rules = JSON.parse(fs.readFileSync(path, 'utf8')).capabilities.db.rules;
 assert.ok(rules.every(rule => !rule.path.startsWith('mentor')), path + ' must not grant access to mixed mentor records');
}
assert.match(html, /In-app pairing and check-ins are paused until private access is enforced/);
assert.match(html, /function openMentorInfo\(/);
console.log('PASS: active prototype has no mentor reads/writes or capability grants; info retained; inline scripts parse');
