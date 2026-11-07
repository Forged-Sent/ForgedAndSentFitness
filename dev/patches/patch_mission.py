import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
def rep(a,b,n=1):
    global s; assert s.count(a)==n,(s.count(a),a[:80]); s=s.replace(a,b)
# Remove the Sent mission feature (Profile button, campaign card, Ask/help entries). Code stays unused-free.
rep('''\n    <button class="btn ghost" type="button" id="p-mission" style="width:100%;margin-top:8px" hidden>My mission</button>''','')
rep('''\n        if (state.me) box.appendChild(sentCard("Campaign " + n + " is complete. Write the mission God is sending you on."));''','')
rep(''' $("p-mission").hidden = !own;''','')
rep('''\n    $("p-mission").addEventListener("click", function () { openSent(); });''','')
i=s.index('    { t: "My mission (Sent)"'); j=s.index('\n',i)
line=s[i:j]; assert line.rstrip().endswith('}')
s=s[:i].rstrip().rstrip(',')+'\n'+s[j+1:] if False else s[:i]+s[j+1:]
# fix trailing comma on previous ASK entry
k=s.rindex('\n',0,i-1); prev=s[k+1:i-1]
if prev.rstrip().endswith('},'): s=s[:k+1]+prev.rstrip()[:-1]+'\n'+s[i:]
i=s.index('  if (HELP.camp && HELP.camp.how) HELP.camp.how.push("When a campaign ends'); j=s.index('\n',i); s=s[:i]+s[j+1:]
# My Creed becomes My Mission
rep('font-size:13px;color:var(--brass);margin-bottom:4px">My Creed</div>','font-size:13px;color:var(--brass);margin-bottom:4px">My Mission</div>')
rep('<label class="flabel">My Creed<input class="field" type="text" id="s-motto" maxlength="80" placeholder="e.g. Be strong. Lead well."></label>','<label class="flabel">My Mission<input class="field" type="text" id="s-motto" maxlength="80" placeholder="e.g. Lead my family and train men who train others."></label>')
rep('>Save handle and creed</button>','>Save handle and mission</button>')
rep('PRs, creed and posts.</p>','PRs, mission and posts.</p>')
rep('" His creed: \\u201C"','" His mission: \\u201C"')
rep('own ? "No creed yet. Set it in Settings." : "No creed yet."','own ? "No mission yet. Set it in Settings." : "No mission yet."')
rep('var t = el("h2", null, "My Creed"); t.id = "mo-t";','var t = el("h2", null, "My Mission"); t.id = "mo-t";')
rep('"You haven\\u2019t set your creed yet. Write one in your profile and it will show here every morning."','"You haven\\u2019t set your mission yet. Write it in your profile and it will show here every morning."')
rep('el("button", "btn", "Set my creed")','el("button", "btn", "Set my mission")')
rep('sub = done[tk.id] ? "Read today" : mm ? "Tap to read your creed" : "Set your creed in Settings";','sub = done[tk.id] ? "Read today" : mm ? "Tap to read your mission" : "Set your mission in Settings";')
rep('like the devotional, your creed or your steps.",','like the devotional, your mission or your steps.",')
rep('the devotional and creed, training,','the devotional and mission, training,')
rep('why: "A man\'s creed, stats and core lift PRs."','why: "A man\'s mission, stats and core lift PRs."')
rep('"Your profile: photo, banner, handle and creed."','"Your profile: photo, banner, handle and mission."')
rep('motto: ["My Creed", "A short line you live by. It shows on your profile, and every morning you read it to check your My Creed box for 1 p','motto: ["My Mission", "What God has called you to, in one line. It shows on your profile, and every morning you read it to check your My Mission box for 1 p')
rep('onbField(body, "My Creed", "motto", "motto", "text", { maxlength: "80", placeholder: "e.g. Be strong. Lead well."','onbField(body, "My Mission", "motto", "motto", "text", { maxlength: "80", placeholder: "e.g. Lead my family and train men who train others."')
rep('like the devotional, your creed and your steps.", "Your Bold Step','like the devotional, your mission and your steps.", "Your Bold Step')
rep('{"t": "My creed", "a": "Write your creed in Settings. The My Creed box on Today shows it each morning.", "w": "Settings › Your profile", "k": "creed motto"','{"t": "My mission", "a": "Write your mission in Settings: what God has called you to, in one line. The My Mission box on Today shows it each morning.", "w": "Settings › Your profile", "k": "mission creed motto sent calling"')
# Today box title comes from the live task row; show My Mission even before the DB title changes.
rep('nm = el("span", "name", tk.kind === "calories" && foodMode() !== "app" ? FOOD_MODES[foodMode()].box : tk.title);','nm = el("span", "name", tk.kind === "calories" && foodMode() !== "app" ? FOOD_MODES[foodMode()].box : tk.id === "t_motto" ? "My Mission" : tk.title);')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
