import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
def rep(a,b,n=1):
    global s; assert s.count(a)==n,(s.count(a),a[:90]); s=s.replace(a,b)
# Day record carries igs (shared to Instagram today, +5, once a day)
rep('''onote: String(x.onote || "").slice(0, 140), obonus: !!x.obonus }; }));''','''onote: String(x.onote || "").slice(0, 140), obonus: !!x.obonus, igs: !!x.igs }; }));''')
rep('''onote: String(rec.onote || "").slice(0, 140), obonus: !!rec.obonus }); },''','''onote: String(rec.onote || "").slice(0, 140), obonus: !!rec.obonus, igs: !!rec.igs }); },''')
rep('''opt: normOpt(cur.opt), onote: String(cur.onote || ""), obonus: !!cur.obonus };''','''opt: normOpt(cur.opt), onote: String(cur.onote || ""), obonus: !!cur.obonus, igs: !!cur.igs };''')
rep('''  var OPT_BONUS = 1; // finishing the optional 4th-day workout''','''  var OPT_BONUS = 1; // finishing the optional 4th-day workout
  var IG_BONUS = 5; // sharing a workout to Instagram and tagging @forged.and.sent, once a day, on his honor
  var IG_HANDLE = "forged.and.sent";''')
rep('''+ (rec.obonus ? OPT_BONUS : 0); }''','''+ (rec.obonus ? OPT_BONUS : 0) + (rec.igs ? IG_BONUS : 0); }''')
rep('''var t = { boxes: 0, habits: 0, steps: 0, protein: 0, prs: 0, opt: 0, dbl: 0 }, prList = [];''','''var t = { boxes: 0, habits: 0, steps: 0, protein: 0, prs: 0, opt: 0, dbl: 0, ig: 0 }, prList = [];''')
rep('''t.opt += c.obonus ? OPT_BONUS : 0; t.dbl += campDoubleExtra(c);''','''t.opt += c.obonus ? OPT_BONUS : 0; t.ig += c.igs ? IG_BONUS : 0; t.dbl += campDoubleExtra(c);''')
rep('''var kw = t.boxes + t.habits + t.steps + t.protein + t.prs + t.opt + t.dbl + rcPts;''','''var kw = t.boxes + t.habits + t.steps + t.protein + t.prs + t.opt + t.ig + t.dbl + rcPts;''')
rep('''["Optional workout bonus", t.opt], ["Campaign double points", t.dbl],''','''["Optional workout bonus", t.opt], ["Shared the mission", t.ig], ["Campaign double points", t.dbl],''')
rep('''    group("Sent", [["A brother you invited joins", "+" + RECRUIT_PTS + " pts"]],''','''    group("Share the mission", [["Share a workout to Instagram and tag @" + IG_HANDLE, "+" + IG_BONUS + " pts"], ["Limit", "Once a day"]], "On your honor. Use Share to Instagram on a finished workout's image, paste the caption, and confirm you posted.");
    group("Sent", [["A brother you invited joins", "+" + RECRUIT_PTS + " pts"]],''')
i=s.index('D.checkins.forEach(function (c) { try { pts += pointsOf({ done: c.done || {}')
j=s.index('obonus: !!c.obonus',i); s=s[:j]+'obonus: !!c.obonus, igs: !!c.igs'+s[j+len('obonus: !!c.obonus'):]
# Workout image dialog: Share to Instagram
rep('''    var save = el("button", "btn", "Save image"); save.type = "button"; save.disabled = true; box.appendChild(save);''','''    var ig = el("button", "btn ig-btn"); ig.type = "button"; ig.disabled = true; box.appendChild(ig);
    var igBox = el("div", "ig-box"); igBox.hidden = true; box.appendChild(igBox);
    var save = el("button", "btn ghost", "Save image"); save.type = "button"; save.disabled = true; box.appendChild(save);''')
rep('''    save.hidden = !canSave; save.disabled = !canSave;
    save.addEventListener("click", function () {''','''    save.hidden = !canSave; save.disabled = !canSave;
    igSetup(d, blob, ig, igBox, note);
    save.addEventListener("click", function () {''')
