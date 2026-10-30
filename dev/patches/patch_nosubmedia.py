import sys,re
src,dst,ver=sys.argv[1:4]; s=open(src).read()
i=s.index('        if ((a.media || []).length) { var mm = el("div", "ch-media");'); j=s.index('\n',i)+1
assert s.count('if ((a.media || []).length) { var mm = el("div", "ch-media");')==1
s=s[:i]+'        // His photos and videos open from the proof icon by his name in Standings, so they are not repeated here.\n'+s[j:]
m=re.search(r'var APP_VERSION = "[^"]+";',s); s=s.replace(m.group(0),'var APP_VERSION = "%s";'%ver)
open(dst,'w').write(s); print('ok')
