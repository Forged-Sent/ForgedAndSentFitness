import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
def rep(a,b,n=1):
    global s; assert s.count(a)==n,(s.count(a),a[:90]); s=s.replace(a,b)
SHARE_SVG='<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 15V3M7 8l5-5 5 5"/><path d="M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7"/></svg>'
# Locked workout: one Share button (Rally, Instagram, save image)
rep('''    var share = el("button", "btn lk-btn"); share.type = "button"; share.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v11H9l-5 4z"/></svg>'; share.appendChild(document.createTextNode("Share to Rally"));
    share.addEventListener("click", function () {
      var info = workoutShareInfo(key, wk.root || rec, S ? rec : null, w);
      computePRs(key, wk.root || rec, function (list) { openShare(info, list.filter(function (x) { return info.keys[x.k]; })); });
    });
    body.appendChild(share);
    var ib = el("button", "btn ghost lk-btn"); ib.type = "button"; ib.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="1"/><path d="m3 16 5-5 4 4 3-3 6 6"/></svg>'; ib.appendChild(document.createTextNode("Save as image"));
    ib.addEventListener("click", function () { openWorkoutImage(workoutImageData(key, rec, w, S)); });
    body.appendChild(ib);''','''    var share = el("button", "btn lk-btn"); share.type = "button"; share.id = "wk-share"; share.innerHTML = \''''+SHARE_SVG+'''\'; share.appendChild(document.createTextNode("Share"));
    share.addEventListener("click", function () { openWorkoutShare(key, wk.root || rec, rec, w, S); });
    body.appendChild(share);''')
# Finish: after the points, prompt Rally and Instagram
rep('''          awardPRs(key, wk.root, 0, function (list) { openShare(info, list.filter(function (x) { return info.keys[x.k]; })); });''','''          var shRec = rec; awardPRs(key, wk.root, 0, function (list) { openWorkoutShare(key, wk.root, shRec, w, S, list.filter(function (x) { return info.keys[x.k]; }), true); });''')
# Hub: the workout image dialog becomes the share sheet
rep('''  async function openWorkoutImage(d) {''','''  // One place to share a workout: post to Rally, share to Instagram (+5 once a day) or save the image.
  function openWorkoutShare(key, root, rec, w, S, prs, justFinished) {
    var info = workoutShareInfo(key, root, S ? rec : null, w);
    function go(list) { openWorkoutImage(workoutImageData(key, rec, w, S), { rally: function () { openShare(info, list); }, fresh: !!justFinished }); }
    if (prs) go(prs); else computePRs(key, root, function (list) { go(list.filter(function (x) { return info.keys[x.k]; })); });
  }
  async function openWorkoutImage(d, opt) {
    opt = opt || {};''')
rep('''    var t = el("h2", null, "Workout image"); t.id = "im-t"; box.appendChild(t);''','''    var t = el("h2", null, opt.fresh ? "Share the work" : "Share your workout"); t.id = "im-t"; box.appendChild(t);''')
rep('''    var ig = el("button", "btn ig-btn"); ig.type = "button"; ig.disabled = true; box.appendChild(ig);''','''    if (opt.rally) {
      var rl = el("button", "btn ig-btn"); rl.type = "button"; rl.id = "sh-rally"; rl.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v11H9l-5 4z"/></svg>'; rl.appendChild(document.createTextNode("Post to Rally"));
      rl.disabled = !state.me || !state.canWrite; rl.addEventListener("click", function () { close(); opt.rally(); }); box.appendChild(rl);
    }
    var ig = el("button", "btn ig-btn"); ig.type = "button"; ig.disabled = true; box.appendChild(ig);''')
rep('''    note.textContent = canSave ? "Save it to your phone, then text it to a buddy." : "Press and hold the image to save it to your photos, then text it to a buddy.";''','''    note.textContent = (opt.fresh ? "Let the brothers see the work. " : "") + "Post it to Rally, share it to Instagram, or save it" + (canSave ? "." : " by pressing and holding the image.");''')
# Close button reads Not now right after finishing
rep('''    var cl = el("button", "btn ghost", "Close"); cl.type = "button"; box.appendChild(cl);
    var url = "", blob = null;''','''    var cl = el("button", "btn ghost", opt.fresh ? "Not now" : "Close"); cl.type = "button"; box.appendChild(cl);
    var url = "", blob = null;''')
# help text
s=s.replace('"Share the mission: on a finished workout, tap Workout image, then Share to Instagram.','"Share the mission: on a finished workout, tap Share, then Share to Instagram.')
s=s.replace('Use Share to Instagram on a finished workout\'s image, paste the caption, and confirm you posted.','Tap Share on a finished workout, then Share to Instagram. Paste the caption and confirm you posted.')
rep('/* Share to Instagram */','/* Share to Instagram */\n.im-box .im-prev { max-height: 44vh; aspect-ratio: auto; }')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
