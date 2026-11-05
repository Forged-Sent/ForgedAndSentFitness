const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const html = fs.readFileSync('index.html', 'utf8').replace(/\r\n/g, '\n');
for (const [,script] of html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)) new vm.Script(script);
const code = html.slice(html.indexOf('  async function jrSave('), html.indexOf('  function jrWhen('));
const ctx = {state:{me:'test-user',page:'today',journal:[]}, B:{}, drawToday(){}, drawJournalPage(){}};
vm.createContext(ctx); vm.runInContext(code,ctx);
(async()=>{
 const entry={id:'j1',t:'unsaved words'};
 ctx.B.saveJournal=()=>Promise.reject(new Error('offline'));
 await assert.rejects(ctx.jrSave(entry)); assert.equal(ctx.state.journal.length,0);
 let ack; ctx.B.saveJournal=()=>new Promise(r=>ack=r); const saving=ctx.jrSave(entry);
 assert.equal(ctx.state.journal.length,0); ack(); await saving; assert.equal(ctx.state.journal[0],entry);
 ctx.B.deleteJournal=()=>Promise.reject(new Error('denied'));
 await assert.rejects(ctx.jrDelete('j1')); assert.equal(ctx.state.journal.length,1);
 ctx.B.deleteJournal=()=>Promise.resolve(); await ctx.jrDelete('j1'); assert.equal(ctx.state.journal.length,0);
 const button={disabled:false}, message={textContent:''};
 assert.equal(await ctx.jrAction(button,message,()=>Promise.reject(new Error('fail'))),false);
 assert.match(message.textContent,/Could not save/); assert.equal(button.disabled,false);
 let release; let calls=0; const first=ctx.jrAction(button,message,()=>{calls++;return new Promise(r=>release=r)});
 assert.equal(await ctx.jrAction(button,message,()=>{calls++}),false); assert.equal(calls,1); release(); assert.equal(await first,true);
 const input={disabled:false}, preDisabled={disabled:true};
 const scope={dataset:{},querySelectorAll:()=>[button,input,preDisabled]};button.closest=()=>scope;
 const pending=ctx.jrAction(button,message,()=>new Promise(r=>release=r));
 assert.equal(input.disabled,true);assert.equal(scope.dataset.jrBusy,'1');release();await pending;
 assert.equal(input.disabled,false);assert.equal(preDisabled.disabled,true);assert.equal(scope.dataset.jrBusy,undefined);
 // Execute the real deletion method with a DB stand-in and failed unrelated delete.
 const start=html.indexOf('    deleteMyData: async function (uid) {');
 const end=html.indexOf('\n    }\n  };',start);
 assert.ok(start>=0&&end>start,'deletion method extraction must cover actual source');
 const method=html.slice(start,end+6).trim();
 let deleted=[], failJournal=false;
 const db={collection(){return {where(){return {get:async()=>({docs:[]})}}}},doc(path){return {
  get:async()=>({exists:false}),
  delete:async()=>{if(path.endsWith('/liftnotes'))throw Error('unrelated'); if(failJournal&&path.includes('/journal/entries/'))throw Error('journal denied');deleted.push(path)},
  collection(name){return {get:async()=>({docs:name==='entries'?[{id:'j1',data:()=>({})}]:[]})}}
 }}};
 const delctx={B:{deleteAsset(){}},db}; vm.createContext(delctx);
 vm.runInContext('var backend = {'+method+'}; backend.db=db; backend.deleteAsset=async()=>{};',delctx);
 await delctx.backend.deleteMyData('test-user'); assert.ok(deleted.includes('data/users/test-user/journal/entries/j1'));
 failJournal=true; await assert.rejects(delctx.backend.deleteMyData('test-user'));
 console.log('PASS: inline JS syntax; journal rejection, acknowledgement, delete, UI retry/double-submit guard; account purge failures');
})().catch(e=>{console.error(e);process.exitCode=1});

