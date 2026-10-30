#!/usr/bin/env python3
"""Rally as a chat (Forged in Faith chat style), no threads, replies stay under their post.
Usage: patch_rally.py <in.html> <out.html> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()

def rep(old, new, count=1):
    global s
    assert s.count(old) == count, ("anchor", old[:80], s.count(old))
    s = s.replace(old, new)

def rep_between(start, end, new):
    """Replace text from start (inclusive) up to end (exclusive)."""
    global s
    assert s.count(start) == 1, ("start", start[:60], s.count(start))
    i = s.index(start); j = s.index(end, i)
    s = s[:i] + new + s[j:]

# ------------------------------------------------------------------ HTML
i = s.index('  <!-- CHECK-IN -->'); j = s.index('  <!-- DEVOTIONAL -->', i)
s = s[:i] + '''  <!-- CHECK-IN: Rally, a chat with no threads. Replies sit under the post they answer. -->
  <div class="page" id="page-checkin" hidden>
    <div class="topline rl-top"><span class="rl-av" aria-hidden="true">R</span><div class="rl-tt"><h1 class="pg" id="h-feed">Rally</h1><small>Encourage a brother.</small></div><button type="button" class="me-btn" data-open="me" aria-label="Your profile"></button></div>
    <div class="feed rl-list" id="feed" role="log" aria-live="polite" aria-labelledby="h-feed"></div>
    <form class="composer rl-foot" id="composer">
      <div id="rl-bar" hidden></div>
      <div class="chips" id="file-chips"></div>
      <p class="error" id="post-error" hidden></p>
      <div class="rl-cmp">
        <label class="rl-clip" id="attach-label" aria-label="Add a photo or video"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 11.5l-8.2 8.2a5 5 0 0 1-7.1-7.1l8.6-8.6a3.4 3.4 0 0 1 4.8 4.8l-8.4 8.4a1.7 1.7 0 0 1-2.4-2.4l7.6-7.6"/></svg><input type="file" id="post-file" accept="image/*,video/*" multiple hidden></label>
        <div class="mention-wrap"><textarea id="post-text" rows="1" maxlength="1000" placeholder="Post to the brothers" aria-label="Your post"></textarea><div class="mentions" id="mention-list" hidden></div></div>
        <button class="rl-send" type="submit" id="post-btn" aria-label="Send"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h13M13 6l6 6-6 6"/></svg></button>
      </div>
    </form>
  </div>

''' + s[j:]

# ------------------------------------------------------------------ CSS
CSS = r'''/* Rally chat */
#scroll.rally-mode { padding: 0; overflow: hidden; }
#scroll.rally-mode main { max-width: none; height: 100%; }
#page-checkin { height: 100%; gap: 0; }
.rl-top { flex: 0 0 auto; display: flex; align-items: center; gap: 10px; flex-wrap: nowrap; padding: 10px max(14px, env(safe-area-inset-right, 0px)) 10px max(14px, env(safe-area-inset-left, 0px)); background: var(--surface); border-bottom: 1px solid var(--line); }
.rl-av { flex: none; width: 40px; height: 40px; border-radius: 50%; display: grid; place-items: center; background: var(--accent); color: var(--accent-ink); font-family: var(--f-label); font-weight: 800; font-size: 19px; }
.rl-tt { flex: 1 1 auto; min-width: 0; }
.rl-tt h1.pg { font-size: 22px; line-height: 1; }
.rl-tt small { display: block; color: var(--muted); font-size: 12.5px; line-height: 1.25; margin-top: 2px; }
@media (max-width: 360px) { .rl-tt small { display: none; } .rl-av { width: 34px; height: 34px; font-size: 16px; } }
.rl-list.feed { flex: 1 1 auto; min-height: 0; overflow-y: auto; overflow-x: hidden; overscroll-behavior: contain; -webkit-overflow-scrolling: touch; display: flex; flex-direction: column; gap: 3px; border-top: 0; padding: 10px max(12px, calc((100% - 600px) / 2)) 14px; background: var(--bg); }
.rl-list .empty { margin: auto 0; }
.rl-day { align-self: center; margin: 12px 0 4px; padding: 3px 12px; border-radius: 10px; background: var(--surface); color: var(--muted); font-family: var(--f-label); font-size: 12px; letter-spacing: .08em; text-transform: uppercase; }
.rl-m { display: flex; flex-direction: column; max-width: 86%; min-width: 0; }
.rl-m.mine { align-self: flex-end; align-items: flex-end; }
.rl-m.theirs { align-self: flex-start; align-items: flex-start; }
.rl-m.first { margin-top: 10px; }
.rl-b { padding: 6px 10px 6px; border-radius: 12px; background: var(--surface-2); color: var(--ink); font-size: 15px; line-height: 1.38; text-align: left; cursor: pointer; min-width: 0; max-width: 100%; -webkit-touch-callout: none; }
.rl-m.mine > .rl-b { background: color-mix(in srgb, var(--accent) 24%, var(--surface)); }
.rl-m.mine.first > .rl-b { border-top-right-radius: 4px; }
.rl-m.theirs.first > .rl-b { border-top-left-radius: 4px; }
.rl-b:focus-visible { outline: 2px solid var(--brass); outline-offset: 2px; }
.rl-n { display: block; font-family: var(--f-label); font-weight: 700; font-size: 13.5px; letter-spacing: .04em; margin-bottom: 1px; width: fit-content; }
.rl-t { white-space: pre-wrap; overflow-wrap: anywhere; }
.rl-meta { float: right; margin: 7px 0 0 10px; font-size: 11px; line-height: 1; color: var(--muted); }
.rl-b .wcard { margin: 6px 0 2px; }
.rl-b .media { margin-top: 6px; gap: 6px; }
.rl-b .media img, .rl-b .media video { border-radius: 8px; max-height: 360px; min-height: 100px; }
.rl-cr { display: flex; flex-wrap: wrap; gap: 4px; margin: 3px 4px 0; }
.rl-cr:empty { display: none; }
.rl-cr button { min-height: 28px; padding: 0 9px; border: 1px solid var(--line); border-radius: 14px; background: var(--surface); color: var(--ink); font-size: 13.5px; cursor: pointer; }
.rl-cr button.me { border-color: var(--accent); color: var(--accent); font-weight: 700; }
.rl-reps { align-self: stretch; display: flex; flex-direction: column; gap: 4px; margin: 4px 0 0 12px; padding-left: 9px; border-left: 2px solid var(--line); }
.rl-m.mine .rl-reps { margin: 4px 12px 0 0; padding: 0 9px 0 0; border-left: 0; border-right: 2px solid var(--line); }
.rl-r { align-self: flex-start; max-width: 94%; padding: 5px 9px; border-radius: 10px; background: var(--surface); border: 1px solid var(--line); font-size: 14px; line-height: 1.35; cursor: pointer; text-align: left; min-width: 0; -webkit-touch-callout: none; }
.rl-r.mine { align-self: flex-end; background: color-mix(in srgb, var(--accent) 14%, var(--surface)); }
.rl-r .rl-n { font-size: 12.5px; }
.rl-more, .rl-rb { align-self: flex-start; min-height: 30px; padding: 2px 0; background: none; border: 0; font-family: var(--f-label); font-weight: 700; font-size: 12.5px; letter-spacing: .08em; text-transform: uppercase; cursor: pointer; }
.rl-more { color: var(--brass); }
.rl-rb { color: var(--muted); margin-left: 12px; }
.rl-m.mine .rl-rb { align-self: flex-end; margin: 0 12px 0 0; }
.rl-rb.on { color: var(--accent); }
.rl-m .ed-form { width: min(100%, 420px); }
.rl-m.flash > .rl-b, .rl-m.flash { animation: fsflash 2s ease; }
.rl-foot.composer { flex: 0 0 auto; gap: 0; background: var(--surface); border-top: 1px solid var(--line); padding: 0 max(10px, calc((100% - 620px) / 2)) env(safe-area-inset-bottom, 0px); }
#rl-bar { display: flex; align-items: center; gap: 10px; margin: 8px 0 0; padding: 6px 10px; border-left: 3px solid var(--brass); border-radius: 6px; background: color-mix(in srgb, var(--ink) 7%, transparent); font-size: 13px; color: var(--muted); }
#rl-bar[hidden] { display: none !important; }
#rl-bar > div { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
#rl-bar b { color: var(--brass); }
#rl-bar button { flex: none; width: 32px; height: 32px; border: 0; border-radius: 50%; background: transparent; color: var(--muted); font-size: 19px; }
.rl-foot .chips:not(:empty) { margin-top: 8px; }
.rl-foot .error { margin: 6px 4px 0; }
.rl-cmp { display: flex; align-items: flex-end; gap: 8px; padding: 8px 0; }
.rl-cmp .mention-wrap { flex: 1 1 auto; min-width: 0; }
#composer .rl-cmp textarea { display: block; width: 100%; min-height: 46px; max-height: 140px; resize: none; padding: 12px 16px; border-radius: 23px; background: var(--bg); border: 1px solid var(--line); color: var(--ink); line-height: 1.3; font-size: 16px; }
.rl-foot .mentions { top: auto; bottom: calc(100% + 6px); }
.rl-clip { flex: none; width: 46px; height: 46px; border-radius: 50%; border: 1px solid var(--line); background: var(--bg); color: var(--muted); display: grid; place-items: center; cursor: pointer; }
.rl-clip svg { width: 21px; height: 21px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.rl-send { flex: none; width: 46px; height: 46px; border: 0; border-radius: 50%; background: var(--accent); color: var(--accent-ink); display: grid; place-items: center; cursor: pointer; }
.rl-send:disabled { opacity: .45; cursor: default; }
.rl-send svg { width: 22px; height: 22px; fill: none; stroke: currentColor; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
.rl-sheet .rl-em { display: flex; gap: 6px; margin: 2px 0 12px; }
.rl-sheet .rl-em button { flex: 1; min-height: 52px; border: 1px solid var(--line); border-radius: 10px; background: var(--surface); color: var(--ink); display: grid; justify-items: center; align-content: center; gap: 1px; cursor: pointer; }
.rl-sheet .rl-em button.me { border-color: var(--accent); }
.rl-sheet .rl-em .e { font-size: 24px; line-height: 1.1; }
.rl-sheet .rl-em .l { font-family: var(--f-label); font-weight: 600; font-size: 10.5px; letter-spacing: .08em; text-transform: uppercase; color: var(--muted); }
.rl-sheet .rl-mn { display: flex; flex-direction: column; gap: 8px; }
.rl-sheet .rl-mn .btn { width: 100%; }
.rl-sheet .rl-mn .btn.danger { border-color: var(--danger); color: var(--danger); }
.rl-sheet .rl-q { margin: 0 0 10px; padding: 6px 10px; border-left: 3px solid var(--brass); font-size: 13.5px; color: var(--muted); display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
.tabbar button { position: relative; }
.rl-badge { position: absolute; top: 6px; left: calc(50% + 6px); min-width: 18px; height: 18px; padding: 0 5px; border-radius: 9px; background: var(--hot); color: #fff; font-family: var(--f-label); font-weight: 700; font-size: 11px; line-height: 18px; letter-spacing: 0; text-align: center; }
'''
rep('.onb-tiles { display: grid;', CSS + '.onb-tiles { display: grid;')

# ------------------------------------------------------------------ seen state carries a Rally marker so the tab can show what is new
rep('saveSeen: function (uid, o) { return this.db.doc("data/users/" + uid + "/seen").set({ tags: Number(o.tags) || 0 }); },',
    'saveSeen: function (uid, o) { return this.db.doc("data/users/" + uid + "/seen").set({ tags: Number(o.tags) || 0, rally: Number(o.rally) || 0 }); },')
rep('B.watchSeen(state.me, function (o) { state.seen = { tags: Number(o.tags) || 0 }; drawTagBells(); });',
    'B.watchSeen(state.me, function (o) { state.seen = { tags: Number(o.tags) || 0, rally: Math.max(Number(o.rally) || 0, Number(state.seen && state.seen.rally) || 0) }; drawTagBells(); rlBadge(); });')
rep('if (latest > seen) { state.seen = Object.assign({}, state.seen || {}, { tags: latest });',
    'if (latest > seen) { state.seen = Object.assign({}, state.seen || {}, { tags: latest, rally: Number(state.seen && state.seen.rally) || 0 });')

# ------------------------------------------------------------------ navigation: Rally fills the screen like a chat
rep('    if (p === "checkin") drawFeed();\n    if (p === "devo")',
    '    $("scroll").classList.toggle("rally-mode", p === "checkin"); rlBadge();\n    if (p === "checkin") { rlStick = true; drawFeed(true); }\n    if (p === "devo")')

# ------------------------------------------------------------------ drawFeed: keep the list where he left it, stick to the newest on open
rep('''    var sc = $("scroll"), se = document.scrollingElement, keepTop = sc ? sc.scrollTop : 0, keepDoc = se ? se.scrollTop : 0;
    // Hold the height while rebuilding so the page doesn't jump to the top.
    feed.style.minHeight = feed.offsetHeight + "px"; feed.textContent = "";
    try { drawFeedInner(feed); } finally { feed.style.minHeight = ""; if (state.page === "checkin") { if (sc) sc.scrollTop = keepTop; if (se) se.scrollTop = keepDoc; } }''',
'''    var keepTop = feed.scrollTop, near = feed.scrollHeight - feed.scrollTop - feed.clientHeight < 140;
    feed.textContent = "";
    try { drawFeedInner(feed); } finally { if (rlStick || near || !feed.dataset.ready) { feed.scrollTop = feed.scrollHeight; rlStick = false; } else feed.scrollTop = keepTop; feed.dataset.ready = "1"; rlSeen(); }''')
rep('  function drawFeed(force) {\n    var feed = $("feed"); if (!feed) return;',
    '  function drawFeed(force) {\n    var feed = $("feed"); if (!feed) return; rlBadge();')
rep("Object.keys(state.reported || {}), state.me || \"\", !!state.canWrite,",
    "Object.keys(state.reported || {}), state.me || \"\", !!state.canWrite, JSON.stringify(state.repliesAll || {}), state.rlReply ? state.rlReply.postId : \"\", state.editing ? state.editing.type + state.editing.id : \"\",")
rep('if (!(ae && (ae.id === "reply-in" || /^ed-/.test(ae.id || "")) && ae.closest && ae.closest(\'[data-replies="\' + p.id + \'"]\'))) refreshReplies(p.id); });',
    'if (!(ae && /^ed-/.test(ae.id || "") && ae.closest && ae.closest(\'[data-post="\' + p.id + \'"]\'))) refreshReplies(p.id); });')

# ------------------------------------------------------------------ the feed itself
rep_between('function drawFeedInner(feed) {', '  function drawChips() {', r'''function drawFeedInner(feed) {
    var blocked = state.settings.blocked || {};
    var posts = state.posts.filter(function (p) { return p.uid === state.me || !blocked[p.uid]; }).slice().sort(function (a, b) { return (a.createdAt || 0) - (b.createdAt || 0); });
    if (!posts.length) {
      var e = el("div", "empty"); e.appendChild(el("strong", null, "No posts yet"));
      e.appendChild(document.createTextNode("Be the first. Post your workout, a photo, or a word for a brother.")); feed.appendChild(e); return;
    }
    var prev = null, prevHadReps = false;
    posts.forEach(function (p) {
      if (!prev || dkey(new Date(prev.createdAt)) !== dkey(new Date(p.createdAt))) feed.appendChild(el("div", "rl-day", rlDayLabel(p.createdAt)));
      var mine = p.uid === state.me, first = !prev || prevHadReps || prev.uid !== p.uid || p.createdAt - prev.createdAt > 300000 || dkey(new Date(prev.createdAt)) !== dkey(new Date(p.createdAt));
      var w = el("div", "rl-m " + (mine ? "mine" : "theirs") + (first ? " first" : "")); w.dataset.post = p.id;
      var editingThis = state.editing && state.editing.type === "post" && state.editing.id === p.id && mine;
      if (editingThis) {
        w.appendChild(editBox(p.id, p.text, 1000, function (t) {
          var ments = mentionsIn(t, p.mentions); p.text = t; p.mentions = ments; p.editedAt = Date.now(); stopEditing(); drawFeed(true);
          if (B.db) B.editPost(p.id, t, ments).catch(function () { postError("Couldn’t save your edit. Check your connection and try again."); });
        }, function () { stopEditing(); drawFeed(true); }));
      } else {
        var b = el("div", "rl-b"); b.tabIndex = 0; b.setAttribute("role", "button"); b.setAttribute("aria-label", (mine ? "Your post" : nameOf(p.uid) + "'s post") + ". Tap for options.");
        if (!mine && first) { var n = el("span", "rl-n", nameOf(p.uid)); n.style.color = rlColor(p.uid); makeLink(n, p.uid); b.appendChild(n); }
        if (p.text) { var tx = el("div", "rl-t"); appendWithMentions(tx, p.text, p.mentions); b.appendChild(tx); }
        if (p.card) b.appendChild(workoutCardEl(p.card, true));
        if (p.media && p.media.length) {
          var md = el("div", "media");
          p.media.forEach(function (m) {
            if (!m || !m.id) return;
            if (m.type === "video") { var v = el("video"); v.controls = true; v.preload = "metadata"; v.playsInline = true; v.src = "/_blob/" + m.id; md.appendChild(v); }
            else { var im = el("img"); im.alt = "Photo from " + nameOf(p.uid); im.loading = "lazy"; im.src = "/_blob/" + m.id; md.appendChild(im); }
          });
          b.appendChild(md);
        }
        var meta = el("span", "rl-meta", (p.editedAt ? "edited " : "") + rlTime(p.createdAt)); if (p.text && !p.media.length && !p.card) b.lastChild.appendChild(meta); else b.appendChild(meta);
        rlTap(b, function () { rlMenu(p, null); });
        w.appendChild(b);
      }
      var cr = el("div", "rl-cr"); cr.dataset.reacts = p.id; rlChips(cr, p.id); w.appendChild(cr);
      var reps = (state.replies || []).filter(function (r) { return r.postId === p.id && (r.uid === state.me || !blocked[r.uid]); }).sort(function (a, b) { return (a.createdAt || 0) - (b.createdAt || 0); });
      if (reps.length) {
        var rw = el("div", "rl-reps"); rw.dataset.replies = p.id;
        var all = state.repliesAll && state.repliesAll[p.id], start = all ? 0 : Math.max(0, reps.length - 2);
        if (start > 0) { var mb = el("button", "rl-more", "View " + start + " more " + (start === 1 ? "reply" : "replies")); mb.type = "button"; mb.addEventListener("click", function () { state.repliesAll = state.repliesAll || {}; state.repliesAll[p.id] = true; drawFeed(true); }); rw.appendChild(mb); }
        reps.slice(start).forEach(function (r) {
          var rm = r.uid === state.me, edR = state.editing && state.editing.type === "reply" && state.editing.id === r.id && rm;
          if (edR) { rw.appendChild(editBox(r.id, r.text, 500, function (t) {
              var ments = mentionsIn(t, r.mentions || []); r.text = t; r.mentions = ments; r.editedAt = Date.now(); stopEditing(); drawFeed(true);
              if (B.db) B.editReply(r.id, t, ments).catch(function () { postError("Couldn’t save your edit. Check your connection and try again."); });
            }, function () { stopEditing(); drawFeed(true); })); return; }
          var rb = el("div", "rl-r" + (rm ? " mine" : "")); rb.tabIndex = 0; rb.setAttribute("role", "button"); rb.setAttribute("aria-label", (rm ? "Your reply" : nameOf(r.uid) + "'s reply") + ". Tap for options.");
          var rn = el("span", "rl-n", rm ? "You" : nameOf(r.uid)); rn.style.color = rlColor(r.uid); if (!rm) makeLink(rn, r.uid); rb.appendChild(rn);
          var rt = el("div", "rl-t"); appendWithMentions(rt, r.text, r.mentions || []); rt.appendChild(el("span", "rl-meta", (r.editedAt ? "edited " : "") + rlTime(r.createdAt))); rb.appendChild(rt);
          if (!/^local_/.test(r.id)) rlTap(rb, function () { rlMenu(p, r); });
          rw.appendChild(rb);
        });
        w.appendChild(rw);
      }
      if (state.me && state.canWrite) { var on = state.rlReply && state.rlReply.postId === p.id, ry = el("button", "rl-rb" + (on ? " on" : ""), on ? "Replying…" : "Reply"); ry.type = "button"; ry.addEventListener("click", function () { rlStartReply(p); }); w.appendChild(ry); }
      feed.appendChild(w); prev = p; prevHadReps = reps.length > 0;
    });
  }
  /* ---------- Rally helpers ---------- */
  var rlStick = false;
  function rlTime(ms) { return new Date(ms).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" }); }
  function rlDayLabel(ms) { var d = new Date(ms), k = dkey(d); if (k === todayKey()) return "Today"; if (k === addDays(todayKey(), -1)) return "Yesterday"; return d.toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" }); }
  function rlColor(uid) { var h = 0, p = ["var(--accent)", "var(--brass)", "var(--hot)", "var(--ink)"]; String(uid).split("").forEach(function (c) { h = (h * 31 + c.charCodeAt(0)) >>> 0; }); return p[h % p.length]; }
  // A tap opens the options. Taps on names, videos, links and workout cards keep doing their own thing.
  function rlTap(node, fn) {
    node.addEventListener("click", function (ev) { if (ev.target.closest("a, video, .clk, button, .wcard, input, textarea")) return; fn(); });
    node.addEventListener("keydown", function (ev) { if (ev.target === node && (ev.key === "Enter" || ev.key === " ")) { ev.preventDefault(); fn(); } });
  }
  function rlChips(box, postId) {
    var rs = reactsFor(postId), can = !!(state.me && state.canWrite); box.textContent = "";
    REACTS.forEach(function (k) {
      var n = rs.c[k[0]] || 0; if (!n) return;
      var b = el("button", rs.mine === k[0] ? "me" : null, k[1] + (n > 1 ? " " + n : "")); b.type = "button"; b.disabled = !can;
      b.setAttribute("aria-label", k[2] + ", " + n + (rs.mine === k[0] ? ". You reacted. Tap to take it back." : ". Tap to add yours."));
      b.addEventListener("click", function () { setMyReact(postId, k[0]); }); box.appendChild(b);
    });
  }
  function rlBar() {
    var bar = $("rl-bar"), ta = $("post-text"), clip = $("attach-label"); if (!bar) return;
    var r = state.rlReply; bar.textContent = "";
    if (!r) { bar.hidden = true; if (ta) ta.placeholder = "Post to the brothers"; if (clip && B.canUpload && B.canUpload()) clip.hidden = false; return; }
    var d = el("div"); d.appendChild(el("b", null, "Replying to " + (r.uid === state.me ? "your post" : nameOf(r.uid)))); d.appendChild(el("br")); d.appendChild(document.createTextNode(r.snip || "")); bar.appendChild(d);
    var x = el("button", null, "×"); x.type = "button"; x.setAttribute("aria-label", "Cancel reply"); x.addEventListener("click", function () { state.rlReply = null; rlBar(); drawFeed(true); }); bar.appendChild(x);
    bar.hidden = false; if (ta) ta.placeholder = "Reply"; if (clip) clip.hidden = true;
  }
  function rlStartReply(p) {
    if (!state.me || !state.canWrite) return;
    if (state.rlReply && state.rlReply.postId === p.id) { state.rlReply = null; rlBar(); drawFeed(true); return; }
    state.rlReply = { postId: p.id, uid: p.uid, snip: String(p.text || (p.card ? "Workout" : "Photo")).replace(/\s+/g, " ").slice(0, 90) };
    if (state.files.length) { state.files = []; drawChips(); }
    rlBar(); drawFeed(true); postError("");
    setTimeout(function () { var t = $("post-text"); if (t) try { t.focus({ preventScroll: true }); } catch (e) {} var w = document.querySelector('#feed [data-post="' + p.id + '"]'); if (w && w.scrollIntoView) w.scrollIntoView({ block: "nearest" }); }, 0);
  }
  function rlMenu(p, r) {
    var old = $("cdlg"); if (old) old.remove();
    var it = r || p, mine = it.uid === state.me, can = !!(state.me && state.canWrite);
    var back = el("div", "cdlg"); back.id = "cdlg"; var box = el("div", "cdlg-box nw-box rl-sheet"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-label", r ? "Reply options" : "Post options");
    function close() { back.remove(); }
    var snip = String(it.text || (p.card ? "Workout" : "Photo")).replace(/\s+/g, " ").slice(0, 160); box.appendChild(el("p", "rl-q", (mine ? "You" : nameOf(it.uid)) + ": " + snip));
    if (!r && can) {
      var em = el("div", "rl-em"), cur = reactsFor(p.id).mine;
      REACTS.forEach(function (k) { var b = el("button", cur === k[0] ? "me" : null); b.type = "button"; b.setAttribute("aria-pressed", String(cur === k[0])); b.setAttribute("aria-label", k[2]); b.appendChild(el("span", "e", k[1])); b.appendChild(el("span", "l", k[2])); b.addEventListener("click", function () { close(); setMyReact(p.id, k[0]); }); em.appendChild(b); });
      box.appendChild(em);
    }
    var mn = el("div", "rl-mn");
    function item(label, fn, cls) { var b = el("button", "btn ghost" + (cls ? " " + cls : ""), label); b.type = "button"; b.addEventListener("click", fn); mn.appendChild(b); return b; }
    if (can) item("Reply", function () { close(); rlStartReply(p); });
    if (mine && can && (r || p.text || !p.media.length)) item("Edit", function () { close(); state.editing = { type: r ? "reply" : "post", id: it.id }; state.editDraft = null; drawFeed(true); });
    if (mine && can) item("Delete", function () {
      close();
      if (r) confirmDelete({ title: "Delete this reply?", message: "Your reply will be removed for everyone.", yes: "Delete" }, function () { state.replies = state.replies.filter(function (x) { return x.id !== r.id; }); drawFeed(true); if (B.db) B.deleteReply(r.id).catch(noop); });
      else confirmDelete({ title: "Delete this post?", message: "Your post will be removed for everyone.", yes: "Delete" }, function () { state.posts = state.posts.filter(function (x) { return x.id !== p.id; }); if (state.rlReply && state.rlReply.postId === p.id) { state.rlReply = null; rlBar(); } drawFeed(true); if (B.db) B.deletePost(p.id).catch(noop); });
    }, "danger");
    item("Close", close);
    box.appendChild(mn); back.appendChild(box);
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); close(); } });
    document.body.appendChild(back); var f = box.querySelector("button"); if (f) try { f.focus({ preventScroll: true }); } catch (e) {}
  }
  function rlLatest() {
    var blocked = state.settings.blocked || {}, n = 0;
    (state.posts || []).forEach(function (p) { if (p.uid !== state.me && !blocked[p.uid] && p.createdAt > n) n = p.createdAt; });
    (state.replies || []).forEach(function (r) { if (r.uid !== state.me && !blocked[r.uid] && r.createdAt > n) n = r.createdAt; });
    return n;
  }
  function rlUnread() {
    var seen = Number(state.seen && state.seen.rally) || 0, blocked = state.settings.blocked || {}, n = 0; if (!state.me || !seen) return 0;
    (state.posts || []).forEach(function (p) { if (p.uid !== state.me && !blocked[p.uid] && p.createdAt > seen) n++; });
    (state.replies || []).forEach(function (r) { if (r.uid !== state.me && !blocked[r.uid] && r.createdAt > seen) n++; });
    return n;
  }
  function rlBadge() {
    var tb = document.querySelector('.tabbar [data-page="checkin"]'); if (!tb) return;
    var n = state.page === "checkin" ? 0 : rlUnread(), bd = tb.querySelector(".rl-badge");
    if (n) { if (!bd) { bd = el("span", "rl-badge"); tb.appendChild(bd); } bd.textContent = n > 99 ? "99+" : String(n); tb.setAttribute("aria-label", "Rally, " + n + " new"); }
    else { if (bd) bd.remove(); tb.removeAttribute("aria-label"); }
  }
  // Opening Rally marks everything up to the newest message as seen. A brand-new man starts with nothing unread.
  function rlSeen() {
    if (state.page !== "checkin" || !state.me) return;
    var latest = Math.max(rlLatest(), Number(state.seen && state.seen.rally) ? 0 : Date.now()), cur = Number(state.seen && state.seen.rally) || 0;
    if (latest > cur) { state.seen = Object.assign({}, state.seen || {}, { rally: latest }); if (B.db) B.saveSeen(state.me, state.seen).catch(noop); }
    rlBadge();
  }
''')

# refreshReplies: replies live inside the feed, so a change redraws the feed once.
rep_between('function refreshReplies(postId) {', '  /* ---------- Reactions: hold a post', '''function refreshReplies(postId) {
    if (rlRedrawT) return; rlRedrawT = setTimeout(function () { rlRedrawT = 0; drawFeed(true); }, 0);
  }
  var rlRedrawT = 0;
''')
rep_between('function refreshLikes() {', '  function closeReactPicker', '''function refreshLikes() {
    Array.prototype.forEach.call(document.querySelectorAll("#feed [data-reacts]"), function (b) { rlChips(b, b.dataset.reacts); });
  }
''')

# ------------------------------------------------------------------ the composer posts, or replies when a reply is open
rep('''  async function submitPost(ev) {
    ev.preventDefault();
    if (state.posting || !state.me || !state.canWrite || !B.db) return;
    var text = $("post-text").value.trim();''', '''  async function submitPost(ev) {
    ev.preventDefault();
    if (state.posting || !state.me || !state.canWrite || !B.db) return;
    var text = $("post-text").value.trim();
    if (state.rlReply) {
      var rp = state.rlReply; if (!text) { postError("Write your reply first."); return; }
      var r = { postId: rp.postId, uid: state.me, text: text.slice(0, 500), mentions: mentionsIn(text, state.mentions), createdAt: Date.now() };
      state.replies = (state.replies || []).concat([Object.assign({ id: "local_" + r.createdAt }, r)]);
      state.rlReply = null; $("post-text").value = ""; state.mentions.length = 0; hideMentions(); rlBar(); rlFit(); postError(""); rlStick = true; drawFeed(true);
      B.addReply(r).catch(function () { state.replies = state.replies.filter(function (x) { return x.id !== "local_" + r.createdAt; }); drawFeed(true); postError("Couldn\\u2019t send your reply. Check your connection and try again."); });
      return;
    }''')
rep('      $("post-text").value = ""; state.files = []; state.mentions.length = 0; drawChips(); hideMentions();',
    '      $("post-text").value = ""; state.files = []; state.mentions.length = 0; drawChips(); hideMentions(); rlFit(); rlStick = true; drawFeed(true);')
# grow the box as he types; Ctrl/Cmd+Enter sends
rep('    $("composer").addEventListener("submit", submitPost);',
    '''    $("composer").addEventListener("submit", submitPost);
    $("post-text").addEventListener("input", rlFit);
    $("post-text").addEventListener("keydown", function (ev) { if (ev.key === "Enter" && (ev.metaKey || ev.ctrlKey)) { ev.preventDefault(); $("composer").requestSubmit ? $("composer").requestSubmit() : submitPost(ev); } if (ev.key === "Escape" && state.rlReply) { state.rlReply = null; rlBar(); drawFeed(true); } });''')
rep('  function postError(msg) {', '  function rlFit() { var t = $("post-text"); if (!t) return; t.style.height = "auto"; t.style.height = Math.min(140, t.scrollHeight + 2) + "px"; }\n  function postError(msg) {')

# ------------------------------------------------------------------ jump to a post from a tag: scroll inside the chat list
rep('''      a.classList.add("flash"); setTimeout(function () { a.classList.remove("flash"); }, 2200);''',
    '''      a.classList.add("flash"); setTimeout(function () { a.classList.remove("flash"); }, 2200);''')

# ------------------------------------------------------------------ help text
rep('''      "Press and hold a post to react: \\uD83D\\uDD25 Strong for the effort, \\u2764\\uFE0F Brother when you\\'ve got his back. Tap a reaction again to take it back. Tap Reply to answer him. Tap Edit to fix your own post or reply, or Delete to remove it.",''',
    '''      "Tap a post to react: \\uD83D\\uDD25 Strong for the effort, \\u2764\\uFE0F Brother when you\\'ve got his back. Tap a reaction again to take it back.",
      "Tap Reply under a post to answer it. Replies stay right under the post they answer. Tap your own post or reply to edit or delete it.",''')
rep('checkin: { t: "Rally", why: "The group thread. Show up, share wins and encourage a brother.", how: [',
    'checkin: { t: "Rally", why: "The brothers\\u2019 chat. Show up, share wins and encourage a brother.", how: [')
rep('''      "Write a post and add a photo or video if you want. Type @ to tag someone.",''',
    '''      "Write at the bottom and tap the arrow to post. The paper clip adds a photo or video. Type @ to tag someone.",''')

# ------------------------------------------------------------------ version
m = re.search(r'var APP_VERSION = "[^"]+";', s); assert m
s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s)
print("patched ->", dst, len(s))
