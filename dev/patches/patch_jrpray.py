#!/usr/bin/env python3
"""Journal prayers made obvious (Curtis 2026-11-05).
- Tapping Prayer shows: "Tagged as a prayer. When God answers it, mark it answered in My journal."
- Writing that starts like a prayer ("Pray for", "Lord", "Father", "Jesus", "God, ...") without the tag shows
  "Tag this as a prayer?" One tap adds the tag; nothing is tagged automatically.
- Saved card for a prayer says how it works and adds "See my prayers".
- My journal tabs: Entries, Praying for (open prayers with Mark answered), Answered.
- Opening a prayer entry shows Mark answered / Undo answered right in the entry.
Usage: patch_jrpray.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

rep('''.jr-tabs { display: grid; grid-template-columns: 1fr 1fr;''', '''.jr-ph { margin: -2px 0 8px; padding: 8px 10px; border-left: 3px solid var(--accent); background: var(--surface); font-size: 13.5px; line-height: 1.4; }
.jr-sug { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin: 6px 0 0; padding: 8px 10px; border: 1px dashed var(--accent); border-radius: 8px; font-size: 13.5px; }
.jr-sug .mini { min-height: 32px; flex: none; }
.jr-ansbar { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin: 0 0 8px; padding: 8px 10px; border: 1px solid var(--accent); border-radius: 8px; font-size: 13.5px; }
.jr-ansbar.done { background: color-mix(in srgb, var(--accent) 12%, transparent); }
.jr-ansbar .mini { min-height: 34px; flex: none; }
.jr-tabs button { font-size: 12.5px !important; line-height: 1.15; }
.jr-tabs { display: grid; grid-template-columns: 1fr 1fr 1fr;''')

# --- entry sheet: prayer hint, suggestion, mark answered in the entry ---
rep('''      box.appendChild(chips);
      var ta = el("textarea", "field jr-ta");''', '''      box.appendChild(chips);
      var ph = el("p", "jr-ph", "\\uD83D\\uDE4F\\uFE0E Tagged as a prayer. When God answers it, mark it answered in My journal \\u203A Praying for."); box.appendChild(ph);
      if (ed && (ed.tags || []).indexOf("prayer") >= 0) {
        var abar = el("div", "jr-ansbar" + (ed.ans ? " done" : "")), atx = el("span", null, ed.ans ? "\\u2713 Answered " + new Date(ed.ans).toLocaleDateString(undefined, { month: "short", day: "numeric" }) + ". Praise God." : "Still praying for this?");
        var ab2 = el("button", "mini" + (ed.ans ? "" : " on"), ed.ans ? "Undo" : "Mark answered"); ab2.type = "button";
        ab2.addEventListener("click", function () { var y = Object.assign({}, ed); if (y.ans) delete y.ans; else y.ans = Date.now(); jrSave(y); F.t = ta.value; openJournal({ edit: y.id, keep: true }); });
        abar.appendChild(atx); abar.appendChild(ab2); box.appendChild(abar);
      }
      var ta = el("textarea", "field jr-ta");''')
rep('''      ta.addEventListener("input", function () { F.t = ta.value; }); box.appendChild(ta);''', '''      var sug = el("div", "jr-sug"), sgb = el("button", "mini on", "Tag as prayer"); sgb.type = "button"; sug.appendChild(el("span", null, "This sounds like a prayer. Tag it so you can mark it answered later.")); sug.appendChild(sgb);
      var PRAY_RX = /^\\s*(pray(ing)?\\s+for|please\\s+pray|lord\\b|father\\b|jesus\\b|god,|dear\\s+(god|lord|jesus))|\\bpray(ing)?\\s+for\\b/i;
      function updPray() {
        var on = F.tags.indexOf("prayer") >= 0; ph.hidden = !on;
        sug.hidden = on || !!sug.dataset.no || !PRAY_RX.test(ta.value || "");
      }
      sgb.addEventListener("click", function () { if (F.tags.indexOf("prayer") < 0) F.tags.push("prayer"); Array.prototype.forEach.call(chips.children, function (c, i) { if (JR_TAGS[i][0] === "prayer") { c.classList.add("on"); c.setAttribute("aria-pressed", "true"); } }); updPray(); });
      chips.addEventListener("click", function () { setTimeout(updPray, 0); });
      ta.addEventListener("input", function () { F.t = ta.value; updPray(); }); box.appendChild(ta); box.appendChild(sug); updPray();''')
# keep edits when re-opening after Mark answered from inside the entry
rep('''    if (opts.edit !== undefined || opts.fresh) { F.edit = opts.edit || ""; F.saved = ""; var e0 = F.edit ? (state.journal || []).filter(function (y) { return y.id === F.edit; })[0] : null; F.t = e0 ? e0.t : "";''',
    '''    if (opts.edit !== undefined || opts.fresh) { var keepT = opts.keep ? F.t : null, keepTags = opts.keep ? (F.tags || []).slice() : null; F.edit = opts.edit || ""; F.saved = ""; var e0 = F.edit ? (state.journal || []).filter(function (y) { return y.id === F.edit; })[0] : null; F.t = keepT != null ? keepT : e0 ? e0.t : "";''')
rep('''F.tags = e0 ? (e0.tags || []).slice() : (opts.tags || []).slice();''', '''F.tags = keepTags ? keepTags : e0 ? (e0.tags || []).slice() : (opts.tags || []).slice();''')
# saved card: prayer explanation + See my prayers
rep('''      ct.appendChild(el("small", null, "Only you can read it.")); card.appendChild(ct); box.appendChild(card);''', '''      ct.appendChild(el("small", null, "Only you can read it.")); card.appendChild(ct); box.appendChild(card);
      if ((sv0.tags || []).indexOf("prayer") >= 0) {
        var pp = el("p", "jr-ph", "\\uD83D\\uDE4F\\uFE0E Saved to Praying for. When God answers it, open it and tap Mark answered. It moves to Answered so you can look back on what He has done."); box.appendChild(pp);
        var sp = el("button", "btn ghost", "See my prayers"); sp.type = "button"; sp.addEventListener("click", function () { F.saved = ""; close(); jrUI.tab = "pray"; jrUI.q = ""; go("journal"); }); box.appendChild(sp);
      }''')
# --- page: three tabs ---
rep('''    var all = journalSorted(), prayers = all.filter(function (x) { return x.ans; });''', '''    var all = journalSorted(), prayers = all.filter(function (x) { return x.ans; }), open = all.filter(function (x) { return !x.ans && (x.tags || []).indexOf("prayer") >= 0; });''')
rep('''[["all", "Entries"], ["ans", "Answered prayers · " + prayers.length]]''', '''[["all", "Entries"], ["pray", "Praying for · " + open.length], ["ans", "Answered · " + prayers.length]]''')
rep('''    var rows = (jrUI.tab === "ans" ? prayers : all)''', '''    if (jrUI.tab === "pray" && !ql) body.appendChild(el("p", "jr-ph", "Entries tagged Prayer that God hasn\\u2019t answered yet. When He does, tap Mark answered."));
    var rows = (jrUI.tab === "ans" ? prayers : jrUI.tab === "pray" ? open : all)''')
rep('''jrUI.tab === "ans" ? "When God answers a prayer you wrote down, mark it answered and it will be k''', '''jrUI.tab === "pray" ? "No open prayers. When you write one, tap the Prayer tag and it will wait here until you mark it answered." : jrUI.tab === "ans" ? "When God answers a prayer you wrote down, mark it answered and it will be k''')
# help bubble line
rep('''      "Tag a prayer, then tap Mark answered when God answers it. Answered prayers keeps them all in one place.",''', '''      "Prayers: tap the Prayer tag when you write one. It waits in Praying for. When God answers it, tap Mark answered (in the list or inside the entry) and it moves to Answered.",
      "If what you write sounds like a prayer and isn\\u2019t tagged, the app asks if you want to tag it. Nothing is tagged without you.",''')
rep('''"t": "Answered prayers", "a": "Tag an entry Prayer. When God answers it, open My journal and tap Mark answered. The Answered prayers tab keeps them together.", "w": "My journal \\u203A Answered prayers"''', '''"t": "Answered prayers", "a": "When you write a prayer, tap the Prayer tag. It waits in My journal \\u203A Praying for. When God answers it, tap Mark answered in the list or inside the entry, and it moves to Answered.", "w": "My journal \\u203A Praying for \\u00B7 Answered"''')
# Profile: My journal button beside Settings (own profile only)
rep('''      <button class="mini prof-set" type="button" id="prof-gear">''', '''      <button class="mini prof-set" type="button" id="prof-jr"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 20h4L19 9l-4-4L4 16v4z"/><path d="M13.5 6.5l4 4"/></svg>Journal</button>
      <button class="mini prof-set" type="button" id="prof-gear">''')
rep('''    $("prof-gear").hidden = !own;''', '''    $("prof-gear").hidden = !own; $("prof-jr").hidden = !own;''')
rep('''    $("prof-gear").addEventListener("click", function () { go("settings"); });''', '''    $("prof-gear").addEventListener("click", function () { go("settings"); });
    $("prof-jr").addEventListener("click", function () { jrUI.tab = "all"; go("journal"); });''')
rep('''.prof-set{display:inline-flex;''', '''#page-profile .pbar{flex-wrap:nowrap;gap:6px}#page-profile .pbar .mini{min-width:0;padding:0 8px;letter-spacing:.05em;font-size:12px}#page-profile .pbar .help-right{gap:6px}#prof-jr{margin-left:auto}
.prof-set{display:inline-flex;''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
