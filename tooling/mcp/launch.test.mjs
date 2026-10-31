import test from 'node:test';
import assert from 'node:assert/strict';
import {commandFor} from './launch.mjs';

test('Dart is directly executable on macOS without cmd.exe',()=>{
 const s=commandFor('dart','darwin','/nonexistent-forged-sent-path');
 assert.equal(s.command,'dart');
 assert.deepEqual(s.args,['mcp-server']);
});
test('Playwright uses fixed version and safe macOS command',()=>{
 const s=commandFor('playwright','darwin');
 assert.equal(s.command,'npx');
 assert.deepEqual(s.args,['-y','@playwright/mcp@0.0.83','--browser=chrome']);
});
test('Windows execution uses cmd wrapper for .cmd and .bat compatibility',()=>{
 const s=commandFor('dart','win32');
 assert.equal(s.command,'cmd.exe');
 assert.match(s.args.join(' '),/mcp-server/);
});
test('Mac Maestro invokes native executable (optional Mobile tool)',()=>{
 assert.deepEqual(commandFor('maestro','darwin'),{command:'maestro',args:['mcp']});
});
test('No Firebase cloud MCP or arbitrary executable is accepted',()=>{
 assert.throws(()=>commandFor('firebase','darwin'),/forbidden/i);
 assert.throws(()=>commandFor('anything','win32'),/forbidden/i);
});
