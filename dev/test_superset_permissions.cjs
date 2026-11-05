const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const html = fs.readFileSync('index.html','utf8');
const start = html.indexOf('  function supGroup('), end = html.indexOf('  function drawWorkoutPage(',start);
let buttons=[],sets=[[],[]],saves=0;
function el(tag,cls,text){const node={tagName:tag.toUpperCase(),children:[],textContent:text||'',classList:{add(){},contains(){return false},toggle(){}},appendChild(x){this.children.push(x)},insertBefore(x){this.children.push(x)},querySelector(){return null},addEventListener(event,fn){this[event]=fn},remove(){}};if(tag==='button')buttons.push(node);return node;}
// Font fitting is deferred by v234; this permission test has no layout engine.
const ctx={setTimeout(){},el,setsOf:i=>sets[i],saveWkNow(){saves++},redrawKeepScroll(){},supShortRx:x=>x,supRestText:()=>'',restOf:()=>60,document:{createTextNode:()=>el('span')},restBar:()=>el('div')};
vm.createContext(ctx);vm.runInContext(html.slice(start,end),ctx);
function render(off){buttons=[];ctx.supGroup(el('div'),'A',[0,1].map(idx=>({idx,ex:el('div'),e:['lift','rx'],name:'lift',ps:{target:10}})),off)}
render(true);assert.equal(buttons.length,2);for(const b of buttons){assert.equal(b.disabled,true);b.click()};assert.deepEqual(sets,[[],[]]);assert.equal(saves,0);
render(false);buttons.find(b=>b.textContent==='+ Add set').click();assert.equal(sets[0].length,1);assert.equal(sets[1].length,1);assert.equal(saves,1);
buttons.find(b=>b.textContent==='+ Warm-up set').click();assert.equal(sets[0][0].k,'w');assert.equal(sets[1][0].k,'w');assert.equal(saves,2);
assert.match(html,/supGroup\(body, L, \[supEls\[idx\], supEls\[idx \+ 1\]\], off\)/);
console.log('PASS: read-only superset controls cannot mutate sets; writable paired additions retained');
