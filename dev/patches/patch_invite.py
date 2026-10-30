#!/usr/bin/env python3
"""Invite a brother opens a pop-up with the message, Share, Copy and a press-and-hold box. Usage: patch_invite.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep_between(start, end, new):
    global s
    assert s.count(start) == 1, ("start", start[:60], s.count(start))
    i = s.index(start); j = s.index(end, i)
    s = s[:i] + new + s[j:]

rep_between('  function inviteBrother(btn) {', '  function saveProfilePatch(patch) {', r'''  function inviteBrother(btn) {
    var txt = "Join me on Forged & Sent, the app our men use to train, pray and stay accountable. Open " + APP_LINK + " and when you set up, search my name, " + nameOf(state.me) + ", under “Who invited you?”" + ".";
    var old = $("cdlg"); if (old) old.remove();
    var back = el("div", "cdlg"); back.id = "cdlg";
    var box = el("div", "cdlg-box nw-box inv-box"); box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-labelledby", "inv-t");
    var h = el("h2", null, "Invite a brother"); h.id = "inv-t"; box.appendChild(h);
    box.appendChild(el("p", null, "Send him this message. When he joins and picks you under “Who invited you?”, you get " + RECRUIT_PTS + " points."));
    var ta = el("textarea", "field inv-text"); ta.readOnly = true; ta.rows = 5; ta.value = txt; ta.setAttribute("aria-label", "Invite message"); box.appendChild(ta);
    var msg = el("p", "note inv-msg"); msg.setAttribute("aria-live", "polite"); msg.textContent = "Or press and hold the message to copy it yourself.";
    var row = el("div", "cdlg-btns");
    var sh = el("button", "btn", "Share"); sh.type = "button";
    var cp = el("button", "btn ghost", "Copy text"); cp.type = "button";
    function selectAll() { try { ta.focus({ preventScroll: true }); ta.select(); ta.setSelectionRange(0, ta.value.length); } catch (e) {} }
    function copied(ok) { msg.textContent = ok ? "Copied. Paste it in a text to him." : "Your phone blocked copying here. Press and hold the message above, then tap Copy."; if (!ok) selectAll(); }
    cp.addEventListener("click", function () {
      var done = false;
      try {
        if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(txt).then(function () { done = true; copied(true); }, function () { selectAll(); var ok = false; try { ok = document.execCommand("copy"); } catch (e) {} copied(ok); });
        else { selectAll(); var ok2 = false; try { ok2 = document.execCommand("copy"); } catch (e) {} copied(ok2); }
      } catch (e) { copied(false); }
    });
    if (navigator.share) {
      sh.addEventListener("click", function () {
        try { navigator.share({ title: "Forged & Sent", text: txt }).then(function () { msg.textContent = "Sent. Thanks for bringing a brother in."; }, function (e) { if (e && e.name === "AbortError") return; msg.textContent = "Sharing isn’t allowed here. Tap Copy text, or press and hold the message."; }); }
        catch (e) { msg.textContent = "Sharing isn’t allowed here. Tap Copy text, or press and hold the message."; }
      });
      row.appendChild(sh); row.appendChild(cp);
    } else { row.style.gridTemplateColumns = "1fr"; cp.className = "btn"; row.appendChild(cp); }
    box.appendChild(row); box.appendChild(msg);
    var cl = el("button", "btn ghost inv-close", "Close"); cl.type = "button"; box.appendChild(cl);
    function close() { back.remove(); if (btn) try { btn.focus({ preventScroll: true }); } catch (e) {} }
    cl.addEventListener("click", close);
    back.addEventListener("click", function (ev) { if (ev.target === back) close(); });
    back.addEventListener("keydown", function (ev) { if (ev.key === "Escape") close(); });
    back.appendChild(box); document.body.appendChild(back);
    try { ta.style.height = (ta.scrollHeight + 2) + "px"; } catch (e) {}
    try { sh.focus ? (navigator.share ? sh : cp).focus({ preventScroll: true }) : null; } catch (e) {}
  }
''')
s = s.replace('.onb-tiles { display: grid;', '''.inv-text { min-height: 120px; resize: none; font-size: 15px; line-height: 1.45; -webkit-user-select: text; user-select: text; }
.inv-box .cdlg-btns { margin-top: 10px; }
.inv-msg { margin: 8px 0 0; }
.inv-close { width: 100%; margin-top: 10px; }
.onb-tiles { display: grid;''', 1)
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
