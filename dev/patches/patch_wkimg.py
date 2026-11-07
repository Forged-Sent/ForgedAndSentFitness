import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
a='    var W = 1080, H = 1350, c = document.createElement("canvas"); c.width = W; c.height = H; var x = c.getContext("2d");\n'
b='    return await new Promise(function (res) { c.toBlob(function (b) { res(b); }, "image/png"); });'
i=s.index(a); j=s.index(b,i); assert s.count(a)==1
NEW=r'''    var W = 1080, H = 1350, c = document.createElement("canvas"); c.width = W; c.height = H; var x = c.getContext("2d");
    // Design B (Nov 7): ember header like the app, four stat cards, one line per lift. Colors match the app's Forged Iron theme.
    var C = { bg: "#151719", panel: "#25292c", line: "#45494b", ink: "#f2f0eb", muted: "#b8b4ad", accent: "#f2853c", gold: "#f2a15e", dark: "#171411" };
    var HEAD = "'Saira Condensed', 'Arial Narrow', sans-serif", BODY = "'IBM Plex Sans', system-ui, sans-serif", SCRIPT = "'Merriweather', Georgia, serif";
    function track(px) { try { x.letterSpacing = px + "px"; } catch (e) {} }
    function rr(X, Y, w, h, r) { x.beginPath(); x.moveTo(X + r, Y); x.arcTo(X + w, Y, X + w, Y + h, r); x.arcTo(X + w, Y + h, X, Y + h, r); x.arcTo(X, Y + h, X, Y, r); x.arcTo(X, Y, X + w, Y, r); x.closePath(); }
    function wrap(text, font, maxW) { x.font = font; var words = text.split(/\s+/), lines = [], cur = ""; words.forEach(function (wd) { var t = cur ? cur + " " + wd : wd; if (x.measureText(t).width > maxW && cur) { lines.push(cur); cur = wd; } else cur = t; }); if (cur) lines.push(cur); return lines; }
    function fit(t, maxW) { if (x.measureText(t).width <= maxW) return t; while (t.length > 2 && x.measureText(t + "…").width > maxW) t = t.slice(0, -1); return t.trim() + "…"; }
    var M = 64;
    x.fillStyle = C.bg; x.fillRect(0, 0, W, H);
    // Title first, so the header can size to it
    var ts = 80, tl; while (ts > 62) { tl = wrap(d.title.toUpperCase(), "800 " + ts + "px " + HEAD, W - 2 * M); if (tl.length === 1) break; ts -= 2; }
    if (tl.length > 1) { ts = 80; do { tl = wrap(d.title.toUpperCase(), "800 " + ts + "px " + HEAD, W - 2 * M); if (tl.length <= 2) break; ts -= 6; } while (ts > 44); }
    tl = tl.slice(0, 2);
    var titleTop = 210, titleBottom = titleTop + ts * 0.8 + (tl.length - 1) * ts * 0.95, statsTop = titleBottom + 70, heroH = statsTop + 40;
    // Ember header: warm gradient, sun glow, fades into the page
    var g = x.createLinearGradient(0, 0, 0, heroH); g.addColorStop(0, "#3a2414"); g.addColorStop(0.5, "#5a2f14"); g.addColorStop(1, "#2a1a10"); x.fillStyle = g; x.fillRect(0, 0, W, heroH);
    var sun = x.createRadialGradient(W * 0.82, 90, 0, W * 0.82, 90, 420); sun.addColorStop(0, "rgba(255,190,110,.55)"); sun.addColorStop(0.2, "rgba(242,133,60,.25)"); sun.addColorStop(1, "rgba(242,133,60,0)"); x.fillStyle = sun; x.fillRect(0, 0, W, heroH);
    var fade = x.createLinearGradient(0, heroH - 150, 0, heroH); fade.addColorStop(0, "rgba(21,23,25,0)"); fade.addColorStop(1, C.bg); x.fillStyle = fade; x.fillRect(0, heroH - 150, W, 150);
    // Logo: shield with cross, then the name
    x.save(); x.translate(M, 50); x.scale(38 / 30, 38 / 30); x.strokeStyle = C.accent; x.lineWidth = 2.6; x.lineJoin = "round"; x.lineCap = "round";
    x.stroke(new Path2D("M15 2 L27 6 V16 C27 24 21 29.5 15 32 C9 29.5 3 24 3 16 V6 Z")); x.stroke(new Path2D("M15 9 V24 M10 14 H20")); x.restore();
    x.textBaseline = "alphabetic"; x.fillStyle = C.ink; x.font = "800 26px " + HEAD; track(3.6); x.fillText("FORGED & SENT", M + 52, 82);
    x.fillStyle = C.gold; x.font = "700 24px " + HEAD; track(3.8); x.fillText(fit((d.date + (d.who ? " · " + d.who : "")).toUpperCase(), W - 2 * M), M, 150); track(0);
    x.fillStyle = C.ink; x.font = "800 " + ts + "px " + HEAD; x.shadowColor = "rgba(0,0,0,.4)"; x.shadowBlur = 10; x.shadowOffsetY = 2;
    tl.forEach(function (l, k) { x.fillText(l, M, titleTop + ts * 0.8 + k * ts * 0.95); }); x.shadowColor = "transparent"; x.shadowBlur = 0; x.shadowOffsetY = 0;
    // Four stat cards
    var stats = [[d.time || "—", "TIME"], [fmt(d.vol), "LB MOVED"], [String(d.sets), "WORK SETS"], [String(d.prs.length), d.prs.length === 1 ? "PR" : "PRS"]];
    var gap = 12, cw = (W - 2 * M - 3 * gap) / 4, ch = 108;
    stats.forEach(function (st, k) {
      var X = M + k * (cw + gap); x.fillStyle = C.panel; rr(X, statsTop, cw, ch, 12); x.fill();
      x.save(); rr(X, statsTop, cw, ch, 12); x.clip(); x.fillStyle = C.accent; x.fillRect(X, statsTop, cw, 4); x.restore();
      x.textAlign = "center"; x.fillStyle = k === 3 && d.prs.length ? C.accent : C.ink; x.font = "800 50px " + HEAD; x.fillText(st[0], X + cw / 2, statsTop + 58);
      x.fillStyle = C.muted; x.font = "700 17px " + HEAD; track(2.4); x.fillText(st[1], X + cw / 2, statsTop + 88); track(0);
    });
    x.textAlign = "left";
    // One line per lift: name on the left, sets on the right
    function setsText(e) {
      var u = e.unit ? " " + e.unit : "", same = e.sets.every(function (v) { return v === e.sets[0]; });
      return e.sets.length > 1 && same ? e.sets.length + " sets × " + e.sets[0] + u : e.sets.join(" · ") + u;
    }
    var ex = d.ex, top = statsTop + ch + 26, footTop = H - 110, avail = footTop - top - 10;
    var rowH = ex.length ? Math.max(40, Math.min(74, avail / ex.length)) : 74, show = ex.length ? Math.min(ex.length, Math.floor(avail / rowH)) : 0;
    if (show < ex.length) show = Math.max(1, show - 1);
    var fsN = Math.max(17, Math.min(28, rowH * 0.4)), fsS = Math.max(15, Math.min(24, rowH * 0.34));
    if (!ex.length) { x.fillStyle = C.muted; x.font = "400 30px " + BODY; x.fillText("Workout complete.", M, top + 50); }
    ex.slice(0, show).forEach(function (e, k) {
      var Y = top + k * rowH, base = Y + rowH / 2 + fsN * 0.34, st = setsText(e);
      x.font = "400 " + fsS + "px " + BODY; var sw = Math.min(x.measureText(st).width, (W - 2 * M) * 0.55), stFit = fit(st, sw + 1);
      x.fillStyle = e.pr ? C.ink : C.muted; x.textAlign = "right"; x.fillText(stFit, W - M, base); x.textAlign = "left";
      var badge = e.pr ? fsN * 1.5 + 12 : 0, nameMax = W - 2 * M - sw - 24 - badge;
      x.font = "700 " + fsN + "px " + HEAD; var nm = fit(e.name.toUpperCase(), nameMax); x.fillStyle = e.pr ? C.accent : C.ink; x.fillText(nm, M, base);
      if (e.pr) { var bx = M + x.measureText(nm).width + 12, bh = fsN * 1.05; x.fillStyle = C.accent; rr(bx, base - fsN * 0.86, fsN * 1.5, bh, 4); x.fill(); x.fillStyle = C.dark; x.font = "800 " + (fsN * 0.66) + "px " + HEAD; x.textAlign = "center"; x.fillText("PR", bx + fsN * 0.75, base - fsN * 0.12); x.textAlign = "left"; }
      x.strokeStyle = C.line; x.lineWidth = 1.5; x.beginPath(); x.moveTo(M, Y + rowH); x.lineTo(W - M, Y + rowH); x.stroke();
    });
    if (show < ex.length) { x.fillStyle = C.muted; x.font = "500 " + fsS + "px " + BODY; x.fillText("+ " + (ex.length - show) + " more", M, top + show * rowH + rowH * 0.6); }
    // Footer: the creed and its reference
    x.fillStyle = C.muted; x.font = "italic 400 22px " + SCRIPT; x.fillText("“Be watchful, stand firm in the faith, act like men, be strong.”", M, H - 58);
    x.textAlign = "right"; x.fillStyle = C.accent; x.font = "700 20px " + HEAD; track(2.8); x.fillText("1 COR 16:13", W - M, H - 58); track(0); x.textAlign = "left";
'''
s=s[:i]+NEW+s[j:]
old='"400 40px \'Saira Stencil One\'"].map('
assert s.count(old)==1
s=s.replace(old,'"400 40px \'Saira Stencil One\'", "800 40px \'Saira Condensed\'", "italic 400 22px Merriweather"].map(')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
