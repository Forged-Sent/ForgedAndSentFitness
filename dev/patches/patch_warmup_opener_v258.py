import sys
S = ''  # set to the folder that holds v257/app-v257.html and v258/add3.js
src = open(S + 'v257/app-v257.html', encoding='utf-8').read()
add = open(S + 'v258/add3.js', encoding='utf-8').read()
def rep(old, new, count=1):
    global src
    n = src.count(old)
    if n != count: sys.exit('expected %d, found %d: %r' % (count, n, old[:90]))
    src = src.replace(old, new)
rep('var APP_VERSION = "v257";', 'var APP_VERSION = "v258";')
rep('/* First-time setup */', '''/* v258: warm-up opener swap */
.wu-top { display: flex; align-items: center; justify-content: space-between; gap: 10px; } .wu-top .wn { min-width: 0; }
.cdlg-box.wus-box { border-color: var(--brass); } .wus-box .btn { width: 100%; } .wus-k { font-size: 12px; color: var(--brass); padding-right: 40px; } .wus-p { margin: 0; font-size: 14px; color: var(--muted); }
.wus-list { display: flex; flex-direction: column; gap: 6px; }
.wus-opt { display: flex; align-items: center; justify-content: space-between; gap: 10px; min-height: 44px; padding: 6px 12px; text-align: left; border: 1px solid var(--line); border-radius: var(--radius, 4px); background: transparent; color: var(--ink); font-size: 14.5px; }
.wus-opt small { flex: none; font-size: 11.5px; color: var(--muted); text-align: right; } .wus-opt.on { border-color: var(--accent); background: color-mix(in srgb, var(--accent) 14%, transparent); }
.wus-all { display: flex; align-items: center; gap: 10px; font-size: 14px; min-height: 40px; } .wus-all input { width: 22px; height: 22px; accent-color: var(--accent); }
/* First-time setup */''')
rep('  function drawWarmup(body, w, th, rec, live, off) {', add + '  function drawWarmup(body, w, th, rec, live, off) {')
# settings: the standing warm-up pick is saved and loaded
rep('dayMoves: state.settings.dayMoves || {}, fast:', 'dayMoves: state.settings.dayMoves || {}, wuOpen: state.settings.wuOpen || "", fast:')
rep('dayMoves: normMoves(st && st.dayMoves), fast:', 'dayMoves: normMoves(st && st.dayMoves), wuOpen: wuOpt(st && st.wuOpen) ? st.wuOpen : "", fast:')
rep('''      o.skip = normSkip(r.skip);''', '''      o.skip = normSkip(r.skip);
      if (wuOpt(r.wuSwap)) o.wuSwap = r.wuSwap;''')
# warm-up header no longer claims "no equipment"
rep('rounds > 1 ? "No equipment needed. Go through round 1 in order, then round "', 'rounds > 1 ? "Go through round 1 in order, then round "')
rep('"No equipment needed. Work through these in order, then build to your first work set."', '"Work through these in order, then build to your first work set."')
# the opener shows his pick
rep('''    function nameEl(e) {
      var shown = moveName(e[0], p.equip);
      if (moveVideo(e[0])) {''', '''    var oi = wuOpenerIdx(list, plans), osw = oi >= 0 ? wuOpenChoice(rec, list[oi][0], rec.date || todayKey()) : null;
    function nameEl(e, i) {
      var o = i === oi ? osw : null, shown = o ? o.name : moveName(e[0], p.equip), vg = o ? o.g : e[0];
      if (o && !vg) return el("span", "wn", shown);
      if (moveVideo(vg)) {''')
rep('''nb.addEventListener("click", function () { saveWkNow(); openVideo(e[0], shown); }); return nb;
      }
      return el("span", "wn", shown);
    }
    if (!live) {''', '''nb.addEventListener("click", function () { saveWkNow(); openVideo(vg, shown); }); return nb;
      }
      return el("span", "wn", shown);
    }
    if (!live) {''')
rep('''        var box = el("div", "wx wu"); box.appendChild(nameEl(e)); box.appendChild(el("span", "wr", e[1]));
        var c = moveCue(e[0]); if (c) box.appendChild(el("span", "wc", c));''', '''        var box = el("div", "wx wu"); box.appendChild(nameEl(e, i)); box.appendChild(el("span", "wr", e[1]));
        var c = i === oi && osw ? osw.cue : moveCue(e[0]); if (c) box.appendChild(el("span", "wc", c));''')
