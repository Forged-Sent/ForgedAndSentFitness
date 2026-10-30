import sys,re
src,dst,ver=sys.argv[1:4]; s=open(src).read()
start='    if (me) { var yp = el("div", "ch-score");'
assert s.count(start)==1
i=s.index(start); j=s.index('\n',i)+1
s=s[:i]+'    // His points show on his Standings row, which updates as he submits, so they are not repeated here.\n'+s[j:]
m=re.search(r'var APP_VERSION = "[^"]+";',s); s=s.replace(m.group(0),'var APP_VERSION = "%s";'%ver)
open(dst,'w').write(s); print('ok')
