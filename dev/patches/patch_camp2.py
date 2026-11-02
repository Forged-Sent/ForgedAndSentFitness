#!/usr/bin/env python3
"""Campaigns, stage 2: team chat. The team page has a Team chat button with an unread count. It opens full screen
and works like Rally (posts, photos and videos, replies, reactions, @tags, edit and delete your own), with the team's
banner and a back button to the team page. Only the team's men (and the owner, to moderate) open it; the owner can
delete any team post. Posts live in tposts (team id on each); replies and reactions reuse Rally's.
Privacy note (agreed by Curtis 2026-10-31): on claude.ai the chat is hidden from other teams in the app, but the
storage can't restrict reading by team; true privacy comes with Firebase security rules.
Usage: patch_camp2.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new, cnt=1):
    global s
    assert s.count(old) == cnt, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

# ---- backend: team posts, and per-team "seen" marks
rep('    deletePost: function (id) { return this.db.doc("posts/" + id).delete(); },',
    '''    deletePost: function (id) { return this.db.doc("posts/" + id).delete(); },
    watchTPosts: function (team, cb) {
      return this.db.collection("tposts").where("team", "==", team).onSnapshot(function (s) {
        cb(s.docs.map(function (d) { var x = d.data() || {};
          return { id: d.id, team: String(x.team || ""), uid: x.uid, text: String(x.text || ""), media: Array.isArray(x.media) ? x.media : [], mentions: Array.isArray(x.mentions) ? x.mentions : [], card: null, ch: null, createdAt: Number(x.createdAt) || 0, editedAt: Number(x.editedAt) || 0 }; })
          .sort(function (a, b) { return b.createdAt - a.createdAt; }).slice(0, 200));
      }, noop);
    },
    addTPost: function (p) { return this.db.collection("tposts").add(p); },
    deleteTPost: function (id) { return this.db.doc("tposts/" + id).delete(); },
    editTPost: function (id, text, mentions) { return this.db.doc("tposts/" + id).update({ text: text, mentions: mentions, editedAt: Date.now() }); },''')
rep('saveSeen: function (uid, o) { return this.db.doc("data/users/" + uid + "/seen").set({ tags: Number(o.tags) || 0, rally: Number(o.rally) || 0 }); },',
    'saveSeen: function (uid, o) { return this.db.doc("data/users/" + uid + "/seen").set({ tags: Number(o.tags) || 0, rally: Number(o.rally) || 0, team: normTeamSeen(o.team || (state.seen && state.seen.team)) }); },')
rep('      B.watchSeen(state.me, function (o) { state.seen = { tags: Number(o.tags) || 0, rally: Math.max(Number(o.rally) || 0, Number(state.seen && state.seen.rally) || 0) }; drawTagBells(); rlBadge(); });',
    '''      B.watchSeen(state.me, function (o) { var tm = normTeamSeen(o.team), lt = (state.seen && state.seen.team) || {}; Object.keys(lt).forEach(function (k) { tm[k] = Math.max(tm[k] || 0, lt[k] || 0); }); state.seen = { tags: Number(o.tags) || 0, rally: Math.max(Number(o.rally) || 0, Number(state.seen && state.seen.rally) || 0), team: tm }; drawTagBells(); rlBadge(); if (state.page === "team") drawTeamPage(); });''')

# ---- which list the feed shows: Rally, or the open team chat
rep('  function drawFeed(force) {', '''  function feedPosts() { return state.chan ? (state.tposts || []).filter(function (p) { return p.team === state.chan; }) : state.posts; }
  function drawFeed(force) {''')
rep('    var sig = JSON.stringify([state.posts.map(function (p) { return p.id', '    var sig = JSON.stringify([state.chan || "", feedPosts().map(function (p) { return p.id')
rep('      if (rsig !== repSig) { repSig = rsig; state.posts.forEach(function (p) {', '      if (rsig !== repSig) { repSig = rsig; feedPosts().forEach(function (p) {')
rep('    var posts = state.posts.filter(function (p) { return p.uid === state.me || !blocked[p.uid]; })', '    var posts = feedPosts().filter(function (p) { return p.uid === state.me || !blocked[p.uid]; })')
rep('''      e.appendChild(document.createTextNode("Be the first. Post your workout, a photo, or a word for a brother.")); feed.appendChild(e); return;''',
    '''      e.appendChild(document.createTextNode(state.chan ? "Be the first. Rally your team: call out the double, pray for a brother, hold the wall." : "Be the first. Post your workout, a photo, or a word for a brother.")); feed.appendChild(e); return;''')
rep('        if (B.db) B.editPost(p.id, t, ments).catch(', '        if (B.db) (p.team ? B.editTPost(p.id, t, ments) : B.editPost(p.id, t, ments)).catch(')
rep('    if (mine && can) item("Delete", function () {', '    if ((mine || (p.team && state.isOwner && !r)) && can) item("Delete", function () {')
rep('else confirmDelete({ title: "Delete this post?", message: "Your post will be removed for everyone.", yes: "Delete" }, function () { state.posts = state.posts.filter(function (x) { return x.id !== p.id; });',
    'else confirmDelete({ title: "Delete this post?", message: mine ? "Your post will be removed for everyone." : "This post will be removed for the whole team.", yes: "Delete" }, function () { if (p.team) { state.tposts = (state.tposts || []).filter(function (x) { return x.id !== p.id; }); drawFeed(true); if (B.db) B.deleteTPost(p.id).catch(noop); return; } state.posts = state.posts.filter(function (x) { return x.id !== p.id; });')
# Rally's own unread count leaves team-chat replies out
rep('''    (state.replies || []).forEach(function (r) { if (r.uid !== state.me && !blocked[r.uid] && r.createdAt > n) n = r.createdAt; });
    return n;''', '''    var rids = {}; (state.posts || []).forEach(function (p) { rids[p.id] = 1; });
    (state.replies || []).forEach(function (r) { if (rids[r.postId] && r.uid !== state.me && !blocked[r.uid] && r.createdAt > n) n = r.createdAt; });
    return n;''')
rep('''    (state.replies || []).forEach(function (r) { if (r.uid !== state.me && !blocked[r.uid] && r.createdAt > seen) n++; });
    return n;''', '''    var rids = {}; (state.posts || []).forEach(function (p) { rids[p.id] = 1; });
    (state.replies || []).forEach(function (r) { if (rids[r.postId] && r.uid !== state.me && !blocked[r.uid] && r.createdAt > seen) n++; });
    return n;''')
rep('''  function rlSeen() {
    if (state.page !== "checkin" || !state.me) return;''', '''  function rlSeen() {
    if (state.page !== "checkin" || !state.me) return;
    if (state.chan) { teamSeen(state.chan); return; }''')
rep('    var n = state.page === "checkin" ? 0 : rlUnread(), bd = tb.querySelector(".rl-badge");', '    var n = state.page === "checkin" && !state.chan ? 0 : rlUnread(), bd = tb.querySelector(".rl-badge");')
# tags: team posts that tag him count too, and open the team chat
rep('''    state.posts.forEach(function (p) { if (p.uid !== me && (p.mentions || []).some(function (m) { return m && m.id === me; })) out.push({ kind: "post", id: p.id, postId: p.id, uid: p.uid, text: p.text, at: p.createdAt }); });''',
    '''    state.posts.concat(state.tposts || []).forEach(function (p) { if (p.uid !== me && (p.mentions || []).some(function (m) { return m && m.id === me; })) out.push({ kind: "post", id: p.id, postId: p.id, uid: p.uid, text: p.text, at: p.createdAt }); });''')
rep('''  function showPost(postId, openReplies) {
    go("checkin");''', '''  function showPost(postId, openReplies) {
    var tp = (state.tposts || []).filter(function (x) { return x.id === postId; })[0];
    if (tp) openTeamChat(tp.team); else go("checkin");''')

# ---- composer posts to the team when the team chat is open
rep('      await B.addPost({ uid: state.me, text: text, media: media, mentions: ments, createdAt: Date.now(), date: todayKey() });\n      var ct = taskOfKind("checkin"); if (ct && !myDoc().done[ct.id]) toggle(ct.id);',
    '      if (state.chan) await B.addTPost({ team: state.chan, uid: state.me, text: text, media: media, mentions: ments, createdAt: Date.now(), date: todayKey() });\n      else { await B.addPost({ uid: state.me, text: text, media: media, mentions: ments, createdAt: Date.now(), date: todayKey() });\n      var ct = taskOfKind("checkin"); if (ct && !myDoc().done[ct.id]) toggle(ct.id); }')

# ---- opening the team chat (reuses the Rally screen with the team's header)
rep('''  function go(p) {
    if (p === "board" && state.page !== "board") state.boardView = "kw";''', '''  function go(p) {
    if (p === "board" && state.page !== "board") state.boardView = "kw";
    if (p === "checkin") { state.chan = state.chanNext || ""; state.chanNext = ""; } else state.chan = "";
    paintChanHead();''')
rep('''      if (b.dataset.page === (p === "workout" || p === "video" || p === "chal" ? "train" : p === "ideas" ? "fuel" : p === "team" ? "board" : p))''',
    '''      if (b.dataset.page === (p === "workout" || p === "video" || p === "chal" ? "train" : p === "ideas" ? "fuel" : p === "team" || (p === "checkin" && state.chan) ? "board" : p))''')

CHAT = r'''  /* ---------- Team chat ---------- */
  function normTeamSeen(x) { var o = {}; if (x && typeof x === "object") Object.keys(x).slice(0, 20).forEach(function (k) { if (/^[A-Za-z0-9_-]{1,80}$/.test(k) && Number(x[k]) > 0) o[k] = Number(x[k]); }); return o; }
  var tpostSub = { team: "", off: null };
  function campWatchTPosts() {
    var t = myTeam(), open = state.chanNext || state.chan, want = t ? t.id : "";
    if (open && state.isOwner) want = open;
    if (!B.db || want === tpostSub.team) return;
    if (tpostSub.off) try { tpostSub.off(); } catch (e) {}
    tpostSub = { team: want, off: null }; state.tposts = [];
    if (want) tpostSub.off = B.watchTPosts(want, function (rows) { state.tposts = rows; if (state.page === "checkin" && state.chan) drawFeed(); if (state.page === "team") drawTeamPage(); drawTagBells(); loadProfiles(); });
  }
  function teamLatest(team) {
    var ids = {}, n = 0, blocked = state.settings.blocked || {};
    (state.tposts || []).forEach(function (p) { if (p.team !== team) return; ids[p.id] = 1; if (p.uid !== state.me && !blocked[p.uid] && p.createdAt > n) n = p.createdAt; });
    (state.replies || []).forEach(function (r) { if (ids[r.postId] && r.uid !== state.me && !blocked[r.uid] && r.createdAt > n) n = r.createdAt; });
    return n;
  }
  function teamUnread(team) {
    var seen = ((state.seen && state.seen.team) || {})[team] || 0, ids = {}, n = 0, blocked = state.settings.blocked || {};
    (state.tposts || []).forEach(function (p) { if (p.team !== team) return; ids[p.id] = 1; if (p.uid !== state.me && !blocked[p.uid] && p.createdAt > seen) n++; });
    (state.replies || []).forEach(function (r) { if (ids[r.postId] && r.uid !== state.me && !blocked[r.uid] && r.createdAt > seen) n++; });
    return n;
  }
  function teamSeen(team) {
    if (!state.me) return; var latest = teamLatest(team), tm = Object.assign({}, (state.seen && state.seen.team) || {});
    if (latest > (tm[team] || 0)) { tm[team] = latest; state.seen = Object.assign({}, state.seen || {}, { team: tm }); if (B.db) B.saveSeen(state.me, state.seen).catch(noop); }
  }
  function openTeamChat(id) { state.chanNext = id; state.teamId = id; campWatchTPosts(); rlStick = true; go("checkin"); drawFeed(true); }
  var chanHeadSaved = null;
  function paintChanHead() {
    var top = document.querySelector("#page-checkin .rl-top"); if (!top) return;
    var av = top.querySelector(".rl-av"), h = $("h-feed"), sm = top.querySelector(".rl-tt small"), bk = $("chan-back"), pt = $("post-text");
    if (!chanHeadSaved) chanHeadSaved = { h: h.textContent, sm: sm.textContent, ph: pt ? pt.placeholder : "" };
    var t = state.chan ? (teamById(state.chan) || { name: "Team chat", banner: "trumpet", men: [] }) : null;
    if (!bk) { bk = el("div", "chan-back"); bk.id = "chan-back"; var b = el("button", "mini", "‹ Team page"); b.type = "button"; b.addEventListener("click", function () { openTeam(state.teamId || state.chan); }); bk.appendChild(b); top.parentNode.insertBefore(bk, top); }
    bk.hidden = !t;
    var bn = top.querySelector(".chan-ban"); if (bn) bn.remove();
    if (t) { av.hidden = true; var bb = bannerEl(t.banner, "chan-ban"); top.insertBefore(bb, av); h.textContent = t.name; sm.textContent = "Team chat · " + t.men.length + (t.men.length === 1 ? " man" : " men") + " · only your team sees this"; if (pt) pt.placeholder = "Post to " + t.name; }
    else { av.hidden = false; h.textContent = chanHeadSaved.h; sm.textContent = chanHeadSaved.sm; if (pt) pt.placeholder = chanHeadSaved.ph; }
  }
'''
rep('  function openRaiseTeam(edit) {', CHAT + '  function openRaiseTeam(edit) {')
# Team page: the chat button (members, and the owner to moderate)
rep('''    // Actions
    if (isCap && (ph === "signup" || ph === "soon") && state.canWrite) {''', '''    // Team chat
    if (onIt || state.isOwner) {
      var un = onIt ? teamUnread(t.id) : 0, cb = el("button", "btn ghost tm-chat"); cb.type = "button";
      cb.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v11H11l-5 4v-4H4z"/></svg>';
      cb.appendChild(el("span", null, "Team chat")); if (un) cb.appendChild(el("span", "tm-unread", un > 99 ? "99+" : String(un))); cb.appendChild(el("span", "tm-chev", "›"));
      cb.setAttribute("aria-label", "Open team chat" + (un ? ", " + un + " new" : "")); cb.addEventListener("click", function () { openTeamChat(t.id); }); body.appendChild(cb);
    }
    // Actions
    if (isCap && (ph === "signup" || ph === "soon") && state.canWrite) {''')
# start/keep the team-post subscription in step with his team
rep('    campDirty(); campWatchChecks();', '    campDirty(); campWatchChecks(); campWatchTPosts();')
rep('#team-body > .btn { width: 100%; margin-top: 8px; }', '''#team-body > .btn { width: 100%; margin-top: 8px; }
.tm-chat { display: flex !important; align-items: center; justify-content: center; gap: 10px; position: relative; margin-top: 14px !important; }
.tm-chat svg { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linejoin: round; }
.tm-unread { min-width: 24px; height: 24px; padding: 0 7px; border-radius: 12px; background: var(--accent); color: #111; font-size: 13px; letter-spacing: 0; display: inline-grid; place-items: center; }
.tm-chev { position: absolute; right: 14px; }
.chan-back { padding: 6px 0 2px; } .chan-back[hidden] { display: none; }
.rl-top .chan-ban { width: 38px; height: 43px; }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
