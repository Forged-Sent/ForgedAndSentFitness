#!/usr/bin/env python3
"""Bug fix (Curtis 2026-11-05, "the microphone does not work well ... every location"):
the portrait lock read "frame wider than tall" as "phone turned sideways". When the keyboard or the dictation panel
opens, the app's frame gets short, so the app rotated itself mid-typing and dictation broke.
Now: use the phone's real orientation angle when the browser gives one; never rotate while a text box is focused
(the screen stays as it was until he is done typing). Usage: patch_kbrot.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''    var a = typeof window.orientation === "number" ? window.orientation : (screen.orientation && typeof screen.orientation.angle === "number" ? screen.orientation.angle : 90);
    a = ((a % 360) + 360) % 360;
    var cls = phone && w > h ? (a === 270 ? "rot-r" : "rot-l") : "";''', '''    var known = typeof window.orientation === "number" || !!(screen.orientation && typeof screen.orientation.angle === "number");
    var a = typeof window.orientation === "number" ? window.orientation : (screen.orientation && typeof screen.orientation.angle === "number" ? screen.orientation.angle : 90);
    a = ((a % 360) + 360) % 360;
    var ae = document.activeElement, typing = !!(ae && (ae.tagName === "TEXTAREA" || (ae.tagName === "INPUT" && !/^(button|checkbox|radio|range|file|submit|color)$/i.test(ae.type)) || ae.isContentEditable));
    // Sideways only when the phone itself is turned. A short frame from the keyboard or dictation panel is not a turn.
    var turned = known ? (a === 90 || a === 270) && w > h : w > h && !typing;
    var cls = phone && turned ? (a === 270 ? "rot-r" : "rot-l") : "";
    if (typing && phone) return; // keyboard or dictation is open: keep the screen as it is until he is done typing''')
rep('''    window.addEventListener("resize", applyPortraitLock);''', '''    window.addEventListener("resize", applyPortraitLock);
    document.addEventListener("focusout", function () { setTimeout(applyPortraitLock, 300); });''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
