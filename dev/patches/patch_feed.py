#!/usr/bin/env python3
"""On top of patch_rally.py: Rally laid out as a feed (newest first, full-width cards, replies in the card).
Usage: patch_feed.py <in.html> <out.html> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()

def rep(old, new, count=1):
    global s
    assert s.count(old) == count, ("anchor", old[:80], s.count(old))
    s = s.replace(old, new)

def rep_between(start, end, new):
    global s
    assert s.count(start) == 1, ("start", start[:60], s.count(start))
    i = s.index(start); j = s.index(end, i)
    s = s[:i] + new + s[j:]

# ---- HTML: post box sits right under the header; the feed fills the rest
rep('''    <div class="feed rl-list" id="feed" role="log" aria-live="polite" aria-labelledby="h-feed"></div>
    <form class="composer rl-foot" id="composer">''', '''    <form class="composer rl-foot" id="composer">''')
rep('''    </form>
  </div>

  <!-- DEVOTIONAL -->''', '''    </form>
    <div class="feed rl-list" id="feed" aria-labelledby="h-feed"></div>
  </div>

  <!-- DEVOTIONAL -->''')

# ---- CSS: cards
CSS = r'''/* Rally feed */
#page-checkin .rl-top { order: 0; }
#page-checkin .rl-foot { order: 1; border-top: 0; border-bottom: 1px solid var(--line); }
#page-checkin .rl-list { order: 2; }
#page-checkin.rl-replying .rl-foot { order: 3; border-bottom: 0; border-top: 1px solid var(--line); }
.rl-foot .mentions { top: calc(100% + 6px); bottom: auto; }
#page-checkin.rl-replying .rl-foot .mentions { top: auto; bottom: calc(100% + 6px); }
.rl-list.feed { gap: 10px; padding: 10px max(10px, calc((100% - 600px) / 2)) 18px; }
.rl-card { background: var(--surface); border: 1px solid var(--line); border-radius: 12px; padding: 11px 12px; display: flex; flex-direction: column; gap: 7px; min-width: 0; -webkit-touch-callout: none; }
.rl-card.mine { border-color: color-mix(in srgb, var(--accent) 35%, var(--line)); }
.rl-card.flash { animation: fsflash 2s ease; }
.rl-ph { display: flex; align-items: center; gap: 10px; min-width: 0; }
.rl-pa { flex: none; width: 38px; height: 38px; border-radius: 50%; overflow: hidden; display: grid; place-items: center; background: var(--surface-2); color: var(--ink); font-family: var(--f-label); font-weight: 700; font-size: 16px; border: 1px solid var(--line); }
.rl-pa img { width: 100%; height: 100%; object-fit: cover; display: block; }
.rl-who { min-width: 0; display: flex; flex-direction: column; }
.rl-who b { font-family: var(--f-label); font-weight: 700; font-size: 15.5px; letter-spacing: .04em; text-transform: uppercase; line-height: 1.1; width: fit-content; max-width: 100%; overflow-wrap: anywhere; }
.rl-who small { color: var(--muted); font-size: 12.5px; }
.rl-card > .rl-t { font-size: 15px; line-height: 1.45; cursor: pointer; }
.rl-card .wcard { margin: 0; }
.rl-card .media { margin: 0; gap: 6px; }
.rl-card .media img, .rl-card .media video { border-radius: 8px; max-height: 420px; min-height: 110px; }
.rl-acts { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; min-height: 30px; }
.rl-acts .rl-cr { margin: 0; }
.rl-acts .rl-cr:empty { display: flex; }
.rl-acts .rl-rb { margin: 0 0 0 auto; }
.rl-card .rl-reps { margin: 0 0 0 4px; padding-left: 10px; border-left: 2px solid var(--line); border-right: 0; }
.rl-card .rl-r { align-self: stretch; max-width: 100%; background: var(--bg); border: 0; }
.rl-card .rl-r.mine { background: color-mix(in srgb, var(--accent) 12%, var(--bg)); }
.rl-card .rl-r .rl-n { display: inline; margin: 0 6px 0 0; }
.rl-card .rl-r .rl-t { display: inline; }
.rl-card .rl-meta { float: none; display: inline-block; margin: 0 0 0 8px; vertical-align: baseline; }
.rl-card .ed-form { width: 100%; }
'''
rep('.onb-tiles { display: grid;', CSS + '.onb-tiles { display: grid;')

# ---- scrolling: open at the top (newest); keep his place on updates
rep('if (rlStick || near || !feed.dataset.ready) { feed.scrollTop = feed.scrollHeight; rlStick = false; } else feed.scrollTop = keepTop;',
    'if (rlStick || !feed.dataset.ready) { feed.scrollTop = 0; rlStick = false; } else feed.scrollTop = keepTop;')
# a sent reply keeps his place; a new post jumps to the top
rep('rlBar(); rlFit(); postError(""); rlStick = true; drawFeed(true);', 'rlBar(); rlFit(); postError(""); drawFeed(true);')

# ---- reply mode moves the box to the bottom
rep('    if (!r) { bar.hidden = true;', '    var pg = $("page-checkin"); if (pg) pg.classList.toggle("rl-replying", !!r);\n    if (!r) { bar.hidden = true;')

# ---- the feed itself
rep_between('function drawFeedInner(feed) {', '  /* ---------- Rally helpers ---------- */', r'''function drawFeedInner(feed) {
    var blocked = state.settings.blocked || {};
    var posts = state.posts.filter(function (p) { return p.uid === state.me || !blocked[p.uid]; }).slice().sort(function (a, b) { return (b.createdAt || 0) - (a.createdAt || 0); });
    if (!posts.length) {
      var e = el("div", "empty"); e.appendChild(el("strong", null, "No posts yet"));
      e.appendChild(document.createTextNode("Be the first. Post your workout, a photo, or a word for a brother.")); feed.appendChild(e); return;
    }
    var can = !!(state.me && state.canWrite);
    posts.forEach(function (p) {
      var mine = p.uid === state.me, card = el("article", "rl-card" + (mine ? " mine" : "")); card.dataset.post = p.id;
      card.tabIndex = 0; card.setAttribute("aria-label", (mine ? "Your post" : nameOf(p.uid) + "'s post") + ". Press Enter for options.");
      var ph = el("div", "rl-ph"), av = el("span", "rl-pa"); fillAvatar(av, p.uid); makeLink(av, p.uid); ph.appendChild(av);
      var who = el("div", "rl-who"), nm = el("b", null, mine ? "You" : nameOf(p.uid)); makeLink(nm, p.uid); who.appendChild(nm);
      who.appendChild(el("small", null, timeLabel(p.createdAt) + (p.editedAt ? " · edited" : ""))); ph.appendChild(who); card.appendChild(ph);
      var editingThis = state.editing && state.editing.type === "post" && state.editing.id === p.id && mine;
      if (editingThis) card.appendChild(editBox(p.id, p.text, 1000, function (t) {
        var ments = mentionsIn(t, p.mentions); p.text = t; p.mentions = ments; p.editedAt = Date.now(); stopEditing(); drawFeed(true);
        if (B.db) B.editPost(p.id, t, ments).catch(function () { postError("Couldn’t save your edit. Check your connection and try again."); });
      }, function () { stopEditing(); drawFeed(true); }));
      else if (p.text) { var tx = el("div", "rl-t"); appendWithMentions(tx, p.text, p.mentions); card.appendChild(tx); }
      if (p.card) card.appendChild(workoutCardEl(p.card, true));
      if (p.media && p.media.length) {
        var md = el("div", "media");
        p.media.forEach(function (m) {
          if (!m || !m.id) return;
          if (m.type === "video") { var v = el("video"); v.controls = true; v.preload = "metadata"; v.playsInline = true; v.src = "/_blob/" + m.id; md.appendChild(v); }
          else { var im = el("img"); im.alt = "Photo from " + nameOf(p.uid); im.loading = "lazy"; im.src = "/_blob/" + m.id; md.appendChild(im); }
        });
        card.appendChild(md);
      }
      var reps = (state.replies || []).filter(function (r) { return r.postId === p.id && (r.uid === state.me || !blocked[r.uid]); }).sort(function (a, b) { return (a.createdAt || 0) - (b.createdAt || 0); });
      var acts = el("div", "rl-acts"), cr = el("div", "rl-cr"); cr.dataset.reacts = p.id; rlChips(cr, p.id); acts.appendChild(cr);
      if (can) {
        var on = state.rlReply && state.rlReply.postId === p.id, ry = el("button", "rl-rb" + (on ? " on" : ""), on ? "Replying…" : "Reply" + (reps.length ? " · " + reps.length : "")); ry.type = "button";
        ry.addEventListener("click", function () { rlStartReply(p); }); acts.appendChild(ry);
      } else if (reps.length) acts.appendChild(el("span", "rl-rb", reps.length + (reps.length === 1 ? " reply" : " replies")));
      card.appendChild(acts);
      if (reps.length) {
        var rw = el("div", "rl-reps"); rw.dataset.replies = p.id;
        var all = state.repliesAll && state.repliesAll[p.id], start = all ? 0 : Math.max(0, reps.length - 2);
        if (start > 0) { var mb = el("button", "rl-more", "View " + start + " earlier " + (start === 1 ? "reply" : "replies")); mb.type = "button"; mb.addEventListener("click", function () { state.repliesAll = state.repliesAll || {}; state.repliesAll[p.id] = true; drawFeed(true); }); rw.appendChild(mb); }
        reps.slice(start).forEach(function (r) {
          var rm = r.uid === state.me, edR = state.editing && state.editing.type === "reply" && state.editing.id === r.id && rm;
          if (edR) { rw.appendChild(editBox(r.id, r.text, 500, function (t) {
              var ments = mentionsIn(t, r.mentions || []); r.text = t; r.mentions = ments; r.editedAt = Date.now(); stopEditing(); drawFeed(true);
              if (B.db) B.editReply(r.id, t, ments).catch(function () { postError("Couldn’t save your edit. Check your connection and try again."); });
            }, function () { stopEditing(); drawFeed(true); })); return; }
          var rb = el("div", "rl-r" + (rm ? " mine" : "")); rb.tabIndex = 0; rb.setAttribute("role", "button"); rb.setAttribute("aria-label", (rm ? "Your reply" : nameOf(r.uid) + "'s reply") + ". Tap for options.");
          var rn = el("span", "rl-n", rm ? "You" : nameOf(r.uid)); rn.style.color = rlColor(r.uid); if (!rm) makeLink(rn, r.uid); rb.appendChild(rn);
          var rt = el("span", "rl-t"); appendWithMentions(rt, r.text, r.mentions || []); rb.appendChild(rt);
          rb.appendChild(el("span", "rl-meta", (r.editedAt ? "edited " : "") + rlTime(r.createdAt)));
          if (!/^local_/.test(r.id)) rlTap(rb, function () { rlMenu(p, r); });
          rw.appendChild(rb);
        });
        card.appendChild(rw);
      }
      // Tapping the post itself (not its buttons, names, replies or video) opens the options.
      card.addEventListener("click", function (ev) { if (editingThis || ev.target.closest("a, video, .clk, button, .wcard, input, textarea, .rl-reps, .ed-form")) return; rlMenu(p, null); });
      card.addEventListener("keydown", function (ev) { if (ev.target === card && (ev.key === "Enter" || ev.key === " ")) { ev.preventDefault(); rlMenu(p, null); } });
      feed.appendChild(card);
    });
  }
''')

# ---- help text: newest on top, box at the top
rep('"Write at the bottom and tap the arrow to post. The paper clip adds a photo or video. Type @ to tag someone.",',
    '"Newest posts are on top. Write in the box at the top and tap the arrow to post. The paper clip adds a photo or video. Type @ to tag someone.",')
rep('"Tap Reply under a post to answer it. Replies stay right under the post they answer. Tap your own post or reply to edit or delete it.",',
    '"Tap Reply on a post to answer it. Your reply shows inside that post\\u2019s card. Tap your own post or reply to edit or delete it.",')

m = re.search(r'var APP_VERSION = "[^"]+";', s); assert m
s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s)
print("patched ->", dst, len(s))
