#!/usr/bin/env python3
"""Legal agreement (draft): every brother agrees once to the Terms of Use, Health Disclaimer & Release, Privacy Policy
and Copyright Policy before using the app (new and existing members). Saved on his settings as agreed {v, at}; a new
LEGAL_VERSION asks again. Settings gets a Legal section (status + the four documents). Challenge pages and the
Campaign board carry "Scale or skip anything. Stop if you feel pain." Text is a DRAFT pending attorney review and is
labeled that way in the app. Approved by Curtis 2026-11-01 (ship now as draft, re-agree when final).
Usage: patch_legal.py <in> <out> <version>"""
import sys, re, json
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

LLC = "the LLC that runs Forged &amp; Sent"
CONTACT = "the app owner (post in Rally or ask your Forged &amp; Sent leader)"
def P(b, t): return "<p><b>" + b + "</b> " + t + "</p>"
TERMS = "".join([
 "<p>These Terms are an agreement between you and " + LLC + " (&ldquo;Forged &amp; Sent,&rdquo; &ldquo;we&rdquo;). By using the app you agree to these Terms, the Health Disclaimer and Release, and the Privacy Policy.</p>",
 P("1. Who can use the app.", "You must be 18 or older. The app is built for men pursuing faith, brotherhood and fitness. We may approve, refuse or remove any account."),
 P("2. Your account.", "Keep your login secure. You are responsible for activity on your account."),
 P("3. What the app is, and is not.", "General fitness and faith content: workout plans, nutrition tracking, challenges, campaigns, devotionals and a community feed. It is not medical, nutritional, mental health or pastoral counseling. Coach Gideon is an automated guide, not a licensed professional."),
 P("4. Community rules.", "Do not post anything unlawful, threatening, harassing, hateful or sexually explicit; other people&rsquo;s private information or photos without permission; content that infringes someone&rsquo;s copyright; spam or sales pitches; impersonation; or anything that tries to break the app."),
 P("5. Your content.", "You own what you post. You give us a non-exclusive, royalty-free license to host and show it inside the app so the app works. You are responsible for what you post."),
 P("6. Moderation.", "We do not review everything posted and are not responsible for what members post. We may remove content or end accounts at any time."),
 P("7. Team chat.", "Team chats are meant for their members, but no online space is fully private. Don&rsquo;t post what you wouldn&rsquo;t want others to see."),
 P("8. Points, badges and campaigns.", "For encouragement and bragging rights only. No cash value. We may change scoring, fix errors or reset results."),
 P("9. Media retention.", "Rally and challenge-proof photos and videos are deleted after 30 days. Profile, progress and meal photos stay until you delete them."),
 P("10. Faith content.", "The app includes Christian devotionals, Scripture and prayer features. Participation is voluntary."),
 P("11. Changes.", "The app may change, pause or stop. If these Terms change in a material way, the app asks you to agree again."),
 P("12. No warranties.", "To the fullest extent the law allows, the app is provided &ldquo;as is&rdquo; and &ldquo;as available.&rdquo;"),
 P("13. Limitation of liability.", "To the fullest extent the law allows, Forged &amp; Sent and its owners, leaders and volunteers are not liable for indirect, incidental, consequential or punitive damages, or for injury or loss from using the app or joining any workout, challenge, campaign or meet-up. Total liability for any claim is limited to the greater of what you paid us in the past 12 months or $100."),
 P("14. Indemnity.", "You agree to hold Forged &amp; Sent harmless from claims arising from your content or your breaking these Terms."),
 P("15. Disputes.", "Arizona law governs these Terms. (How disputes are resolved is pending legal review.)"),
 P("16. Ending your account.", "You can delete your data any time in Settings."),
 P("Contact.", CONTACT + "."),
])
HEALTH = "".join([
 P("Not medical advice.", "Forged &amp; Sent provides general fitness, nutrition and faith content. It does not replace a doctor, dietitian, physical therapist or counselor. Coach Gideon and all workout, step, calorie and macro targets are general guidance, not a plan made for your health."),
 P("See your doctor first.", "Talk with your doctor before starting any exercise or nutrition program, especially if you have heart, blood pressure, joint, breathing or other health conditions, take medication, are recovering from injury, or haven&rsquo;t exercised in a while."),
 P("Stop if something is wrong.", "Stop right away and get medical help if you feel chest pain, pressure, dizziness, faintness, unusual shortness of breath or sharp pain. Call 911 in an emergency."),
 P("You choose your effort.", "You decide which workouts, challenges, campaigns, weights, distances and calorie levels to attempt, and you can scale, swap, rest or skip any of them. Points, streaks and team goals never require you to train through pain or illness."),
 P("Known risks.", "Exercise and diet changes carry risks, including strains, sprains, fractures, joint injury, heat illness, dehydration, overtraining, falls, equipment failure, low blood sugar, heart attack, stroke and, rarely, death. Outdoor activities add traffic, weather and terrain risks. Group meet-ups add travel and other participants."),
 P("Assumption of risk.", "I understand these risks. I choose to take part voluntarily and accept the risks, known and unknown, of any activity I do because of the app."),
 P("Release.", "To the fullest extent Arizona law allows, I release " + LLC + " and its owners, leaders and volunteers from claims for injury, illness, death or property loss arising from my use of the app or my participation in its workouts, challenges, campaigns or meet-ups, including claims based on their ordinary negligence. This does not cover gross negligence or intentional misconduct."),
])
PRIVACY = "".join([
 "<p>We collect only what the app needs to run, never sell your data, and let you delete it.</p>",
 P("What we collect.", "Account (name, email, profile photo, who invited you); fitness (workouts, PRs, steps, body weight, progress photos); nutrition (meals, meal photos, calories, macros); faith (devotional check-ins, prayer requests); community (Rally posts, comments, team chat, photos and videos you post); settings; and basic technical info to fix problems."),
 P("Who sees it.", "Members see your name, photo, posts, PRs and points. Your meals, weight and settings are yours unless you post them. Prayer requests go to the members you share them with."),
 P("How we use it.", "Only to run the app: your plan, points, boards, challenges, campaigns, posts and reminders, keeping the community safe, and fixing problems. Never for advertising."),
 P("Who we share it with.", "Other members as above; the services that host the app, only to run it; authorities when the law requires or to protect someone&rsquo;s safety. We never sell your personal information."),
 P("How long we keep it.", "Rally and challenge-proof media: 30 days. Profile, progress and meal photos: until you delete them. Everything else: while your account is open."),
 P("Your choices.", "Edit or delete your posts, photos and logs; turn off food tracking; skip health data; or delete everything in Settings."),
 P("Age.", "The app is for adults 18 and older."),
 P("Contact.", CONTACT + "."),
])
COPY = "".join([
 "<p>We respect copyright and remove infringing content when properly notified.</p>",
 P("To report infringement,", "send the app owner your signature, the work you say was infringed, where it is in the app, your contact information, a good-faith statement that the use isn&rsquo;t authorized, and a statement under penalty of perjury that your notice is accurate."),
 P("Counter-notice.", "If your content was removed by mistake, send a counter-notice with your signature, what was removed, a statement under penalty of perjury that it was a mistake, and consent to federal court jurisdiction."),
 P("Repeat infringers.", "We end the accounts of members who repeatedly infringe."),
])
DOCS = [["terms", "Terms of Use", TERMS], ["health", "Health Disclaimer & Release", HEALTH], ["privacy", "Privacy Policy", PRIVACY], ["copyright", "Copyright Policy", COPY]]

