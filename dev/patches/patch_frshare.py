#!/usr/bin/env python3
"""Family report: "Share with my family" did nothing inside the Claude app (the share sheet is refused there and the
error was swallowed). Now it tries the share sheet, then copies the text, and if neither works shows the report text
in a box he can press and hold to copy. It always says what happened. Usage: patch_frshare.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''    sh.addEventListener("click", function () { saved.shared = true; keep(); drawAll(); var txt = reportText(rw, st, saved);
      if (navigator.share) navigator.share({ title: "Family report", text: txt }).catch(noop);
      else { try { navigator.clipboard.writeText(txt).then(function () { sh.textContent = "Copied. Paste it in a text."; }); } catch (e) {} } });''',
'''    var shMsg = el("p", "note fr-shmsg"); shMsg.setAttribute("role", "status"); box.appendChild(shMsg);
    sh.addEventListener("click", async function () { saved.shared = true; keep(); drawAll(); var txt = reportText(rw, st, saved);
      function showText(why) { shMsg.textContent = why; var old2 = box.querySelector(".fr-copy"); if (old2) old2.remove(); var ta = el("textarea", "field fr-copy"); ta.readOnly = true; ta.rows = 8; ta.value = txt; shMsg.after(ta); try { ta.focus({ preventScroll: true }); ta.select(); } catch (e) {} ta.scrollIntoView({ block: "nearest" }); }
      if (navigator.share) { try { await navigator.share({ title: "Family report", text: txt }); shMsg.textContent = "\\u2713 Shared. Your report is marked done for today."; return; } catch (e) { if (e && e.name === "AbortError") { shMsg.textContent = "Share canceled. It\\u2019s still marked done; tap Share again anytime."; return; } } }
      try { await navigator.clipboard.writeText(txt); shMsg.textContent = "\\u2713 Copied. Open Messages and paste it to your family."; sh.textContent = "Copied"; return; } catch (e) {}
      showText("Your phone blocked sharing here. Press and hold the text below, Select All, then Copy and paste it in a text."); });''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
