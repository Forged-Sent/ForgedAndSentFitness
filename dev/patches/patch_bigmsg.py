#!/usr/bin/env python3
"""Bigger message boxes: the share message (after a workout) and edit-your-message boxes start taller, and every
typing box in the app grows with the text as he types, so he sees the whole message instead of a scrolling slit.
Capped at half the screen, then it scrolls. Rally's own composer keeps its chat-style sizing.
Usage: patch_bigmsg.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

FIT = r'''  /* Typing boxes grow with what's in them (up to half the screen). */
  function fitTA(t) {
    if (!t || t.tagName !== "TEXTAREA" || t.readOnly || t.id === "post-text" || (t.closest && t.closest("#composer"))) return;
    var cap = Math.max(160, Math.round((window.innerHeight || 700) * 0.5)), min = parseFloat(getComputedStyle(t).minHeight) || 0;
    t.style.height = "auto"; var want = Math.max(min, t.scrollHeight + 2);
    t.style.height = Math.min(want, cap) + "px"; t.style.overflowY = want > cap ? "auto" : "hidden";
  }
  document.addEventListener("input", function (ev) { fitTA(ev.target); });
  document.addEventListener("focusin", function (ev) { fitTA(ev.target); });
  function fitSoon(t) { requestAnimationFrame(function () { fitTA(t); }); }
'''
rep('  function confirmDelete(o, onYes) {', FIT + '  function confirmDelete(o, onYes) {')
rep('''    l.appendChild(ta); box.appendChild(l);
    var prev = el("div", "sh-prev"); prev.hidden = true; box.appendChild(prev);''',
    '''    l.appendChild(ta); box.appendChild(l); fitSoon(ta);
    var prev = el("div", "sh-prev"); prev.hidden = true; box.appendChild(prev);''')
rep('''    ta.addEventListener("input", function () { state.editDraft = ta.value; });''',
    '''    ta.addEventListener("input", function () { state.editDraft = ta.value; }); fitSoon(ta);''')
rep('.sh-box textarea { min-height: 76px; resize: vertical; }', '.sh-box textarea { min-height: 150px; resize: none; line-height: 1.45; }')
rep('.ed-form textarea { width: 100%; resize: vertical; }', '.ed-form textarea { width: 100%; min-height: 120px; resize: none; line-height: 1.45; }')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