NEW=r'''  /* ---------- Share to Instagram: +5 once a day, on his honor (Instagram can't be checked from the app) ---------- */
  var IG_SVG = '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4.2"/><circle cx="17.3" cy="6.7" r="1" fill="currentColor" stroke="none"/></svg>';
  function igCaption(d) {
    var n = d.prs.length, t = String(d.title || "Workout").replace(/\s+/g, " ").trim();
    return t + " done. " + fmt(d.vol) + " lb moved" + (n ? ", " + n + (n === 1 ? " PR" : " PRs") : "") + ". Stronger to serve. @" + IG_HANDLE + " #ForgedAndSent #StandFirm";
  }
  function igDoneToday() { return !!recFor(todayKey()).igs; }
  function igLabel(b) { b.innerHTML = IG_SVG; b.appendChild(document.createTextNode(igDoneToday() ? "Share to Instagram · ✓ +" + IG_BONUS + " today" : "Share to Instagram · +" + IG_BONUS)); }
  function igSetup(d, blob, btn, box, note) {
    igLabel(btn); btn.disabled = false;
    var cap = igCaption(d), fn = "Forged-and-Sent-" + String(d.title || "workout").replace(/[^A-Za-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 60) + ".png";
    function confirmBox(shared) {
      box.textContent = ""; box.hidden = false;
      var cb = el("div", "ig-cap"); cb.appendChild(el("b", null, "Caption copied · paste it in Instagram")); var ct = el("p", null, cap); cb.appendChild(ct); box.appendChild(cb);
      box.appendChild(el("p", "fnote", shared ? "Instagram doesn’t let apps fill in the caption or tag for you. Long-press the caption box and tap Paste. On a Story, add the @" + IG_HANDLE + " sticker." : "Save the image (or press and hold it), then post it from your photos in Instagram and paste the caption. Tag @" + IG_HANDLE + "."));
      if (igDoneToday()) { box.appendChild(el("p", "ig-ok", "✓ +" + IG_BONUS + " for sharing today. Thanks for sharing the mission, brother.")); return; }
      var q = el("p", "ig-q", "Did you post it and tag @" + IG_HANDLE + "? On your honor."); box.appendChild(q);
      var row = el("div", "ig-row"), yes = el("button", "btn", "Yes, I posted it · +" + IG_BONUS), no = el("button", "btn ghost", "Not yet"); yes.type = no.type = "button";
      yes.disabled = !state.me || !state.canWrite;
      yes.addEventListener("click", function () {
        if (igDoneToday()) return; writeDay(function (r) { r.igs = true; });
        row.remove(); q.remove(); box.appendChild(el("p", "ig-ok", "✓ +" + IG_BONUS + ". Thanks for sharing the mission, brother.")); igLabel(btn);
      });
      no.addEventListener("click", function () { box.hidden = true; });
      row.appendChild(yes); row.appendChild(no); box.appendChild(row);
    }
    btn.addEventListener("click", async function () {
      try { await navigator.clipboard.writeText(cap); } catch (e) {}
      var shared = false;
      try {
        var file = new File([blob], fn, { type: "image/png" });
        if (navigator.canShare && navigator.canShare({ files: [file] })) { await navigator.share({ files: [file], text: cap }); shared = true; }
      } catch (e) { if (e && e.name === "AbortError") { confirmBox(true); return; } }
      confirmBox(shared);
    });
  }

'''
rep('''  async function openWorkoutImage(d) {''', NEW+'''  async function openWorkoutImage(d) {''')
CSS='''
/* Share to Instagram */
.ig-btn { display: flex; align-items: center; justify-content: center; gap: 10px; }
.ig-btn svg { width: 22px; height: 22px; fill: none; stroke: currentColor; stroke-width: 2.2; flex: none; }
.ig-box { display: flex; flex-direction: column; gap: 8px; margin: 2px 0 6px; }
.ig-cap { padding: 10px 12px; border: 1px dashed var(--accent); border-radius: 8px; background: var(--surface); }
.ig-cap b { display: block; font-family: var(--f-label); font-weight: 700; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); margin-bottom: 3px; }
.ig-cap p { margin: 0; font-size: 14px; line-height: 1.45; user-select: text; -webkit-user-select: text; }
.ig-q { margin: 2px 0 0; font-weight: 600; font-size: 14.5px; }
.ig-row { display: grid; grid-template-columns: 1.4fr 1fr; gap: 8px; }
.ig-ok { margin: 0; font-weight: 600; color: var(--accent); }
'''
rep('/* Footer verse on Today */', CSS+'/* Footer verse on Today */')
# Help and Ask
rep('''"Your two: add up to two personal habits of your own. Each is worth 1 point."''','''"Your two: add up to two personal habits of your own. Each is worth 1 point.",
      "Share the mission: on a finished workout, tap Workout image, then Share to Instagram. Tag @forged.and.sent and confirm you posted for +5, once a day."''')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