JS = r'''
  /* ---------- Legal agreement (DRAFT pending attorney review). Bump LEGAL_VERSION to ask everyone again. ---------- */
  var LEGAL_VERSION = "draft-1", LEGAL_DRAFT = true;
  var LEGAL_DOCS = %s;
  function legalAgreed() { var a = state.settings && state.settings.agreed; return !!(a && a.v === LEGAL_VERSION); }
  function openLegalDoc(key) {
    var d = LEGAL_DOCS.filter(function (x) { return x[0] === key; })[0]; if (!d) return;
    var old = $("lg-view"); if (old) old.remove();
    var back = el("div", "lg-view"); back.id = "lg-view";
    var box = el("div", "lg-vbox"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "lg-vt");
    var hd = el("div", "lg-vhd"), t = el("h2", null, d[1]); t.id = "lg-vt"; hd.appendChild(t);
    var x = el("button", "mini", "Close"); x.type = "button"; hd.appendChild(x); box.appendChild(hd);
    var bd = el("div", "lg-vbd");
    if (LEGAL_DRAFT) bd.appendChild(el("p", "lg-draft", "Draft · pending legal review"));
    var c = el("div"); c.innerHTML = d[2]; bd.appendChild(c); box.appendChild(bd); back.appendChild(box);
    function close() { back.remove(); }
    x.addEventListener("click", close); back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") { ev.stopPropagation(); close(); } });
    document.body.appendChild(back); x.focus();
  }
  function legalLinks(p) {
    LEGAL_DOCS.slice(0, 3).forEach(function (d, i) {
      var a = el("a", "lg-link", d[1]); a.href = "#"; a.setAttribute("role", "button"); a.addEventListener("click", function (ev) { ev.preventDefault(); ev.stopPropagation(); openLegalDoc(d[0]); });
      p.appendChild(a); p.appendChild(document.createTextNode(i === 0 ? ", " : i === 1 ? " and " : "."));
    });
  }
  function legalMaybe() {
    var g = $("lg-gate");
    if (!state.me || !state.settingsLoaded || !state.canWrite || legalAgreed()) { if (g) g.remove(); return; }
    if (g) return;
    var updated = !!(state.settings.agreed && state.settings.agreed.v);
    g = el("div", "lg-gate"); g.id = "lg-gate"; g.setAttribute("role", "dialog"); g.setAttribute("aria-modal", "true"); g.setAttribute("aria-labelledby", "lg-t");
    var in_ = el("div", "lg-in");
    var em = el("div", "lg-emb"); em.innerHTML = '<svg viewBox="0 0 180 130" aria-hidden="true"><path d="M8 109 L48 66 L61 79 L91 38 L127 81 L139 68 L172 109 M27 109 L49 88 M109 64 L130 109"/><path d="M91 9 V49 M77 23 H105"/></svg>'; in_.appendChild(em);
    var h = el("h1", "lg-h", updated ? "We updated our terms" : "Before you begin"); h.id = "lg-t"; in_.appendChild(h);
    in_.appendChild(el("p", "lg-lead", updated ? "Read what changed, then agree once to keep going." : "One step, one time. Here’s what you’re agreeing to."));
    var ul = el("ul", "lg-pts");
    ["Not medical advice. Check with your doctor before you start.", "You choose your effort. Scale, rest or skip anything, and stop if you feel pain.", "Be a brother online: no harassment, explicit content or other people’s private info.", "We never sell your data. Rally media is deleted after 30 days."].forEach(function (t) { ul.appendChild(el("li", null, t)); });
    in_.appendChild(ul);
    var lab = el("label", "lg-agree"), cb = el("input"); cb.type = "checkbox"; cb.id = "lg-cb"; lab.appendChild(cb);
    var tx = el("span"); tx.appendChild(document.createTextNode("I’m 18 or older and agree to the ")); legalLinks(tx); lab.appendChild(tx); in_.appendChild(lab);
    var go = el("button", "btn lg-go", "I agree"); go.type = "button"; go.disabled = true; in_.appendChild(go);
    if (LEGAL_DRAFT) in_.appendChild(el("p", "lg-fine", "Draft documents pending legal review. You’ll be asked once more when they’re final."));
    var err = el("p", "error"); err.hidden = true; in_.appendChild(err);
    cb.addEventListener("change", function () { go.disabled = !cb.checked; });
    go.addEventListener("click", function () {
      go.disabled = true; go.textContent = "Saving…";
      state.settings.agreed = { v: LEGAL_VERSION, at: Date.now() }; saveSettings();
      writeChain.then(function () { var g2 = $("lg-gate"); if (g2) g2.remove(); drawSettings(); });
    });
    g.appendChild(in_); document.body.appendChild(g);
  }
  function drawLegalSettings() {
    var box = $("legal-body"); if (!box) return; box.textContent = "";
    var a = state.settings && state.settings.agreed;
    box.appendChild(el("p", "note", a && a.at ? "You agreed " + new Date(a.at).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" }) + (LEGAL_DRAFT ? " · draft version, pending legal review." : ".") : "Not agreed yet."));
    var g = el("div", "lg-list");
    LEGAL_DOCS.forEach(function (d) { var b = el("button", "btn ghost", d[1]); b.type = "button"; b.addEventListener("click", function () { openLegalDoc(d[0]); }); g.appendChild(b); });
    box.appendChild(g);
  }
'''.replace("%s", json.dumps(DOCS))

