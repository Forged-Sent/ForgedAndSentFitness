import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {commandFor} from './launch.mjs';

test('Dart is directly executable on macOS without cmd.exe',()=>{
 const s=commandFor('dart','darwin','/nonexistent-forged-sent-path');
 assert.equal(s.command,'dart');
 assert.deepEqual(s.args,['mcp-server']);
});
test('Playwright uses fixed version and safe macOS command',()=>{
 const s=commandFor('playwright','darwin');
 assert.equal(s.command,'npx');
 assert.deepEqual(s.args,['-y','@playwright/mcp@0.0.83','--browser=chrome','--isolated']);
});
test('Windows Dart uses pinned native SDK executable, without cmd.exe',()=>{
 const home=mkdtempSync(join(tmpdir(),'forged dart & '));
 try {
   const dart=join(home,'develop','flutter','bin','cache','dart-sdk','bin','dart.exe');
   mkdirSync(join(home,'develop','flutter','bin','cache','dart-sdk','bin'),{recursive:true});
   writeFileSync(dart,'');
   assert.deepEqual(commandFor('dart','win32',home),{command:dart,args:['mcp-server']});
 } finally {rmSync(home,{recursive:true,force:true});}
});
test('Windows Dart fails closed when Flutter SDK is missing',()=>{
 const home=mkdtempSync(join(tmpdir(),'forged-no-sdk-'));
 try {assert.throws(()=>commandFor('dart','win32',home),/Pinned Flutter Dart SDK missing/);}
 finally {rmSync(home,{recursive:true,force:true});}
});
test('Mac Maestro invokes native executable (optional Mobile tool)',()=>{
 assert.deepEqual(commandFor('maestro','darwin'),{command:'maestro',args:['mcp']});
});
test('Windows Playwright and Maestro commands use only the audited fixed launch forms',()=>{
 assert.deepEqual(commandFor('playwright','win32'),{
  command:'cmd.exe',args:['/d','/c','npx -y @playwright/mcp@0.0.83 --browser=chrome --isolated']
 });
 assert.deepEqual(commandFor('maestro','win32'),{
  command:'cmd.exe',args:['/d','/c','maestro mcp']
 });
});
test('Only three approved local MCP tools are dispatchable on both platforms',()=>{
 for(const platform of ['darwin','win32']){
  for(const tool of ['fb','firebase-tools','github','sentry','shell','anything']){
   assert.throws(()=>commandFor(tool,platform),/forbidden/i);
  }
 }
});
test('No Firebase cloud MCP or arbitrary executable is accepted',()=>{
 assert.throws(()=>commandFor('firebase','darwin'),/forbidden/i);
 assert.throws(()=>commandFor('anything','win32'),/forbidden/i);
});
