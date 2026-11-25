import sys
S = ''  # set to the folder that holds v258/app-v258.html
src = open(S + 'v258/app-v258.html', encoding='utf-8').read()
def rep(old, new, count=1):
    global src
    n = src.count(old)
    if n != count: sys.exit('expected %d, found %d: %r' % (count, n, old[:90]))
    src = src.replace(old, new)
rep('var APP_VERSION = "v258";', 'var APP_VERSION = "v259";')
# The keypad stays docked: moving to another box retargets it, a redraw re-attaches it, blank taps do nothing.
rep('''    if (KP && KP.row === row) { if (KP.cur !== inp) { KP.cur = inp; KP.fresh = true; kpPaint(); } return; }
    kpClose();
    var r = row.querySelector(".sr"), w = row.querySelector(".sw");
    KP = { row: row, r: r, w: w, cur: inp, fresh: true, buf: { r: r ? r.value : "", w: w ? w.value : "" }, self: false };
    var sh = el("div", "kp"); sh.id = "kp"; sh.setAttribute("role", "group"); sh.setAttribute("aria-label", "Keypad");''', '''    if (KP && KP.row === row) { if (KP.cur !== inp) { KP.cur = inp; KP.fresh = true; kpPaint(); } return; }
    var r = row.querySelector(".sr"), w = row.querySelector(".sw");
    if (KP && $("kp")) { KP.row = row; KP.r = r; KP.w = w; KP.cur = inp; KP.fresh = true; KP.buf = { r: r ? r.value : "", w: w ? w.value : "" }; KP.key = kpKeyOf(row); kpPaint(); kpReveal(); return; }
    kpClose();
    KP = { row: row, r: r, w: w, cur: inp, fresh: true, buf: { r: r ? r.value : "", w: w ? w.value : "" }, self: false, key: kpKeyOf(row) };
    var sh = el("div", "kp"); sh.id = "kp"; sh.setAttribute("role", "group"); sh.setAttribute("aria-label", "Keypad");
    // Swipe down on the top edge tucks the keypad away.
    var sy = null;
    sh.addEventListener("pointerdown", function (ev) { sy = ev.target.closest && ev.target.closest(".kp-grab, .kp-h") && !ev.target.closest("button") ? ev.clientY : null; });
    sh.addEventListener("pointermove", function (ev) { if (sy !== null && ev.clientY - sy > 34) { sy = null; kpClose(); } });
    sh.addEventListener("pointerup", function () { sy = null; }); sh.addEventListener("pointercancel", function () { sy = null; });''')
rep('''  function kpOpen(inp) {''', '''  function kpKeyOf(row) { return row.classList.contains("wu-line") ? "w:" + Array.prototype.indexOf.call(document.querySelectorAll("#wkp-body .wu-line"), row) : "s:" + row.dataset.fix; }
  // After the workout page redraws, the keypad finds its set again and stays open.
  function kpRelocate() {
    if (!KP || document.contains(KP.row)) return;
    var k = KP.key || "", row = k.charAt(0) === "w" ? document.querySelectorAll("#wkp-body .wu-line")[+k.slice(2)] : document.querySelector('#wkp-body .setrow[data-fix="' + k.slice(2) + '"]');
    var r = row && row.querySelector(".sr"); if (!row || !r) { kpClose(); return; }
    var wasW = KP.cur && KP.cur.classList.contains("sw"), w = row.querySelector(".sw");
    KP.row = row; KP.r = r; KP.w = w; KP.cur = wasW && w ? w : r; KP.buf = { r: r.value, w: w ? w.value : "" }; kpPaint();
  }
  function kpOpen(inp) {''')
rep('''    sh.textContent = ""; var r = KP.r, w = KP.w, cur = KP.cur,''', '''    sh.textContent = ""; sh.appendChild(el("div", "kp-grab")); var r = KP.r, w = KP.w, cur = KP.cur,''')
rep('''    var sh = $("kp"); if (!sh || !KP) return; if (!document.contains(KP.row)) { kpClose(); return; }''', '''    var sh = $("kp"); if (!sh || !KP) return; if (!document.contains(KP.row)) { kpRelocate(); return; }''')
rep('''    kpClose(); body.textContent = ""; $("wkp-date").textContent = longDate(key); paintClock(); loadWkHist();''', '''    if (KP) setTimeout(kpRelocate, 0); body.textContent = ""; $("wkp-date").textContent = longDate(key); paintClock(); loadWkHist();''')
# a tap on blank space no longer closes it; opening something else does
rep('''  document.addEventListener("pointerdown", function (ev) { if (!KP) return; var t = ev.target; if (t && t.closest && (t.closest("#kp") || t.closest(".setrow input.field, .wu-line input.field"))) return; kpClose(); }, true);''',
    '''  document.addEventListener("click", function (ev) { if (!KP) return; var t = ev.target; if (t && t.closest && t.closest("#wkp-body .sw-btn, #wkp-body .wlink, #wkp-body .help-btn, #wkp-body .wu-timer, .wk-clock button")) kpClose(); }, true);''')
rep('''.kp-h { display: flex; align-items: baseline;''', '''.kp-grab { height: 14px; margin-top: -2px; position: relative; touch-action: none; } .kp-grab::after { content: ""; position: absolute; left: 50%; top: 5px; width: 40px; height: 4px; margin-left: -20px; border-radius: 2px; background: var(--line); }
.kp-h { touch-action: none; display: flex; align-items: baseline;''')
open(S + 'v259/app-v259.html', 'w', encoding='utf-8').write(src)
print('ok', len(src))
