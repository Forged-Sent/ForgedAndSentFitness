import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
def rep(a,b):
    global s; assert s.count(a)==1,(s.count(a),a[:80]); s=s.replace(a,b)
rep('''      <div class="banner" id="banner" hidden>Every box checked. Mission accomplished.</div>
    </section>''','''      <div class="banner" id="banner" hidden>Every box checked. Mission accomplished.</div>
      <ul class="today-foot" id="today-foot"></ul>
    </section>''')
rep('''    var wt = taskOfKind("weigh");
    if (wt && !isWeighDay(todayKey())) {''','''    var wt = taskOfKind("weigh"), foot = $("today-foot") || list; if (foot !== list) foot.textContent = "";
    if (wt && !isWeighDay(todayKey())) {''')
rep('''      list.appendChild(el("li", "wk-hint", "Weekly weigh-in" + (taskOfKind("photos")''','''      foot.appendChild(el("li", "wk-hint", "Weekly weigh-in" + (taskOfKind("photos")''')
rep('''sol.addEventListener("click", openSitOut); soli.appendChild(sol); list.appendChild(soli); }''','''sol.addEventListener("click", openSitOut); soli.appendChild(sol); foot.appendChild(soli); }''')
rep('/* Share to Instagram */','/* Today footnotes: weigh-in reminder and sit out, below Your two */\n.today-foot { margin-top: 14px; }\n.today-foot:empty { display: none; }\n/* Share to Instagram */')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
