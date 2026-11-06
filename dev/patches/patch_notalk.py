#!/usr/bin/env python3
"""Remove "I need to talk" from the weekly Paul & Timothy check-in (Curtis 2026-11-06):
a man is responsible to reach out to his Paul directly. Paul's view no longer shows "Asked to talk" (old flags ignored).
Usage: patch_notalk.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''      var tl = el("label", "men-talk"), cb = el("input"); cb.type = "checkbox"; cb.checked = S.talk; cb.disabled = off; cb.addEventListener("change", function () { S.talk = cb.checked; }); tl.appendChild(cb); var tt = el("span"); tt.appendChild(el("b", null, "I need to talk")); tt.appendChild(el("small", null, nameOf(p) + " gets a nudge to reach out today")); tl.appendChild(tt); f.appendChild(tl);
''', '')
rep('''pray: String(S.pray || "").trim().slice(0, 280), talk: !!S.talk };''', '''pray: String(S.pray || "").trim().slice(0, 280) };''')
rep('''var c = menOf(t).chk[menWeek()]; if (c && c.talk) return ["Asked to talk", "Reach out", "hot"]; if (c)''', '''var c = menOf(t).chk[menWeek()]; if (c)''')
rep('''    if (c && c.talk) box.appendChild(el("div", "men-alert", nameOf(t) + " asked to talk. Reach out today: call or text him from your phone."));
''', '')
rep('''["Every week", "your Timothy checks in, and you reach out when he needs to talk."],''', '''["Every week", "your Timothy checks in and tells you how to pray for him. You pray, and you stay in touch."],''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
