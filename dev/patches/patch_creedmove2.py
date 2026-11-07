import sys,re
s=open(sys.argv[1],encoding='utf-8').read()
i=s.index('  <div class="creed" id="creed-today"'); i=s.rindex('\n',0,i)+1; j=s.index('\n',i)+1
creed=s[i:j].strip(); s=s[:i]+s[j:]
old='    <div id="mentor-today"></div>\n'
assert s.count(old)==1
s=s.replace(old, old+'    '+creed+'\n')
s=s.replace('.creed { margin: 18px 0 0;','.creed { margin: 0;',1)
s=s.replace('The Stand Firm creed sits above your three habits.','The Stand Firm creed sits under Walk with your brothers.',1)
s=s.replace('"The Stand Firm creed above your three habits is','"The Stand Firm creed under Walk with your brothers is',1)
s=s.replace('w: "Today, above Your three"','w: "Today, under Walk with your brothers"',1)
s=re.sub(r'var APP_VERSION = "v\d+";','var APP_VERSION = "%s";'%sys.argv[3],s,count=1)
open(sys.argv[2],'w',encoding='utf-8').write(s); print('ok')
