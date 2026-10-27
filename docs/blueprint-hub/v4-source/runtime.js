(function () {
  "use strict";
  var $ = function (id) { return document.getElementById(id); };
  function el(tag, cls, text) { var e = document.createElement(tag); if (cls) e.className = cls; if (text != null) e.textContent = text; return e; }
  var REPO = "https://github.com/sfcsmithc-afk/ForgedAndSentFitness";
  var ST = {
    new: ["New", "Submitted; nobody has responded yet."],
    discussing: ["Discussing", "Being talked through; questions still open."],
    needs_decision: ["Needs decision", "Options are clear; the owners are asked to rule."],
    approved: ["Approved", "An owner ruled yes with a reason. Authoritative once recorded in GitHub (decision log / ADR)."],
    deferred: ["Deferred", "Good, but not now. The reason names when to revisit."],
    rejected: ["Rejected", "The owners ruled no, with a reason."],
    implemented: ["Implemented", "Built, merged (PR linked) and verified."]
  };
  /* Primary ADR per decision, from docs/architecture/00-reconciliation-matrix.md (summary table). */
  var ADR_FOR = { D01: "ADR-0001", D02: "ADR-0002", D03: "ADR-0003", D04: "ADR-0006", D05: "ADR-0004", D06: "ADR-0007", D07: "ADR-0015", D08: "ADR-0008", D09: "ADR-0012", D10: "ADR-0011",
    D12: "ADR-0004", D13: "ADR-0013", D15: "ADR-0007", D17: "ADR-0005", D18: "ADR-0010", D19: "ADR-0010", D20: "ADR-0009", D21: "ADR-0009", D22: "ADR-0009", D23: "ADR-0009", D24: "ADR-0009",
    D25: "ADR-0009", D26: "ADR-0009", D27: "ADR-0019", D28: "ADR-0001", D29: "ADR-0013", D30: "ADR-0011", D31: "ADR-0011", D32: "ADR-0017", D35: "ADR-0016", W04: "ADR-0012", W05: "ADR-0010", W10: "ADR-0013", W12: "ADR-0020" };
  var TERMINAL = { approved: 1, deferred: 1, rejected: 1, implemented: 1 };
  var IDEA_TYPES = { feature: "Feature", improvement: "Improvement", alternative: "Architecture alternative", concern: "Concern", question: "Question" };
  var IMPACT = { product: "Product behavior", architecture: "Architecture / data / security", minor: "Small or cosmetic" };
  var ALL = WORKSHOP.concat(DECISIONS);
  var byId = {}; ALL.forEach(function (d) { byId[d.id] = d; });
  var S = { db: null, user: null, comments: null, downloads: null, me: null, canEdit: false, canWrite: true, writeBlocked: false, pageOwner: false,
            votes: {}, mineVotes: { picks: {}, ideaVotes: {} }, ideas: {}, mineIdeas: [], logs: {}, mineLog: [], owners: { ids: [], github: {} },
            profiles: {}, cards: {}, pend: { votes: 0, ideas: 0, log: 0 }, timers: {},
            filter: { area: "all", status: "all", block: false, q: "" }, ifilter: { status: "open", type: "all" }, ideasDirty: false };

  /* ---------- Helpers ---------- */
  function nameOf(id) { var p = S.profiles[id]; return (p && p.name) || (id === S.me ? "You" : "Someone"); }
  function avatarOf(id) { var p = S.profiles[id]; return p && p.avatarUrl; }
  function fmtDate(t) { try { return new Date(t).toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" }); } catch (e) { return ""; } }
  function uid() { return Date.now().toString(36) + Math.random().toString(36).slice(2, 7); }
  function ownersSet() { return S.owners.ids && S.owners.ids.length > 0; }
  function isOfficial(u) { return ownersSet() ? S.owners.ids.indexOf(u) >= 0 : true; }
  function amOwner() { return !!S.me && !S.writeBlocked && (ownersSet() ? S.owners.ids.indexOf(S.me) >= 0 : (S.canEdit || S.pageOwner)); }
  function canVote() { return !!S.db && !!S.me && S.canWrite && !S.writeBlocked; }
  function allEntries() { var out = []; Object.keys(S.logs).forEach(function (u) { (S.logs[u] || []).forEach(function (e) { out.push(Object.assign({ by: u }, e)); }); }); return out; }
  function rulingFor(key) {
    var best = null; Object.keys(S.logs).forEach(function (u) { if (!isOfficial(u)) return; (S.logs[u] || []).forEach(function (e) { if (e.item === key && e.act === "rule" && (!best || e.at > best.at)) best = Object.assign({ by: u }, e); }); });
    return best;
  }
  function historyFor(key) { return allEntries().filter(function (e) { return e.item === key; }).sort(function (a, b) { return b.at - a.at; }); }
  function allIdeas() { var out = []; Object.keys(S.ideas).forEach(function (u) { (S.ideas[u] || []).forEach(function (x) { out.push({ uid: u, x: x, key: "I-" + x.id }); }); }); return out; }
  function ideaByKey(key) { var f = allIdeas().filter(function (i) { return i.key === key; }); return f[0] || null; }
  function statusOf(key) { var r = rulingFor(key); if (r) return r.status; if (byId[key]) return "needs_decision"; var i = ideaByKey(key); return (i && i.x.stage) || "new"; }
  function titleOf(key) { if (byId[key]) return byId[key].title; var i = ideaByKey(key); return i ? i.x.title : key; }
  function picksFor(did) { var out = []; Object.keys(S.votes).forEach(function (u) { var p = ((S.votes[u] || {}).picks || {})[did]; if (p) out.push({ uid: u, p: p }); }); return out; }
  function ideaVotesFor(key) { var out = []; Object.keys(S.votes).forEach(function (u) { var v = ((S.votes[u] || {}).ideaVotes || {})[key]; if (v && v.v) out.push({ uid: u, v: v }); }); return out; }
  function pill(status) { var s = ST[status] || ST.new; var p = el("span", "pill st-" + status, s[0]); p.title = s[1]; return p; }
  function linkFor(kind, v) {
    v = (v || "").trim(); if (!v) return null;
    if (/^https?:\/\//.test(v)) return v;
    if (kind === "issue" || kind === "pr") { var n = v.replace(/^#/, ""); if (/^\d+$/.test(n)) return REPO + (kind === "pr" ? "/pull/" : "/issues/") + n; }
    if (kind === "adr" && /^ADR-\d{4}$/i.test(v)) return REPO + "/tree/main/docs/adr";
    if (kind === "dec" && /^DEC-\d{4}$/i.test(v)) return REPO + "/blob/main/docs/planning/decision-log.yaml";
    if (kind === "fs" && /^FS-[A-Z]+-\d{3}$/i.test(v)) return REPO + "/blob/main/docs/requirements/requirements.yaml";
    return null;
  }
  var LINK_LABEL = { dec: "Decision log", adr: "ADR", fs: "Requirement", issue: "Issue", pr: "PR" };
  function linksRow(links) {
    var row = el("div", "links"); links = links || {}; var any = false;
    ["dec", "adr", "fs", "issue", "pr"].forEach(function (k) { var v = links[k]; if (!v) return; any = true; var href = linkFor(k, v); var a = el(href ? "a" : "span", "lk", LINK_LABEL[k] + ": " + v); if (href) { a.href = href; a.target = "_blank"; a.rel = "noopener"; } row.appendChild(a); });
    return any ? row : null;
  }
  function ghUrl(template, key, title, fields) {
    var q = ["template=" + encodeURIComponent(template), "title=" + encodeURIComponent("[" + key + "] " + title)];
    Object.keys(fields).forEach(function (f) { if (fields[f]) q.push(encodeURIComponent(f) + "=" + encodeURIComponent(String(fields[f]).slice(0, 900))); });
    return REPO + "/issues/new?" + q.join("&");
  }
  function ghButton(key, label) {
    var a = el("a", "btn ghost", label || "Open in GitHub"); a.target = "_blank"; a.rel = "noopener";
    a.addEventListener("click", function () {
      var r = rulingFor(key), d = byId[key], i = ideaByKey(key), ch = d && r ? d.options.filter(function (o) { return o.k === r.outcome; })[0] : null;
      var tpl = r && (r.status === "approved") && !(r.links && r.links.issue) ? "task.yml" : "decision.yml";
      a.href = ghUrl(tpl, key, titleOf(key), {
        hub_id: key, status: r ? ST[r.status][0] : ST[statusOf(key)][0],
        context: d ? d.eli5 : (i ? (i.x.problem || "") + (i.x.proposal ? "\n\nProposal: " + i.x.proposal : "") : ""),
        decision: ch ? ch.label : (r && r.outcome) || "", rationale: r ? r.rationale : "", decided_by: r ? (S.owners.github[r.by] || nameOf(r.by)) : ""
      });
    });
    a.href = REPO + "/issues/new/choose"; return a;
  }

  /* ---------- Static content ---------- */
  RISKS.forEach(function (r) {
    var tr = el("tr"); tr.appendChild(el("td", "mono", r[0]));
    var td = el("td"); td.appendChild(el("span", "sev " + r[1], r[1] === "c" ? "CRITICAL" : r[1] === "h" ? "HIGH" : "MEDIUM")); tr.appendChild(td);
    tr.appendChild(el("td", null, r[2])); tr.appendChild(el("td", "muted", r[3])); $("risk-body").appendChild(tr);
  });
  GLOSSARY.forEach(function (g) { $("gloss").appendChild(el("dt", null, g[0])); $("gloss").appendChild(el("dd", null, g[1])); });
  Object.keys(AREAS).forEach(function (k) { if (k === "workshop") return; var o = el("option", null, AREAS[k].label); o.value = k; $("i-area").appendChild(o); });
  Object.keys(IDEA_TYPES).forEach(function (k) { var o = el("option", null, IDEA_TYPES[k]); o.value = k; $("i-type").appendChild(o); var o2 = o.cloneNode(true); $("if-type").appendChild(o2); });
  Object.keys(IMPACT).forEach(function (k) { var o = el("option", null, IMPACT[k]); o.value = k; $("i-impact").appendChild(o); });
  (function () { var tb = $("st-defs"); Object.keys(ST).forEach(function (k) { var tr = el("tr"); var td = el("td"); td.appendChild(pill(k)); tr.appendChild(td); tr.appendChild(el("td", null, ST[k][1])); tr.appendChild(el("td", "muted", TERMINAL[k] ? "Owners" : k === "new" ? "Anyone (on submit)" : k === "implemented" ? "Owners" : "Author or owners")); tb.appendChild(tr); }); })();

  /* ---------- Decision cards ---------- */
  function areaButtons() {
    var seg = $("f-area"); var list = [["all", "All areas"]].concat(Object.keys(AREAS).map(function (k) { return [k, AREAS[k].label]; }));
    list.forEach(function (a) {
      var b = el("button", "fbtn", a[1]); b.type = "button"; b.setAttribute("aria-pressed", String(S.filter.area === a[0]));
      b.addEventListener("click", function () { S.filter.area = a[0]; Array.prototype.forEach.call(seg.children, function (x) { x.setAttribute("aria-pressed", "false"); }); b.setAttribute("aria-pressed", "true"); applyFilters(); });
      seg.appendChild(b);
    });
    Object.keys(ST).forEach(function (k) { var o = el("option", null, ST[k][0]); o.value = "s:" + k; $("f-status").appendChild(o); });
  }
  function buildCards() {
    var wrap = $("dwrap");
    Object.keys(AREAS).forEach(function (ak) {
      var head = el("div", "area-head"); head.id = "area-" + ak; head.appendChild(el("h3", null, AREAS[ak].label)); head.appendChild(el("span", "muted", AREAS[ak].blurb));
      var list = el("div", "dlist"); wrap.appendChild(head); wrap.appendChild(list);
      ALL.filter(function (d) { return d.area === ak; }).forEach(function (d) { list.appendChild(buildCard(d)); });
    });
  }
  function buildCard(d) {
    var c = el("article", "dcard" + (d.blocking ? " blocking" : "")); c.id = "d-" + d.id; c.setAttribute("data-comment-target", "");
    var top = el("div", "dtop"); top.appendChild(el("span", "did", d.id));
    if (d.blocking) top.appendChild(el("span", "pill block", "Blocking"));
    var st = el("span", "pill"); top.appendChild(st);
    top.appendChild(el("span", "did", d.refs || ""));
    c.appendChild(top);
    c.appendChild(el("h4", null, d.title));
    c.appendChild(el("div", "eli5", d.eli5));
    var det = el("details", "more"); det.appendChild(el("summary", null, "Technical detail")); det.appendChild(el("p", "muted pre", d.detail)); c.appendChild(det);
    var opts = el("div", "opts"); opts.setAttribute("role", "radiogroup"); opts.setAttribute("aria-label", "Your preferred option for " + d.id);
    var optEls = {};
    d.options.forEach(function (o) {
      var lab = el("label", "opt" + (o.k === d.rec ? " rec" : "")); var r = el("input"); r.type = "radio"; r.name = "pick-" + d.id; r.value = o.k;
      var mid = el("div"); var ol = el("div", "ol", o.label); if (o.k === d.rec) ol.appendChild(el("span", "tag-rec", "Recommended")); mid.appendChild(ol);
      var pc = el("div", "pc"); var p1 = el("span"); p1.appendChild(el("em", null, "For: ")); p1.appendChild(document.createTextNode(o.pros)); pc.appendChild(p1);
      var p2 = el("span"); p2.appendChild(el("em", null, "Against: ")); p2.appendChild(document.createTextNode(o.cons)); pc.appendChild(p2); mid.appendChild(pc);
      var tally = el("div", "tally"); tally.setAttribute("aria-label", "Votes");
      lab.appendChild(r); lab.appendChild(mid); lab.appendChild(tally); opts.appendChild(lab);
      r.addEventListener("change", function () { if (r.checked) setPick(d.id, { opt: o.k }); });
      optEls[o.k] = { lab: lab, radio: r, tally: tally };
    });
    c.appendChild(opts);
    if (d.why) { var w = el("p", "why"); w.appendChild(el("b", null, "Why recommended: ")); w.appendChild(document.createTextNode(d.why)); c.appendChild(w); }
    var rc = (typeof RECON !== "undefined" && RECON[d.id]) || null;
    if (rc) { var rp = el("div", "recon"); var rh = el("div", "dtop"); rh.appendChild(el("span", "pill rc-" + rc[0].split(" ")[0].toLowerCase(), "Reconciled: " + rc[0])); if (rc[2] && rc[2] !== "No") rh.appendChild(el("span", "pill block", "Needs approval: " + rc[2])); if (rc[3]) rh.appendChild(el("span", "did", rc[3])); rp.appendChild(rh); rp.appendChild(el("p", null, rc[1])); c.appendChild(rp); }
    var outcome = el("div", "outcome"); outcome.hidden = true; c.appendChild(outcome);
    var foot = el("div", "dfoot");
    var nl = el("label", "muted"); nl.style.fontSize = ".82rem"; nl.textContent = "Your note (saved automatically, visible to everyone)"; nl.htmlFor = "note-" + d.id;
    var ta = el("textarea"); ta.id = "note-" + d.id; ta.maxLength = 2000; ta.placeholder = "Your reasoning, a concern, or a better option";
    var tmr = null; ta.addEventListener("input", function () { clearTimeout(tmr); tmr = setTimeout(function () { setPick(d.id, { note: ta.value.trim() }); }, 900); });
    ta.addEventListener("blur", function () { clearTimeout(tmr); setPick(d.id, { note: ta.value.trim() }); });
    var row = el("div", "row");
    var disc = el("label"); disc.style.fontSize = ".86rem"; var cb = el("input"); cb.type = "checkbox"; disc.appendChild(cb); disc.appendChild(document.createTextNode(" Flag for discussion"));
    cb.addEventListener("change", function () { setPick(d.id, { discuss: cb.checked }); });
    var cmt = el("button", "btn ghost cmt", "Comment"); cmt.type = "button"; cmt.hidden = true; cmt.addEventListener("click", function () { openComment(c); });
    var link = el("button", "btn ghost", "Copy link"); link.type = "button"; link.addEventListener("click", function () { copyText(location.href.split("#")[0] + "#d-" + d.id, link); });
    var saved = el("span", "saved"); saved.setAttribute("role", "status");
    row.appendChild(disc); row.appendChild(cmt); row.appendChild(link); row.appendChild(ghButton(d.id)); row.appendChild(saved);
    foot.appendChild(nl); foot.appendChild(ta); foot.appendChild(row);
    var notes = el("div", "notes"); foot.appendChild(notes);
    var ed = el("details", "editor"); ed.hidden = true; foot.appendChild(ed);
    var hist = el("details", "more hist-d"); hist.appendChild(el("summary", null, "History")); var hl = el("div", "hist"); hist.appendChild(hl); foot.appendChild(hist);
    c.appendChild(foot);
    S.cards[d.id] = { root: c, status: st, opts: optEls, outcome: outcome, note: ta, discuss: cb, notes: notes, editor: ed, saved: saved, hist: hl };
    return c;
  }
  function ruleEditor(key, options, box, onSaved) {
    box.textContent = "";
    box.appendChild(el("summary", null, "Record an owner ruling"));
    var cur = rulingFor(key) || {};
    var g = el("div", "grid2");
    var l1 = el("label", null, "Status"); var ss = el("select"); Object.keys(ST).forEach(function (s) { var o = el("option", null, ST[s][0]); o.value = s; ss.appendChild(o); }); l1.appendChild(ss); g.appendChild(l1);
    var so = null;
    if (options) { var l2 = el("label", null, "Chosen option"); so = el("select"); var o0 = el("option", null, "None"); o0.value = ""; so.appendChild(o0); options.forEach(function (o) { var x = el("option", null, o.label); x.value = o.k; so.appendChild(x); }); var oc = el("option", null, "Something else (explain in the reason)"); oc.value = "other"; so.appendChild(oc); l2.appendChild(so); g.appendChild(l2); }
    box.appendChild(g);
    var l3 = el("label", null, "Reason (required for Approved, Deferred, Rejected and Implemented)"); var rt = el("textarea"); rt.maxLength = 2000; l3.appendChild(rt); box.appendChild(l3);
    var lg = el("div", "grid5"); var inputs = {};
    [["dec", "Decision log id", "DEC-0014"], ["adr", "ADR", "ADR-0020"], ["fs", "Requirement", "FS-TRN-007"], ["issue", "GitHub issue", "#12 or URL"], ["pr", "Pull request", "#34 or URL"]].forEach(function (f) {
      var l = el("label", null, f[1]); var i = el("input"); i.type = "text"; i.maxLength = 200; i.placeholder = f[2]; l.appendChild(i); lg.appendChild(l); inputs[f[0]] = i;
    });
    box.appendChild(lg);
    ss.value = cur.status || statusOf(key); if (so) so.value = cur.outcome || ""; rt.value = cur.rationale || "";
    Object.keys(inputs).forEach(function (k) { inputs[k].value = (cur.links || {})[k] || ""; });
    if (!cur.links && ADR_FOR[key]) inputs.adr.value = ADR_FOR[key];
    var row = el("div", "row"); var b = el("button", "btn", "Save ruling"); b.type = "button"; var msg = el("span", "saved"); msg.setAttribute("role", "status"); row.appendChild(b); row.appendChild(msg); box.appendChild(row);
    box.appendChild(el("p", "muted small", "A ruling here is advisory until it's recorded in docs/planning/decision-log.yaml through a PR both owners approve. Agents read only that file."));
    b.addEventListener("click", function () {
      var status = ss.value, why = rt.value.trim(), links = {};
      Object.keys(inputs).forEach(function (k) { var v = inputs[k].value.trim(); if (v) links[k] = v; });
      if (TERMINAL[status] && !why) { msg.textContent = "Add the reason first."; rt.focus(); return; }
      if (status === "implemented" && !links.pr) { msg.textContent = "Implemented needs the pull request."; inputs.pr.focus(); return; }
      appendLog([{ id: uid(), at: Date.now(), item: key, act: "rule", status: status, outcome: so ? so.value : "", rationale: why, links: links }], msg, onSaved);
    });
  }
  function refreshCard(d) {
    var k = S.cards[d.id]; if (!k) return;
    var r = rulingFor(d.id), status = r ? r.status : "needs_decision";
    k.status.className = "pill st-" + status; k.status.textContent = ST[status][0]; k.status.title = ST[status][1];
    var picks = picksFor(d.id);
    d.options.forEach(function (o) {
      var oe = k.opts[o.k], who = picks.filter(function (x) { return x.p.opt === o.k; });
      oe.tally.textContent = ""; if (who.length) { oe.tally.appendChild(el("b", null, String(who.length))); who.slice(0, 5).forEach(function (x) { var src = avatarOf(x.uid); if (src) { var im = el("img"); im.src = src; im.alt = ""; im.title = nameOf(x.uid); oe.tally.appendChild(im); } }); oe.tally.title = who.map(function (x) { return nameOf(x.uid); }).join(", "); }
      oe.lab.classList.toggle("chosen", !!(r && r.outcome === o.k && TERMINAL[status]));
    });
    var my = S.mineVotes.picks[d.id] || {};
    d.options.forEach(function (o) { var rr = k.opts[o.k].radio; rr.checked = my.opt === o.k; rr.disabled = !canVote(); });
    if (document.activeElement !== k.note) k.note.value = my.note || "";
    k.note.disabled = !canVote(); k.discuss.disabled = !canVote(); k.discuss.checked = !!my.discuss;
    k.notes.textContent = "";
    picks.filter(function (x) { return x.uid !== S.me && (x.p.note || x.p.discuss); }).sort(function (a, b) { return (b.p.at || 0) - (a.p.at || 0); }).forEach(function (x) {
      var n = el("div", "note"); var opt = d.options.filter(function (o) { return o.k === x.p.opt; })[0];
      n.appendChild(el("span", "who", nameOf(x.uid) + (opt ? " · prefers: " + opt.label : "") + (x.p.discuss ? " · wants to discuss" : "")));
      if (x.p.note) n.appendChild(el("span", null, x.p.note)); k.notes.appendChild(n);
    });
    renderOutcome(k.outcome, r, d.options);
    var ed = k.editor; ed.hidden = !amOwner();
    if (amOwner() && !ed.contains(document.activeElement) && !ed.open) ruleEditor(d.id, d.options, ed);
    renderHistory(k.hist, d.id, d.options);
  }
  function renderOutcome(box, r, options) {
    if (!r) { box.hidden = true; return; }
    box.hidden = false; box.className = "outcome st-" + r.status; box.textContent = "";
    var ch = options ? options.filter(function (o) { return o.k === r.outcome; })[0] : null;
    box.appendChild(el("b", null, ST[r.status][0] + (ch ? ": " + ch.label : r.outcome === "other" ? ": another approach" : "")));
    if (r.rationale) box.appendChild(el("span", "pre", r.rationale));
    var lr = linksRow(r.links); if (lr) box.appendChild(lr);
    var who = nameOf(r.by) + (S.owners.github[r.by] ? " (@" + S.owners.github[r.by] + ")" : "");
    box.appendChild(el("span", "hist", "Ruled by " + who + " · " + fmtDate(r.at) + (ownersSet() ? "" : " · owner list not set yet") + (TERMINAL[r.status] && !(r.links && r.links.dec) ? " · not yet in the GitHub decision log" : "")));
  }
  function renderHistory(box, key, options) {
    box.textContent = ""; var h = historyFor(key);
    if (!h.length) { box.appendChild(el("div", null, "No history yet.")); return; }
    h.slice(0, 40).forEach(function (e) {
      var ch = options && e.outcome ? options.filter(function (o) { return o.k === e.outcome; })[0] : null;
      var t = fmtDate(e.at) + " · " + nameOf(e.by) + " ";
      if (e.act === "rule") t += "ruled " + (ST[e.status] || ST.new)[0] + (ch ? " (" + ch.label + ")" : "") + (e.rationale ? ": " + e.rationale : "") + (isOfficial(e.by) ? "" : " [not an owner: ignored]");
      else if (e.act === "submit") t += "submitted the idea";
      else if (e.act === "stage") t += "moved it to " + (ST[e.status] || ST.new)[0];
      else if (e.act === "edit") t += "edited the idea";
      else if (e.act === "withdraw") t += "withdrew the idea";
      else t += e.act;
      box.appendChild(el("div", null, t));
    });
  }
  function refreshAll() { ALL.forEach(refreshCard); applyFilters(); renderIdeas(); renderDashboard(); renderOwners(); }
  function applyFilters() {
    var f = S.filter, q = f.q.toLowerCase(), shown = 0;
    ALL.forEach(function (d) {
      var st = statusOf(d.id), settled = !!TERMINAL[st], my = S.mineVotes.picks[d.id] || {};
      var anyDiscuss = picksFor(d.id).some(function (x) { return x.p.discuss; });
      var fs = f.status, ok = (f.area === "all" || d.area === f.area) && (!f.block || d.blocking)
        && (fs === "all" || (fs === "open" && !settled) || (fs === "settled" && settled) || (fs === "mine" && !settled && !my.opt) || (fs === "discuss" && anyDiscuss) || (fs.indexOf("s:") === 0 && st === fs.slice(2)))
        && (!q || (d.id + " " + d.title + " " + d.eli5 + " " + d.detail + " " + d.options.map(function (x) { return x.label; }).join(" ")).toLowerCase().indexOf(q) >= 0);
      S.cards[d.id].root.hidden = !ok; if (ok) shown++;
    });
    Object.keys(AREAS).forEach(function (ak) { var any = ALL.some(function (d) { return d.area === ak && !S.cards[d.id].root.hidden; }); var h = $("area-" + ak); h.hidden = !any; h.nextSibling.hidden = !any; });
    $("dnone").hidden = shown > 0;
  }

  /* ---------- Ideas ---------- */
  $("iform").addEventListener("submit", function (ev) {
    ev.preventDefault();
    var t = $("i-title").value.trim(); if (!t) { $("i-msg").textContent = "Add a short title first."; $("i-title").focus(); return; }
    if (!canVote()) { $("i-msg").textContent = "Submitting ideas needs Contributor access (or an Editor invite from outside the organization)."; return; }
    if (S.mineIdeas.length >= 80) { $("i-msg").textContent = "You've reached 80 ideas. Withdraw a few first."; return; }
    var id = uid(), now = Date.now();
    var x = { id: id, type: $("i-type").value, title: t.slice(0, 140), area: $("i-area").value, impact: $("i-impact").value, problem: $("i-problem").value.trim().slice(0, 2000), proposal: $("i-proposal").value.trim().slice(0, 2000), stage: "new", at: now, upd: now };
    S.mineIdeas = S.mineIdeas.concat([x]); S.ideas[S.me] = S.mineIdeas;
    ["i-title", "i-problem", "i-proposal"].forEach(function (k) { $(k).value = ""; });
    saveIdeas($("i-msg")); appendLog([{ id: uid(), at: now, item: "I-" + id, act: "submit" }], null);
    refreshAll();
  });
  $("if-status").addEventListener("change", function () { S.ifilter.status = this.value; renderIdeas(true); });
  $("if-type").addEventListener("change", function () { S.ifilter.type = this.value; renderIdeas(true); });
  $("ilist").addEventListener("focusout", function () { setTimeout(function () { if (S.ideasDirty && !$("ilist").contains(document.activeElement)) renderIdeas(true); }, 50); });
  function setIdeaStage(x, stage) {
    S.mineIdeas = S.mineIdeas.map(function (y) { return y.id === x.id ? Object.assign({}, y, { stage: stage, upd: Date.now() }) : y; }); S.ideas[S.me] = S.mineIdeas;
    saveIdeas(null); appendLog([{ id: uid(), at: Date.now(), item: "I-" + x.id, act: "stage", status: stage }], null); refreshAll();
  }
  function renderIdeas(force) {
    var box = $("ilist");
    if (!force && box.contains(document.activeElement)) { S.ideasDirty = true; return; }
    S.ideasDirty = false; box.textContent = "";
    var list = allIdeas().map(function (i) { return Object.assign(i, { status: statusOf(i.key) }); });
    var f = S.ifilter;
    var shown = list.filter(function (i) { return (f.type === "all" || i.x.type === f.type) && (f.status === "all" || (f.status === "open" && !TERMINAL[i.status]) || (f.status === "closed" && TERMINAL[i.status]) || i.status === f.status); });
    shown.sort(function (a, b) { return (b.x.upd || b.x.at || 0) - (a.x.upd || a.x.at || 0); });
    $("i-count").textContent = list.length ? shown.length + " of " + list.length + " ideas" : "";
    if (!shown.length) { box.appendChild(el("div", "empty", list.length ? "No ideas match this filter." : "No ideas yet. Use the form to add the first one.")); return; }
    shown.forEach(function (i) { box.appendChild(ideaCard(i)); });
  }
  function ideaCard(i) {
    var x = i.x, key = i.key, c = el("article", "dcard idea"); c.id = "i-" + x.id; c.setAttribute("data-comment-target", "");
    var top = el("div", "dtop"); top.appendChild(el("span", "did", key)); top.appendChild(pill(i.status)); top.appendChild(el("span", "pill", IDEA_TYPES[x.type] || "Idea"));
    if (AREAS[x.area]) top.appendChild(el("span", "pill", AREAS[x.area].label));
    if (x.impact === "architecture") top.appendChild(el("span", "pill block", "Needs ADR if approved"));
    c.appendChild(top); c.appendChild(el("h4", null, x.title));
    if (x.problem) { var p = el("p", "pre"); p.appendChild(el("b", null, "Problem or reason: ")); p.appendChild(document.createTextNode(x.problem)); c.appendChild(p); }
    if (x.proposal) { var q = el("p", "pre"); q.appendChild(el("b", null, "Proposal: ")); q.appendChild(document.createTextNode(x.proposal)); c.appendChild(q); }
    c.appendChild(el("span", "hist", nameOf(i.uid) + " · " + fmtDate(x.at) + " · " + (IMPACT[x.impact] || "")));
    var r = rulingFor(key); var out = el("div", "outcome"); renderOutcome(out, r, null); c.appendChild(out);
    var vrow = el("div", "row votes"); var vs = ideaVotesFor(key), mine = (S.mineVotes.ideaVotes[key] || {}).v;
    [["up", "Support"], ["unsure", "Unsure"], ["down", "Oppose"]].forEach(function (v) {
      var who = vs.filter(function (z) { return z.v.v === v[0]; });
      var b = el("button", "fbtn", v[1] + (who.length ? " · " + who.length : "")); b.type = "button"; b.setAttribute("aria-pressed", String(mine === v[0])); b.disabled = !canVote() || !!TERMINAL[i.status];
      b.title = who.map(function (z) { return nameOf(z.uid); }).join(", ") || "No votes yet";
      b.addEventListener("click", function () { setIdeaVote(key, mine === v[0] ? "" : v[0]); });
      vrow.appendChild(b);
    });
    c.appendChild(vrow);
    var row = el("div", "row");
    if (S.comments) { var cm = el("button", "btn ghost", "Comment"); cm.type = "button"; cm.addEventListener("click", function () { openComment(c); }); row.appendChild(cm); }
    var cl = el("button", "btn ghost", "Copy link"); cl.type = "button"; cl.addEventListener("click", function () { copyText(location.href.split("#")[0] + "#i-" + x.id, cl); }); row.appendChild(cl);
    row.appendChild(ghButton(key));
    if (i.uid === S.me && canVote() && !r) {
      if (x.stage === "new") { var b1 = el("button", "btn ghost", "Start discussion"); b1.type = "button"; b1.addEventListener("click", function () { setIdeaStage(x, "discussing"); }); row.appendChild(b1); }
      if (x.stage !== "needs_decision") { var b2 = el("button", "btn ghost", "Ready for decision"); b2.type = "button"; b2.addEventListener("click", function () { setIdeaStage(x, "needs_decision"); }); row.appendChild(b2); }
      var wd = el("button", "btn ghost", "Withdraw"); wd.type = "button"; wd.addEventListener("click", function () {
        if (wd.dataset.arm !== "1") { wd.dataset.arm = "1"; wd.textContent = "Tap again to withdraw"; setTimeout(function () { wd.dataset.arm = ""; wd.textContent = "Withdraw"; }, 3000); return; }
        S.mineIdeas = S.mineIdeas.filter(function (y) { return y.id !== x.id; }); S.ideas[S.me] = S.mineIdeas; saveIdeas(null); appendLog([{ id: uid(), at: Date.now(), item: key, act: "withdraw" }], null); refreshAll();
      }); row.appendChild(wd);
    }
    c.appendChild(row);
    if (amOwner()) { var ed = el("details", "editor"); ruleEditor(key, null, ed); c.appendChild(ed); }
    var hd = el("details", "more hist-d"); hd.appendChild(el("summary", null, "History")); var hl = el("div", "hist"); renderHistory(hl, key, null); hd.appendChild(hl); c.appendChild(hd);
    return c;
  }

  /* ---------- Dashboard ---------- */
  function dashList(id, items, empty) {
    var ul = $(id); ul.textContent = "";
    if (!items.length) { ul.appendChild(el("li", "muted", empty)); return; }
    items.slice(0, 8).forEach(function (it) {
      var li = el("li"); var a = el("a", null, it.key + " · " + it.title); a.href = it.href; li.appendChild(a);
      if (it.note) li.appendChild(el("span", "muted", " · " + it.note)); ul.appendChild(li);
    });
    if (items.length > 8) ul.appendChild(el("li", "muted", "+ " + (items.length - 8) + " more"));
  }
  function renderDashboard() {
    var formal = ALL.map(function (d) { return { key: d.id, title: d.title, href: "#d-" + d.id, d: d, status: statusOf(d.id), r: rulingFor(d.id) }; });
    var ideas = allIdeas().map(function (i) { return { key: i.key, title: i.x.title, href: "#i-" + i.x.id, i: i, status: statusOf(i.key), r: rulingFor(i.key) }; });
    var everything = formal.concat(ideas);
    var settled = formal.filter(function (f) { return TERMINAL[f.status]; }).length;
    var blocking = formal.filter(function (f) { return f.d.blocking && !TERMINAL[f.status]; });
    var waiting = S.me ? formal.filter(function (f) { return !TERMINAL[f.status] && !((S.mineVotes.picks[f.key] || {}).opt); })
      .concat(ideas.filter(function (x) { return x.status === "needs_decision" && !(S.mineVotes.ideaVotes[x.key] || {}).v; })) : [];
    var fresh = ideas.filter(function (x) { return x.status === "new"; });
    var needs = ideas.filter(function (x) { return x.status === "needs_decision"; }).concat(formal.filter(function (f) { return f.d.area === "workshop" && !TERMINAL[f.status]; }));
    var toGit = everything.filter(function (x) { return x.r && TERMINAL[x.r.status] && !(x.r.links && x.r.links.dec); });
    var ready = everything.filter(function (x) { return x.r && x.r.status === "approved" && x.r.links && x.r.links.issue; });
    $("st-decided").textContent = settled; $("st-total").textContent = formal.length; $("st-bar").style.width = Math.round(100 * settled / formal.length) + "%";
    $("st-block").textContent = blocking.length; $("st-mine").textContent = S.me ? String(waiting.length) : "–";
    $("st-ideas").textContent = ideas.length; $("st-git").textContent = toGit.length; $("st-ready").textContent = ready.length;
    dashList("dl-block", blocking.map(function (x) { return Object.assign(x, { note: (x.d.refs || "").split(" · ")[0] }); }), "Nothing blocking is undecided.");
    dashList("dl-mine", waiting, S.me ? "You've weighed in on everything open." : "Sign in to see what's waiting on you.");
    dashList("dl-new", fresh.map(function (x) { return Object.assign(x, { note: nameOf(x.i.uid) }); }), "No new ideas.");
    dashList("dl-needs", needs, "Nothing is waiting on an owner ruling.");
    dashList("dl-git", toGit.map(function (x) { return Object.assign(x, { note: ST[x.r.status][0] }); }), "Every ruling has a decision-log id.");
    dashList("dl-ready", ready.map(function (x) { return Object.assign(x, { note: x.r.links.issue }); }), "Nothing approved with an issue yet.");
    var people = {}; Object.keys(S.votes).forEach(function (u) { var v = S.votes[u] || {}; if (Object.keys(v.picks || {}).length || Object.keys(v.ideaVotes || {}).length) people[u] = 1; });
    Object.keys(S.ideas).forEach(function (u) { if ((S.ideas[u] || []).length) people[u] = 1; });
    $("st-people").textContent = Object.keys(people).length;
    var pp = $("people"); pp.textContent = ""; Object.keys(people).forEach(function (u) { var ch = el("span", "chip"); var src = avatarOf(u); if (src) { var im = el("img"); im.src = src; im.alt = ""; ch.appendChild(im); } ch.appendChild(document.createTextNode(nameOf(u) + (isOfficial(u) && ownersSet() ? " · owner" : ""))); pp.appendChild(ch); });
    var rb = $("ratify"); rb.hidden = !amOwner();
    var pending = ratifiable(); $("ratify-n").textContent = pending.length; $("ratify-btn").disabled = !pending.length;
  }
  function ratifiable() { return DECISIONS.filter(function (d) { var rc = RECON[d.id]; return rc && rc[2] === "No" && !rulingFor(d.id); }); }
  $("ratify-btn").addEventListener("click", function () {
    var b = this, list = ratifiable(); if (!list.length || !amOwner()) return;
    if (b.dataset.arm !== "1") { b.dataset.arm = "1"; b.textContent = "Confirm: record " + list.length + " rulings"; setTimeout(function () { b.dataset.arm = ""; b.textContent = "Ratify these"; }, 5000); return; }
    b.dataset.arm = ""; b.textContent = "Ratify these";
    var now = Date.now();
    appendLog(list.map(function (d, n) { return { id: uid(), at: now + n, item: d.id, act: "rule", status: "approved", outcome: d.rec, rationale: "Ratified: aligned with the approved direction of 27 Oct 2026 (docs/architecture/00-reconciliation-matrix.md). " + RECON[d.id][1], links: ADR_FOR[d.id] ? { adr: ADR_FOR[d.id] } : {} }; }), $("ratify-msg"));
  });

  /* ---------- Owners ---------- */
  function knownPeople() { var ids = {}; [S.votes, S.ideas, S.logs].forEach(function (m) { Object.keys(m).forEach(function (u) { ids[u] = 1; }); }); (S.owners.ids || []).forEach(function (u) { ids[u] = 1; }); if (S.me) ids[S.me] = 1; return Object.keys(ids); }
  function renderOwners() {
    var box = $("owners-list"); box.textContent = "";
    var ids = S.owners.ids || [];
    box.appendChild(el("p", null, ids.length ? "Project owners: " + ids.map(function (u) { return nameOf(u) + (S.owners.github[u] ? " (@" + S.owners.github[u] + ")" : ""); }).join(", ") + ". Only their rulings count." : "The owner list isn't set yet, so any editor's ruling counts. The page owner should set it below."));
    var ed = $("owners-ed"); ed.hidden = !S.pageOwner; if (!S.pageOwner || ed.contains(document.activeElement)) return;
    var body = $("owners-body"); body.textContent = "";
    knownPeople().forEach(function (u) {
      var row = el("div", "row"); var lab = el("label"); var cb = el("input"); cb.type = "checkbox"; cb.checked = ids.indexOf(u) >= 0; cb.dataset.u = u; lab.appendChild(cb); lab.appendChild(document.createTextNode(" " + nameOf(u) + (u === S.me ? " (you)" : "")));
      var gh = el("input"); gh.type = "text"; gh.placeholder = "GitHub handle"; gh.maxLength = 39; gh.value = S.owners.github[u] || ""; gh.dataset.u = u; gh.className = "gh";
      row.appendChild(lab); row.appendChild(gh); body.appendChild(row);
    });
  }
  $("owners-save").addEventListener("click", function () {
    if (!S.db || !S.pageOwner) return;
    var ids = [], gh = {};
    $("owners-body").querySelectorAll("input[type=checkbox]").forEach(function (cb) { if (cb.checked) ids.push(cb.dataset.u); });
    $("owners-body").querySelectorAll("input.gh").forEach(function (i) { var v = i.value.trim().replace(/^@/, ""); if (v) gh[i.dataset.u] = v; });
    if (S.me && ids.length && ids.indexOf(S.me) < 0) { $("owners-msg").textContent = "Include yourself, or you'll lose the ability to rule."; return; }
    $("owners-msg").textContent = "Saving…";
    S.db.doc("config/owners").set({ ids: ids, github: gh, updatedAt: Date.now() }).then(function () { $("owners-msg").textContent = "Saved"; }, function () { $("owners-msg").textContent = "Not saved. Only the page owner can change this."; });
  });

  /* ---------- Writes ---------- */
  var chains = { votes: Promise.resolve(), ideas: Promise.resolve(), log: Promise.resolve() };
  function write(kind, path, bodyFn, msgEl, delay, done) {
    if (!S.db || !S.me) return; if (msgEl) msgEl.textContent = "Saving…";
    clearTimeout(S.timers[kind]);
    S.timers[kind] = setTimeout(function () {
      S.timers[kind] = null; S.pend[kind]++;
      var body = bodyFn();
      chains[kind] = chains[kind].then(function () { return S.db.doc(path).set(body); })
        .then(function () { S.pend[kind]--; if (msgEl) msgEl.textContent = "Saved"; if (done) done(); })
        .catch(function (e) { S.pend[kind]--; handleWriteError(e, msgEl); });
    }, delay);
  }
  function setPick(did, patch) {
    if (!canVote()) return;
    var cur = Object.assign({}, S.mineVotes.picks[did] || {}), changed = false;
    Object.keys(patch).forEach(function (k) { if (cur[k] !== patch[k]) { cur[k] = patch[k]; changed = true; } });
    if (!changed) return;
    cur.at = Date.now(); S.mineVotes.picks[did] = cur; S.votes[S.me] = S.mineVotes; refreshCard(byId[did]); renderDashboard();
    saveVotes(S.cards[did].saved);
  }
  function setIdeaVote(key, v) {
    if (!canVote()) return;
    if (v) S.mineVotes.ideaVotes[key] = { v: v, at: Date.now() }; else delete S.mineVotes.ideaVotes[key];
    S.votes[S.me] = S.mineVotes; renderIdeas(true); renderDashboard(); saveVotes(null);
  }
  function saveVotes(msgEl) { write("votes", "votes/" + S.me, function () { return { picks: S.mineVotes.picks, ideaVotes: S.mineVotes.ideaVotes, updatedAt: Date.now() }; }, msgEl, 500); }
  function saveIdeas(msgEl) { write("ideas", "ideas/" + S.me, function () { return { items: S.mineIdeas, updatedAt: Date.now() }; }, msgEl, 200); }
  function appendLog(entries, msgEl, done) {
    if (!S.db || !S.me || S.writeBlocked) { if (msgEl) msgEl.textContent = "Not saved: no write access."; return; }
    S.mineLog = S.mineLog.concat(entries).slice(-600); S.logs[S.me] = S.mineLog; refreshAll();
    write("log", "log/" + S.me, function () { return { entries: S.mineLog, updatedAt: Date.now() }; }, msgEl, 100, done);
  }
  function handleWriteError(e, msgEl) {
    var code = e && e.code;
    if (code === "invalid_argument" || code === "permission_denied" || code === "not_granted") { S.writeBlocked = true; showConn("You can read this page but not save. Ask the owner for Contributor access (or an Editor invite if you're outside the organization).", "warn"); refreshAll(); }
    else if (code === "quota_exceeded") { if (msgEl) msgEl.textContent = "Storage is full. Ask the owner to export and archive."; }
    else if (msgEl) msgEl.textContent = "Not saved. Check your connection and try again.";
  }

  /* ---------- Comments, copy, export ---------- */
  function openComment(target) {
    if (!S.comments) return;
    S.comments.openComposer({ element: target }).catch(function (e) { if (e && (e.code === "unavailable" || e.code === "not_granted")) { S.comments = null; document.querySelectorAll(".cmt").forEach(function (b) { b.hidden = true; }); } });
  }
  function copyText(t, btn) {
    var orig = btn.textContent;
    try { navigator.clipboard.writeText(t).then(function () { btn.textContent = "Copied"; setTimeout(function () { btn.textContent = orig; }, 1500); }, function () { fallbackCopy(t, btn, orig); }); } catch (e) { fallbackCopy(t, btn, orig); }
  }
  function fallbackCopy(t, btn, orig) { var ta = el("textarea"); ta.value = t; ta.style.position = "fixed"; ta.style.opacity = "0"; document.body.appendChild(ta); ta.select(); var ok = false; try { ok = document.execCommand("copy"); } catch (e) {} ta.remove(); btn.textContent = ok ? "Copied" : "Copy failed"; setTimeout(function () { btn.textContent = orig; }, 1500); }
  function rulingOut(r, options) {
    if (!r) return null; var ch = options ? options.filter(function (o) { return o.k === r.outcome; })[0] : null;
    return { status: r.status, outcome: r.outcome || "", outcomeLabel: ch ? ch.label : "", rationale: r.rationale || "", by: r.by, byName: nameOf(r.by), github: S.owners.github[r.by] || "", official: isOfficial(r.by), at: new Date(r.at).toISOString(), links: r.links || {} };
  }
  function histOut(key) { return historyFor(key).map(function (e) { return { at: new Date(e.at).toISOString(), by: e.by, byName: nameOf(e.by), act: e.act, status: e.status || "", outcome: e.outcome || "", rationale: e.rationale || "", links: e.links || {}, official: isOfficial(e.by) }; }); }
  function exportData() {
    var people = {}; knownPeople().forEach(function (u) { people[u] = nameOf(u); });
    var items = ALL.map(function (d) {
      var picks = picksFor(d.id), votes = {}; d.options.forEach(function (o) { votes[o.k] = picks.filter(function (p) { return p.p.opt === o.k; }).length; });
      return { id: d.id, kind: d.area === "workshop" ? "workshop" : "decision", area: d.area, title: d.title, blocking: !!d.blocking, refs: d.refs || "", status: statusOf(d.id), recommended: d.rec,
        options: d.options.map(function (o) { return { key: o.k, label: o.label }; }), votes: votes,
        voters: picks.map(function (p) { return { id: p.uid, name: nameOf(p.uid), option: p.p.opt || "", note: p.p.note || "", discuss: !!p.p.discuss, at: p.p.at ? new Date(p.p.at).toISOString() : "" }; }),
        reconciliation: RECON[d.id] ? { class: RECON[d.id][0], disposition: RECON[d.id][1], approval: RECON[d.id][2], refs: RECON[d.id][3] } : null,
        ruling: rulingOut(rulingFor(d.id), d.options), history: histOut(d.id) };
    }).concat(allIdeas().map(function (i) {
      var vs = ideaVotesFor(i.key);
      return { id: i.key, kind: "idea", area: i.x.area, title: i.x.title, type: i.x.type, impact: i.x.impact, problem: i.x.problem, proposal: i.x.proposal, author: i.uid, authorName: nameOf(i.uid), createdAt: new Date(i.x.at).toISOString(), status: statusOf(i.key),
        votes: { up: vs.filter(function (z) { return z.v.v === "up"; }).length, unsure: vs.filter(function (z) { return z.v.v === "unsure"; }).length, down: vs.filter(function (z) { return z.v.v === "down"; }).length },
        voters: vs.map(function (z) { return { id: z.uid, name: nameOf(z.uid), vote: z.v.v, at: new Date(z.v.at).toISOString() }; }),
        ruling: rulingOut(rulingFor(i.key), null), history: histOut(i.key) };
    }));
    return { schema: "fs-planning-hub-export/1", exportedAt: new Date().toISOString(), source: "Forged & Sent Planning Hub", repository: REPO,
      owners: (S.owners.ids || []).map(function (u) { return { id: u, name: nameOf(u), github: S.owners.github[u] || "" }; }), people: people, items: items };
  }
  function summaryMd() {
    var data = exportData(), lines = ["# Forged & Sent planning summary (" + new Date().toLocaleDateString() + ")", ""];
    [["workshop", "Owner workshop"], ["decision", "Architecture decisions"], ["idea", "Ideas"]].forEach(function (g) {
      lines.push("## " + g[1], "");
      data.items.filter(function (x) { return x.kind === g[0]; }).forEach(function (x) {
        var r = x.ruling;
        lines.push("- **" + x.id + " " + x.title + "** — " + ST[x.status][0] + (r && r.outcomeLabel ? ": " + r.outcomeLabel : "") + (r && r.rationale ? ". " + r.rationale : "") + (x.blocking ? " _(blocking)_" : ""));
        if (x.options) lines.push("  - Votes: " + x.options.map(function (o) { return o.label.split(" (")[0] + ": " + x.votes[o.key]; }).join("; "));
        else lines.push("  - Votes: support " + x.votes.up + ", unsure " + x.votes.unsure + ", oppose " + x.votes.down);
      });
      lines.push("");
    });
    return lines.join("\n");
  }
  function doExport(btn, msg) {
    var json = JSON.stringify(exportData(), null, 2);
    if (!S.downloads) { copyText(json, btn); msg.textContent = "Downloads aren't available here, so the JSON was copied to your clipboard."; return; }
    S.downloads.save({ filename: "forged-and-sent-planning-" + new Date().toISOString().slice(0, 10) + ".json", data: json })
      .then(function () { msg.textContent = "Saved. Commit it with tools/planning/import_hub_export.py."; }).catch(function (e) { msg.textContent = e && e.code === "declined" ? "Download cancelled." : "Couldn't save the file here. Try Copy summary instead."; });
  }
  document.querySelectorAll(".exp-json").forEach(function (b) { b.addEventListener("click", function () { doExport(b, b.parentNode.querySelector(".saved")); }); });
  document.querySelectorAll(".copy-md").forEach(function (b) { b.addEventListener("click", function () { copyText(summaryMd(), b); }); });

  /* ---------- Lazy content ---------- */
  $("schema-d").addEventListener("toggle", function () { if (!this.open || this.dataset.done) return; this.dataset.done = "1"; fetch("firestore.rules").then(function (r) { return r.text(); }).then(function (t) { $("schema-pre").textContent = t; }).catch(function () { $("schema-pre").textContent = "The rules file couldn't be loaded here."; }); });
  $("review-d").addEventListener("toggle", function () {
    if (!this.open || this.dataset.done) return; this.dataset.done = "1";
    fetch("review.md").then(function (r) { return r.text(); }).then(function (t) {
      var box = $("review-body");
      if (window.marked && window.marked.parse) { box.innerHTML = window.marked.parse(t); } else { box.textContent = ""; var pre = el("pre", null, t); pre.style.whiteSpace = "pre-wrap"; box.appendChild(pre); }
      box.querySelectorAll("a[href^='http']").forEach(function (a) { a.target = "_blank"; a.rel = "noopener"; });
    }).catch(function () { $("review-body").textContent = "The full review couldn't be loaded here."; });
  });
  function renderMermaid() {
    if (!window.mermaid) return;
    try {
      var dark = document.documentElement.getAttribute("data-theme") === "dark" || (document.documentElement.getAttribute("data-theme") !== "light" && window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches);
      window.mermaid.initialize({ startOnLoad: false, theme: dark ? "dark" : "neutral", securityLevel: "strict", fontFamily: "IBM Plex Sans, system-ui, sans-serif" });
      window.mermaid.run({ querySelector: "pre.mermaid" }).catch(function () {});
    } catch (e) {}
  }

  /* ---------- Navigation ---------- */
  function goHash() {
    var h = (location.hash || "").slice(1); if (!h) return;
    if (/^d-[DW]\d+$/.test(h)) { S.filter = { area: "all", status: "all", block: false, q: "" }; $("f-status").value = "all"; $("f-q").value = ""; $("f-block").setAttribute("aria-pressed", "false"); applyFilters(); }
    if (/^i-/.test(h)) { S.ifilter.status = "all"; $("if-status").value = "all"; renderIdeas(true); }
    var t = document.getElementById(h); if (t) setTimeout(function () { t.scrollIntoView({ block: "start" }); }, 30);
  }
  window.addEventListener("hashchange", goHash);
  var navLinks = document.querySelectorAll("nav.sections a");
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (es) { es.forEach(function (e) { if (e.isIntersecting) navLinks.forEach(function (a) { a.classList.toggle("on", a.getAttribute("href") === "#" + e.target.id); }); }); }, { rootMargin: "-40% 0px -55% 0px" });
    document.querySelectorAll("section.sec").forEach(function (s) { io.observe(s); });
  }
  $("f-status").addEventListener("change", function () { S.filter.status = this.value; applyFilters(); });
  $("f-block").addEventListener("click", function () { S.filter.block = !S.filter.block; this.setAttribute("aria-pressed", String(S.filter.block)); applyFilters(); });
  $("f-q").addEventListener("input", function () { S.filter.q = this.value.trim(); applyFilters(); });
  function showConn(t, kind) { var b = $("conn"); b.hidden = !t; b.textContent = t || ""; if (kind) b.setAttribute("data-kind", kind); else b.removeAttribute("data-kind"); }

  /* ---------- Boot ---------- */
  areaButtons(); buildCards(); refreshAll(); goHash(); renderMermaid();
  showConn("Connecting to the shared register…");
  var profTimer = null, profBusy = false;
  function loadProfiles() {
    clearTimeout(profTimer);
    profTimer = setTimeout(function () {
      if (!S.user || profBusy) return;
      var list = knownPeople().filter(function (x) { return !S.profiles[x]; }); if (!list.length) return;
      profBusy = true; S.user.profiles(list).then(function (m) { Object.assign(S.profiles, m || {}); profBusy = false; refreshAll(); }, function () { profBusy = false; });
    }, 150);
  }
  function adoptMine(kind, server) {
    if (!S.me || S.timers[kind] || S.pend[kind]) return;
    if (kind === "votes") S.mineVotes = { picks: Object.assign({}, (server && server.picks) || {}), ideaVotes: Object.assign({}, (server && server.ideaVotes) || {}) };
    if (kind === "ideas") S.mineIdeas = ((server && server.items) || []).slice();
    if (kind === "log") S.mineLog = ((server && server.entries) || []).slice();
  }
  function obj(x) { return (x && typeof x === "object") ? x : {}; }
  (async function () {
    var c = window.claude;
    if (!c || !c.use) { showConn("Read-only copy: voting, ideas and rulings work when this page is opened on claude.ai.", "warn"); return; }
    var r = await Promise.all([c.use("db"), c.use("user"), c.use("comments"), c.use("downloads")]);
    S.db = r[0]; S.user = r[1]; S.comments = r[2]; S.downloads = r[3];
    if (S.comments) document.querySelectorAll(".cmt").forEach(function (b) { b.hidden = false; });
    if (S.user) {
      try { var me = await S.user.me(); S.me = me.id || null; S.canEdit = !!me.canEdit; S.pageOwner = !!me.isOwner; } catch (e) { S.me = null; }
      try { var cw = await S.user.can("data.write"); S.canWrite = cw !== false; } catch (e) { S.canWrite = true; }
    }
    if (!S.db) { showConn("The shared register isn't available in this view. You can read everything; open it on claude.ai to take part.", "warn"); refreshAll(); return; }
    if (!S.me) showConn("Sign in to claude.ai to vote, add ideas and comment. You can read everything now.", "warn");
    else if (!S.canWrite) showConn("You have view access: you can read and comment. Ask the owner for Contributor access to vote and add ideas.", "warn");
    else showConn("");
    function sub(col, fn) { S.db.collection(col).onSnapshot(function (snap) { fn(snap); refreshAll(); loadProfiles(); }, function () { showConn("Live updates stopped. Reload the page to reconnect.", "warn"); }); }
    sub("votes", function (snap) { var m = {}; snap.docs.forEach(function (d) { var x = obj(d.data()); m[d.id] = { picks: obj(x.picks), ideaVotes: obj(x.ideaVotes) }; }); if (S.me) { adoptMine("votes", m[S.me]); m[S.me] = S.mineVotes; } S.votes = m; });
    sub("ideas", function (snap) { var m = {}; snap.docs.forEach(function (d) { var x = obj(d.data()); m[d.id] = Array.isArray(x.items) ? x.items : []; }); if (S.me) { adoptMine("ideas", { items: m[S.me] }); m[S.me] = S.mineIdeas; } S.ideas = m; });
    sub("log", function (snap) { var m = {}; snap.docs.forEach(function (d) { var x = obj(d.data()); m[d.id] = Array.isArray(x.entries) ? x.entries : []; }); if (S.me) { adoptMine("log", { entries: m[S.me] }); m[S.me] = S.mineLog; } S.logs = m; });
    sub("config", function (snap) { snap.docs.forEach(function (d) { if (d.id === "owners") { var x = obj(d.data()); S.owners = { ids: Array.isArray(x.ids) ? x.ids : [], github: obj(x.github) }; } }); });
  })();
})();