rep('''  function drawSettings() {''', JS + '''  function drawSettings() {
    drawLegalSettings();''')
# settings: carry agreed through load and save
rep('''foodMode: st && (st.foodMode === "elsewhere" || st.foodMode === "none") ? st.foodMode : "app" }; if (state.settings.theme)''',
    '''foodMode: st && (st.foodMode === "elsewhere" || st.foodMode === "none") ? st.foodMode : "app", agreed: st && st.agreed && typeof st.agreed === "object" ? { v: String(st.agreed.v || ""), at: Number(st.agreed.at) || 0 } : null }; if (state.settings.theme)''')
rep('''state.settingsLoaded = true; drawAll(); drawFeed(); refreshHealth(); onbMaybeStart();''', '''state.settingsLoaded = true; drawAll(); drawFeed(); refreshHealth(); onbMaybeStart(); legalMaybe();''')
m = re.search(r'foodMode: foodMode\(\) \}', s); assert m and s.count(m.group(0)) == 1
s = s.replace(m.group(0), 'foodMode: foodMode(), agreed: state.settings.agreed || null }')
# settings section
rep('''    <section aria-labelledby="h-s-acct">''', '''    <section aria-labelledby="h-s-legal">
      <div class="section-head"><h2 class="label-caps" id="h-s-legal" data-sub="Terms, health release, privacy and copyright.">Legal</h2></div>
      <div id="legal-body"></div>
    </section>

    <section aria-labelledby="h-s-acct">''')
