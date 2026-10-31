/* Architecture Atlas: offline viewer, no external packages or network calls. */
(function () {
  'use strict';
  var DATA=window.FS_ATLAS_DATA;
  if (!DATA || !Array.isArray(DATA.files) || !DATA.model) {
    document.querySelector('.hero p').textContent='Architecture catalog is missing. Run python3 tooling/architecture/build_explorer.py --write and open build/architecture-explorer/index.html.';
    document.querySelector('#view-map').classList.add('hidden');
    return;
  }
  var $=function(sel){return document.querySelector(sel);};
  var $$=function(sel){return Array.from(document.querySelectorAll(sel));};
  var files=DATA.files, model=DATA.model, documents=DATA.documents||[], byPath=new Map(files.map(function(f){return [f.path,f];}));
  var view='map',stage='current',zoom=1,platform='windows',author='human',visibleFiles=[],activeFile=null,resultIndex=0,drawerOpen=false,helpOpen=false,lastFocus=null,activeDocument=null;
  var SVG='http://www.w3.org/2000/svg';
  function node(tag,cls,text) {
    var n=document.createElement(tag);
    if(cls)n.className=cls;
    if(text!==undefined&&text!==null)n.textContent=String(text);
    return n;
  }
  function sv(tag,attrs,text){
    var n=document.createElementNS(SVG,tag);
    Object.keys(attrs||{}).forEach(function(k){n.setAttribute(k,attrs[k]);});
    if(text!==undefined)n.textContent=String(text);
    return n;
  }
  function clear(n){while(n.firstChild)n.removeChild(n.firstChild);}
  function link(path,line){
    var base=DATA.repository||'https://github.com/Forged-Sent/ForgedAndSentFitness';
    return base+'/blob/'+encodeURIComponent(DATA.ref||'main')+'/'+path.split('/').map(encodeURIComponent).join('/')+(line?'#L'+line:'');
  }
  function setCopy(button,value){
    button.addEventListener('click',function(){
      function done(){var previous=button.textContent;button.textContent='Copied ✓';setTimeout(function(){button.textContent=previous;},1300);}
      if(navigator.clipboard&&navigator.clipboard.writeText){
        navigator.clipboard.writeText(value).then(done,function(){legacy();});
      }else legacy();
      function legacy(){
        var input=node('textarea');input.value=value;input.style.cssText='position:fixed;opacity:0;pointer-events:none';document.body.appendChild(input);
        input.select();try{if(document.execCommand('copy'))done();else button.textContent='Select & copy';}catch(_){button.textContent='Select & copy';}
        input.remove();
      }
    });
  }
  function srcLink(path,line,text){
    var a=node('a',null,text||'Open source ↗');a.href=link(path,line);a.target='_blank';a.rel='noopener noreferrer';return a;
  }
  function go(which){
    if(!['map','files','agents','guide','docs'].includes(which))return;
    view=which;
    $$('[data-panel]').forEach(function(p){p.classList.toggle('hidden',p.dataset.panel!==which);});
    $$('[data-view]').forEach(function(p){
      var yes=p.dataset.view===which;
      p.classList.toggle('active',yes);
      p.setAttribute('aria-current',yes?'page':'false');
    });
    if(which==='files'){$('#file-search').value=$('#global-search').value;renderFiles();}
    if(which==='docs')renderDocsList();
    window.history.replaceState(null,'','#'+which);
  }
  function sourceForModel(n){return (n.files||[]).filter(function(p){return byPath.has(p);});}
  function renderMap(){
    var chosen=model.systems.filter(function(n){return n.stage===stage;});
    $('#map-stage-title').textContent=stage==='current'?'CURRENT IMPLEMENTATION':stage==='planned'?'FUTURE DESIGN INTENT':'DEVELOPMENT & REVIEW';
    $('#map-node-count').textContent=chosen.length+' components';
    $$('[data-stage]').forEach(function(btn){
      var active=btn.dataset.stage===stage;btn.classList.toggle('active',active);
      btn.setAttribute('aria-pressed',active?'true':'false');
    });
    var svg=$('#architecture-svg');clear(svg);
    var defs=sv('defs');
    var marker=sv('marker',{id:'arrow',markerWidth:8,markerHeight:8,refX:6,refY:3,orient:'auto',markerUnits:'strokeWidth'});
    marker.appendChild(sv('path',{d:'M0,0 L6,3 L0,6 Z',fill:'#688f97'}));defs.appendChild(marker);svg.appendChild(defs);
    var index=new Map(chosen.map(function(n){return[n.id,n];}));
    chosen.forEach(function(n){
      (n.depends||[]).forEach(function(id){
        var dest=index.get(id);if(!dest)return;
        var x1=n.x+232,y1=n.y+48,x2=dest.x-5,y2=dest.y+48;
        var backward=x2<x1;
        var c1=backward?x1+42:x1+(x2-x1)*.45,c2=backward?x2-42:x2-(x2-x1)*.45;
        var line=sv('path',{d:'M'+x1+' '+y1+' C'+c1+' '+y1+' '+c2+' '+y2+' '+x2+' '+y2,
          class:'arch-edge arrow'+(stage==='planned'?' planned':'')});
        svg.appendChild(line);
      });
    });
    chosen.forEach(function(n){
      var g=sv('g',{transform:'translate('+n.x+' '+n.y+')',class:'graph-node '+(n.stage==='planned'?'planned':n.stage==='process'?'process':''),
        tabindex:0,role:'button','aria-label':n.label+', '+n.short+'. Open component details.'});
      g.appendChild(sv('rect',{x:0,y:0,width:232,height:96,rx:12,class:'node-bg'}));
      g.appendChild(sv('text',{x:16,y:22,class:'node-pill'},n.stage==='planned'?'PLANNED':n.stage==='process'?'WORKFLOW':'IMPLEMENTED'));
      g.appendChild(sv('text',{x:16,y:52,class:'node-title'},n.label.length>25?n.label.slice(0,23)+'…':n.label));
      g.appendChild(sv('text',{x:16,y:73,class:'node-sub'},n.short.length>30?n.short.slice(0,29)+'…':n.short));
      g.appendChild(sv('text',{x:207,y:53,class:'node-arrow'},'↗'));
      g.addEventListener('click',function(){openModel(n);});
      g.addEventListener('keydown',function(e){if(e.key==='Enter'||e.key===' '){e.preventDefault();openModel(n);}});
      var title=sv('title',{},n.purpose);g.appendChild(title);svg.appendChild(g);
    });
    applyZoom();
  }
  function applyZoom(){
    zoom=Math.min(1.8,Math.max(.7,zoom));
    var svg=$('#architecture-svg');
    svg.style.width=(zoom*100)+'%';
    $('#zoom-reset').textContent=Math.round(zoom*100)+'%';
  }
  function drawTag(parent,text,extra){parent.appendChild(node('span','tag '+(extra||''),text));}
  function detailTitle(container,heading){
    container.appendChild(node('h4',null,heading));
  }
  function modelFileClick(container,path){
    var button=node('button','drawer-file',path+' ↗');
    button.type='button';
    button.addEventListener('click',function(){closeDrawer();go('files');selectFile(path);});
    container.appendChild(button);
  }
  function openDrawer(){
    lastFocus=document.activeElement;
    $('#drawer-cover').classList.remove('hidden');$('#detail-drawer').classList.remove('hidden');
    $('#detail-drawer').focus();drawerOpen=true;document.body.style.overflow='hidden';
  }
  function closeDrawer(){
    if(!drawerOpen)return;
    drawerOpen=false;$('#drawer-cover').classList.add('hidden');$('#detail-drawer').classList.add('hidden');
    document.body.style.overflow='';
    if(lastFocus&&lastFocus.focus)lastFocus.focus();
  }
  function openModel(n){
    var out=$('#drawer-content');clear(out);
    var over=node('div','detail-overline',n.stage==='current'?'IMPLEMENTED COMPONENT':n.stage==='planned'?'PLANNED / NOT IMPLEMENTED':'DEVELOPMENT PROCESS');
    out.appendChild(over);out.appendChild(node('h2','detail-title',n.label));
    out.appendChild(node('p',null,n.purpose));
    var tags=node('div','tag-row');drawTag(tags,n.stage==='current'?'Current':n.stage==='planned'?'Future design':'Workflow',n.stage==='planned'?'planned':'green');
    if(n.files&&n.files.length)drawTag(tags,n.files.length+' owned file(s)');
    out.appendChild(tags);
    if(n.notes){var section=node('div','detail-section');detailTitle(section,'What to know');section.appendChild(node('p',null,n.notes));out.appendChild(section);}
    var owned=sourceForModel(n);
    var sectionFiles=node('div','detail-section');detailTitle(sectionFiles,'Owned and related files');
    if(owned.length)owned.forEach(function(path){modelFileClick(sectionFiles,path);});
    else sectionFiles.appendChild(node('p',null,n.stage==='planned'?'No files implement this proposed component yet.':'No linked tracked files.'));
    out.appendChild(sectionFiles);
    if(n.functions&&n.functions.length){
      var fs=node('div','detail-section');detailTitle(fs,'Named interfaces / functions');
      n.functions.forEach(function(key){
        var parts=key.split('::'),f=byPath.get(parts[0]);var match=f&&f.symbols.find(function(s){return s.name===parts[1]||s.name.endsWith('.'+parts[1]);});
        var b=node('button','dep-link',parts[1]+'() · '+parts[0]);b.type='button';
        b.addEventListener('click',function(){closeDrawer();go('files');selectFile(parts[0],match&&match.id);});fs.appendChild(b);
      });out.appendChild(fs);
    }
    var depends=node('div','detail-section');detailTitle(depends,'Model dependencies');
    if(n.depends&&n.depends.length){
      n.depends.forEach(function(d){var dest=model.systems.find(function(x){return x.id===d;});if(dest){var b=node('button','dep-link',dest.label+' →');b.type='button';b.addEventListener('click',function(){openModel(dest);});depends.appendChild(b);}});
    }else depends.appendChild(node('p',null,'No outgoing model dependency recorded.'));
    out.appendChild(depends);
    if(n.stage!=='current')out.appendChild(node('p','truth-note','This is planned/process guidance, not evidence of shipped application code.'));
    openDrawer();
  }
  function renderFiles(){
    var text=($('#file-search').value||'').trim().toLowerCase();
    var cat=$('#category-filter').value;
    visibleFiles=files.filter(function(f){
      var allowed=(cat==='all'||(cat==='core'&&!f.path.startsWith('versions/'))||cat===f.category);
      if(!allowed)return false;
      if(!text)return true;
      return f.path.toLowerCase().includes(text)||f.description.toLowerCase().includes(text)||
        f.symbols.some(function(s){return s.name.toLowerCase().includes(text)||s.description.toLowerCase().includes(text);});
    });
    if(text)visibleFiles.sort(function(a,b){
      function score(f){return(f.path.toLowerCase().split('/').pop().startsWith(text)?0:f.path.toLowerCase().includes(text)?1:2);}
      return score(a)-score(b)||a.path.localeCompare(b.path);
    });
    $('#results-count').textContent=visibleFiles.length+' files';
    var panel=$('#file-results');clear(panel);
    if(!visibleFiles.length){panel.appendChild(node('div','no-result','No files matched. Try a shorter query or enable archived snapshots.'));return;}
    visibleFiles.forEach(function(f,i){
      var button=node('button','file-result');button.type='button';button.setAttribute('role','option');
      button.setAttribute('aria-selected',activeFile&&activeFile.path===f.path?'true':'false');
      var tag=node('span','file-icon',fileInitial(f.language));button.appendChild(tag);
      var label=node('span');label.appendChild(node('strong',null,f.path.split('/').pop()));
      label.appendChild(node('small',null,f.path));button.appendChild(label);
      if(f.symbols.length)button.appendChild(node('span','sym-total',String(f.symbols.length)));
      button.addEventListener('click',function(){resultIndex=i;selectFile(f.path);});
      panel.appendChild(button);
    });
  }
  function fileInitial(language){var m={python:'PY',dart:'DART',powershell:'PS',shell:'SH',javascript:'JS',markdown:'MD',yaml:'CI',json:'JSON',html:'HTML','html-archive':'OLD',batch:'BAT',toml:'TOML','firebase-rules':'RULE'};return m[language]||'FILE';}
  function selectFile(path,focusSymbol){
    var f=byPath.get(path);if(!f)return;activeFile=f;
    $('#global-search').value=$('#global-search').value; // Do not clear the user's search.
    var out=$('#file-detail');clear(out);
    var label=node('div','detail-overline',f.category.toUpperCase()+' / '+f.language.toUpperCase());
    out.appendChild(label);out.appendChild(node('h3',null,f.path));
    out.appendChild(node('p','detail-description',f.description));
    var tags=node('div','tag-row');drawTag(tags,f.symbols.length+' declarations','green');drawTag(tags,f.deps.length+' outgoing links');drawTag(tags,f.usedBy.length+' referencing files');
    if(f.largeOrBinary)drawTag(tags,'Content not embedded','planned');out.appendChild(tags);
    var source=srcLink(f.path,0,'Read entire source on GitHub ↗');source.className='detail-source-link';out.appendChild(source);
    if(f.largeOrBinary)out.appendChild(node('p','truth-note','File is too large or not safely readable as text. Its path is indexed but source text was not embedded.'));
    var headings=f.symbols;
    var section=node('div','detail-section');detailTitle(section,'Classes, functions, jobs and sections');
    if(!headings.length)section.appendChild(node('p','detail-description','No named declarations detected by the lexical scanner. This does not mean the file has no behavior.'));
    headings.forEach(function(symbol){
      var box=node('details','symbol-card');box.id='symbol-'+hash(symbol.id);
      if(focusSymbol===symbol.id)box.open=true;
      var summary=node('summary','symbol-head');summary.appendChild(node('strong',null,symbol.name));
      summary.appendChild(node('span',null,'L'+symbol.line));
      box.appendChild(summary);
      box.appendChild(node('p',null,symbol.description));
      if(symbol.curated)box.appendChild(node('div','detail-overline','CURATED BEHAVIOR NOTE'));
      if(symbol.excerpt)box.appendChild(node('pre',null,symbol.excerpt));
      box.appendChild(srcLink(f.path,symbol.line,'Open declaration in GitHub ↗'));section.appendChild(box);
    });
    out.appendChild(section);
    function linksArea(title,arr,rev){
      var sec=node('div','detail-section');detailTitle(sec,title);
      if(!arr.length){sec.appendChild(node('p','detail-description',rev?'No inbound tracked-file references detected.':'No tracked local dependency detected. External SDK calls may still exist.'));}
      arr.forEach(function(item){
        var path=rev?item:item.target,b=node('button','dep-link');b.type='button';
        var body=node('span');body.appendChild(node('strong',null,path));
        if(!rev)body.appendChild(node('span','dep-kind',item.kind+' · '+item.confidence+' · line '+item.line));
        b.appendChild(body);b.addEventListener('click',function(){selectFile(path);});sec.appendChild(b);
      });
      out.appendChild(sec);
    }
    linksArea('Depends on / references',f.deps,false);
    linksArea('Referenced by these files',f.usedBy,true);
    if(f.externals&&f.externals.length){var ex=node('div','detail-section');detailTitle(ex,'External SDK / package imports');var chips=node('div','tag-row');f.externals.forEach(function(p){drawTag(chips,p);});ex.appendChild(chips);out.appendChild(ex);}
    var advisory=node('p','truth-note','This is a static source inventory. "Mentions path" is not a runtime dependency; name-based declarations may miss generated or dynamic code.');
    out.appendChild(advisory);
    $$('#file-results .file-result').forEach(function(b,i){b.setAttribute('aria-selected',visibleFiles[i]&&visibleFiles[i].path===path?'true':'false');});
    if(focusSymbol){var x=$('#symbol-'+hash(focusSymbol));if(x){x.open=true;x.scrollIntoView({block:'nearest'});}}
  }
  function hash(s){var h=0;for(var i=0;i<s.length;i++)h=((h<<5)-h+s.charCodeAt(i))|0;return Math.abs(h);}
  function setupAgents(){
    var panel=$('#agent-cards');clear(panel);
    var icons=['✧','✳','◇'];
    model.agents.forEach(function(agent,i){
      var card=node('article','agent-card');
      card.appendChild(node('div','agent-avatar',icons[i]||'◈'));
      card.appendChild(node('h3',null,agent.name));
      card.appendChild(node('p',null,agent.role));
      var inst=node('div','agent-instructions');inst.appendChild(node('div','detail-overline','INSTRUCTIONS & SKILLS'));
      agent.instructions.forEach(function(path){inst.appendChild(srcLink(path,0,path));});
      card.appendChild(inst);panel.appendChild(card);
    });
    var a=$('#author-options');clear(a);
    ['human','codex','claude','gemini'].forEach(function(id){
      var b=node('button','author-btn'+(id===author?' active':''),id.charAt(0).toUpperCase()+id.slice(1));
      b.type='button';b.dataset.author=id;b.setAttribute('aria-pressed',id===author?'true':'false');
      b.addEventListener('click',function(){author=id;updateCommand();});a.appendChild(b);
    });
    updateCommand();
  }
  function updateCommand(){
    var reviewers={human:'codex,claude',codex:'claude,gemini',claude:'codex,gemini',gemini:'codex,claude'};
    var cmd='python3 tooling/review/review.py --author '+author+' --reviewers '+reviewers[author];
    $('#review-command').textContent=cmd;
    $$('.author-btn').forEach(function(b){var selected=b.dataset.author===author;b.classList.toggle('active',selected);b.setAttribute('aria-pressed',String(selected));});
    $('#review-explanation').textContent='Independent reviewers: '+reviewers[author].replace(',',' and ')+'. The authoring '+(author==='human'?'person':'model')+' is not counted as an independent AI reviewer. Run locally only after checking the diff for secrets.';
    var button=$('#copy-review');var clone=button.cloneNode(true);button.replaceWith(clone);setCopy(clone,cmd);
  }
  function setupGuide(){
    $$('[data-platform]').forEach(function(b){var selected=b.dataset.platform===platform;b.classList.toggle('active',selected);b.setAttribute('aria-pressed',String(selected));});
    var panel=$('#guide-steps');clear(panel);
    (model.guide[platform]||[]).forEach(function(step,i){
      var outer=node('div','guide-step');outer.appendChild(node('span','guide-number',String(i+1).padStart(2,'0')));
      var body=node('div');body.appendChild(node('h3',null,step[0]));body.appendChild(node('code',null,step[1]));outer.appendChild(body);
      var copy=node('button',null,'Copy');copy.type='button';setCopy(copy,step[1]);outer.appendChild(copy);panel.appendChild(outer);
    });
    $('#link-system').href=link('docs/architecture/SYSTEM.md');
  }
  function help(show){
    helpOpen=show;$('#help-modal').classList.toggle('hidden',!show);
    document.body.style.overflow=show?'hidden':drawerOpen?'hidden':'';
    if(show){lastFocus=document.activeElement;$('#close-help').focus();}
    else if(lastFocus&&lastFocus.focus)lastFocus.focus();
  }
  function setupHelp(){
    var grid=$('#shortcut-grid');clear(grid);
    (model.guide.shortcuts||[]).forEach(function(s){
      var item=node('div','shortcut-item');item.appendChild(node('span',null,s[1]));item.appendChild(node('kbd',null,s[0]));grid.appendChild(item);
    });
    $('#open-help-top').addEventListener('click',function(){help(true);});
    $('#open-help-side').addEventListener('click',function(){help(true);});
    $('#close-help').addEventListener('click',function(){help(false);});
    $('#help-modal').addEventListener('click',function(e){if(e.target===$('#help-modal'))help(false);});
  }
  function shortcuts(e){
    if(e.ctrlKey||e.metaKey||e.altKey||helpOpen&&e.key!=='Escape')return;
    if(e.key==='Escape'){if(helpOpen)help(false);else closeDrawer();return;}
    var tag=(e.target.tagName||'').toLowerCase();
    var typing=tag==='input'||tag==='textarea'||tag==='select'||e.target.isContentEditable;
    if(e.key==='/'&&!typing){e.preventDefault();go('files');$('#file-search').focus();return;}
    if(typing)return;
    var views={'1':'map','2':'files','3':'agents','4':'guide','5':'docs',g:'map',f:'files',a:'agents',d:'docs'};
    if(views[e.key]){go(views[e.key]);return;}
    if(e.key==='?'){help(true);return;}
    if(view==='map'){
      if(e.key==='+'||e.key==='='){zoom+=.12;applyZoom();}
      if(e.key==='-'){zoom-=.12;applyZoom();}
      if(e.key==='0'){zoom=1;applyZoom();}
    }
    if(view==='files'&&visibleFiles.length&&(e.key==='j'||e.key==='k')){
      e.preventDefault();
      resultIndex=Math.max(0,Math.min(visibleFiles.length-1,resultIndex+(e.key==='j'?1:-1)));
      selectFile(visibleFiles[resultIndex].path);
      var b=$$('#file-results .file-result')[resultIndex];if(b)b.scrollIntoView({block:'nearest'});
    }
  }

  /* Safe Markdown renderer: textContent throughout; no raw HTML interpretation. */
  function docPath(base,href) {
    if(href.charAt(0)==='#')return null;
    if(/^https?:\/\//i.test(href))return href;
    var parts=base.split('/');parts.pop();
    href.split('/').forEach(function(p){
      if(p==='..')parts.pop();else if(p!=='.'&&p!=='')parts.push(p);
    });
    return parts.join('/');
  }
  function appendInline(target,text,path){
    var pattern=/(\[[^\]]+\]\([^)]+\)|\*\*[^*]+\*\*|`[^`]+`|\*[^*]+\*)/g;
    var offset=0,match;
    while((match=pattern.exec(text))!==null){
      if(match.index>offset)target.appendChild(document.createTextNode(text.slice(offset,match.index)));
      var token=match[0];
      if(token.charAt(0)==='['){
        var parsed=/^\[([^\]]+)\]\(([^)]+)\)$/.exec(token);
        if(parsed){
          var dest=docPath(path,parsed[2]);
          var a=node('a',null,parsed[1]);
          if(dest&&/^https?:\/\//i.test(dest)){a.href=dest;a.target='_blank';a.rel='noopener noreferrer';}
          else if(parsed[2].charAt(0)==='#'){a.href=parsed[2];}
          else if(dest&&byPath.has(dest)){a.href=link(dest);a.addEventListener('click',function(e){e.preventDefault();go('files');selectFile(this.dataset.file);});a.dataset.file=dest;}
          else {a.removeAttribute('href');a.title='Reference not resolved within tracked repository';}
          target.appendChild(a);
        }else target.appendChild(document.createTextNode(token));
      }else if(token.startsWith('**')){
        target.appendChild(node('strong',null,token.slice(2,-2)));
      }else if(token.charCodeAt(0)===96){
        target.appendChild(node('code',null,token.slice(1,-1)));
      }else if(token.startsWith('*')){
        target.appendChild(node('em',null,token.slice(1,-1)));
      }else target.appendChild(document.createTextNode(token));
      offset=pattern.lastIndex;
    }
    if(offset<text.length)target.appendChild(document.createTextNode(text.slice(offset)));
  }
  function isTableSeparator(line){return /^\s*\|?\s*:?-{3,}(?:\s*\|\s*:?-{3,})+\s*\|?\s*$/.test(line);}
  function cells(line){return line.trim().replace(/^\|/,'').replace(/\|$/,'').split('|').map(function(s){return s.trim();});}
  function markdownBody(doc){
    var container=node('div','doc-body'),text=doc.markdown||'',lines=text.split(/\r?\n/),i=0,headingNum=0;
    var toc=node('nav','doc-contents');toc.setAttribute('aria-label','On this page');
    var body=node('div');
    function heading(level,label){
      var h=node('h'+level,null);h.id='doc-section-'+headingNum++;appendInline(h,label,doc.path);body.appendChild(h);
      if(level===2||level===3){
        var a=node('a',null,label.slice(0,55));a.href='#'+h.id;
        a.addEventListener('click',function(e){e.preventDefault();h.scrollIntoView({behavior:'smooth',block:'start'});});
        toc.appendChild(a);
      }
    }
    while(i<lines.length){
      var line=lines[i],trim=line.trim();
      if(!trim){i++;continue;}
      var fence=String.fromCharCode(96).repeat(3);
      if(trim.startsWith(fence)){
        var lang=trim.slice(3).trim(),content=[];i++;
        while(i<lines.length&&!lines[i].trim().startsWith(fence)){content.push(lines[i]);i++;}
        if(i<lines.length)i++;
        var pre=node('pre');var code=node('code',null,content.join('\n'));pre.appendChild(code);body.appendChild(pre);
        if(lang.toLowerCase()==='mermaid'){
          var box=node('div','doc-diagram-hint','This source diagram also has an interactive component map. ');
          var b=node('button','quiet-btn','Open interactive map ↗');b.type='button';b.addEventListener('click',function(){go('map');});
          box.appendChild(b);body.appendChild(box);
        }
        continue;
      }
      var h=/^(#{1,4})\s+(.+)$/.exec(line);
      if(h){heading(h[1].length,h[2]);i++;continue;}
      if(/^---+$/.test(trim)){body.appendChild(node('hr'));i++;continue;}
      if(trim.startsWith('|')&&i+1<lines.length&&isTableSeparator(lines[i+1])){
        var wrap=node('div','doc-table-wrap'),table=node('table'),thead=node('thead'),tr=node('tr');
        cells(lines[i]).forEach(function(v){var th=node('th');appendInline(th,v,doc.path);tr.appendChild(th);});
        thead.appendChild(tr);table.appendChild(thead);i+=2;
        var tbody=node('tbody');
        while(i<lines.length&&lines[i].trim().startsWith('|')){
          var row=node('tr');cells(lines[i]).forEach(function(v){var td=node('td');appendInline(td,v,doc.path);row.appendChild(td);});
          tbody.appendChild(row);i++;
        }
        table.appendChild(tbody);wrap.appendChild(table);body.appendChild(wrap);continue;
      }
      if(/^>\s?/.test(trim)){
        var quote=node('blockquote');while(i<lines.length&&/^>\s?/.test(lines[i].trim())){
          var p=node('p');appendInline(p,lines[i].trim().replace(/^>\s?/,''),doc.path);quote.appendChild(p);i++;
        }body.appendChild(quote);continue;
      }
      if(/^[-*+]\s+/.test(trim)||/^\d+\.\s+/.test(trim)){
        var ordered=/^\d+\.\s+/.test(trim),list=node(ordered?'ol':'ul');
        while(i<lines.length){
          var candidate=lines[i].trim(),m=ordered?/^\d+\.\s+(.+)$/.exec(candidate):/^[-*+]\s+(.+)$/.exec(candidate);
          if(!m)break;
          var li=node('li');appendInline(li,m[1],doc.path);list.appendChild(li);i++;
        }body.appendChild(list);continue;
      }
      var fragments=[trim];i++;
      while(i<lines.length&&lines[i].trim()&&
        !/^(#{1,4})\s+/.test(lines[i])&&!lines[i].trim().startsWith(fence)&&
        !/^[-*+]\s+|^\d+\.\s+|^>\s?/.test(lines[i].trim())){
        if(lines[i].trim().startsWith('|')&&i+1<lines.length&&isTableSeparator(lines[i+1]))break;
        fragments.push(lines[i].trim());i++;
      }
      var p=node('p');appendInline(p,fragments.join(' '),doc.path);body.appendChild(p);
    }
    if(toc.children.length){container.appendChild(toc);}
    container.appendChild(body);return container;
  }
  function renderDocsList(){
    var query=($('#doc-search').value||'').trim().toLowerCase();
    var eligible=documents.filter(function(d){return d.path.toLowerCase().includes(query)||d.title.toLowerCase().includes(query);});
    eligible.sort(function(a,b){
      function rank(d){return d.path==='docs/architecture/SYSTEM.md'?0:d.path==='docs/architecture/CODE-MAP.md'?1:d.path.startsWith('docs/architecture/')?2:d.path.startsWith('docs/development/')?3:4;}
      return rank(a)-rank(b)||a.path.localeCompare(b.path);
    });
    $('#doc-count').textContent=eligible.length+' Markdown documents';
    var panel=$('#doc-list');clear(panel);
    if(!eligible.length)panel.appendChild(node('div','no-result','No Markdown document matches your search.'));
    eligible.forEach(function(d){
      var b=node('button','doc-choice'+(activeDocument&&activeDocument.path===d.path?' active':''));
      b.type='button';b.appendChild(node('strong',null,d.title));b.appendChild(node('small',null,d.path));
      b.addEventListener('click',function(){selectDoc(d.path);});panel.appendChild(b);
    });
    if(!activeDocument&&documents.length){
      var first=documents.find(function(d){return d.path==='docs/architecture/SYSTEM.md';})||documents[0];
      selectDoc(first.path);
    }
  }
  function selectDoc(path){
    var d=documents.find(function(x){return x.path===path;});if(!d)return;
    activeDocument=d;var panel=$('#doc-reader');clear(panel);
    var head=node('div','doc-reader-head');head.appendChild(node('span',null,d.path));
    head.appendChild(srcLink(d.path,0,'Read original Markdown ↗'));panel.appendChild(head);
    panel.appendChild(markdownBody(d));panel.scrollTop=0;
    $('.doc-choice').forEach(function(b){
      b.classList.toggle('active',b.querySelector('small')&&b.querySelector('small').textContent===path);
    });
  }

  function init(){
    $('#stat-files').textContent=DATA.stats.files.toLocaleString();
    $('#stat-symbols').textContent=DATA.stats.symbols.toLocaleString();
    $('#stat-links').textContent=DATA.stats.links.toLocaleString();
    $('#stat-archive').textContent=DATA.stats.archived.toLocaleString();
    $('#revision').textContent='SOURCE REVISION '+(DATA.ref||'unknown').slice(0,12);
    $('#github-repo').href=DATA.repository||'#';
    $$('[data-view]').forEach(function(b){b.addEventListener('click',function(){go(b.dataset.view);});});
    $$('[data-go]').forEach(function(b){b.addEventListener('click',function(){go(b.dataset.go);});});
    $$('[data-stage]').forEach(function(b){b.addEventListener('click',function(){stage=b.dataset.stage;renderMap();});});
    $('#zoom-in').addEventListener('click',function(){zoom+=.15;applyZoom();});
    $('#zoom-out').addEventListener('click',function(){zoom-=.15;applyZoom();});
    $('#zoom-reset').addEventListener('click',function(){zoom=1;applyZoom();});
    $('#file-search').addEventListener('input',function(){resultIndex=0;renderFiles();});
    $('#category-filter').addEventListener('change',function(){resultIndex=0;renderFiles();});
    $('#global-search').addEventListener('input',function(){if(this.value.trim()){go('files');$('#file-search').value=this.value;renderFiles();}});
    $('#global-search').addEventListener('keydown',function(e){if(e.key==='Enter'){go('files');$('#file-search').focus();}});
    $('#browse-all').addEventListener('click',function(){$('#category-filter').value='all';renderFiles();});
    $$('.guide-platform').forEach(function(b){b.addEventListener('click',function(){platform=b.dataset.platform;setupGuide();});});
    $('#close-drawer').addEventListener('click',closeDrawer);$('#drawer-cover').addEventListener('click',closeDrawer);
    document.addEventListener('keydown',shortcuts);
    renderMap();renderFiles();setupAgents();setupGuide();setupHelp();renderDocsList();
    $('#doc-search').addEventListener('input',renderDocsList);
    var start=location.hash.replace('#','');if(['map','files','agents','guide','docs'].includes(start))go(start);
  }
  init();
})();
