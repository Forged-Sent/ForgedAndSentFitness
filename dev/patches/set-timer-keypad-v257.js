  /* ---------- v257: a timer on each timed set and round, and the app's own keypad for reps and weight ---------- */
  function stSecs(target) { var t = String(target || ""), m = /(\d+)\s*sec/i.exec(t), n = m ? +m[1] : 0; if (!n) { m = /(\d+(?:\.\d+)?)\s*min/i.exec(t); n = m ? Math.round(+m[1] * 60) : 0; } return n >= 5 && n <= 600 ? n : 0; }
  // "2 rounds: 30 sec hold or 6 slow reps per side"
  function stRounds(rx) { var m = /^\s*(\d+)\s*rounds?:\s*(\d+)\s*sec hold(?:\s+or\s+([^.(]+))?/i.exec(String(rx || "")); if (!m || +m[1] < 1 || +m[1] > 6 || +m[2] < 5) return null; return { n: +m[1], secs: +m[2], sides: /per side|each side/i.test(rx), alt: (m[3] || "").trim() }; }
  function stRest(idx) { var t = wk && wk.timers && wk.timers[idx]; if (t && !t.running && t.timeEl && document.contains(t.timeEl)) { t.done = false; t.left = t.base; timerStart(t); } }
  // Start button mark: a stopwatch with a play arrow, drawn in the button's own colour.
  var ST_ICON = '<svg class="st-ic" viewBox="0 0 24 24" aria-hidden="true"><path d="M9.5 2.5h5M12 2.5v3" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="12" cy="14" r="8" fill="none" stroke="currentColor" stroke-width="2"/><path d="M10.2 10.4v7.2l6-3.6z" fill="currentColor"/></svg>';
  function stGoBtn(label) { var b = el("button", "mini st-go"); b.type = "button"; b.innerHTML = ST_ICON; b.appendChild(el("span", null, "Start")); b.setAttribute("aria-label", label); return b; }
  var ST = null;
  function stQuiet() { if (!ST) return; (ST.tn.tones || []).forEach(function (o) { try { o.stop(); } catch (e) {} }); ST.tn.tones = []; try { if (beepEl) beepEl.pause(); } catch (e) {} }
  function stClose(keepSound) { if (!ST) return; clearInterval(ST.iv); if (!keepSound) stQuiet(); try { if (ST.lock && ST.lock.release) ST.lock.release(); } catch (e) {} var n = $("stov"); if (n) n.remove(); ST = null; }
  function stChime() { try { if (navigator.vibrate) navigator.vibrate([250, 120, 400]); } catch (e) {} if (!playBeepEl(3)) playTones(ST ? ST.tn : null, 0); }
  // Three short ticks, then a longer tone when the count reaches zero.
  function stCount(leftMs) { if (!playBeepEl(Math.max(0, 3 - leftMs / 1000))) playTones(ST ? ST.tn : null, leftMs / 1000); }
  function openSetTimer(o) {
    stClose(); kpClose(); unlockAudio();
    var seq = [{ k: "count", label: "Get ready", secs: 3 }, { k: "hold", label: o.sides ? "Left side" : "Hold", secs: o.secs }];
    if (o.sides) seq.push({ k: "count", label: "Switch sides", secs: 5, chime: true }, { k: "hold", label: "Right side", secs: o.secs });
    var back = el("div", "cdlg st-ov"); back.id = "stov";
    var box = el("div", "cdlg-box st-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "st-l");
    box.appendChild(el("span", "label-caps st-k", o.title + " · " + o.label));
    var lab = el("div", "st-l"); lab.id = "st-l"; box.appendChild(lab);
    var big = el("div", "st-big"); big.setAttribute("aria-live", "off"); box.appendChild(big);
    var sub = el("p", "st-sub"); box.appendChild(sub);
    var say = el("span", "st-say"); say.setAttribute("aria-live", "assertive"); box.appendChild(say);
    var btn = el("button", "btn ghost", "Cancel"); btn.type = "button"; box.appendChild(btn);
    back.appendChild(box); document.body.appendChild(back);
    ST = { i: -1, seq: seq, end: 0, tn: { tones: [] }, iv: 0, lock: null };
    try { if (navigator.wakeLock && navigator.wakeLock.request) navigator.wakeLock.request("screen").then(function (l) { if (ST) ST.lock = l; else l.release(); }).catch(noop); } catch (e) {}
    function enter(i) {
      ST.i = i; var ph = seq[i]; ph.sounded = false; ST.start = Date.now(); ST.end = ST.start + ph.secs * 1000;
      if (ph.chime) stChime();
      lab.textContent = ph.label; say.textContent = ph.label; box.className = "cdlg-box st-box " + ph.k;
      btn.textContent = ph.k === "hold" ? "Stop early" : "Cancel";
      sub.textContent = ph.k === "hold" ? "Counting down from " + mmss(ph.secs) + "." : i === 0 ? "Get into position." : "Time. Change sides.";
      paint();
    }
    function finish(held, natural) { stClose(natural); if (held > 0) o.onDone(held); }
    function paint() {
      if (!ST) return; var ph = seq[ST.i], now = Date.now(), leftMs = ST.end - now;
      if (ph.k === "count" && !ph.sounded && leftMs <= 3000) { ph.sounded = true; stCount(Math.max(0, leftMs)); }
      if (leftMs <= 0) {
        if (ph.k === "hold") { if (ST.i === seq.length - 1) { stChime(); finish(ph.secs, true); return; } }
        enter(ST.i + 1); return;
      }
      var left = Math.ceil(leftMs / 1000); big.textContent = ph.k === "count" ? String(Math.min(3, left)) : mmss(left);
    }
    btn.addEventListener("click", function () { var ph = seq[ST.i]; if (ph.k === "hold") finish(Math.floor((Date.now() - ST.start) / 1000)); else if (ST.i > 0) finish(seq[ST.i - 1].secs); else stClose(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); stClose(); } });
    ST.iv = setInterval(paint, 100); enter(0); btn.focus({ preventScroll: true });
  }
  function drawRounds(ex, a, rd, o) {
    while (a.length < rd.n) a.push({ w: "", r: "", d: false });
    for (var i = 0; i < rd.n; i++) (function (s, n) {
      var row = el("div", "setrow rnd" + (s.d ? " ok" : "")); row.appendChild(el("span", "sn", "Round " + n));
      row.appendChild(el("span", "rnd-t", s.d && s.t ? "Held " + s.t + " sec" + (rd.sides ? " each side" : "") : rd.secs + " sec" + (rd.sides ? " each side" : "")));
      if (o.can && !s.d) {
        var go = stGoBtn("Start the timer for round " + n + " of " + o.name);
        go.addEventListener("click", function () { saveWkNow(); openSetTimer({ title: o.name, label: "Round " + n, secs: rd.secs, sides: rd.sides, onDone: function (held) { s.d = true; s.t = held; saveWkNow(); drawWorkoutPage(true); } }); });
        row.appendChild(go);
      } else row.appendChild(el("span"));
      var ck = el("button", "setck-btn", "✓"); ck.type = "button"; ck.setAttribute("aria-pressed", String(!!s.d)); ck.setAttribute("aria-label", "Mark round " + n + " done"); ck.disabled = !o.can;
      ck.addEventListener("click", function () { s.d = !s.d; if (!s.d) delete s.t; saveWkNow(); redrawKeepScroll(); });
      row.appendChild(ck); ex.appendChild(row);
    })(a[i], i + 1);
    if (o.can) ex.appendChild(el("p", "rnd-n", (rd.sides ? "One Start runs both sides back to back. " : "") + (rd.alt ? "Did " + rd.alt + " instead? Tick the round." : "")));
  }
  /* Keypad: opens when a set's reps or weight box is tapped. The boxes stay real fields, so a hardware keyboard still types into them. */
  var KP = null;
  function kpClose() { if (!KP) return; var n = $("kp"); if (n) n.remove(); document.body.classList.remove("kp-on"); var sc = $("scroll"); if (sc) sc.style.paddingBottom = ""; KP = null; }
  function kpKind(inp) { return inp.classList.contains("sw") ? "w" : /sec/i.test(inp.placeholder || "") ? "s" : "r"; }
  function kpPush(inp) { KP.self = true; inp.value = String(KP.buf[kpKind(inp) === "w" ? "w" : "r"]).replace(/\.$/, ""); inp.dispatchEvent(new Event("input", { bubbles: true })); KP.self = false; kpPaint(); }
  function kpOpen(inp) {
    var row = inp.closest(".setrow"); if (!row || !row.dataset.fix) return;
    if (KP && KP.row === row) { if (KP.cur !== inp) { KP.cur = inp; KP.fresh = true; kpPaint(); } return; }
    kpClose();
    var r = row.querySelector(".sr"), w = row.querySelector(".sw");
    KP = { row: row, r: r, w: w, cur: inp, fresh: true, buf: { r: r ? r.value : "", w: w ? w.value : "" }, self: false };
    var sh = el("div", "kp"); sh.id = "kp"; sh.setAttribute("role", "group"); sh.setAttribute("aria-label", "Keypad");
    // Keep the typing focus in the box on a mouse click. Touches are left alone: cancelling a touch also cancels the tap.
    sh.addEventListener("mousedown", function (ev) { ev.preventDefault(); });
    document.body.appendChild(sh); document.body.classList.add("kp-on"); kpPaint();
    kpReveal();
  }
  // Keeps the set being entered in view, just above the keypad.
  function kpReveal() {
    setTimeout(function () {
      var sh = $("kp"), sc = $("scroll"); if (!sh || !sc || !KP || !document.contains(KP.row)) return;
      sc.style.paddingBottom = (sh.offsetHeight + 24) + "px";
      var top = sh.getBoundingClientRect().top, rr = KP.row.getBoundingClientRect(), sr = sc.getBoundingClientRect(), d = rr.bottom - (top - 14);
      if (d > 0) sc.scrollTop += d; else if (rr.top < sr.top + 96) sc.scrollTop -= (sr.top + 96 - rr.top);
    }, 40);
  }
  function kpPrev() { var p = KP.row.querySelector(".sn-prev"), m = p ? /(?:\+?([\d.]+)×)?(\d+(?:\.\d+)?)\s*$/.exec(p.textContent.trim()) : null; return m ? { w: m[1] || "", r: m[2] } : null; }
  function kpPaint() {
    var sh = $("kp"); if (!sh || !KP) return; if (!document.contains(KP.row)) { kpClose(); return; }
    sh.textContent = ""; var r = KP.r, w = KP.w, cur = KP.cur, kind = kpKind(cur), key = kind === "w" ? "w" : "r", prev = kpPrev();
    var card = KP.row.closest(".wx"), nmEl = card && !card.classList.contains("sup-card") ? card.querySelector(".wn") : null, lb = KP.row.querySelector(".sn-l");
    var hd = el("div", "kp-h"); hd.appendChild(el("b", null, (nmEl ? nmEl.textContent.trim() + " · " : "") + (lb ? lb.textContent : "Set")));
    var pv = KP.row.querySelector(".sn-prev"); hd.appendChild(el("span", null, pv ? "Last time: " + pv.textContent.trim() : ""));
    var x = el("button", "kp-x", "Close"); x.type = "button"; x.addEventListener("click", function () { var c = KP.cur; kpClose(); try { c.blur(); } catch (e) {} }); hd.appendChild(x); sh.appendChild(hd);
    var f2 = el("div", "kp-f" + (w ? "" : " one"));
    [[r, "r"], [w, "w"]].forEach(function (p) {
      if (!p[0]) return; var k = kpKind(p[0]), t = el("button", "kp-fld" + (p[0] === cur ? " on" : "")); t.type = "button";
      t.appendChild(el("span", null, k === "w" ? (p[0].classList.contains("opt") ? "Added weight · lb" : "Weight · lb") : k === "s" ? "Seconds" : "Reps"));
      var v = KP.buf[p[1]]; t.appendChild(el("b", v === "" ? "e" : null, v === "" ? (k === "w" ? "lb" : k === "s" ? "sec" : "reps") : v));
      t.addEventListener("click", function () { KP.cur = p[0]; KP.fresh = true; try { p[0].focus({ preventScroll: true }); } catch (e) {} kpPaint(); }); f2.appendChild(t);
    });
    sh.appendChild(f2);
    function setBuf(v) { KP.buf[key] = v; KP.fresh = false; kpPush(cur); }
    var qk = el("div", "kp-q"), qs = [];
    if (prev && (kind === "w" ? prev.w : prev.r)) qs.push(["Same as last", function () { setBuf(kind === "w" ? prev.w : prev.r); }]);
    qs.forEach(function (q) { var b = el("button", "kp-qb", q[0]); b.type = "button"; b.addEventListener("click", q[1]); qk.appendChild(b); }); if (qs.length) sh.appendChild(qk);
    var pad = el("div", "kp-pad");
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "⌫"].forEach(function (k) {
      var b = el("button", "kp-k" + (k === "." || k === "⌫" ? " d" : ""), k); b.type = "button"; b.setAttribute("aria-label", k === "⌫" ? "Delete" : k === "." ? "Decimal point" : k);
      if (k === "." && kind !== "w") b.disabled = true;
      b.addEventListener("click", function () {
        var v = KP.fresh ? "" : String(KP.buf[key]);
        if (k === "⌫") v = String(KP.buf[key]).slice(0, -1);
        else if (k === ".") { if (v.indexOf(".") < 0) v = (v || "0") + "."; }
        else if (v.replace(".", "").length < (kind === "w" ? 5 : 3) && !/\.\d$/.test(v)) v = v === "0" ? k : v + k;
        setBuf(v);
      });
      pad.appendChild(b);
    });
    sh.appendChild(pad);
    var needW = w && cur === r && !w.classList.contains("opt") && KP.buf.w === "", main = el("button", "btn kp-go", needW ? "Next: weight" : "Log set"); main.type = "button";
    main.disabled = !needW && !(parseFloat(KP.buf.r) > 0);
    main.addEventListener("click", function () {
      if (needW) { KP.cur = w; KP.fresh = true; try { w.focus({ preventScroll: true }); } catch (e) {} kpPaint(); return; }
      var row = KP.row, idx = row.dataset.fix.split("-")[0];
      [r, w].forEach(function (f) { if (f) f.dispatchEvent(new Event("change", { bubbles: true })); }); saveWkNow();
      var rows = card ? Array.prototype.slice.call(card.querySelectorAll(".setrow[data-fix]")) : [], at = rows.indexOf(row), next = null;
      for (var j = at + 1; j < rows.length; j++) { var q = rows[j].querySelector(".sr"); if (q && q.value === "") { next = rows[j]; break; } }
      var wv = w ? w.value : "";
      kpClose(); stRest(idx);
      if (!next) { try { document.activeElement.blur(); } catch (e) {} return; }
      var nw = next.querySelector(".sw");
      if (nw && nw.value === "" && wv !== "" && next.dataset.fix.split("-")[0] === idx) { nw.value = wv; nw.dispatchEvent(new Event("input", { bubbles: true })); nw.dispatchEvent(new Event("change", { bubbles: true })); }
      var nr = next.querySelector(".sr"); try { nr.focus({ preventScroll: true }); } catch (e) {} kpOpen(nr);
    });
    sh.appendChild(main);
  }
  document.addEventListener("focusin", function (ev) { var i = ev.target; if (i && i.matches && i.matches("#wkp-body .setrow input.field")) kpOpen(i); });
  document.addEventListener("input", function (ev) { if (!KP || KP.self) return; if (ev.target === KP.r) KP.buf.r = KP.r.value; else if (ev.target === KP.w) KP.buf.w = KP.w.value; else return; KP.fresh = false; kpPaint(); });
  document.addEventListener("pointerdown", function (ev) { if (!KP) return; var t = ev.target; if (t && t.closest && (t.closest("#kp") || t.closest(".setrow input.field"))) return; kpClose(); }, true);
