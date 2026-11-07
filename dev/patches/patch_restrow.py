import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
a='.rest .mini { min-width: 48px; min-height: 48px; padding: 0 8px; }\n'
assert s.count(a)==1
s=s.replace(a,a+'''/* Rest timer stays on one row: label, time, -15, +15, Start, Reset. */
.rest { flex-wrap: nowrap; gap: 6px; }
.rest .rt-label { flex: 0 1 auto; min-width: 0; font-size: clamp(10px, 2.9vw, 13px); letter-spacing: .06em; line-height: 1.15; }
.rest .rt-time { flex: 1 1 auto; min-width: 0; font-size: clamp(17px, 5vw, 21.5px); white-space: nowrap; }
.rest .mini { flex: none; min-width: 0; min-height: 44px; padding: 0 clamp(5px, 1.6vw, 9px); font-size: clamp(10.5px, 3vw, 12.5px); letter-spacing: .04em; }
@media (max-width: 390px) { .rest .mini { min-width: 0; padding: 0 5px; font-size: 11px; } }
.rest .rt-time { flex: 0 0 auto; margin-right: auto; }
@media (max-width: 360px) { .rest { gap: 4px; } .rest .mini { padding: 0 4px; font-size: 10px; letter-spacing: 0; } .rest .rt-time { font-size: 16px; } .rest .rt-label { font-size: 9.5px; letter-spacing: .02em; } }
''')
old='rb.insertBefore(el("span", "rt-label", "After " + L + "2 \u00B7"), rb.firstChild);'
if old not in s: old='rb.insertBefore(el("span", "rt-label", "After " + L + "2 ·"), rb.firstChild);'
assert s.count(old)==1, 'anchor'
s=s.replace(old,'var rl = rb.querySelector(".rt-label"); rl.textContent = ""; rl.classList.add("two"); rl.appendChild(el("span", null, "After " + L + "2")); rl.appendChild(el("span", null, "Rest"));')
s=s.replace('@media (max-width: 390px) { .rest .mini { min-width: 0;','.rest .rt-label.two { display: flex; flex-direction: column; white-space: nowrap; }\n@media (max-width: 390px) { .rest .mini { min-width: 0;',1)
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
