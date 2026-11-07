import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
old='''
    <footer class="anchor">
      <blockquote>Be watchful, stand firm in the faith, act like men, be strong. Let all that you do be done in love.</blockquote>
      <span class="ref label-caps">1 Corinthians 16:13&ndash;14 (ESV)</span>
    </footer>
'''
assert s.count(old)==1; s=s.replace(old,'\n')
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
