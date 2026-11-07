import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
a='.ch-head.has-badge > .ch-desc { grid-column: 1 / -1; }'
assert s.count(a)==1
s=s.replace(a,a+'\n/* Safety line: full width, one line. */\n.ch-head.has-badge > .safe-line { grid-column: 1 / -1; }\n.safe-line { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-size: clamp(11px, 3.4vw, 13.5px); }')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
