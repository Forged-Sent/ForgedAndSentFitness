#!/usr/bin/env python3
"""Journal for all of life, not only faith (Curtis 2026-11-05).
- Tags lead with everyday life: Workout, Win, Struggle, Family, Work, Grateful, Prayer, God showed me (old tags keep working).
- Wording on Today, the entry sheet, My journal, info bubbles, tour, setup and Ask invites anything: training, work, home, faith.
- Finished workouts get "Write about this workout", which opens the journal tagged Workout with the workout name on top.
Usage: patch_jrlife.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''var JR_TAGS = [["grateful", "Grateful"], ["prayer", "Prayer"], ["win", "Win"], ["struggle", "Struggle"], ["god", "God showed me"]];''',
    '''var JR_TAGS = [["workout", "Workout"], ["win", "Win"], ["struggle", "Struggle"], ["family", "Family"], ["work", "Work"], ["grateful", "Grateful"], ["prayer", "Prayer"], ["god", "God showed me"]];''')
rep('''"What is God showing you today? No points, just you and Him."''', '''"Your workout, your day, your family, your faith. No points, just write."''')
rep('''pv.textContent = "\U0001F512︎ Private. Only you can read your journal. It is never ''', '''pv.textContent = "\U0001F512︎ Private. Write about anything: a lift, your work, your family, your faith. Only you can read your journal. It is never ''')
rep('''ta.placeholder = "What happened? W''', '''ta.placeholder = "What happened today? Something you noticed in your workout, a win at work, a moment at home, what God is showing you. W''')
# check what the rest of the old placeholder was
m = re.search(r'ta\.placeholder = "What happened today\?[^"]*"', s); assert m
s = s.replace(m.group(0), 'ta.placeholder = "What happened today? Something you noticed in your workout, a win at work, a moment at home, what God is showing you."')
# preset tags and a heading line when opened from a finished workout
rep('''F.tags = e0 ? (e0.tags || []).slice() : []; }''', '''F.tags = e0 ? (e0.tags || []).slice() : (opts.tags || []).slice(); F.p = e0 ? "" : (opts.p || ""); F.src = e0 ? "" : (opts.src || ""); }''')
rep('''if (ed && ed.p) box.appendChild(el("blockquote", "mem-v lg-p", ed.p));''', '''if ((ed && ed.p) || (!ed && F.p)) box.appendChild(el("blockquote", "mem-v lg-p", ed ? ed.p : F.p));''')
rep('''t: v, tags: F.tags.slice(), src: "pen" };''', '''t: v, tags: F.tags.slice(), src: F.src || "pen", p: F.p || "" };''')
rep('''jrSave(x); F.saved = x.id; F.edit = ""; F.t = ""; F.tags = []; openJournal();''', '''jrSave(x); F.saved = x.id; F.edit = ""; F.t = ""; F.tags = []; F.p = ""; F.src = ""; openJournal();''')
# finished workout button
rep('''    body.appendChild(ib);
    var un = el("button", "btn ghost lk-btn");''', '''    body.appendChild(ib);
    var jw = el("button", "btn ghost lk-btn"); jw.type = "button"; jw.innerHTML = PEN_SVG; jw.appendChild(document.createTextNode("Write about this workout"));
    jw.addEventListener("click", function () { var dl = new Date(key + "T12:00:00").toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" }); openJournal({ fresh: true, tags: ["workout"], src: "workout", p: ((w && w.title) || "Workout") + " \\u00B7 " + dl }); });
    body.appendChild(jw);
    var un = el("button", "btn ghost lk-btn");''')
# help, tour, setup, Ask
rep('''journal: { t: "My journal", why: "A private place to write what God is doing in your life, and to remember it later. Only you can read it. It is never scored.", how: [
      "Tap the pen at the top of any page to write. Pick a tag if it helps: Grateful, Prayer, Win, Struggle or God showed me.",''', '''journal: { t: "My journal", why: "A private place to write down anything worth remembering: what you noticed in your workout, what happened at work or at home, and what God is showing you. Only you can read it. It is never scored.", how: [
      "Tap the pen at the top of any page to write. Pick a tag if it helps: Workout, Win, Struggle, Family, Work, Grateful, Prayer or God showed me.",
      "After a workout, tap Write about this workout. The entry is tagged Workout with that day\\u2019s workout on top.",''')
rep('''"Journal: tap the pen at the top of any page to write a quick entry. Private, and never scored.''', '''"Journal: tap the pen at the top of any page to write about anything: your workout, work, family or faith. Private, and never scored.''')
rep('''["journal", "Journal", ["Tap the pen at the top of any page to write a quick entry. Only you can read it.", "Tag prayers and mark them answered. Look back with search and On this day.", "Write it down at the end of the devotional starts with that day\\u2019s question. No points, just you and God."]],''',
    '''["journal", "Journal", ["Tap the pen at the top of any page to write about anything: a lift, your work, your family, your faith. Only you can read it.", "After a workout, Write about this workout keeps what you noticed. Tag prayers and mark them answered.", "Look back with search and On this day. No points, just write."]],''')
rep('''["Journal", "A private place to write what God is doing. Tap the pen at the top of any page.",''', '''["Journal", "A private place to write down anything: your training, work, family and faith. Tap the pen at the top of any page.",''')
rep('''"t": "Write in my journal", "a": "Tap the pen at the top of any page. Pick a tag if it helps, write, and tap Save. Only you can read it. It is never scored.", "w": "The pen at the top of any page \\u00B7 Today \\u203A Journal", "k": "journal write entry diary notes pen private reflect thoughts",''',
    '''"t": "Write in my journal", "a": "Tap the pen at the top of any page. Write about anything: your workout, work, family or faith. Pick a tag if it helps, and tap Save. After a workout, tap Write about this workout. Only you can read it. It is never scored.", "w": "The pen at the top of any page \\u00B7 Today \\u203A Journal \\u00B7 a finished workout", "k": "journal write entry diary notes pen private reflect thoughts workout life family work log",''')
rep('''"Nothing written yet. Tap the pen at the top of any page to start."''', '''"Nothing written yet. Tap the pen at the top of any page and write about your workout, your day, your family or your faith."''')
rep('return day + (x.src === "devo" ? " · Devotional" : ', 'return day + (x.src === "devo" ? " · Devotional" : x.src === "workout" && x.p ? " · " + String(x.p).split(" · ")[0] : ')
rep('''.jr-hd { display: inline-flex;''', '''.cdlg[data-k="journal"] .lg-chips { gap: 5px; margin: 4px 0 8px; }
.cdlg[data-k="journal"] .lg-chips .mini { min-height: 28px; min-width: 0; padding: 0 7px; font-size: 10.5px; letter-spacing: .04em; }
.jr-hd { display: inline-flex;''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
