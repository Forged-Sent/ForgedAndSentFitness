#!/usr/bin/env python3
"""Owner tools: a page only the owner sees, opened from an "Owner tools" row at the top of Settings. It houses
Campaigns (moved from Settings), Reports (posts brothers flagged: Keep or Remove post), and App (the testing date,
moved from Settings so brothers no longer see it). Members and Content are listed as coming next.
Approved direction by Curtis 2026-11-01 (mockup). Usage: patch_owner.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

def cut(pattern):
    global s
    m = re.search(pattern, s, re.S); assert m, pattern
    s = s.replace(m.group(0), "", 1); return m.group(0)

owner_sec = cut(r'    <section aria-labelledby="h-s-owner" id="s-owner-sec" hidden>.*?</section>\n\n')
test_sec = cut(r'    <section aria-labelledby="h-s-test">.*?</section>\n\n')
owner_sec = owner_sec.replace('data-sub="Only you see this. Campaign dates, the weekly double, team names.">Owner</h2>', 'data-sub="Sign-up and start dates, the weekly double, team names.">Campaigns</h2>')
test_sec = test_sec.replace('>Testing: change the date</h2>', '>App: test a different date</h2>')

PAGE = '''  <div class="page" id="page-owner" hidden>
    <div class="pbar">
      <button class="mini" type="button" id="own-back">&lsaquo; Settings</button>
      <span class="date label-caps">Only you see this</span>
    </div>
    <h1 class="pg">Owner tools</h1>
    <p class="note">Everything you need to run Forged &amp; Sent, in one place.</p>

    <section aria-labelledby="h-o-rep">
      <div class="section-head"><h2 class="label-caps" id="h-o-rep" data-sub="Posts brothers flagged. Keep them or remove them.">Reports</h2></div>
      <div id="o-reports"></div>
    </section>

''' + owner_sec + test_sec + '''    <section class="o-soon" aria-label="Coming next">
      <h2 class="label-caps">Coming next</h2>
      <div class="o-soon-row"><b>Members</b><span>Who’s in, who invited whom, who hasn’t agreed to the latest terms.</span></div>
      <div class="o-soon-row"><b>Content</b><span>This week’s challenges, the lift list and the daily boxes.</span></div>
    </section>
  </div>

'''
rep('''  <div class="page" id="page-camp" hidden>''', PAGE + '''  <div class="page" id="page-camp" hidden>''')
# Owner row at top of Settings
rep('''    <section aria-labelledby="h-s-guide">''', '''    <button type="button" class="set-ownrow" id="set-owner" hidden><span class="sc-txt"><span>Owner tools</span><small>Campaigns, reports and app tools. Only you see this.</small></span><span class="o-badge" id="o-badge" hidden></span><span class="sc-chev">›</span></button>

    <section aria-labelledby="h-s-guide">''')
rep('''"h-s-test", "h-s-export", "h-s-legal", "h-s-acct"].forEach''', '''"h-s-test", "h-s-export", "h-s-legal", "h-s-acct", "h-o-rep"].forEach''')
# routing
rep('''"chal", "ideas", "team", "camp"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''', '''"chal", "ideas", "team", "camp", "owner"].forEach(function (n) { $("page-" + n).hidden = n !== p; });''')
rep('''    if (p === "camp") drawCampPage();
''', '''    if (p === "camp") drawCampPage();
    if (p === "owner") { ownerWatch(); drawOwner(); }
''')
rep('''  function openSettingsSection(hid) {
    state.viewUid = state.me; go("settings");''', '''  function openSettingsSection(hid) {
    state.viewUid = state.me; go(/^h-(s-owner|s-test|o-)/.test(hid) ? "owner" : "settings");''')
JS = r'''
  /* ---------- Owner tools ---------- */
  var ownerUnsub = null;
  function ownerWatch() {
    if (ownerUnsub || !state.isOwner || !B.db) return;
    try { ownerUnsub = B.db.collection("reports").onSnapshot(function (s) { state.reports = s.docs.map(function (d) { var x = d.data() || {}; return { id: d.id, postId: String(x.postId || ""), by: String(x.by || ""), author: String(x.author || ""), createdAt: Number(x.createdAt) || 0 }; }).filter(function (r) { return r.postId; }); drawOwner(); drawSettings(); }, noop); } catch (e) {}
  }
  function openReports() { var gone = state.repGone || {}; return (state.reports || []).filter(function (r) { return !gone[r.id]; }); }
  function repPost(r) { var p = (state.posts || []).filter(function (x) { return x.id === r.postId; })[0]; if (p) return { p: p, team: false }; p = (state.tposts || []).filter(function (x) { return x.id === r.postId; })[0]; return p ? { p: p, team: true } : null; }
  function clearReports(postId) { var ids = openReports().filter(function (r) { return r.postId === postId; }).map(function (r) { return r.id; }); state.repGone = state.repGone || {}; ids.forEach(function (id) { state.repGone[id] = 1; try { B.db.doc("reports/" + id).delete().catch(noop); } catch (e) {} }); drawOwner(); drawSettings(); }
  function drawOwner() {
    var box = $("o-reports"); if (!box) return; box.textContent = "";
    var list = openReports(), byPost = {};
    list.forEach(function (r) { (byPost[r.postId] = byPost[r.postId] || []).push(r); });
    var keys = Object.keys(byPost).sort(function (a, b) { return Math.max.apply(null, byPost[b].map(function (r) { return r.createdAt; })) - Math.max.apply(null, byPost[a].map(function (r) { return r.createdAt; })); });
    if (!keys.length) { box.appendChild(el("p", "note", "No open reports. When a brother reports a post, it shows up here.")); }
    keys.forEach(function (pid) {
      var rs = byPost[pid], hit = repPost(rs[0]), card = el("div", "o-rep");
      var hd = el("div", "o-rh"); hd.appendChild(el("b", null, hit ? nameOf(hit.p.uid) + (hit.team ? " · team chat" : " · Rally") : "Post no longer available"));
      hd.appendChild(el("span", "o-rc", rs.length + (rs.length === 1 ? " report" : " reports"))); card.appendChild(hd);
      if (hit) card.appendChild(el("p", "o-rt", String(hit.p.text || "(photo or video)").slice(0, 280)));
      card.appendChild(el("small", "o-rby", "Reported by " + rs.map(function (r) { return nameOf(r.by); }).filter(function (v, i, a) { return a.indexOf(v) === i; }).join(", ") + " · " + new Date(Math.max.apply(null, rs.map(function (r) { return r.createdAt; }))).toLocaleString(undefined, { month: "short", day: "numeric", hour: "numeric", minute: "2-digit" })));
      var row = el("div", "o-ra"), keep = el("button", "btn ghost", hit ? "Keep post" : "Dismiss"); keep.type = "button"; keep.addEventListener("click", function () { clearReports(pid); }); row.appendChild(keep);
      if (hit) { var rm = el("button", "btn o-rm", "Remove post"); rm.type = "button";
        rm.addEventListener("click", function () { confirmDelete({ title: "Remove this post?", message: "It will be removed for everyone. The reports are cleared.", yes: "Remove" }, function () { var pr = hit.team ? B.deleteTPost(pid) : B.deletePost(pid); Promise.resolve(pr).then(function () { if (hit.team) state.tposts = (state.tposts || []).filter(function (x) { return x.id !== pid; }); else state.posts = state.posts.filter(function (x) { return x.id !== pid; }); clearReports(pid); drawFeed(); }).catch(function () { rm.textContent = "Couldn’t remove. Try again."; }); }); });
        row.appendChild(rm); }
      card.appendChild(row); box.appendChild(card);
    });
  }
  function drawOwnerRow() {
    var b = $("set-owner"); if (!b) return; b.hidden = !state.isOwner; if (!state.isOwner) return; ownerWatch();
    var n = openReports().length, bd = $("o-badge"); bd.hidden = !n; bd.textContent = n ? String(n) : "";
  }
'''
rep('''  function drawSettings() {''', JS + '''  function drawSettings() {
    drawOwnerRow();''')
rep('''    $("set-back").addEventListener("click", function () { state.viewUid = state.me; go("profile"); });''', '''    $("set-back").addEventListener("click", function () { state.viewUid = state.me; go("profile"); });
    $("set-owner").addEventListener("click", function () { go("owner"); });
    $("own-back").addEventListener("click", function () { go("settings"); });''')
CSS = '''
.set-ownrow { width: 100%; display: flex; align-items: center; gap: 12px; margin: 0 0 14px; padding: 14px; text-align: left; font: inherit; color: var(--ink); border: 1px solid var(--accent); border-radius: 10px; background: var(--surface); cursor: pointer; }
.set-ownrow .sc-txt { flex: 1; display: grid; gap: 2px; } .set-ownrow .sc-txt > span { font-family: var(--f-label); font-weight: 800; letter-spacing: .1em; text-transform: uppercase; font-size: 16px; color: var(--accent); } .set-ownrow small { color: var(--muted); font-size: 13px; }
.set-ownrow .sc-chev { color: var(--accent); font-size: 22px; }
.o-badge { min-width: 22px; height: 22px; padding: 0 6px; border-radius: 11px; background: var(--accent); color: var(--accent-ink, #111); font-weight: 700; font-size: 12.5px; display: grid; place-items: center; }
#page-owner h1.pg { margin: 6px 0 2px; }
.o-rep { border: 1px solid var(--line); border-radius: 10px; background: var(--surface); padding: 12px; margin-bottom: 10px; }
.o-rh { display: flex; justify-content: space-between; gap: 10px; align-items: baseline; } .o-rc { color: var(--accent); font-family: var(--f-label); font-weight: 700; letter-spacing: .08em; text-transform: uppercase; font-size: 12.5px; }
.o-rt { margin: 8px 0; padding: 8px 10px; border-left: 3px solid var(--line); font-size: 14.5px; line-height: 1.45; white-space: pre-wrap; }
.o-rby { color: var(--muted); font-size: 12.5px; display: block; }
.o-ra { display: flex; gap: 8px; margin-top: 10px; } .o-ra .btn { flex: 1; } .o-rm { background: var(--danger, #c0392b); border-color: var(--danger, #c0392b); color: #fff; }
.o-soon { margin-top: 18px; } .o-soon h2 { margin: 0 0 8px; }
.o-soon-row { display: grid; gap: 2px; padding: 10px 12px; border: 1px dashed var(--line); border-radius: 8px; margin-bottom: 8px; } .o-soon-row span { color: var(--muted); font-size: 13.5px; }
'''
rep('''.cpg-sh { margin: 0 0 8px; }''', '''.cpg-sh { margin: 0 0 8px; }''' + CSS)
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
