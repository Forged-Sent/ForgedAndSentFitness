#!/usr/bin/env python3
"""Paul & Timothy info bubble: an (i) on the Today card and the Paul & Timothy page opens a sheet explaining the
biblical pattern (Acts 16; 1 Timothy 1:2; Philippians 2:22; 1 Corinthians 4:17; 2 Timothy 2:2; Proverbs 27:17, ESV)
and what it looks like in the app. Requested by Curtis 2026-11-02. Usage: patch_mentorinfo.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
JS = r'''
  function menInfoBtn() { var b = el("button", "onb-ib men-ib", "i"); b.type = "button"; b.setAttribute("aria-label", "About Paul and Timothy in the Bible"); b.addEventListener("click", function (ev) { ev.stopPropagation(); openMentorInfo(); }); return b; }
  function openMentorInfo() {
    var old = $("cdlg"); if (old) old.remove(); var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box men-info"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "mi-t");
    box.appendChild(el("p", "fr-k", "Paul & Timothy in Scripture"));
    var h = el("h2", null, "One man pours into another, who pours into others."); h.id = "mi-t"; box.appendChild(h);
    box.appendChild(el("p", "mi-p", "Paul met Timothy as a young believer in Lystra and took him along on his journeys (Acts 16:1–3). He taught him, trusted him with churches, and called him his son in the faith."));
    [["To Timothy, my true child in the faith.", "1 Timothy 1:2"],
     ["But you know Timothy’s proven worth, how as a son with a father he has served with me in the gospel.", "Philippians 2:22"],
     ["That is why I sent you Timothy, my beloved and faithful child in the Lord, to remind you of my ways in Christ.", "1 Corinthians 4:17"]].forEach(function (v) { var q = el("blockquote", "mem-v mi-v", v[0]); q.appendChild(el("cite", null, v[1])); box.appendChild(q); });
    box.appendChild(el("div", "fr-h", "The charge: four generations"));
    var q2 = el("blockquote", "mem-v mi-v mi-key", "And what you have heard from me in the presence of many witnesses entrust to faithful men, who will be able to teach others also."); q2.appendChild(el("cite", null, "2 Timothy 2:2")); box.appendChild(q2);
    var ch = el("div", "mi-chain"); ["Paul", "Timothy", "Faithful men", "Others also"].forEach(function (t, i) { if (i) ch.appendChild(el("span", "mi-arr", "→")); ch.appendChild(el("span", "mi-gen", t)); }); box.appendChild(ch);
    box.appendChild(el("div", "fr-h", "What it looks like here"));
    var ul = el("ul", "mi-list");
    [["Your Paul", "an older or further-along brother who walks with you, prays for you and asks the hard questions."],
     ["Your Timothy", "a newer brother you walk with. You check on him, pray for him and show him the way you live."],
     ["Every week", "your Timothy checks in, and you reach out when he needs to talk."],
     ["The goal", "every Timothy becomes a Paul. Disciples who make disciples."]].forEach(function (r) { var li = el("li"); li.appendChild(el("b", null, r[0] + ": ")); li.appendChild(document.createTextNode(r[1])); ul.appendChild(li); });
    box.appendChild(ul);
    var q3 = el("blockquote", "mem-v mi-v", "Iron sharpens iron, and one man sharpens another."); q3.appendChild(el("cite", null, "Proverbs 27:17")); box.appendChild(q3);
    var cl = el("button", "btn", "Got it"); cl.type = "button"; cl.addEventListener("click", function () { back.remove(); }); box.appendChild(cl);
    back.appendChild(box); back.addEventListener("click", function (ev) { if (ev.target === back) back.remove(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); back.remove(); } }); document.body.appendChild(back); cl.focus();
  }
'''
rep('''  function drawMentorToday() {''', JS + '''  function drawMentorToday() {''')
rep('''card.appendChild(el("div", "label-caps men-k", "Walk with your brothers"));''', '''var kh = el("div", "men-kh"); kh.appendChild(el("span", "label-caps men-k", "Walk with your brothers")); kh.appendChild(menInfoBtn()); card.appendChild(kh);''')
rep('''    box.appendChild(el("p", "note", "A Paul walks with a newer brother (2 Timothy 2:2). A Timothy is the brother you walk with. One Paul, a few Timothys."));''',
    '''    var intro = el("button", "men-intro"); intro.type = "button"; intro.appendChild(el("span", null, "A Paul walks with a newer brother. A Timothy is the brother you walk with. One Paul, a few Timothys.")); intro.appendChild(el("b", null, "Why Paul & Timothy? ›")); intro.addEventListener("click", openMentorInfo); box.appendChild(intro);''')
rep('''.men-wide { width: 100%; margin-top: 8px; }''', '''.men-wide { width: 100%; margin-top: 8px; }
.men-kh { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.men-ib { flex: none; }
.men-intro { width: 100%; display: grid; gap: 4px; margin: 6px 0 4px; padding: 12px; text-align: left; font: inherit; color: var(--ink); background: var(--surface); border: 1px solid var(--line); border-radius: 10px; cursor: pointer; } .men-intro span { color: var(--muted); font-size: 14px; } .men-intro b { color: var(--accent); font-family: var(--f-label); letter-spacing: .08em; text-transform: uppercase; font-size: 13.5px; }
.men-info { max-height: 88vh; overflow-y: auto; }
.mi-p { margin: 0 0 10px; line-height: 1.5; }
.mi-v { margin: 8px 0; } .mi-v cite { display: block; margin-top: 4px; font-style: normal; font-family: var(--f-label); font-weight: 700; letter-spacing: .08em; text-transform: uppercase; font-size: 12px; color: var(--accent); }
.mi-key { font-size: 17px; }
.mi-chain { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin: 6px 0 12px; } .mi-gen { padding: 6px 10px; border: 1px solid var(--accent); border-radius: 16px; font-family: var(--f-label); font-weight: 700; letter-spacing: .06em; text-transform: uppercase; font-size: 13px; } .mi-arr { color: var(--accent); font-weight: 700; }
.mi-list { margin: 0 0 10px; padding-left: 18px; display: grid; gap: 6px; line-height: 1.45; }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
