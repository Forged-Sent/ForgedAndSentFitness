  /* ---------- v260: total lifted on each lift. Display only: PR, volume and points math are untouched. ---------- */
  function tlWeighIn(key) { var w = state.weights || {}, ks = Object.keys(w).filter(function (k) { return k <= key && Number(w[k]) > 0; }).sort(); return ks.length ? { d: ks[ks.length - 1], lb: Number(w[ks[ks.length - 1]]) } : null; }
  // "w" needs a weight, "bw" is a bodyweight lift, "cardio" gets no weight total, "" shows nothing (timed work, stretches written as rounds).
  function tlKind(g, ps, equip) { if (!ps || ps.time) return ""; var pat = (PLAN.M[g] || {}).pattern || ""; if (/^(Conditioning|Mobility|Recovery)$/.test(pat)) return "cardio"; return needsWeight(g, equip) ? "w" : "bw"; }
  function tlCalc(a, kind, bwLb) {
    var o = { n: 0, done: 0, reps: 0, tot: 0 };
    (Array.isArray(a) ? a : []).forEach(function (s) {
      if (!s || s.k === "w") return; o.n++;
      var r = Number(s.r) || 0, w = Number(s.w) || 0; if (r <= 0 || (kind === "w" && w <= 0)) return;
      o.done++; o.reps += r; o.tot += r * (kind === "bw" ? (bwLb || 0) + w : w);
    });
    return o;
  }
  function tlShort(d) { try { return new Date(d + "T12:00:00").toLocaleDateString("en-US", { month: "short", day: "numeric" }); } catch (e) { return d; } }
  function tlBox(getSets, g, ps, equip, key) {
    var kind = tlKind(g, ps, equip); if (!kind) return null;
    var box = el("div", "tl"), wi = kind === "bw" ? tlWeighIn(key) : null;
    box.paint = function () {
      var c = tlCalc(getSets(), kind, wi ? wi.lb : 0); box.textContent = ""; box.hidden = !c.done; if (!c.done) return;
      var sub = c.done + " of " + c.n + (c.n === 1 ? " set" : " sets") + " · " + c.reps + " reps";
      if (kind === "cardio") { box.className = "tl plain"; box.appendChild(el("span", "tl-s", sub + ". No weight total for cardio.")); return; }
      box.className = "tl" + (kind === "bw" && !wi ? " ask" : "");
      var l = el("div", "tl-l"); l.appendChild(el("span", "tl-k", "Total lifted")); l.appendChild(el("span", "tl-s", sub)); box.appendChild(l);
      if (kind === "bw" && !wi) { box.appendChild(el("span", "tl-a", "Log a weigh-in to see a total")); return; }
      box.appendChild(el("b", "tl-v", fmt(c.tot) + " lb"));
      if (kind === "bw") box.appendChild(el("span", "tl-n", "Uses your last weigh-in: " + fmt(wi.lb) + " lb on " + tlShort(wi.d) + ". Added weight is counted on top. Only you see this."));
    };
    box.paint(); return box;
  }
  // Totals repaint as he types or ticks a set. Superset rows are moved out of their lift's card, so this listens on the page.
  var TL_LIVE = [];
  function tlRepaint() { TL_LIVE.forEach(function (b) { if (document.contains(b)) b.paint(); }); }
  document.addEventListener("input", function (ev) { var t = ev.target; if (TL_LIVE.length && t && t.closest && t.closest("#wkp-body")) tlRepaint(); });
  document.addEventListener("click", function (ev) { var t = ev.target; if (TL_LIVE.length && t && t.closest && (t.closest("#wkp-body") || t.closest("#kp"))) setTimeout(tlRepaint, 0); });
