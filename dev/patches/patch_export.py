#!/usr/bin/env python3
"""Download my data: Settings card where a brother downloads his own data once a day as JSON (complete), CSV
(daily points, workouts, food, weigh-ins, PRs) and/or Markdown (readable summary). One format = one file; more than
one = a single .zip. Photos are not included (a list of photo dates is). Only his own data: other brothers' posts and
team chat stay out. The once-a-day limit is stored as settings.lastExport (enforced on the device for now; Firebase
should enforce it server-side). Approved by Curtis 2026-11-01.
Usage: patch_export.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

JS = r'''
  /* ---------- Download my data (once a day): JSON, CSV, Markdown. ---------- */
  var EXPORT_GAP = 24 * 3600 * 1000, expFmt = { json: true, csv: true, md: true }, expBusy = false, expMsg = "";
  function expNextAt() { var t = Number(state.settings && state.settings.lastExport) || 0; return t ? t + EXPORT_GAP : 0; }
  function expTimeText(t) { var d = new Date(t), today = new Date(), tm = d.toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit" }); var sameDay = d.toDateString() === today.toDateString(); var tmr = new Date(today.getTime() + 86400000).toDateString() === d.toDateString(); return (sameDay ? "today" : tmr ? "tomorrow" : d.toLocaleDateString(undefined, { month: "short", day: "numeric" })) + " at " + tm; }
  function onceSnap(q) { return new Promise(function (res) { var done = false, un = null; try { un = q.onSnapshot(function (s) { if (done) return; done = true; res(s.docs ? s.docs.map(function (d) { var x = d.data() || {}; x._id = d.id; return x; }) : []); setTimeout(function () { try { un && un(); } catch (e) {} }, 0); }, function () { if (!done) { done = true; res([]); } }); } catch (e) { res([]); } setTimeout(function () { if (!done) { done = true; res([]); } }, 15000); }); }
  function csvCell(v) { v = v === null || v === undefined ? "" : String(v); return /[",\n\r]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v; }
  function csvOf(head, rows) { return [head].concat(rows).map(function (r) { return r.map(csvCell).join(","); }).join("\r\n") + "\r\n"; }
  var CRC_T = null;
  function crc32(u8) { if (!CRC_T) { CRC_T = []; for (var n = 0; n < 256; n++) { var c = n; for (var k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; CRC_T[n] = c >>> 0; } } var crc = 0xFFFFFFFF; for (var i = 0; i < u8.length; i++) crc = CRC_T[(crc ^ u8[i]) & 255] ^ (crc >>> 8); return (crc ^ 0xFFFFFFFF) >>> 0; }
  // A plain "stored" zip (no compression): small, dependable, opens on every phone and computer.
  function zipOf(files) {
    var enc = new TextEncoder(), parts = [], central = [], off = 0, d = new Date();
    var dt = ((d.getHours() << 11) | (d.getMinutes() << 5) | (d.getSeconds() >> 1)) & 0xFFFF, dd = (((d.getFullYear() - 1980) << 9) | ((d.getMonth() + 1) << 5) | d.getDate()) & 0xFFFF;
    files.forEach(function (f) {
      var name = enc.encode(f.name), data = enc.encode(f.text), crc = crc32(data);
      var h = new DataView(new ArrayBuffer(30)); h.setUint32(0, 0x04034b50, true); h.setUint16(4, 20, true); h.setUint16(6, 0x0800, true); h.setUint16(8, 0, true); h.setUint16(10, dt, true); h.setUint16(12, dd, true); h.setUint32(14, crc, true); h.setUint32(18, data.length, true); h.setUint32(22, data.length, true); h.setUint16(26, name.length, true); h.setUint16(28, 0, true);
      parts.push(new Uint8Array(h.buffer), name, data);
      var c = new DataView(new ArrayBuffer(46)); c.setUint32(0, 0x02014b50, true); c.setUint16(4, 20, true); c.setUint16(6, 20, true); c.setUint16(8, 0x0800, true); c.setUint16(10, 0, true); c.setUint16(12, dt, true); c.setUint16(14, dd, true); c.setUint32(16, crc, true); c.setUint32(20, data.length, true); c.setUint32(24, data.length, true); c.setUint16(28, name.length, true); c.setUint32(42, off, true);
      central.push(new Uint8Array(c.buffer), name); off += 30 + name.length + data.length;
    });
    var csize = central.reduce(function (a, b) { return a + b.length; }, 0), e = new DataView(new ArrayBuffer(22));
    e.setUint32(0, 0x06054b50, true); e.setUint16(8, files.length, true); e.setUint16(10, files.length, true); e.setUint32(12, csize, true); e.setUint32(16, off, true);
    return new Blob(parts.concat(central, [new Uint8Array(e.buffer)]), { type: "application/zip" });
  }
  async function gatherExport() {
    var me = state.me, db = B.db, logRef = db.doc("data/users/" + me + "/log");
    var checks = await onceSnap(db.collection("checkins").where("uid", "==", me));
    if (!checks.length) checks = (await onceSnap(db.collection("checkins").where("date", ">=", "2000-01-01"))).filter(function (c) { return c.uid === me; });
    var days = await onceSnap(logRef.collection("days"));
    var wks = []; try { wks = await B.listWorkouts(me); } catch (e) { wks = []; }
    var prof = (state.pubProfiles || {})[me] || {}, lifts = state.lifts || [];
    var team = null; try { var t = myTeam && myTeam(); if (t) team = { name: t.name, campaign: (campCfg() || {}).n || 1 }; } catch (e) {}
    return {
      exportedAt: new Date().toISOString(), app: "Forged & Sent", version: APP_VERSION,
      profile: { name: nameOf(me), handle: prof.handle || "", motto: prof.motto || "", invitedBy: prof.invitedBy ? nameOf(prof.invitedBy) : "" },
      agreement: state.settings.agreed || null,
      settings: Object.assign({}, state.settings, { lastExport: undefined }),
      checkins: checks.map(function (c) { delete c._id; return c; }).sort(function (a, b) { return a.date < b.date ? -1 : 1; }),
      food: days.map(function (d) { var k = d.date || d._id; delete d._id; d.date = k; return d; }).sort(function (a, b) { return a.date < b.date ? -1 : 1; }),
      workouts: wks.slice().sort(function (a, b) { return a.date < b.date ? -1 : 1; }),
      weighIns: state.weights || {},
      prs: Object.keys(prof.prs || {}).map(function (id) { var l = lifts.filter(function (x) { return x.id === id; })[0]; var p = prof.prs[id] || {}; return { lift: l ? l.name : id, weight: Number(p.w) || 0, reps: Number(p.reps) || 0, date: p.date || "" }; }).filter(function (x) { return x.weight > 0; }),
      habits: state.habits || {},
      liftNotes: state.liftNotes || {},
      progressPhotoDates: (state.progress || []).map(function (x) { return x.date; }).sort(),
      posts: (state.posts || []).filter(function (p) { return p.uid === me; }).map(function (p) { return { createdAt: p.createdAt, text: p.text || "", photos: (p.media || p.photos || []).length || (p.photo ? 1 : 0) }; }),
      team: team
    };
  }
  function exportCsvs(D) {
    var taskName = {}; (state.tasks || []).forEach(function (t) { taskName[t.id] = t.title; });
    var out = [];
    out.push({ name: "daily.csv", text: csvOf(["date", "points", "boxes_checked", "steps", "protein_bonus", "prs"], D.checkins.map(function (c) { var rec = { done: c.done || {}, prs: normPrs(c.prs), steps: normSteps(c.steps), pbonus: !!c.pbonus, obonus: !!c.obonus, date: c.date, uid: state.me }; var pts = 0; try { pts = pointsOf(rec); } catch (e) {} return [c.date, Math.round(pts * 10) / 10, Object.keys(c.done || {}).filter(function (k) { return c.done[k]; }).map(function (k) { return taskName[k] || k; }).join("; "), rec.steps || "", rec.pbonus ? "yes" : "", rec.prs.n || ""]; })) });
    var wr = [];
    D.workouts.forEach(function (w) { var root = normWk(w, w.date); var es = []; try { es = exEntriesOf(root, w.date); } catch (e) {} es.forEach(function (e) { (e[2] || []).forEach(function (st, i) { if (!st || (!st.r && !st.w)) return; wr.push([w.date, moveName(e[0]), i + 1, st.k === "w" ? "warm-up" : st.k === "x" ? "added" : "working", st.r || "", st.w || "", st.d ? "yes" : ""]); }); }); });
    out.push({ name: "workouts.csv", text: csvOf(["date", "exercise", "set", "type", "reps", "weight_lb", "checked_off"], wr) });
    var fr = [];
    D.food.forEach(function (d) { MEALS.forEach(function (m) { ((d.meals || {})[m.k] || []).forEach(function (e) { fr.push([d.date, m.label, e.name || "", e.n || 1, Math.round(Number(e.kcal) || 0), Math.round(Number(e.p) || 0), Math.round(Number(e.c) || 0), Math.round(Number(e.f) || 0)]); }); }); });
    out.push({ name: "food.csv", text: csvOf(["date", "meal", "food", "servings", "calories", "protein_g", "carbs_g", "fat_g"], fr) });
    out.push({ name: "weigh-ins.csv", text: csvOf(["date", "weight_lb"], Object.keys(D.weighIns).sort().map(function (k) { return [k, D.weighIns[k]]; })) });
    out.push({ name: "prs.csv", text: csvOf(["lift", "weight_lb", "reps", "date"], D.prs.map(function (p) { return [p.lift, p.weight, p.reps, p.date]; })) });
    return out;
  }
  function exportMd(D) {
    var L = [], pts = 0, wkDone = D.workouts.filter(function (w) { return Number(w.finishedAt) > 0; });
    D.checkins.forEach(function (c) { try { pts += pointsOf({ done: c.done || {}, prs: normPrs(c.prs), steps: normSteps(c.steps), pbonus: !!c.pbonus, obonus: !!c.obonus, date: c.date, uid: state.me }); } catch (e) {} });
    L.push("# Forged & Sent: " + D.profile.name, "", "Exported " + new Date(D.exportedAt).toLocaleString() + ".", "");
    L.push("## At a glance", "", "| | |", "| --- | --- |", "| Days checked in | " + D.checkins.length + " |", "| Kingdom Warrior points | " + Math.round(pts) + " |", "| Workouts finished | " + wkDone.length + " |", "| Days with food logged | " + D.food.length + " |");
    var wk = Object.keys(D.weighIns).sort(); if (wk.length) L.push("| Weight | " + D.weighIns[wk[0]] + " lb (" + wk[0] + ") to " + D.weighIns[wk[wk.length - 1]] + " lb (" + wk[wk.length - 1] + ") |");
    if (D.team) L.push("| Campaign team | " + D.team.name + " |");
    L.push("");
    if (D.prs.length) { L.push("## Personal records", "", "| Lift | Weight | Reps | Date |", "| --- | --- | --- | --- |"); D.prs.forEach(function (p) { L.push("| " + p.lift + " | " + p.weight + " lb | " + (p.reps || "") + " | " + p.date + " |"); }); L.push(""); }
    var recent = wkDone.slice(-10).reverse();
    if (recent.length) {
      L.push("## Recent workouts", "");
      recent.forEach(function (w) { var root = normWk(w, w.date), es = []; try { es = exEntriesOf(root, w.date); } catch (e) {}
        L.push("### " + longDate(w.date)); es.forEach(function (e) { var work = (e[2] || []).filter(function (st) { return st && !st.k && Number(st.r) > 0; }); if (!work.length) return; L.push("- " + moveName(e[0]) + ": " + work.map(function (st) { return (st.w ? st.w + " × " : "") + st.r; }).join(", ")); }); L.push(""); });
    }
    if (D.posts.length) { L.push("## Your Rally posts", ""); D.posts.slice().sort(function (a, b) { return b.createdAt - a.createdAt; }).slice(0, 20).forEach(function (p) { L.push("- " + new Date(p.createdAt).toLocaleDateString() + ": " + String(p.text).replace(/\s+/g, " ").slice(0, 200)); }); L.push(""); }
    L.push("Photos are not included. The JSON file lists your progress photo dates.");
    return L.join("\n") + "\n";
  }
  async function runExport() {
    if (expBusy || !state.me || !B.db) return;
    var next = expNextAt(); if (next && Date.now() < next) return;
    var fmts = ["json", "csv", "md"].filter(function (k) { return expFmt[k]; }); if (!fmts.length) return;
    expBusy = true; expMsg = "Gathering your data…"; drawExportSettings();
    try {
      var D = await gatherExport(), stamp = todayKey(), files = [];
      if (expFmt.json) files.push({ name: "forged-and-sent-data.json", text: JSON.stringify(D, null, 2) });
      if (expFmt.csv) exportCsvs(D).forEach(function (f) { files.push({ name: "csv/" + f.name, text: f.text }); });
      if (expFmt.md) files.push({ name: "forged-and-sent-summary.md", text: exportMd(D) });
      var blob, fn;
      if (fmts.length === 1 && fmts[0] !== "csv") { blob = new Blob([files[0].text], { type: fmts[0] === "json" ? "application/json" : "text/markdown" }); fn = "forged-and-sent-" + stamp + (fmts[0] === "json" ? ".json" : ".md"); }
      else { blob = zipOf(files); fn = "forged-and-sent-" + stamp + ".zip"; }
      if (B.downloads) await B.downloads.save({ filename: fn, data: blob });
      else { var a = document.createElement("a"); a.href = URL.createObjectURL(blob); a.download = fn; document.body.appendChild(a); a.click(); setTimeout(function () { URL.revokeObjectURL(a.href); a.remove(); }, 1000); }
      state.settings.lastExport = Date.now(); saveSettings();
      expMsg = "✓ Saved " + fn + ".";
    } catch (e) { expMsg = "That didn’t download. Check your connection and try again. It won’t count toward today."; }
    expBusy = false; drawExportSettings();
  }
  function drawExportSettings() {
    var box = $("export-body"); if (!box) return; box.textContent = "";
    box.appendChild(el("p", "note", "Everything you’ve logged: check-ins, points, workouts and sets, food, weigh-ins, PRs and your Rally posts. Photos aren’t included."));
    var g = el("div", "exp-fmts");
    [["json", "JSON", "Complete copy. Best for backups."], ["csv", "CSV", "Spreadsheets: daily, workouts, food, weigh-ins, PRs."], ["md", "Markdown", "Readable summary to print or share."]].forEach(function (f) {
      var lab = el("label", "exp-f" + (expFmt[f[0]] ? " on" : "")), cb = el("input"); cb.type = "checkbox"; cb.checked = !!expFmt[f[0]]; cb.disabled = expBusy;
      cb.addEventListener("change", function () { expFmt[f[0]] = cb.checked; drawExportSettings(); });
      var tx = el("span"); tx.appendChild(el("b", null, f[1])); tx.appendChild(el("small", null, f[2])); lab.appendChild(cb); lab.appendChild(tx); g.appendChild(lab);
    });
    box.appendChild(g);
    var n = ["json", "csv", "md"].filter(function (k) { return expFmt[k]; }).length, next = expNextAt(), wait = next && Date.now() < next;
    var b = el("button", "btn exp-go", expBusy ? "Preparing…" : wait ? "Next download " + expTimeText(next) : n > 1 || expFmt.csv ? "Download (.zip)" : "Download"); b.type = "button";
    b.disabled = expBusy || wait || !n || !state.me || !B.db; b.addEventListener("click", runExport); box.appendChild(b);
    var last = Number(state.settings && state.settings.lastExport) || 0;
    box.appendChild(el("p", "fnote", (expMsg ? expMsg + " " : "") + (last ? "Last download " + expTimeText(last) + ". " : "") + "One download a day. Only your own data is included, never other brothers’ posts or team chat."));
  }
'''
rep('''  function drawSettings() {''', JS + '''  function drawSettings() {
    drawExportSettings();''')
rep('''agreed: st && st.agreed && typeof st.agreed === "object" ? { v: String(st.agreed.v || ""), at: Number(st.agreed.at) || 0 } : null }; if (state.settings.theme)''',
    '''agreed: st && st.agreed && typeof st.agreed === "object" ? { v: String(st.agreed.v || ""), at: Number(st.agreed.at) || 0 } : null, lastExport: Number(st && st.lastExport) || 0 }; if (state.settings.theme)''')
rep('''agreed: state.settings.agreed || null }''', '''agreed: state.settings.agreed || null, lastExport: Number(state.settings.lastExport) || 0 }''')
rep('''    <section aria-labelledby="h-s-legal">''', '''    <section aria-labelledby="h-s-export">
      <div class="section-head"><h2 class="label-caps" id="h-s-export" data-sub="Save a copy of everything you’ve logged. Once a day.">Download my data</h2></div>
      <div id="export-body"></div>
    </section>

    <section aria-labelledby="h-s-legal">'''.replace("\\u2019", "’"))
rep('''"h-s-test", "h-s-legal", "h-s-acct"].forEach''', '''"h-s-test", "h-s-export", "h-s-legal", "h-s-acct"].forEach''')
rep('''.safe-line { margin: 8px 0 0;''', '''.exp-fmts { display: grid; gap: 8px; margin: 4px 0 10px; }
.exp-f { display: grid; grid-template-columns: 24px 1fr; gap: 10px; align-items: center; padding: 10px 12px; border: 1px solid var(--line); border-radius: 8px; background: var(--surface); cursor: pointer; }
.exp-f.on { border-color: var(--accent); }
.exp-f input { width: 22px; height: 22px; margin: 0; accent-color: var(--accent); }
.exp-f span { display: grid; gap: 1px; } .exp-f b { font-family: var(--f-label); font-weight: 800; letter-spacing: .08em; text-transform: uppercase; font-size: 15px; } .exp-f small { font-size: 13px; color: var(--muted); }
.exp-go { width: 100%; }
.safe-line { margin: 8px 0 0;''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
