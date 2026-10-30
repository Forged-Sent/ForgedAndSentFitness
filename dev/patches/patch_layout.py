import sys,re
src,dst,ver=sys.argv[1:4]
s=open(src).read()
def rep(a,b,n=1):
    global s
    assert s.count(a)==n,(a[:60],s.count(a)); s=s.replace(a,b)
rep('.pbar{display:flex;justify-content:space-between;align-items:center;gap:12px}',
 '.pbar{display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;row-gap:6px}\n.pbar > .date, .pbar > .label-caps{min-width:0}\n@media (max-width:340px){ .pbar{gap:8px} .pbar .date{font-size:12px;letter-spacing:.04em} .help-right{gap:6px} }')
rep('.rest { display: flex; align-items: center; gap: 8px; margin-top: 12px; padding-top: 10px; border-top: 1px dashed var(--line); }',
 '.rest { display: flex; align-items: center; flex-wrap: wrap; row-gap: 6px; gap: 8px; margin-top: 12px; padding-top: 10px; border-top: 1px dashed var(--line); }\n@media (max-width: 390px) { .rest { gap: 6px; } .rest .mini { min-width: 42px; padding: 0 6px; font-size: 12px; } }')
rep('.rest .rt-time { flex: 1; font-family: var(--f-display); font-weight: 700; font-size: 21.5px; min-width: 62px; }','.rest .rt-time { flex: 1; font-family: var(--f-display); font-weight: 700; font-size: 21.5px; min-width: 56px; }')
rep('.pg-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; }','.pg-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; row-gap: 8px; }')
rep('.wu-tgt { font-size: 12px; color: var(--muted); align-self: center; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }','.wu-tgt { font-size: 12px; color: var(--muted); align-self: center; min-width: 0; line-height: 1.3; overflow-wrap: anywhere; }')
rep('text-transform: uppercase; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }\n.who .nm em','text-transform: uppercase; overflow-wrap: anywhere; }\n.who .nm em')
n=s.count('Two easy recovery days (an incline walk or stair climb plus mobility)')
assert n==2,n
s=s.replace('Two easy recovery days (an incline walk or stair climb plus mobility)','Two easy recovery days (an easy walk or jog plus mobility, all at home with no equipment)')
m=re.search(r'var APP_VERSION = "[^"]+";',s); s=s.replace(m.group(0),'var APP_VERSION = "%s";'%ver)
open(dst,'w').write(s)
