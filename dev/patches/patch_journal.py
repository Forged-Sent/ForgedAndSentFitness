#!/usr/bin/env python3
"""Journal (approved by Curtis 2026-11-04 from journal_mock.png).
- Private: entries live in data/users/<me>/journal/entries/<id>, which only that brother can read or write.
- Quick to reach: a pen button beside the profile button on every main page, a Journal row on Today
  (Done when there is an entry today, no points), and a "Write it down" card at the end of the devotional.
- Quick entry: tags (Grateful, Prayer, Win, Struggle, God showed me), text, Save, edit, delete,
  "Share this entry with my Paul" (share sheet, then clipboard; nothing is stored as shared).
- My journal page: Entries and Answered prayers tabs, keyword search, an "On this day" card, mark a prayer answered.
- Download my data includes the journal (JSON, journal.csv, Markdown section). Delete account removes it.
Search here is keyword only; AI search (RAG) over the brother's own data waits for Firebase (logged).
Usage: patch_journal.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---------- CSS ----------
rep('''.lg-chips { display: flex; flex-wrap: wrap; gap: 8px; margin: 6px 0 10px; }''', '''.lg-chips { display: flex; flex-wrap: wrap; gap: 8px; margin: 6px 0 10px; }
.jr-hd { display: inline-flex; align-items: center; gap: 10px; }
.jr-pen { flex: none; width: 34px; height: 34px; border-radius: 50%; border: 2px solid var(--brass, var(--accent)); background: transparent; padding: 0; display: grid; place-items: center; color: var(--accent); cursor: pointer; }
.jr-pen svg { width: 18px; height: 18px; fill: none; stroke: currentColor; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
.right .jr-pen { margin-right: 6px; }
.jr-priv { margin: 0; padding: 8px 10px; border: 1px dashed var(--accent); border-radius: 8px; font-size: 13.5px; }
.jr-when { font-family: var(--f-label); font-weight: 700; letter-spacing: .1em; text-transform: uppercase; font-size: 12.5px; color: var(--brass, var(--accent)); }
.jr-ta { min-height: 150px; font-size: 16px; line-height: 1.5; }
.jr-tip { font-size: 12.5px !important; color: var(--muted); }
.jr-devo { border: 1px solid var(--line); border-radius: 12px; padding: 14px; background: var(--surface); }
.jr-devo blockquote { margin: 6px 0 10px; padding-left: 10px; border-left: 3px solid var(--accent); font-style: italic; }
.jr-devo textarea { width: 100%; min-height: 110px; }
.jr-devo .jr-ok { margin: 8px 0 0; font-weight: 600; }
.jr-tabs { display: grid; grid-template-columns: 1fr 1fr; border: 1px solid var(--line); border-radius: 10px; overflow: hidden; margin: 6px 0 10px; }
.jr-tabs button { border: 0; background: transparent; color: var(--ink); padding: 10px 6px; font-family: var(--f-label); font-weight: 700; letter-spacing: .1em; text-transform: uppercase; font-size: 13.5px; cursor: pointer; }
.jr-tabs button[aria-selected="true"] { background: var(--accent); color: var(--accent-ink, #111); }
.jr-search { width: 100%; margin: 0 0 10px; }
.jr-otd { border: 1px solid var(--accent); border-radius: 10px; padding: 12px; margin: 0 0 12px; background: var(--surface); width: 100%; text-align: left; color: var(--ink); cursor: pointer; font: inherit; }
.jr-otd p { margin: 4px 0 0; font-size: 14.5px; line-height: 1.45; }
.jr-list { list-style: none; margin: 0; padding: 0; }
.jr-it { border-bottom: 1px solid var(--line); padding: 12px 0; }
.jr-it > button.jr-open { display: block; width: 100%; text-align: left; background: none; border: 0; color: var(--ink); padding: 0; font: inherit; cursor: pointer; }
.jr-it p { margin: 4px 0 6px; font-size: 15px; line-height: 1.45; white-space: pre-wrap; }
.jr-tags { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.jr-tg { font-family: var(--f-label); font-weight: 700; letter-spacing: .08em; text-transform: uppercase; font-size: 11.5px; border: 1px solid var(--line); border-radius: 999px; padding: 2px 8px; color: var(--muted); }
.jr-tg.ans { border-color: var(--accent); color: var(--accent); }
.jr-it .mini { margin-left: auto; }
.jr-empty { color: var(--muted); font-size: 14.5px; line-height: 1.45; padding: 8px 0; }''')

# ---------- HTML: devotional card + journal page ----------
rep('''      <section class="d-sec"><h2 class="d-lbl">Act</h2><p id="d-act"></p></section>
      <div class="devo-end">''', '''      <section class="d-sec"><h2 class="d-lbl">Act</h2><p id="d-act"></p></section>
      <section class="d-sec jr-devo" id="jr-devo" aria-labelledby="jr-devo-h">
        <h2 class="d-lbl" id="jr-devo-h">Write it down</h2>
        <blockquote id="jr-devo-q"></blockquote>
        <textarea class="field" id="jr-devo-ta" rows="5" maxlength="4000" aria-label="Your journal entry" placeholder="Answer it honestly. Only you can read this."></textarea>
        <button class="btn" type="button" id="jr-devo-save">Save to my journal</button>
        <p class="note jr-ok" id="jr-devo-msg" aria-live="polite"></p>
        <p class="note" style="margin:6px 0 0">Today&rsquo;s reflection question starts the entry. Private, and never scored.</p>
      </section>
      <div class="devo-end">''')
rep('''  <div class="page" id="page-mentor" hidden>''', '''  <div class="page" id="page-journal" hidden>
    <div class="pbar">
      <button class="mini" type="button" id="jr-back">&lsaquo; Today</button>
      <span class="date label-caps">Write it down</span>
      <button type="button" class="jr-pen" id="jr-new" aria-label="New journal entry"></button>
    </div>
    <h1 class="pg">My journal</h1>
    <div id="jr-body"></div>
  </div>

  <div class="page" id="page-mentor" hidden>''')

# ---------- navigation ----------
rep('''"chal", "ideas", "team", "camp", "owner", "mentor"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''', '''"chal", "ideas", "team", "camp", "owner", "mentor", "journal"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''')
rep('''p === "mentor" ? "today" :''', '''p === "mentor" || p === "journal" ? "today" :''')
rep('''    if (p === "mentor") drawMentorPage();
    $("scroll")''', '''    if (p === "mentor") drawMentorPage();
    if (p === "journal") drawJournalPage();
    $("scroll")''')

# ---------- backend ----------
rep('''    saveLegacy: function (uid, o) {''', '''    watchJournal: function (uid, cb) { return this.db.doc("data/users/" + uid + "/journal").collection("entries").onSnapshot(function (s) { cb(s.docs.map(function (d) { var x = d.data() || {}; x.id = d.id; return x; })); }, noop); },
    saveJournal: function (uid, x) { return this.db.doc("data/users/" + uid + "/journal").collection("entries").doc(x.id).set(x); },
    deleteJournal: function (uid, id) { return this.db.doc("data/users/" + uid + "/journal").collection("entries").doc(id).delete(); },
    saveLegacy: function (uid, o) {''')
rep('''await db.doc("data/users/" + uid + "/legacy").delete(); } catch (e) {}''', '''await db.doc("data/users/" + uid + "/legacy").delete(); var jr = await db.doc("data/users/" + uid + "/journal").collection("entries").get(); for (var ji = 0; ji < jr.docs.length; ji++) await db.doc("data/users/" + uid + "/journal/entries/" + jr.docs[ji].id).delete(); } catch (e) {}''')
rep('''      if (B.watchLegacy) B.watchLegacy(state.me,''', '''      if (B.watchJournal) B.watchJournal(state.me, function (rows) { state.journal = rows.filter(function (x) { return x && x.t; }); drawToday(); if (state.page === "journal") drawJournalPage(); });
      if (B.watchLegacy) B.watchLegacy(state.me,''')

# ---------- Today row ----------
rep('''      lb0.addEventListener("click", function () { openLegacy(); }); lli.appendChild(lb0); list.appendChild(lli);
    }''', '''      lb0.addEventListener("click", function () { openLegacy(); }); lli.appendChild(lb0); list.appendChild(lli);
    }
    if (state.me) {
      var jt = journalToday(), jli = el("li", "item fr-li"), jb = el("button", "hit fr-open"); jb.type = "button"; jb.id = "jr-today";
      if (jt.length) { jb.classList.add("fr-done"); var jbx = el("span", "box"); jbx.innerHTML = CHECK_SVG; jb.appendChild(jbx); } else { var jic = el("span", "fr-ic"); jic.innerHTML = PEN_SVG; jb.appendChild(jic); }
      var jtx = el("span", "txt"); jtx.appendChild(el("span", "name", "Journal"));
      jtx.appendChild(el("span", "sub", jt.length ? "Written today \\u00B7 Tap to read or add" : "What is God showing you today? No points, just you and Him.")); jb.appendChild(jtx);
      if (jt.length) jb.appendChild(el("span", "pts fr-tag", "Done")); jb.appendChild(el("span", "chev", "\\u203A"));
      jb.addEventListener("click", function () { if (journalToday().length) go("journal"); else openJournal(); }); jli.appendChild(jb); list.appendChild(jli);
    }''')

# ---------- devotional fill ----------
rep('''    $("d-reflect").textContent = t.e.reflect; $("d-act").textContent = t.e.act;''', '''    $("d-reflect").textContent = t.e.reflect; $("d-act").textContent = t.e.act;
    drawJournalDevo(t);''')

# ---------- export ----------
rep('''      liftNotes: state.liftNotes || {},''', '''      liftNotes: state.liftNotes || {},
      journal: journalSorted().map(function (x) { return { date: x.d, at: x.at ? new Date(x.at).toISOString() : "", tags: x.tags || [], text: x.t, prompt: x.p || "", from: x.src || "", answered: x.ans ? new Date(x.ans).toISOString() : "" }; }),''')
rep('''    out.push({ name: "prs.csv",''', '''    out.push({ name: "journal.csv", text: csvOf(["date", "time", "tags", "entry", "prompt", "answered"], (D.journal || []).map(function (j) { return [j.date, j.at ? new Date(j.at).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" }) : "", (j.tags || []).map(jrLabel).join("; "), j.text, j.prompt, j.answered ? dateKeyLocal(new Date(j.answered)) : ""]; })) });
    out.push({ name: "prs.csv",''')

# ---------- functions ----------
JS = r'''
  var PEN_SVG = '<svg viewBox="0 0 24 24" aria-hidden="true" style="width:20px;height:20px;fill:none;stroke:currentColor;stroke-width:2.2;stroke-linecap:round;stroke-linejoin:round"><path d="M4 20h4L19 9l-4-4L4 16v4z"/><path d="M13.5 6.5l4 4"/></svg>';
  var JR_TAGS = [["grateful", "Grateful"], ["prayer", "Prayer"], ["win", "Win"], ["struggle", "Struggle"], ["god", "God showed me"]];
  function jrLabel(k) { for (var i = 0; i < JR_TAGS.length; i++) if (JR_TAGS[i][0] === k) return JR_TAGS[i][1]; return k; }
  function journalSorted() { return (state.journal || []).slice().sort(function (a, b) { return (b.at || 0) - (a.at || 0); }); }
  function journalToday() { var k = todayKey(); return journalSorted().filter(function (x) { return x.d === k; }); }
  function jrSave(x) {
    var list = (state.journal || []).filter(function (y) { return y.id !== x.id; }); list.push(x); state.journal = list;
    try { B.saveJournal(state.me, x); } catch (e) {}
    drawToday(); if (state.page === "journal") drawJournalPage();
  }
  function jrDelete(id) {
    state.journal = (state.journal || []).filter(function (y) { return y.id !== id; });
    try { B.deleteJournal(state.me, id); } catch (e) {}
    drawToday(); if (state.page === "journal") drawJournalPage();
  }
  function jrWhen(x) {
    var k = x.d || "", t = todayKey(), d = new Date(k + "T12:00:00"), yd = new Date(t + "T12:00:00"); yd.setDate(yd.getDate() - 1);
    var day = k === t ? "Today" : k === dateKeyLocal(yd) ? "Yesterday" : d.toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" });
    var tm = x.at ? new Date(x.at).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" }) : "";
    return day + (x.src === "devo" ? " · Devotional" : tm && k === t ? " · " + tm : "");
  }
  function dateKeyLocal(d) { return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0"); }
  async function jrShare(x, msg) {
    var txt = (x.p ? x.p + "\n\n" : "") + x.t + "\n\n(From my Forged & Sent journal)";
    if (navigator.share) { try { await navigator.share({ title: "From my journal", text: txt }); msg.textContent = "✓ Shared."; return; } catch (e) { if (e && e.name === "AbortError") return; } }
    try { await navigator.clipboard.writeText(txt); msg.textContent = "✓ Copied. Paste it in a text to your Paul."; return; } catch (e) {}
    var ta = el("textarea", "field"); ta.value = txt; ta.rows = 5; ta.readOnly = true; ta.setAttribute("aria-label", "Entry to copy"); msg.textContent = "Copy this and send it to your Paul:"; msg.after(ta); ta.select();
  }
  function openJournal(opts) {
    opts = opts || {}; var old = $("cdlg"); if (old) old.remove();
    var F = openJournal.F || (openJournal.F = {});
    if (opts.edit !== undefined || opts.fresh) { F.edit = opts.edit || ""; F.saved = ""; var e0 = F.edit ? (state.journal || []).filter(function (y) { return y.id === F.edit; })[0] : null; F.t = e0 ? e0.t : ""; F.tags = e0 ? (e0.tags || []).slice() : []; }
    if (!F.tags) F.tags = []; if (F.t == null) F.t = "";
    var ed = F.edit ? (state.journal || []).filter(function (y) { return y.id === F.edit; })[0] : null;
    var back = el("div", "cdlg"); back.id = "cdlg"; back.dataset.k = "journal";
    var box = el("div", "cdlg-box nw-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "jr-t");
    var now = ed ? new Date(ed.at || Date.now()) : new Date();
    box.appendChild(el("p", "jr-when", now.toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" }) + " · " + now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })));
    var sv0 = F.saved ? (state.journal || []).filter(function (y) { return y.id === F.saved; })[0] : null;
    var h = el("h2", null, sv0 ? "Saved to your journal." : ed ? "Edit your entry" : "Journal"); h.id = "jr-t"; box.appendChild(h);
    function close() { back.remove(); }
    if (sv0) {
      var card = el("div", "lg-saved"), ck = el("span", "lg-ck"); ck.innerHTML = CHECK_SVG; card.appendChild(ck);
      var ct = el("div", "lg-ct"); ct.appendChild(el("b", null, (sv0.tags || []).map(jrLabel).join(" · ") || "Entry saved"));
      ct.appendChild(el("p", "lg-prev", "“" + sv0.t.replace(/\s+/g, " ").slice(0, 160) + (sv0.t.length > 160 ? "…" : "") + "”"));
      ct.appendChild(el("small", null, "Only you can read it.")); card.appendChild(ct); box.appendChild(card);
      var smsg = el("p", "note", "");
      if (myPaul()) { var shp = el("button", "btn ghost", "Share this entry with my Paul"); shp.type = "button"; shp.addEventListener("click", function () { jrShare(sv0, smsg); }); box.appendChild(shp); box.appendChild(smsg); }
      var r = el("div", "cdlg-btns lg-sbtns"), more = el("button", "btn ghost", "+ Write another"), all = el("button", "btn ghost", "My journal"), dn = el("button", "btn", "Done"); more.type = all.type = dn.type = "button";
      more.addEventListener("click", function () { openJournal({ fresh: true }); });
      all.addEventListener("click", function () { F.saved = ""; close(); go("journal"); });
      dn.addEventListener("click", function () { F.saved = ""; close(); });
      r.appendChild(more); r.appendChild(all); r.appendChild(dn); box.appendChild(r);
    } else {
      var pv = el("p", "jr-priv"); pv.textContent = "🔒︎ Private. Only you can read your journal. It is never scored."; box.appendChild(pv);
      if (ed && ed.p) box.appendChild(el("blockquote", "mem-v lg-p", ed.p));
      var chips = el("div", "lg-chips"); chips.setAttribute("role", "group"); chips.setAttribute("aria-label", "Tags");
      JR_TAGS.forEach(function (tg) { var on = F.tags.indexOf(tg[0]) >= 0, c = el("button", "mini" + (on ? " on" : ""), tg[1]); c.type = "button"; c.setAttribute("aria-pressed", on ? "true" : "false");
        c.addEventListener("click", function () { var i = F.tags.indexOf(tg[0]); if (i >= 0) F.tags.splice(i, 1); else F.tags.push(tg[0]); var on2 = i < 0; c.classList.toggle("on", on2); c.setAttribute("aria-pressed", on2 ? "true" : "false"); }); chips.appendChild(c); });
      box.appendChild(chips);
      var ta = el("textarea", "field jr-ta"); ta.rows = 7; ta.maxLength = 4000; ta.placeholder = "What happened? What is God showing you?"; ta.setAttribute("aria-label", "Your journal entry"); ta.value = F.t;
      ta.addEventListener("input", function () { F.t = ta.value; }); box.appendChild(ta);
      box.appendChild(el("p", "note jr-tip", "Tip: tap the microphone on your keyboard to talk instead of type."));
      var msg = el("p", "note", ""), row = el("div", "cdlg-btns"), sv = el("button", "btn", ed ? "Save changes" : "Save"), cx = el("button", "btn ghost", "Cancel"); sv.type = cx.type = "button";
      sv.addEventListener("click", function () {
        var v = ta.value.trim(); if (!v) { msg.textContent = "Write something first."; return; }
        var x = ed ? Object.assign({}, ed, { t: v, tags: F.tags.slice(), edited: Date.now() }) : { id: "j" + Date.now().toString(36), d: todayKey(), at: Date.now(), t: v, tags: F.tags.slice(), src: "pen" };
        if (x.ans && x.tags.indexOf("prayer") < 0) delete x.ans;
        jrSave(x); F.saved = x.id; F.edit = ""; F.t = ""; F.tags = []; openJournal();
      });
      cx.addEventListener("click", function () { F.edit = ""; F.t = ""; F.tags = []; close(); });
      row.appendChild(sv); row.appendChild(cx); box.appendChild(row); box.appendChild(msg);
      if (ed) {
        var smsg2 = el("p", "note", "");
        if (myPaul()) { var sh2 = el("button", "btn ghost", "Share this entry with my Paul"); sh2.type = "button"; sh2.addEventListener("click", function () { jrShare(Object.assign({}, ed, { t: ta.value.trim() || ed.t }), smsg2); }); box.appendChild(sh2); box.appendChild(smsg2); }
        var del = el("button", "linkish", "Delete this entry"); del.type = "button";
        del.addEventListener("click", function () {
          if (del.dataset.sure) { jrDelete(ed.id); F.edit = ""; F.t = ""; F.tags = []; close(); return; }
          del.dataset.sure = "1"; del.textContent = "Tap again to delete for good";
        });
        box.appendChild(del);
      }
    }
    back.appendChild(box); back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); close(); } }); document.body.appendChild(back);
    h.tabIndex = -1; try { h.focus({ preventScroll: true }); } catch (e) {} box.scrollTop = 0;
  }
  function drawJournalDevo(t) {
    var q = $("jr-devo-q"); if (!q) return; q.textContent = t.e.reflect || "";
    var k = todayKey(), done = journalSorted().filter(function (x) { return x.d === k && x.src === "devo"; })[0], m = $("jr-devo-msg");
    if (done && !$("jr-devo-ta").value) m.textContent = "✓ Saved to your journal today. Write more any time.";
  }
  function wireJournal() {
    Array.prototype.forEach.call(document.querySelectorAll(".me-btn"), function (mb) {
      if (mb.previousElementSibling && mb.previousElementSibling.classList.contains("jr-pen")) return;
      var pen = el("button", "jr-pen"); pen.type = "button"; pen.setAttribute("aria-label", "New journal entry"); pen.innerHTML = PEN_SVG;
      pen.addEventListener("click", function () { openJournal({ fresh: true }); });
      var par = mb.parentNode;
      if (par.classList.contains("right") || par.classList.contains("jr-hd") || par.classList.contains("help-right")) par.insertBefore(pen, mb);
      else { var w = el("span", "jr-hd"); par.insertBefore(w, mb); w.appendChild(pen); w.appendChild(mb); }
    });
    $("jr-back").addEventListener("click", function () { go("today"); });
    $("jr-new").innerHTML = PEN_SVG; $("jr-new").addEventListener("click", function () { openJournal({ fresh: true }); });
    $("jr-devo-save").addEventListener("click", function () {
      var ta = $("jr-devo-ta"), v = ta.value.trim(), m = $("jr-devo-msg"); if (!v) { m.textContent = "Write something first."; ta.focus(); return; }
      var t = devoToday(), x = { id: "j" + Date.now().toString(36), d: todayKey(), at: Date.now(), t: v, tags: [], src: "devo", p: t && t.e ? t.e.reflect : "" };
      jrSave(x); ta.value = ""; m.textContent = "✓ Saved to your journal. Only you can read it.";
    });
  }
  var jrUI = { tab: "all", q: "" };
  function drawJournalPage() {
    var body = $("jr-body"); if (!body) return;
    var hadFocus = document.activeElement && document.activeElement.id === "jr-q", caret = hadFocus ? document.activeElement.selectionStart : 0;
    body.textContent = "";
    var all = journalSorted(), prayers = all.filter(function (x) { return x.ans; });
    var tabs = el("div", "jr-tabs"); tabs.setAttribute("role", "tablist");
    [["all", "Entries"], ["ans", "Answered prayers · " + prayers.length]].forEach(function (tb) { var b = el("button", null, tb[1]); b.type = "button"; b.setAttribute("role", "tab"); b.setAttribute("aria-selected", jrUI.tab === tb[0] ? "true" : "false");
      b.addEventListener("click", function () { jrUI.tab = tb[0]; drawJournalPage(); }); tabs.appendChild(b); });
    body.appendChild(tabs);
    var q = el("input", "field jr-search"); q.id = "jr-q"; q.type = "search"; q.placeholder = "Search your journal"; q.setAttribute("aria-label", "Search your journal"); q.value = jrUI.q;
    q.addEventListener("input", function () { jrUI.q = q.value; drawJournalPage(); }); body.appendChild(q);
    var ql = jrUI.q.trim().toLowerCase();
    if (jrUI.tab === "all" && !ql) {
      var t = new Date(todayKey() + "T12:00:00"), m1 = new Date(t), y1 = new Date(t); m1.setMonth(m1.getMonth() - 1); y1.setFullYear(y1.getFullYear() - 1);
      var otd = null, lbl = "";
      [[y1, "One year ago"], [m1, "One month ago"]].some(function (c) { var k = dateKeyLocal(c[0]), hit = all.filter(function (x) { return x.d === k; })[0]; if (hit) { otd = hit; lbl = c[1] + " · " + c[0].toLocaleDateString(undefined, { month: "short", day: "numeric" }); } return !!hit; });
      if (otd) { var ob = el("button", "jr-otd"); ob.type = "button"; ob.appendChild(el("span", "jr-when", "On this day · " + lbl)); ob.appendChild(el("p", null, "“" + otd.t.replace(/\s+/g, " ").slice(0, 180) + (otd.t.length > 180 ? "…" : "") + "”"));
        ob.addEventListener("click", function () { openJournal({ edit: otd.id }); }); body.appendChild(ob); }
    }
    var rows = (jrUI.tab === "ans" ? prayers : all).filter(function (x) { if (!ql) return true; return (x.t + " " + (x.p || "") + " " + (x.tags || []).map(jrLabel).join(" ")).toLowerCase().indexOf(ql) >= 0; });
    if (!rows.length) {
      body.appendChild(el("p", "jr-empty", ql ? "Nothing matches “" + jrUI.q.trim() + "”." : jrUI.tab === "ans" ? "When God answers a prayer you wrote down, mark it answered and it will be kept here." : "Nothing written yet. Tap the pen at the top of any page to start."));
    } else {
      var ul = el("ul", "jr-list");
      rows.forEach(function (x) {
        var li = el("li", "jr-it"), ob2 = el("button", "jr-open"); ob2.type = "button";
        ob2.appendChild(el("span", "jr-when", jrWhen(x)));
        var txt = x.t.length > 220 ? x.t.slice(0, 220) + "…" : x.t; ob2.appendChild(el("p", null, txt));
        ob2.setAttribute("aria-label", "Open entry from " + jrWhen(x)); ob2.addEventListener("click", function () { openJournal({ edit: x.id }); }); li.appendChild(ob2);
        var tg = el("div", "jr-tags"); (x.tags || []).forEach(function (k) { tg.appendChild(el("span", "jr-tg", jrLabel(k))); });
        if (x.ans) tg.appendChild(el("span", "jr-tg ans", "✓ Answered " + new Date(x.ans).toLocaleDateString(undefined, { month: "short", day: "numeric" })));
        if ((x.tags || []).indexOf("prayer") >= 0) { var ab = el("button", "mini", x.ans ? "Undo answered" : "Mark answered"); ab.type = "button";
          ab.addEventListener("click", function () { var y = Object.assign({}, x); if (y.ans) delete y.ans; else y.ans = Date.now(); jrSave(y); }); tg.appendChild(ab); }
        if (tg.childNodes.length) li.appendChild(tg);
        ul.appendChild(li);
      });
      body.appendChild(ul);
    }
    if (hadFocus) { var q2 = $("jr-q"); q2.focus(); try { q2.setSelectionRange(caret, caret); } catch (e) {} }
  }
'''
rep('''  function openMentorInfo() {''', JS + '''  function openMentorInfo() {''')

# Markdown export section
s2 = s
m = re.search(r'  function exportMd\(D\) \{\n', s)
assert m
# add journal section before the final return of exportMd
i = s.index('return L.join', m.end())
s = s[:i] + '''if ((D.journal || []).length) { L.push("", "## Journal", ""); D.journal.forEach(function (j) { L.push("### " + j.date + ((j.tags || []).length ? " \\u00B7 " + j.tags.map(jrLabel).join(", ") : "") + (j.answered ? " \\u00B7 Answered " + dateKeyLocal(new Date(j.answered)) : ""), ""); if (j.prompt) L.push("> " + j.prompt, ""); L.push(j.text, ""); }); }
    ''' + s[i:]

# wire on start
rep('''    $("bd-ind").addEventListener("click",''', '''    wireJournal();
    $("bd-ind").addEventListener("click",''')


# ---------- Startup tour, onboarding and info bubbles (Curtis 2026-11-04) ----------
rep('''      "Your streak counts days in a row with every daily box checked.",''', '''      "Your streak counts days in a row with every daily box checked.",
      "Journal: tap the pen at the top of any page to write a quick entry. Private, and never scored. The Journal row shows Done once you write today.",''')
rep('''    settings: { t: "Settings", why:''', '''    journal: { t: "My journal", why: "A private place to write what God is doing in your life, and to remember it later. Only you can read it. It is never scored.", how: [
      "Tap the pen at the top of any page to write. Pick a tag if it helps: Grateful, Prayer, Win, Struggle or God showed me.",
      "At the end of the devotional, Write it down starts an entry with that day\\u2019s reflection question.",
      "Tap an entry to read it, edit it or delete it.",
      "Tag a prayer, then tap Mark answered when God answers it. Answered prayers keeps them all in one place.",
      "On this day shows what you wrote one month or one year ago.",
      "Search finds entries by word or tag.",
      "Share this entry with my Paul sends it in a text from your phone. The app never shares it for you.",
      "Download my data in Settings includes your journal."] },
    settings: { t: "Settings", why:''')
rep('''    ["fuel", "Fuel", ["Log meals with search, photo, voice or favorites.",''', '''    ["journal", "Journal", ["Tap the pen at the top of any page to write a quick entry. Only you can read it.", "Tag prayers and mark them answered. Look back with search and On this day.", "Write it down at the end of the devotional starts with that day\\u2019s question. No points, just you and God."]],
    ["fuel", "Fuel", ["Log meals with search, photo, voice or favorites.",''')
rep('''       ["Board and Rally", "Kingdom Warrior points, top lifts, and the group thread.",''', '''       ["Journal", "A private place to write what God is doing. Tap the pen at the top of any page.", '<path d="M4 20h4L19 9l-4-4L4 16v4z"/><path d="M13.5 6.5l4 4"/>'],
       ["Board and Rally", "Kingdom Warrior points, top lifts, and the group thread.",''')
rep('''"k": "legacy journal letter write kids wife son daughter",''', '''"k": "legacy letter write kids wife son daughter",''')
rep('''"go": {"fn": "legacy"}}''', '''"go": {"fn": "legacy"}}, {"t": "Write in my journal", "a": "Tap the pen at the top of any page. Pick a tag if it helps, write, and tap Save. Only you can read it. It is never scored.", "w": "The pen at the top of any page \\u00B7 Today \\u203A Journal", "k": "journal write entry diary notes pen private reflect thoughts", "go": {"p": "journal"}}, {"t": "Answered prayers", "a": "Tag an entry Prayer. When God answers it, open My journal and tap Mark answered. The Answered prayers tab keeps them together.", "w": "My journal \\u203A Answered prayers", "k": "prayer prayers answered request journal pray", "go": {"p": "journal"}}''')

rep('record: "pr", journal: "legacy", ', 'record: "pr", diary: "journal", ')
rep('"k": "note notes lift journal remember sleep felt"', '"k": "note notes lift remember sleep felt"')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s)
print("ok", dst)
