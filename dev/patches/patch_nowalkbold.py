import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
def rep(a,b):
    global s; assert s.count(a)==1,(s.count(a),a[:80]); s=s.replace(a,b)
rep('\n    <div id="walk-bold"></div>','')
rep('''  function drawWalkBold() {
    var box = $("walk-bold"); if (!box) return; box.textContent = "";''','''  function drawWalkBold() {
    var box = $("walk-bold"); if (!box) return; box.textContent = ""; return; // Bold Step stays on Today only.''')
rep('"Brothers: your Paul, your Timothys and your weekly check-in.','"Brothers: your Paul, your Timothys and your weekly check-in.')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
