import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
i=s.index('    <div class="creed" id="creed-today"'); j=s.index('\n',i)+1
creed=s[i:j]; s=s[:i]+s[j:]
old='''      <ul class="rows" id="tasks"></ul>

      <div class="sub-head">
        <span class="label-caps">Your three</span>'''
assert s.count(old)==1
s=s.replace(old,'''      <ul class="rows" id="tasks"></ul>

  '''+creed+'''      <div class="sub-head">
        <span class="label-caps">Your three</span>''')
s=s.replace('.creed { margin: 12px 0 14px;','.creed { margin: 18px 0 0;',1)
s=s.replace('"The Stand Firm creed sits at the top. Each box carries one of its commands."','"The Stand Firm creed sits above your three habits. Each box carries one of its commands."',1)
s=s.replace('"The Stand Firm creed at the top is 1 Corinthians 16:13\\u201314.','"The Stand Firm creed above your three habits is 1 Corinthians 16:13\\u201314.',1)
s=s.replace('w: "Today, at the top"','w: "Today, above Your three"',1)
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
