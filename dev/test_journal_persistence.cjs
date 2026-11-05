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
 assert.match(message.textContent,/Could not confirm/); assert.equal(button.disabled,false);
 let release; let calls=0; const first=ctx.jrAction(button,message,()=>{calls++;return new Promise(r=>release=r)});
 assert.equal(await ctx.jrAction(button,message,()=>{calls++}),false); assert.equal(calls,1); release(); assert.equal(await first,true);
 const input={disabled:false}, preDisabled={disabled:true};
 const retryNotice={hidden:true};
 const scope={dataset:{},querySelector:()=>retryNotice,querySelectorAll:()=>[button,input,preDisabled]};button.closest=()=>scope;
 const pending=ctx.jrAction(button,message,()=>new Promise(r=>release=r));
 assert.equal(input.disabled,true);assert.equal(scope.dataset.jrBusy,'1');release();await pending;
 assert.equal(input.disabled,false);assert.equal(preDisabled.disabled,true);assert.equal(scope.dataset.jrBusy,undefined);
 // Execute the actual editor click binding, not a copy of its draft logic.
 const openStart=html.indexOf('  function openJournal('), openEnd=html.indexOf('  function drawJournalDevo(',openStart);
 const editor=html.slice(openStart,openEnd);
 const saveStart=editor.indexOf('sv.addEventListener("click", function () {'), saveEnd=editor.indexOf('      cx.addEventListener(',saveStart);
 assert.ok(saveStart>=0&&saveEnd>saveStart);
 let saveClick;const editorDraft={t:'old text',tags:[]};
 const editorCtx={sv:{disabled:false,closest:()=>scope,addEventListener(event,fn){saveClick=fn}},F:editorDraft,ta:{value:'retained editor words'},msg:{},ed:null,state:ctx.state,todayKey:()=> '2026-11-05',jrDraftId:ctx.jrDraftId,jrAction(){},openJournal(){}};
 vm.createContext(editorCtx);vm.runInContext(editor.slice(saveStart,saveEnd),editorCtx);saveClick();
 assert.equal(editorDraft.t,'retained editor words');assert.equal(editorDraft.resumeDraft,true);
 // The actual editor failure path reveals its same-entry notice/control now,
 // before any close/reopen; empty validation does not claim an attempted write.
 editorCtx.jrAction=ctx.jrAction;editorCtx.jrSave=ctx.jrSave;ctx.B.saveJournal=()=>Promise.reject(Error('rejected'));
 retryNotice.hidden=true;saveClick();await flush();assert.equal(retryNotice.hidden,false);assert.equal(editorCtx.sv.disabled,false);assert.match(editorCtx.msg.textContent,/Could not confirm/);
 assert.match(editor,/retry\.dataset\.jrRetry = "1"; retry\.hidden = !F\.resumeDraft/);
 editorDraft.resumeDraft=false;editorCtx.ta.value='';saveClick();assert.equal(editorDraft.resumeDraft,false);
 // Retry of the same document preserves confirmed fields received meanwhile.
 editorDraft.tags=['prayer'];editorCtx.ta.value='revised prayer';ctx.state.journal=[{id:editorDraft.jrId,t:'confirmed',tags:['prayer'],ans:123,src:'pen'}];
 let retryPayload;ctx.B.saveJournal=async(uid,x)=>{retryPayload=x};editorCtx.openJournal=()=>{};saveClick();await flush();assert.equal(retryPayload.ans,123);
 ctx.state.journal=[];

 // Execute openJournal itself up to rendering: a sentinel prevents a fake
 // layout engine from hiding whether navigation erased the draft first.
 let removed=0, confirmations=0, acceptDiscard=false;
 const rendered=new Error('render begins');
 const nav={state:{me:'owner-a',journal:[{id:'other',t:'other entry',tags:[]}]},$(){return {remove(){removed++}}},confirm(){confirmations++;return acceptDiscard},el(){throw rendered}};
 vm.createContext(nav);vm.runInContext(editor,nav);
 const retained=()=>({ownerUid:'owner-a',resumeDraft:true,t:'keep these words',tags:['prayer'],jrId:'stable-id',jrAt:123,edit:'',saved:''});
 function render(opts){assert.throws(()=>nav.openJournal(opts),e=>e===rendered)}
 nav.openJournal.F=retained();nav.openJournal({edit:'other'});
 assert.equal(removed,0);assert.equal(confirmations,1);assert.equal(nav.openJournal.F.t,'keep these words');assert.equal(nav.openJournal.F.jrId,'stable-id');
 acceptDiscard=true;render({edit:'other'});assert.equal(removed,1);assert.equal(nav.openJournal.F.t,'other entry');assert.equal(nav.openJournal.F.resumeDraft,false);
 nav.openJournal.F=retained();acceptDiscard=false;const before=confirmations;render({fresh:true});
 assert.equal(confirmations,before);assert.equal(nav.openJournal.F.t,'keep these words');assert.equal(nav.openJournal.F.jrId,'stable-id');
 // Same-entry answered refresh must preserve draft text without a discard prompt.
 render({edit:'stable-id',keep:true});assert.equal(confirmations,before);assert.equal(nav.openJournal.F.t,'keep these words');
 const context={fresh:true,p:'workout prompt',src:'workout',tags:['workout']};const snapshot=JSON.stringify(context), beforeContext=removed;
 nav.openJournal(context);assert.equal(removed,beforeContext);assert.equal(nav.openJournal.F.t,'keep these words');assert.equal(JSON.stringify(context),snapshot);
 nav.openJournal({fresh:true,discardDraft:true});assert.equal(nav.openJournal.F.t,'keep these words');
 acceptDiscard=true;render({fresh:true,discardDraft:true});assert.equal(nav.openJournal.F.t,'');assert.equal(nav.openJournal.F.jrId,'');
 // A different user must never see or reuse the previous user's retained draft.
 nav.openJournal.F=retained();nav.state.me='owner-b';render({edit:'other',keep:true});
 assert.equal(nav.openJournal.F.ownerUid,'owner-b');assert.equal(nav.openJournal.F.t,'');assert.equal(nav.openJournal.F.edit,'');assert.equal(nav.openJournal.F.jrId,'');
 const devo={value:'private words',dataset:{jrOwner:'owner-a',jrId:'private-id',jrAt:'123'}};
 ctx.state.me='owner-b';ctx.jrDevoOwner(devo);assert.equal(devo.value,'');assert.equal(devo.dataset.jrId,undefined);assert.equal(devo.dataset.jrOwner,'owner-b');
 devo.value='current words';ctx.jrDevoOwner(devo);assert.equal(devo.value,'current words');ctx.state.me='test-user';
 assert.doesNotMatch(html.slice(0,openStart),/F\.resumeDraft = true/, 'journal draft changes must not alter legacy save handler');
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
 assert.equal(draft.t,'words to keep');assert.equal(ui.saved,false);assert.match(message.textContent,/not confirmed/);assert.equal(retryNotice.hidden,false);
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
 assert.match(html,/id: jrDraftId\(F\)/);assert.match(html,/id = jrDraftId\(ta\.dataset\)/);
 // A late deletion must not mutate a replacement view after its deadline.
 let deleteLate;ctx.B.deleteJournal=()=>new Promise(r=>deleteLate=r);
 const beforeDelete=ctx.state.journal.length;
 const deleting=ctx.jrAction(button,message,attempt=>ctx.jrDelete(stable,attempt));await flush();
 [...timers.values()][0]();assert.equal(await deleting,false);deleteLate();await flush();
 assert.equal(ctx.state.journal.length,beforeDelete);assert.equal(timers.size,0);
 // Execute the devotional reset binding: decline preserves text/id, accept
 // explicitly starts a new logical entry, and stale completion cannot clear it.
 let resetClick, acceptReset=false, resetPrompts=0;
 const devoTa={value:'old devotional',dataset:{jrOwner:'test-user'},focus(){}};const oldId=ctx.jrDraftId(devoTa.dataset);
 const devoRetry={hidden:false}, devoMessage={textContent:'unconfirmed'}, devoScope={dataset:{},querySelector:()=>devoRetry,querySelectorAll:()=>[button,devoTa]};
 const devoNodes={'jr-devo-new':{addEventListener(event,fn){resetClick=fn}},'jr-devo':devoScope,'jr-devo-ta':devoTa,'jr-devo-retry':devoRetry,'jr-devo-msg':devoMessage};
 const resetCtx={$:id=>devoNodes[id],jrDevoOwner:ctx.jrDevoOwner,confirm(){resetPrompts++;return acceptReset}};
 const wire=html.slice(html.indexOf('  function wireJournal('),html.indexOf('  var jrUI ='));
 const resetStart=wire.indexOf('$("jr-devo-new").addEventListener('),resetEnd=wire.indexOf('    $("jr-devo-save").addEventListener(',resetStart);
 assert.ok(resetStart>=0&&resetEnd>resetStart);vm.createContext(resetCtx);vm.runInContext(wire.slice(resetStart,resetEnd),resetCtx);
 devoScope.dataset.jrBusy='1';resetClick();assert.equal(resetPrompts,0);delete devoScope.dataset.jrBusy;
 resetClick();assert.equal(devoTa.value,'old devotional');assert.equal(devoTa.dataset.jrId,oldId);assert.equal(devoRetry.hidden,false);
 button.closest=()=>devoScope;let lateDevo;ctx.B.saveJournal=()=>new Promise(r=>lateDevo=r);
 const waitingDevo=ctx.jrAction(button,devoMessage,async attempt=>{await ctx.jrSave({id:oldId,t:devoTa.value},attempt);devoTa.value=''});await flush();
 [...timers.values()][0]();assert.equal(await waitingDevo,false);acceptReset=true;resetClick();
 assert.equal(devoTa.value,'');assert.equal(devoTa.dataset.jrId,undefined);assert.equal(devoRetry.hidden,true);
 const newId=ctx.jrDraftId(devoTa.dataset);assert.notEqual(newId,oldId);devoTa.value='new devotional';lateDevo();await flush();assert.equal(devoTa.value,'new devotional');
 // Actual devotional Save merges a confirmed same-ID entry instead of
 // rebuilding it and dropping tags/answered/provenance from a late snapshot.
 let devoSaveClick, devoPayload;
 const confirmedDevo={id:'devo-known',t:'confirmed words',tags:['prayer','grateful'],ans:444,p:'original prompt',src:'devo',d:'2026-11-04',at:100};
 ctx.state.journal=[confirmedDevo];devoTa.value='revised reflection';devoTa.dataset.jrId='devo-known';devoTa.dataset.jrAt='100';
 const devoSaveButton={disabled:false,closest:()=>devoScope,addEventListener(event,fn){devoSaveClick=fn}};devoNodes['jr-devo-save']=devoSaveButton;
 ctx.B.saveJournal=async(uid,x)=>{devoPayload=x};
 const saveCtx={$:id=>devoNodes[id],state:ctx.state,jrDevoOwner:ctx.jrDevoOwner,jrDraftId:ctx.jrDraftId,jrAction:ctx.jrAction,jrSave:ctx.jrSave,devoToday:()=>({e:{reflect:'different prompt'}}),todayKey:()=> '2026-11-05'};
 const devoSaveStart=wire.indexOf('$("jr-devo-save").addEventListener(');
 vm.createContext(saveCtx);vm.runInContext(wire.slice(devoSaveStart,wire.lastIndexOf('\n  }')),saveCtx);devoSaveClick();await flush();await flush();
 assert.equal(devoPayload.t,'revised reflection');for(const key of ['id','ans','p','src','d','at'])assert.equal(devoPayload[key],confirmedDevo[key]);assert.deepEqual(Array.from(devoPayload.tags),confirmedDevo.tags);
 // A stale answered button applies its displayed intent to the latest record,
 // without replacing newer text or tags with the captured row's old fields.
 let answeredClick, answeredPayload;
 const rowStart=html.indexOf('ab.addEventListener("click", function () {',html.indexOf('  function drawJournalPage(')),rowEnd=html.indexOf('; var jm',rowStart);
 assert.ok(rowStart>=0&&rowEnd>rowStart);
 const answeredCtx={ab:{addEventListener(event,fn){answeredClick=fn}},jm:{},state:{journal:[{id:'row1',t:'newer words',tags:['prayer','family'],ans:777}]},x:{id:'row1',t:'stale words',tags:['prayer']},jrAction(button,message,action){return action({})},async jrSave(y){answeredPayload=y}};
 vm.createContext(answeredCtx);vm.runInContext(html.slice(rowStart,rowEnd+1),answeredCtx);answeredClick();await flush();
 assert.equal(answeredPayload.t,'newer words');assert.deepEqual(Array.from(answeredPayload.tags),['prayer','family']);assert.ok(answeredPayload.ans,'Mark answered intent must not undo a newer answered value');
 answeredCtx.x.ans=111;answeredClick();await flush();assert.equal(answeredPayload.ans,undefined);assert.equal(answeredPayload.t,'newer words');
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
 // The editor can remain open after a timed-out write is later acknowledged.
 // Its answered action must not restore the captured older text/metadata.
 {
 const answeredBinding=html.split('\n').find(line=>line.includes('ab2.addEventListener("click"'));
 assert.ok(answeredBinding,'PR40 answered editor binding exists');
 let answeredWrite,answeredAction,answeredClick;
 const answeredCtx={ed:{id:'answered-late',t:'old text',tags:['prayer']},state:{journal:[{id:'answered-late',t:'confirmed newer text',tags:['prayer','family'],ans:123}]},ta:{value:'unsaved editor draft'},F:{},msg:{},ab2:{addEventListener(_,fn){answeredClick=fn}},jrAction(_,__,fn){answeredAction=fn({check(){}})},async jrSave(value){answeredWrite=value},openJournal(){}};
 vm.createContext(answeredCtx);vm.runInContext(answeredBinding,answeredCtx);answeredClick();await answeredAction;
 assert.equal(answeredWrite.t,'confirmed newer text');assert.deepEqual(Array.from(answeredWrite.tags),['prayer','family']);assert.ok(answeredWrite.ans,'Mark answered preserves intended action even if latest entry is already answered');
 }
 console.log('PASS: journal bounded wait, late-completion guard, stable retry IDs, pending-write deduplication, acknowledgement/delete failures and inline syntax');
})().catch(e=>{console.error(e);process.exitCode=1});


assert.match(html, /var PEN_SVG = /, "journal icon must survive mentor-deferral integration");
