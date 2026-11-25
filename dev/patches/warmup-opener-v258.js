  /* ---------- v258: an alternate for the three-minute warm-up opener ---------- */
  var WU_OPTS = [
    { id: "walk", name: "Brisk Walk or March in Place", need: "No equipment", cue: "Tall posture, swing the arms, breathe easy. March in place if you have no room to walk." },
    { id: "jacks", g: "Jumping Jack", name: "Jumping Jacks", need: "No equipment" },
    { id: "step", name: "Step Jacks", need: "No equipment · low impact", cue: "Step one foot out at a time as the arms go overhead. No jumping." },
    { id: "rope", g: "Jump Rope", name: "Jump Rope", need: "Needs a rope" },
    { id: "tread", g: "Incline Treadmill Walk", name: "Incline Treadmill Walk", need: "Needs a treadmill" },
    { id: "bike", g: "Stationary Bike Ride", name: "Stationary Bike or Road Ride", need: "Needs a bike" }
  ];
  function wuOpt(id) { return WU_OPTS.filter(function (o) { return o.id === id; })[0] || null; }
  function wuOptOf(g) { return WU_OPTS.filter(function (o) { return o.g === g; })[0] || null; }
  // The opener is the first warm-up move when it is a single timed block of two minutes or more.
  function wuOpenerIdx(list, plans) { var pl = plans[0]; return list.length && pl && pl.length === 1 && pl[0].time >= 120 ? 0 : -1; }
  // His pick for today, else his standing pick, else low impact when his plan asks for it, else the plan's own opener.
  function wuOpenChoice(rec, g, key) {
    var planned = wuOptOf(g), id = (rec && rec.wuSwap) || state.settings.wuOpen || "", o = wuOpt(id);
    if (!o && planned && (planned.id === "rope" || planned.id === "jacks")) { var p = realPlan(), s = psSetup(p); if (s && (s.impact === "low" || fndOn(p, key))) o = wuOpt("step"); }
    if (!o || (planned && o.id === planned.id)) return null;
    return { id: o.id, g: o.g || "", name: o.name, cue: o.cue || (o.g ? moveCue(o.g) : ""), from: g };
  }
  function openWuSwap(g, shown, cur, onPick) {
    var old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box wus-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "wus-t");
    var x = el("button", "dlg-x"); x.type = "button"; x.setAttribute("aria-label", "Close"); x.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>'; box.appendChild(x);
    box.appendChild(el("span", "label-caps wus-k", "Swap the warm-up opener"));
    var t = el("h2", null, "3 minutes, easy"); t.id = "wus-t"; box.appendChild(t);
    box.appendChild(el("p", "wus-p", "Anything that warms you up and still lets you talk."));
    var planned = wuOptOf(g), sel = cur || (planned ? planned.id : ""), list = el("div", "wus-list"); list.setAttribute("role", "radiogroup");
    function paint() { Array.prototype.forEach.call(list.children, function (b) { var on = b.dataset.id === sel; b.classList.toggle("on", on); b.setAttribute("aria-checked", String(on)); }); go.disabled = !sel; }
    WU_OPTS.forEach(function (o) {
      var b = el("button", "wus-opt"); b.type = "button"; b.dataset.id = o.id; b.setAttribute("role", "radio");
      b.appendChild(el("span", null, o.name)); b.appendChild(el("small", null, planned && planned.id === o.id ? "In the plan today" : o.need));
      b.addEventListener("click", function () { sel = o.id; paint(); }); list.appendChild(b);
    });
    box.appendChild(list);
    var lab = el("label", "wus-all"), cb = el("input"); cb.type = "checkbox"; cb.checked = !!state.settings.wuOpen && state.settings.wuOpen === sel; lab.appendChild(cb); lab.appendChild(el("span", null, "Use this for every warm-up opener")); box.appendChild(lab);
    var go = el("button", "btn", "Swap"); go.type = "button"; box.appendChild(go);
    function close() { back.remove(); }
    x.addEventListener("click", close); back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); close(); } });
    go.addEventListener("click", function () { close(); onPick(sel, cb.checked); });
    back.appendChild(box); document.body.appendChild(back); paint(); go.focus({ preventScroll: true });
  }