rep('''        it.appendChild(nameEl(e));
        var c = moveCue(e[0]); if (c && r === 0) it.appendChild(el("span", "wc", c));''', '''        if (i === oi && r === 0 && !off) {
          var wt = el("div", "wu-top"); wt.appendChild(nameEl(e, i));
          var wab = el("button", "mini sw-btn", "\\u21C4 Alt"); wab.type = "button"; wab.setAttribute("aria-label", "Swap the warm-up opener");
          wab.addEventListener("click", function () { saveWkNow(); openWuSwap(e[0], moveName(e[0], p.equip), osw ? osw.id : "", function (id, always) {
            if (wk && wk.rec) wk.rec.wuSwap = id; if (always) state.settings.wuOpen = id; else if (state.settings.wuOpen && state.settings.wuOpen !== id) state.settings.wuOpen = "";
            if (always || !state.settings.wuOpen) saveSettings(); saveWkNow(); drawWorkoutPage(true); }); });
          wt.appendChild(wab); it.appendChild(wt);
          if (osw) it.appendChild(el("span", "sw-note", "Swapped from " + moveName(e[0], p.equip)));
        } else it.appendChild(nameEl(e, i));
        var c = i === oi && osw ? osw.cue : moveCue(e[0]); if (c && r === 0) it.appendChild(el("span", "wc", c));''')
rep('''        var lab = moveName(e[0], p.equip) + ", round " + (r + 1);''', '''        var lab = (i === oi && osw ? osw.name : moveName(e[0], p.equip)) + ", round " + (r + 1);''')
# keypad in the warm-up too
rep('''          var f = numField("sr", lab + " reps", pl.reps, s.r, 999, function (v) { s.r = v; s.d = Number(v) > 0; paint(); });''', '''          var f = numField("sr", lab + " reps", pl.reps, s.r, 999, function (v) { s.r = v; s.d = Number(v) > 0; paint(); });
          f.setAttribute("inputmode", "none");''')
rep('''    var row = inp.closest(".setrow"); if (!row || !row.dataset.fix) return;''', '''    var row = inp.closest(".setrow, .wu-line"); if (!row || (!row.dataset.fix && !row.classList.contains("wu-line"))) return;''')
rep('''if (i && i.matches && i.matches("#wkp-body .setrow input.field")) kpOpen(i); });''', '''if (i && i.matches && i.matches("#wkp-body .setrow input.field, #wkp-body .wu-line input.field")) kpOpen(i); });''')
rep('''if (t && t.closest && (t.closest("#kp") || t.closest(".setrow input.field"))) return; kpClose(); }, true);''', '''if (t && t.closest && (t.closest("#kp") || t.closest(".setrow input.field, .wu-line input.field"))) return; kpClose(); }, true);''')
rep('''    var hd = el("div", "kp-h"); hd.appendChild(el("b", null, (nmEl ? nmEl.textContent.trim() + " · " : "") + (lb ? lb.textContent : "Set")));''', '''    var isWu = KP.row.classList.contains("wu-line"), wuLab = isWu ? String(cur.getAttribute("aria-label") || "").replace(/ reps$/, "").replace(/, round /, " \\u00B7 Round ") : "";
    var hd = el("div", "kp-h"); hd.appendChild(el("b", null, isWu ? wuLab : (nmEl ? nmEl.textContent.trim() + " · " : "") + (lb ? lb.textContent : "Set")));''')
rep('''      var row = KP.row, idx = row.dataset.fix.split("-")[0];''', '''      var row = KP.row, idx = isWu ? "" : row.dataset.fix.split("-")[0];
      if (isWu) {
        r.dispatchEvent(new Event("change", { bubbles: true })); saveWkNow();
        var wl = Array.prototype.slice.call(document.querySelectorAll("#wkp-body .wu-line input.sr")), wn = null;
        for (var q0 = wl.indexOf(r) + 1; q0 < wl.length; q0++) if (wl[q0].value === "") { wn = wl[q0]; break; }
        kpClose(); if (!wn) { try { document.activeElement.blur(); } catch (e) {} return; }
        try { wn.focus({ preventScroll: true }); } catch (e) {} kpOpen(wn); return;
      }''')
open(S + 'v258/app-v258.html', 'w', encoding='utf-8').write(src)
print('ok', len(src))
