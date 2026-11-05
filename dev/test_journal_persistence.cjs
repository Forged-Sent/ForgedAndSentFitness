const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const html = fs.readFileSync('index.html', 'utf8').replace(/\r\n/g, '\n');
for (const [,script] of html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)) new vm.Script(script);
const code = html.slice(html.indexOf('  var jrPendingWrites = '), html.indexOf('  function jrWhen('));
let timerId=0; const timers=new Map();
const ctx = {setTimeout(fn,ms){assert.equal(ms,15000);timers.set(++timerId,fn);return timerId},clearTimeout(id){timers.delete(id)},state:{me:'test-user',page:'today',journal:[]}, B:{}, drawToday(){}, drawJournalPage(){}};
vm.createContext(ctx); vm.runInContext(code,ctx);
const flush=async()=>{for(let i=0;i<8;i++)await Promise.resolve()};
(async()=>{
 const entry={id:'j1',t:'unsaved words'};
 ctx.B.saveJournal=()=>Promise.reject(new Error('offline'));
 await assert.rejects(ctx.jrSave(entry)); assert.equal(ctx.state.journal.length,0);
 let ack; ctx.B.saveJournal=()=>new Promise(r=>ack=r); const saving=ctx.jrSave(entry);
 assert.equal(ctx.state.journal.length,0); await flush(); ack(); await saving; assert.equal(ctx.state.journal[0],entry);
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
 // A never-settling request releases the UI after a bounded wait, without
 // treating an unconfirmed remote operation as cancelled or successful.
 const draft={t:'words to keep'}, ui={saved:false}, pendingEntry={id:'pending',t:draft.t};
 let late, writes=0;
 ctx.B.saveJournal=()=>{writes++;return new Promise(r=>late=r)};
 scope.isConnected=true;
 const stuck=ctx.jrAction(button,message,async attempt=>{await ctx.jrSave(pendingEntry,attempt);draft.t='';ui.saved=true});
 await flush(); assert.equal(input.disabled,true);assert.equal(scope.dataset.jrBusy,'1');
 const timeout=[...timers.values()][0];timeout();assert.equal(await stuck,false);
 assert.equal(input.disabled,false);assert.equal(preDisabled.disabled,true);assert.equal(scope.dataset.jrBusy,undefined);
 assert.equal(draft.t,'words to keep');assert.equal(ui.saved,false);assert.match(message.textContent,/not confirmed/);
 // Dismissal is allowed once jrBusy is cleared. Simulate closing the old scope
 // and creating a newer draft before the old backend acknowledgement arrives.
 assert.match(html,/function close\(\) \{ if \(!back\.dataset\.jrBusy\) back\.remove\(\); \}/);
 scope.isConnected=false;draft.t='newer draft';late();await flush();
 assert.equal(draft.t,'newer draft');assert.equal(ui.saved,false);assert.equal(ctx.state.journal.length,0);
 // Retry the same pending write without sending a duplicate. An edit may not
 // race an older unconfirmed payload and get overwritten after it finishes.
 scope.isConnected=true;let resolvePending;writes=0;
 ctx.B.saveJournal=()=>{writes++;return new Promise(r=>resolvePending=r)};
 const idHolder={};const stable=ctx.jrDraftId(idHolder);assert.equal(ctx.jrDraftId(idHolder),stable);
 const stableEntry={id:stable,at:Number(idHolder.jrAt),t:'same text'};
 const firstWait=ctx.jrAction(button,message,attempt=>ctx.jrSave(stableEntry,attempt));await flush();
 [...timers.values()][0]();assert.equal(await firstWait,false);
 assert.equal(await ctx.jrAction(button,message,attempt=>ctx.jrSave({...stableEntry,t:'edited'},attempt)),false);
 assert.equal(writes,1);
 const retry=ctx.jrAction(button,message,attempt=>ctx.jrSave(stableEntry,attempt));await flush();assert.equal(writes,1);
 resolvePending();assert.equal(await retry,true);assert.equal(ctx.state.journal[0].id,stable);
 // Failed acknowledgement followed by a new attempt keeps the same draft id.
 const ids=[];ctx.B.saveJournal=async(uid,x)=>{ids.push(x.id);if(ids.length===1)throw Error('lost acknowledgement')};
 const retryHolder={};
 for(let n=0;n<2;n++){const x={id:ctx.jrDraftId(retryHolder),at:Number(retryHolder.jrAt),t:'retry text'};await ctx.jrAction(button,message,attempt=>ctx.jrSave(x,attempt))}
 assert.equal(ids.length,2);assert.equal(ids[0],ids[1]);
 assert.match(html,/id: jrDraftId\(F\)/);assert.match(html,/id: jrDraftId\(ta\.dataset\)/);
 // A late deletion must not mutate a replacement view after its deadline.
 let deleteLate;ctx.B.deleteJournal=()=>new Promise(r=>deleteLate=r);
 const beforeDelete=ctx.state.journal.length;
 const deleting=ctx.jrAction(button,message,attempt=>ctx.jrDelete(stable,attempt));await flush();
 [...timers.values()][0]();assert.equal(await deleting,false);deleteLate();await flush();
 assert.equal(ctx.state.journal.length,beforeDelete);assert.equal(timers.size,0);
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
 console.log('PASS: journal bounded wait, late-completion guard, stable retry IDs, pending-write deduplication, acknowledgement/delete failures and inline syntax');
})().catch(e=>{console.error(e);process.exitCode=1});


assert.match(html, /var PEN_SVG = /, "journal icon must survive mentor-deferral integration");