# safety line on challenges and the campaign board
rep('''    head.appendChild(el("p", "ch-desc", c.description));
    body.appendChild(head);''', '''    head.appendChild(el("p", "ch-desc", c.description));
    head.appendChild(el("p", "safe-line", "Scale or skip anything. Stop if you feel pain."));
    body.appendChild(head);''')
rep('''    box.appendChild(hd);''', '''    box.appendChild(hd); box.appendChild(el("p", "safe-line", "Scale or skip anything. Stop if you feel pain."));''')
CSS = '''
.lg-gate { position: fixed; inset: 0; z-index: 9990; background: var(--bg); overflow-y: auto; -webkit-overflow-scrolling: touch; }
.lg-in { max-width: 460px; margin: 0 auto; min-height: 100%; display: flex; flex-direction: column; padding: max(28px, env(safe-area-inset-top)) 22px max(24px, env(safe-area-inset-bottom)); }
.lg-emb svg { width: 120px; height: 86px; display: block; margin: 8px auto 4px; }
.lg-emb path { fill: none; stroke: var(--accent); stroke-width: 4; stroke-linecap: round; stroke-linejoin: round; }
.lg-h { font-family: var(--f-display, var(--f-label)); font-weight: 800; text-transform: uppercase; letter-spacing: .05em; font-size: 28px; text-align: center; margin: 8px 0 4px; }
.lg-lead { text-align: center; color: var(--muted); font-size: 15px; margin: 0 0 14px; }
.lg-pts { list-style: none; margin: 0 0 16px; padding: 0; display: grid; gap: 10px; }
.lg-pts li { position: relative; padding: 10px 12px 10px 34px; border: 1px solid var(--line); border-radius: 8px; background: var(--surface); font-size: 14.5px; line-height: 1.4; }
.lg-pts li::before { content: "\\2713"; position: absolute; left: 12px; top: 10px; color: var(--accent); font-weight: 700; }
.lg-agree { display: grid; grid-template-columns: 26px 1fr; gap: 10px; align-items: start; margin-top: auto; padding: 12px; border: 1px solid var(--accent); border-radius: 10px; background: var(--surface); font-size: 14.5px; line-height: 1.45; cursor: pointer; }
.lg-agree input { width: 24px; height: 24px; margin: 0; accent-color: var(--accent); }
.lg-link { display: inline; padding: 0; border: 0; background: none; color: var(--brass); font: inherit; text-decoration: underline; text-underline-offset: 2px; cursor: pointer; }
.lg-go { width: 100%; margin-top: 12px; min-height: 52px; }
.lg-go:disabled { opacity: .45; }
.lg-fine { margin: 10px 0 0; text-align: center; font-size: 12.5px; color: var(--muted); }
.lg-view { position: fixed; inset: 0; z-index: 9995; background: rgba(0,0,0,.6); display: flex; align-items: flex-end; justify-content: center; }
.lg-vbox { width: 100%; max-width: 560px; max-height: 88vh; display: flex; flex-direction: column; background: var(--bg); border: 1px solid var(--line); border-radius: 14px 14px 0 0; }
.lg-vhd { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 14px 16px; border-bottom: 1px solid var(--line); }
.lg-vhd h2 { margin: 0; font-family: var(--f-label); font-weight: 800; text-transform: uppercase; letter-spacing: .08em; font-size: 17px; }
.lg-vbd { overflow-y: auto; padding: 14px 16px max(20px, env(safe-area-inset-bottom)); font-size: 14.5px; line-height: 1.5; }
.lg-vbd p { margin: 0 0 10px; }
.lg-draft { display: inline-block; padding: 3px 10px; border: 1px solid var(--accent); border-radius: 12px; color: var(--accent); font-family: var(--f-label); font-weight: 700; letter-spacing: .08em; text-transform: uppercase; font-size: 12px; }
.lg-list { display: grid; gap: 8px; }
.lg-list .btn { width: 100%; }
.safe-line { margin: 8px 0 0; font-size: 13.5px; color: var(--muted); }
.safe-line::before { content: "\\26A0\\FE0E  "; color: var(--accent); }
'''
rep('''.cp-chips{flex-wrap:nowrap;overflow:hidden}''', CSS.strip() + '\n.cp-chips{flex-wrap:nowrap;overflow:hidden}')
rep('''"h-s-health", "h-s-safe", "h-s-test", "h-s-acct"].forEach(function (hid) {''', '''"h-s-health", "h-s-safe", "h-s-test", "h-s-legal", "h-s-acct"].forEach(function (hid) {''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
