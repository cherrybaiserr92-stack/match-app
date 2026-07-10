/* ═══════════════════════════════════════════════════════════
   СДВИГ · match3.js v10 — DOM/CSS, композиция Jewels Planet
   Фиксы v10:
   • невидимые фишки — появляются сразу + opacity-fade (без двойного rAF)
   • производительность — только transform/opacity (GPU), без box-shadow-анимаций
   • усилители — панель снизу со счётчиком + кнопка «+» (покупка) + пополнение по времени
   • звёзды-улики (прогресс), цель, ходы — как в Jewels Planet
   Контракт: Match3.start(container,{mission,boosters,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  const GEMS=[
    {id:'trace',  c1:'#ff7a86',c2:'#a51f2c',glow:'#ff5d6c'},
    {id:'witness',c1:'#6fd6ff',c2:'#155e8a',glow:'#5cd0ff'},
    {id:'exhibit',c1:'#52e0a6',c2:'#10704c',glow:'#46d89b'},
    {id:'alibi',  c1:'#f6d27a',c2:'#9a6a18',glow:'#ffcf6b'},
    {id:'link',   c1:'#bda6ff',c2:'#5a3fb0',glow:'#a98bff'}
  ];
  const NC=GEMS.length, N=8;
  const SP={NONE:0,LINEH:1,LINEV:2,BOMB:3,RAINBOW:4};
  const EMBLEM={
    trace:'<path d="M12 3C12 3 19 12 19 16a7 7 0 0 1-14 0c0-4 7-13 7-13z" fill="currentColor"/>',
    witness:'<ellipse cx="12" cy="12" rx="9" ry="6" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="12" r="3.4" fill="currentColor"/>',
    exhibit:'<circle cx="8" cy="12" r="4.5" fill="none" stroke="currentColor" stroke-width="2.2"/><path d="M12 12h8M17 12v4" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>',
    alibi:'<circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" stroke-width="2"/><path d="M12 12V6.5M12 12l4.5 2.5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>',
    link:'<path d="M5 9c0 7 5 11 7 11s7-4 7-11" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/><circle cx="5" cy="8.5" r="2.4" fill="currentColor"/><circle cx="19" cy="8.5" r="2.4" fill="currentColor"/>'
  };
  const SPMARK={1:'↔',2:'↕',3:'✸',4:'★'};

  // усилители: восстанавливаются по времени (как в Jewels Planet)
  const BOOST_DEF=[
    {k:'ashtray', field:'boosters', ico:'🚬', name:'Окурок',    hint:'прижечь одну ячейку',      regenMs:6*60*1000,  max:3, price:100},
    {k:'siren',   field:'bSiren',   ico:'🚨', name:'Мигалка',   hint:'снять ряд и колонку',       regenMs:10*60*1000, max:2, price:150},
    {k:'shuffle', field:'bShuffle', ico:'📼', name:'Перемотка', hint:'перемешать доску',          regenMs:8*60*1000,  max:3, price:150}
  ];

  let opts=null, mission=null, moves=0, score=0, progress=0, combo=0, comboMax=0;
  let grid=[], invMode=null, running=false, busy=false, sel=null, idleT=0, hintTimer=null;
  let _root,_board,_hud,_bar,_stage,_cellPx=40,_resize,_cellBgs=null;
  const HINT_DELAY=6000;
  const STARS=[0.4,0.7,1.0]; // пороги «улик»-звёзд от target

  window.Match3={
    start(container,o){
      opts=o||{}; mission=opts.mission||{type:'score',target:600,moves:14};
      moves=mission.moves||14; score=0; progress=0; combo=0; comboMax=0;
      invMode=null; sel=null; busy=false; running=true; idleT=0;
      try{ if(window.BgFx&&BgFx.pause) BgFx.pause(); }catch(e){}
      regenAll();
      injectCSS(); buildDOM(container); initGrid(); renderBar(); hud(); scheduleHint();
    },
    stop(){ running=false; clearTimeout(hintTimer);
      try{ window.removeEventListener('resize',_resize); }catch(e){}
      if(_root&&_root.parentNode) _root.parentNode.innerHTML=''; _cellBgs=null; }
  };

  /* ── восстановление усилителей по времени ── */
  function regenAll(){
    const p=(window.App&&App.profile); if(!p) return;
    if(!p.boostTs) p.boostTs={};
    const now=Date.now();
    BOOST_DEF.forEach(b=>{
      const cur=p[b.field]||0;
      if(cur>=b.max){ p.boostTs[b.k]=now; return; }
      const last=p.boostTs[b.k]||now;
      const gained=Math.floor((now-last)/b.regenMs);
      if(gained>0){ p[b.field]=Math.min(b.max,cur+gained); p.boostTs[b.k]=last+gained*b.regenMs;
        if(p[b.field]>=b.max)p.boostTs[b.k]=now; }
      else if(!p.boostTs[b.k]) p.boostTs[b.k]=now;
    });
    try{ window.saveProfile&&saveProfile(); }catch(e){}
  }
  function boostLeftMs(b){ const p=(window.App&&App.profile); if(!p)return 0;
    const cur=p[b.field]||0; if(cur>=b.max)return 0;
    const last=(p.boostTs&&p.boostTs[b.k])||Date.now();
    return b.regenMs-((Date.now()-last)%b.regenMs); }

  /* ── CSS ── */
  function injectCSS(){
    if(document.getElementById('m3v10-css')) return;
    const s=document.createElement('style'); s.id='m3v10-css';
    s.textContent=`
    .m3root{position:absolute;inset:0;display:flex;flex-direction:column;background:radial-gradient(circle at 50% 20%,#16141a,#050507);overflow:hidden;}
    .m3top{flex:0 0 auto;padding:8px 14px 4px;display:flex;align-items:center;gap:10px;font-family:Unbounded,sans-serif;}
    .m3moves{display:flex;flex-direction:column;align-items:center;justify-content:center;min-width:54px;height:48px;border-radius:12px;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));border:1px solid #000;
      box-shadow:0 6px 16px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.08);}
    .m3moves .l{font-size:8px;color:#93a1b3;letter-spacing:.08em;}
    .m3moves .n{font-size:20px;font-weight:900;line-height:1;color:#fff;}
    .m3moves .n.low{color:#ff6470;}
    .m3goalwrap{flex:1;display:flex;flex-direction:column;gap:4px;}
    .m3goaltxt{font-size:9px;letter-spacing:.06em;color:#93a1b3;}
    .m3stars{display:flex;gap:5px;}
    .m3star{width:18px;height:18px;color:#3a342a;transition:color .3s,transform .3s;}
    .m3star.on{color:#46d89b;transform:scale(1.1);filter:drop-shadow(0 0 5px rgba(70,216,155,.7));}
    .m3star svg{width:100%;height:100%;display:block;fill:currentColor;}
    .m3track{height:6px;border-radius:6px;background:rgba(255,255,255,.08);overflow:hidden;}
    .m3fill{height:100%;border-radius:6px;background:linear-gradient(90deg,#2a9d6f,#46d89b);transition:width .35s cubic-bezier(.3,1,.4,1);}
    .m3stage{flex:1 1 auto;display:flex;align-items:center;justify-content:center;min-height:0;position:relative;}
    .m3board{position:relative;touch-action:none;border-radius:14px;
      background:linear-gradient(160deg,#232227,#0a0a0c 60%,#000);padding:3px;border:1px solid #000;
      box-shadow:inset 0 0 34px rgba(0,0,0,.6),0 14px 34px rgba(0,0,0,.55),0 0 0 1px rgba(255,255,255,.05);}
    .m3cellbg{position:absolute;border-radius:8px;background:rgba(255,255,255,.025);box-shadow:inset 0 1px 2px rgba(0,0,0,.5);}
    /* фишка: ТОЛЬКО transform/opacity анимируются (GPU) */
    .m3gem{position:absolute;will-change:transform;cursor:pointer;
      transition:transform .15s cubic-bezier(.34,1.4,.6,1);}
    .m3gem.fall{transition:transform .26s cubic-bezier(.4,1.3,.55,1);}
    .m3gem.spawn{animation:m3spawn .26s ease forwards;}
    @keyframes m3spawn{from{opacity:0}to{opacity:1}}
    .m3gem.pop{animation:m3pop .24s ease forwards;}
    @keyframes m3pop{0%{transform:scale(1)}40%{transform:scale(1.22)}100%{transform:scale(0);opacity:0}}
    .m3gem.sel{z-index:3;animation:m3sel .55s ease-in-out infinite;}
    @keyframes m3sel{0%,100%{transform:translate3d(var(--tx),var(--ty),0) scale(1)}50%{transform:translate3d(var(--tx),var(--ty),0) scale(1.1)}}
    .m3gem.hint .gembody{outline:2px solid rgba(255,255,255,.75);outline-offset:-2px;}
    /* вещдок: тёмное стекло, неоновая иконка улики */
    .gembody{position:absolute;inset:6%;border-radius:26%;overflow:hidden;border:1px solid;
      background:linear-gradient(165deg,#211d26,#0d0b10 70%);
      box-shadow:inset 0 1px 0 rgba(255,255,255,.09),inset 0 -8px 14px rgba(0,0,0,.5),0 3px 8px rgba(0,0,0,.45);}
    .gembody::after{content:'';position:absolute;top:0;left:0;right:0;height:42%;
      background:linear-gradient(180deg,rgba(255,255,255,.07),transparent);}
    .gememb{position:absolute;inset:22%;}
    .gememb svg{width:100%;height:100%;display:block;}
    .gemmark{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;font-weight:900;color:#fff;text-shadow:0 0 8px rgba(255,255,255,.9);}
    .gemspring{position:absolute;inset:3%;border-radius:28%;border:2.5px solid rgba(255,255,255,.9);}
    /* панель усилителей снизу (Jewels Planet style) */
    .m3bar{flex:0 0 auto;display:flex;gap:10px;justify-content:center;padding:8px 10px max(10px,env(safe-area-inset-bottom));}
    .m3boost{position:relative;width:62px;height:58px;border-radius:14px;cursor:pointer;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));
      border:1px solid #000;box-shadow:0 6px 16px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.07);
      display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1px;
      transition:transform .1s,border-color .15s,box-shadow .15s;}
    .m3boost.on{border-color:#e0546e;box-shadow:0 0 14px rgba(224,84,110,.45),inset 0 1px 0 rgba(255,255,255,.07);}
    .m3boost:active{transform:scale(.93);}
    .m3boost .bi{font-size:22px;line-height:1;}
    .m3boost .bn{font-size:16px;font-weight:900;color:#fff;line-height:1;}
    .m3boost .btimer{font-size:8px;color:#93a1b3;line-height:1;}
    .m3boost .bplus{position:absolute;top:-6px;right:-6px;width:20px;height:20px;border-radius:50%;
      background:linear-gradient(180deg,#5fd16a,#2e9b3a);border:2px solid #173;color:#fff;font-weight:900;font-size:13px;
      display:flex;align-items:center;justify-content:center;line-height:1;box-shadow:0 2px 4px rgba(0,0,0,.4);}
    .m3boost.empty .bn{color:#ff6470;}
    .m3burst{position:absolute;width:7px;height:7px;border-radius:50%;pointer-events:none;will-change:transform,opacity;}
    .m3combo{position:absolute;top:36%;left:0;right:0;text-align:center;pointer-events:none;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:30px;color:#ff8fa8;text-shadow:0 0 22px #8e1e36;
      animation:m3combo 1s ease forwards;}
    @keyframes m3combo{0%{opacity:0;transform:translateY(10px) scale(.8)}25%{opacity:1;transform:translateY(0) scale(1.1)}100%{opacity:0;transform:translateY(-26px)}}
    .m3ring{position:absolute;border-radius:50%;pointer-events:none;will-change:transform,opacity;border:3px solid #fff;}
    .m3end{position:absolute;inset:0;z-index:10;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;
      background:radial-gradient(60% 50% at 50% 45%,rgba(10,14,22,.75),rgba(4,7,12,.96));animation:m3fade .4s ease;}
    @keyframes m3fade{from{opacity:0}to{opacity:1}}
    .m3end .v{font-family:Unbounded,sans-serif;font-weight:900;font-size:25px;}
    .m3end .s{font-size:13px;color:#9aa3b2;}
    `;
    document.head.appendChild(s);
  }

  /* ── каркас ── */
  function buildDOM(container){
    container.innerHTML='';
    _root=document.createElement('div'); _root.className='m3root';
    _hud=document.createElement('div'); _hud.className='m3top';
    _stage=document.createElement('div'); _stage.className='m3stage';
    _board=document.createElement('div'); _board.className='m3board';
    _stage.appendChild(_board);
    _bar=document.createElement('div'); _bar.className='m3bar';
    _root.appendChild(_hud); _root.appendChild(_stage); _root.appendChild(_bar);
    container.appendChild(_root);
    _cellBgs=null; _resize=()=>layout(); window.addEventListener("resize",_resize);
    layout();
  }
  function layout(){
    if(!_stage) return;
    const r=_stage.getBoundingClientRect();
    const avail=Math.min(r.width||340, r.height||440)-6;
    _cellPx=Math.max(28,Math.floor(avail/N));
    const px=_cellPx*N;
    _board.style.width=px+'px'; _board.style.height=px+'px';
    if(!_cellBgs){ _cellBgs=[];
      for(let y=0;y<N;y++)for(let x=0;x<N;x++){ const c=document.createElement('div'); c.className='m3cellbg'; _board.appendChild(c); _cellBgs.push(c); }
    }
    let bi=0;
    for(let y=0;y<N;y++)for(let x=0;x<N;x++){ const c=_cellBgs[bi++]; if(!c)continue;
      c.style.left=(x*_cellPx+2)+'px'; c.style.top=(y*_cellPx+2)+'px';
      c.style.width=(_cellPx-4)+'px'; c.style.height=(_cellPx-4)+'px'; }
    for(let k=0;k<N*N;k++){ if(grid[k]&&grid[k].el) place(grid[k].el,k,false); }
  }

  /* ── сетка ── */
  function initGrid(){
    grid=new Array(N*N);
    for(let k=0;k<N*N;k++) grid[k]={c:rnd(),sp:SP.NONE,el:null};
    let guard=0; while(findMatches().length&&guard++<200){ findMatches().forEach(g=>g.forEach(k=>grid[k].c=rnd())); }
    for(let k=0;k<N*N;k++){ grid[k].el=makeGem(grid[k].c,grid[k].sp); _board.appendChild(grid[k].el); place(grid[k].el,k,false); }
    bindInput();
  }
  function rnd(){ return Math.floor(Math.random()*NC); }
  const idx=(x,y)=>y*N+x;
  const inb=(x,y)=>x>=0&&x<N&&y>=0&&y<N;

  function makeGem(c,sp){
    const g=GEMS[c]||GEMS[0];
    const el=document.createElement('div'); el.className='m3gem';
    el.innerHTML='<div class="gembody" style="border-color:'+g.c2+'66"></div>'+
      '<div class="gememb" style="color:'+g.glow+';filter:drop-shadow(0 0 5px '+g.glow+'aa)"><svg viewBox="0 0 24 24">'+(EMBLEM[g.id]||'')+'</svg></div>'+
      (sp?'<div class="gemspring"></div><div class="gemmark" style="font-size:'+(_cellPx*0.4)+'px">'+(SPMARK[sp]||'')+'</div>':'');
    return el;
  }
  /* ключевое: устанавливаем позицию через CSS-переменные + transform.
     Новые фишки появляются СРАЗУ (видимы), со spawn-fade — без двойного rAF */
  function place(el,k,animate,fromY){
    const x=k%N,y=k/N|0;
    el.style.width=_cellPx+'px'; el.style.height=_cellPx+'px';
    el.style.setProperty('--tx',(x*_cellPx)+'px');
    el.style.setProperty('--ty',(y*_cellPx)+'px');
    if(animate==='fall'){ el.classList.add('fall'); }
    el.style.transform='translate3d('+(x*_cellPx)+'px,'+(y*_cellPx)+'px,0)';
    if(animate==='spawn'){ el.classList.add('spawn'); }
  }

  function findMatches(){
    const groups=[];
    for(let y=0;y<N;y++){ let run=1;
      for(let x=1;x<=N;x++){ const same=x<N&&grid[idx(x,y)].c===grid[idx(x-1,y)].c&&grid[idx(x,y)].c>=0;
        if(same)run++; else{ if(run>=3){const g=[];for(let k=x-run;k<x;k++)g.push(idx(k,y));groups.push(g);} run=1; } } }
    for(let x=0;x<N;x++){ let run=1;
      for(let y=1;y<=N;y++){ const same=y<N&&grid[idx(x,y)].c===grid[idx(x,y-1)].c&&grid[idx(x,y)].c>=0;
        if(same)run++; else{ if(run>=3){const g=[];for(let k=y-run;k<y;k++)g.push(idx(x,k));groups.push(g);} run=1; } } }
    return groups;
  }
  function findHint(){ for(let y=0;y<N;y++)for(let x=0;x<N;x++) for(const[dx,dy] of [[1,0],[0,1]]){
    if(!inb(x+dx,y+dy))continue; sd(idx(x,y),idx(x+dx,y+dy));
    const m=findMatches().length>0; sd(idx(x,y),idx(x+dx,y+dy)); if(m)return[idx(x,y),idx(x+dx,y+dy)]; } return null; }
  function sd(a,b){ const tc=grid[a].c; grid[a].c=grid[b].c; grid[b].c=tc; const ts=grid[a].sp; grid[a].sp=grid[b].sp; grid[b].sp=ts; }

  /* ── ввод ── */
  function bindInput(){
    let downK=null,sx=0,sy=0;
    function pick(e){ const r=_board.getBoundingClientRect();
      const px=(e.touches?e.touches[0].clientX:e.clientX)-r.left, py=(e.touches?e.touches[0].clientY:e.clientY)-r.top;
      const x=Math.floor(px/_cellPx), y=Math.floor(py/_cellPx); return inb(x,y)?idx(x,y):null; }
    _board.onpointerdown=(e)=>{ if(busy||!running)return; const k=pick(e); if(k==null)return; clearHint(); idleT=0;
      if(invMode){ applyInventory(k); return; } downK=k; sx=e.clientX; sy=e.clientY; setSel(k); Sound.gemSelect&&Sound.gemSelect(); };
    _board.onpointermove=(e)=>{ if(downK==null||busy)return; const dx=e.clientX-sx,dy=e.clientY-sy;
      if(Math.abs(dx)>_cellPx*0.4||Math.abs(dy)>_cellPx*0.4){ const x=downK%N,y=downK/N|0; let tx=x,ty=y;
        if(Math.abs(dx)>Math.abs(dy))tx+=dx>0?1:-1; else ty+=dy>0?1:-1;
        if(inb(tx,ty))trySwap(downK,idx(tx,ty)); downK=null; setSel(null); } };
    _board.onpointerup=(e)=>{ if(downK!=null){ const k=pick(e);
      if(k!=null&&k!==downK){ const ax=downK%N,ay=downK/N|0,bx=k%N,by=k/N|0;
        if(Math.abs(ax-bx)+Math.abs(ay-by)===1)trySwap(downK,k); else setSel(null); }
      else if(k===downK) setSel(downK); } downK=null; };
  }
  function setSel(k){ if(sel!=null&&grid[sel]&&grid[sel].el) grid[sel].el.classList.remove('sel');
    sel=k; if(k!=null&&grid[k]&&grid[k].el) grid[k].el.classList.add('sel'); }

  function swapFull(a,b){ const ta=grid[a],tb=grid[b]; grid[a]=tb; grid[b]=ta; place(grid[a].el,a); place(grid[b].el,b); }

  function trySwap(a,b){
    if(busy||!running) return;
    const ax=a%N,ay=a/N|0,bx=b%N,by=b/N|0;
    if(Math.abs(ax-bx)+Math.abs(ay-by)!==1) return;
    setSel(null); idleT=0; clearHint();
    if(grid[a].sp===SP.RAINBOW||grid[b].sp===SP.RAINBOW){
      busy=true; Sound.gemSwap&&Sound.gemSwap(); swapFull(a,b);
      setTimeout(()=>{ const rk=grid[a].sp===SP.RAINBOW?a:b; const col=grid[rk===a?b:a].c; detonateRainbow(rk,col); spendMove(); },160); return;
    }
    busy=true; Sound.gemSwap&&Sound.gemSwap(); swapFull(a,b);
    setTimeout(()=>{ const ms=findMatches();
      if(ms.length===0){ Sound.error&&Sound.error(); swapFull(a,b); setTimeout(()=>{busy=false;},160); }
      else{ spendMove(); resolveBoard(ms); } },160);
  }
  function spendMove(){ moves--; combo=0; idleT=0; hud(); }

  function resolveBoard(first){
    let cascade=0;
    function step(matches){
      if(!matches) matches=findMatches();
      if(matches.length===0){ busy=false; scheduleHint(); checkEnd(); return; }
      cascade++; combo++; comboMax=Math.max(comboMax,combo);
      if(combo>=2) showCombo(combo);
      if(mission.type==='combo') progress=comboMax;
      const toClear=new Set(); const specials=[];
      matches.forEach(g=>{ const len=g.length,c=grid[g[0]].c; g.forEach(k=>toClear.add(k));
        if(len===4) specials.push({k:g[len>>1],sp:(g[1]-g[0]===1?SP.LINEH:SP.LINEV),c});
        else if(len>=5) specials.push({k:g[len>>1],sp:SP.RAINBOW,c}); });
      detectL(matches,specials);
      const expand=new Set(toClear); toClear.forEach(k=>{ if(grid[k].sp) triggerSpecial(k,expand); });
      let gained=0;
      expand.forEach(k=>{ if(grid[k].c<0)return; gained+=10+cascade*2; burst(k);
        if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
        if(mission.type==='clear')progress++; });
      score+=gained+(combo>1?combo*5:0); if(mission.type==='score')progress=score;
      Sound.gemMatch&&Sound.gemMatch(matches.length);
      if(cascade>1){Sound.gemCascade&&Sound.gemCascade(cascade);vibrate(8);} else vibrate(12);
      expand.forEach(k=>{ if(specials.some(s=>s.k===k))return; removeGem(k); });
      specials.forEach(s=>{ const old=grid[s.k].el; if(old&&old.parentNode)old.parentNode.removeChild(old);
        grid[s.k].c=s.c; grid[s.k].sp=s.sp; grid[s.k].el=makeGem(s.c,s.sp); _board.appendChild(grid[s.k].el); place(grid[s.k].el,s.k,'spawn'); ring(s.k); });
      hud();
      setTimeout(()=>{ collapse(); setTimeout(()=>step(null),300); },260);
    }
    step(first);
  }
  function removeGem(k){ const el=grid[k].el; if(el){ el.classList.add('pop'); setTimeout(()=>{ if(el.parentNode)el.parentNode.removeChild(el); },250); }
    grid[k].c=-1; grid[k].sp=SP.NONE; grid[k].el=null; }
  function detectL(matches,specials){ const inH={},inV={};
    matches.forEach(g=>{ const h=(g[1]-g[0]===1); g.forEach(k=>{(h?inH:inV)[k]=true;}); });
    Object.keys(inH).forEach(k=>{ if(inV[k]){ const kk=+k; if(!specials.some(s=>s.k===kk)) specials.push({k:kk,sp:SP.BOMB,c:grid[kk].c}); } }); }
  function triggerSpecial(k,set){ const x=k%N,y=k/N|0,sp=grid[k].sp; Sound.booster&&Sound.booster(); ring(k);
    if(sp===SP.LINEH){ for(let xx=0;xx<N;xx++)set.add(idx(xx,y)); }
    else if(sp===SP.LINEV){ for(let yy=0;yy<N;yy++)set.add(idx(x,yy)); }
    else if(sp===SP.BOMB){ for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++)if(inb(x+dx,y+dy))set.add(idx(x+dx,y+dy)); }
    else if(sp===SP.RAINBOW){ const c=grid[k].c; for(let i=0;i<N*N;i++)if(grid[i].c===c)set.add(i); } }
  function detonateRainbow(rk,color){ const set=new Set(); for(let i=0;i<N*N;i++)if(grid[i].c===color)set.add(i); set.add(rk);
    Sound.special&&Sound.special(); let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=14; burst(k);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++; if(mission.type==='clear')progress++; removeGem(k); });
    score+=gained; if(mission.type==='score')progress=score; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),300); },260); }

  /* гравитация: переносим элементы вниз; новые — СРАЗУ видимы на месте + spawn-fade */
  function collapse(){
    for(let x=0;x<N;x++){
      let write=N-1;
      for(let y=N-1;y>=0;y--){ const k=idx(x,y);
        if(grid[k].c>=0){ const w=idx(x,write);
          if(w!==k){ grid[w]={c:grid[k].c,sp:grid[k].sp,el:grid[k].el}; grid[k]={c:-1,sp:SP.NONE,el:null}; place(grid[w].el,w,'fall'); }
          write--; } }
      for(let y=write;y>=0;y--){ const k=idx(x,y); const c=rnd(); const el=makeGem(c,SP.NONE);
        _board.appendChild(el); grid[k]={c,sp:SP.NONE,el};
        place(el,k,'spawn'); // СРАЗУ на месте + opacity-fade. Видима всегда.
      }
    }
    Sound.gemFall&&Sound.gemFall();
  }

  /* ── усилители (инвентарь) ── */
  function applyInventory(k){
    const p=(window.App&&App.profile)||{};
    const def=BOOST_DEF.find(b=>b.k===invMode); if(!def){ invMode=null; renderBar(); return; }
    if((p[def.field]||0)<=0){ invMode=null; renderBar(); return; }
    p[def.field]=(p[def.field]||0)-1;
    if(p.boostTs&&p.boostTs[def.k]===undefined) p.boostTs[def.k]=Date.now();
    saveP();
    if(invMode==='ashtray'){ clearSet(new Set([k])); }
    else if(invMode==='siren'){ const x=k%N,y=k/N|0,set=new Set(); for(let i=0;i<N;i++){set.add(idx(i,y));set.add(idx(x,i));} clearSet(set); }
    else if(invMode==='shuffle'){ shuffleBoard(); }
    invMode=null; renderBar();
  }
  function clearSet(set){ Sound.booster&&Sound.booster(); vibrate([10,30]); busy=true; let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=12; burst(k);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++; if(mission.type==='clear')progress++; removeGem(k); });
    score+=gained; if(mission.type==='score')progress=score; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),300); },260); }
  function shuffleBoard(){ busy=true; const cs=[]; for(let k=0;k<N*N;k++) if(grid[k].c>=0) cs.push(grid[k].c);
    for(let i=cs.length-1;i>0;i--){ const j=Math.random()*(i+1)|0; [cs[i],cs[j]]=[cs[j],cs[i]]; }
    let p=0; for(let k=0;k<N*N;k++){ const c=cs[p++];
      if(grid[k].el&&grid[k].el.parentNode) grid[k].el.parentNode.removeChild(grid[k].el);
      grid[k]={c,sp:SP.NONE,el:makeGem(c,SP.NONE)}; _board.appendChild(grid[k].el); place(grid[k].el,k,'spawn'); }
    let guard=0; while(findMatches().length&&guard++<100){ findMatches().forEach(g=>g.forEach(k=>{ grid[k].c=rnd();
      const gg=GEMS[grid[k].c]; grid[k].el.querySelector('.gembody').style.borderColor=gg.c2+'66';
      const em=grid[k].el.querySelector('.gememb'); if(em){ em.style.color=gg.glow; em.style.filter='drop-shadow(0 0 5px '+gg.glow+'aa)'; } })); }
    Sound.transition&&Sound.transition(); setTimeout(()=>{ busy=false; checkEnd(); },340); }
  function saveP(){ try{ window.saveProfile&&saveProfile(); }catch(e){} }

  /* ── эффекты ── */
  function burst(k){ const g=GEMS[grid[k].c]||GEMS[0]; const x=k%N,y=k/N|0;
    for(let i=0;i<5;i++){ const p=document.createElement('div'); p.className='m3burst'; p.style.background=g.c1;
      p.style.left=(x*_cellPx+_cellPx/2)+'px'; p.style.top=(y*_cellPx+_cellPx/2)+'px';
      const a=Math.random()*6.28,d=10+Math.random()*22; _board.appendChild(p);
      requestAnimationFrame(()=>{ p.style.transition='transform .45s ease-out,opacity .45s'; p.style.opacity='0';
        p.style.transform='translate3d('+(Math.cos(a)*d)+'px,'+(Math.sin(a)*d-8)+'px,0) scale(.2)'; });
      setTimeout(()=>{ if(p.parentNode)p.parentNode.removeChild(p); },480); } }
  function ring(k){ const x=k%N,y=k/N|0; const r=document.createElement('div'); r.className='m3ring';
    r.style.cssText+='left:'+(x*_cellPx+_cellPx/2)+'px;top:'+(y*_cellPx+_cellPx/2)+'px;width:0;height:0;transform:translate(-50%,-50%);opacity:.9;color:'+(GEMS[grid[k].c]||GEMS[0]).glow;
    _board.appendChild(r); requestAnimationFrame(()=>{ r.style.transition='all .5s ease-out';
      r.style.width=(_cellPx*1.7)+'px'; r.style.height=(_cellPx*1.7)+'px'; r.style.opacity='0'; });
    setTimeout(()=>{ if(r.parentNode)r.parentNode.removeChild(r); },520); }
  function showCombo(n){ const w=['','','Хорошо!','Отлично!','Превосходно!','Блестяще!','Гениально!'];
    const d=document.createElement('div'); d.className='m3combo'; d.textContent=w[Math.min(n,6)]||'Комбо!';
    _stage.appendChild(d); setTimeout(()=>{ if(d.parentNode)d.parentNode.removeChild(d); },1000); Sound.approve&&Sound.approve(); }

  /* ── конец ── */
  function checkEnd(){ const target=mission.target||600; if(progress>=target){ win(); return; } if(moves<=0) lose(); }
  function win(){ running=false; clearTimeout(hintTimer); Sound.win&&Sound.win(); vibrate([10,40,10,40]); end(true); setTimeout(()=>opts.onWin&&opts.onWin(),1100); }
  function lose(){ running=false; clearTimeout(hintTimer); Sound.deny&&Sound.deny(); end(false); setTimeout(()=>opts.onLose&&opts.onLose(),1500); }
  function end(won){ const stars=starsEarned();
    const o=document.createElement('div'); o.className='m3end';
    o.innerHTML='<div class="v" style="color:'+(won?'#46d89b':'#ff6470')+';text-shadow:0 0 24px '+(won?'#46d89b':'#ff6470')+'">'+
      (won?'УЛИКА ПОЛУЧЕНА':'УЛИКА УТЕРЯНА')+'</div>'+
      '<div class="s">'+(won?('Улик собрано: '+stars+' / 3'):'Сдвиг недоволен')+'</div>';
    _root.appendChild(o); }

  /* ── HUD: ходы + звёзды-улики + цель ── */
  function starsEarned(){ const target=mission.target||600; let s=0; STARS.forEach(t=>{ if(progress>=target*t)s++; }); return s; }
  const STAR_SVG='<svg viewBox="0 0 24 24"><path d="M12 2l3 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.9 21l1.2-6.8-5-4.9 6.9-1z"/></svg>';
  function hud(){
    const target=mission.target||600, pct=Math.min(100,Math.round(progress/target*100)), st=starsEarned();
    _hud.innerHTML=
      '<div class="m3moves"><span class="l">ХОДЫ</span><span class="n'+(moves<=3?' low':'')+'">'+moves+'</span></div>'+
      '<div class="m3goalwrap">'+
        '<div style="display:flex;align-items:center;justify-content:space-between">'+
          '<span class="m3goaltxt">'+(mission.label||'ЦЕЛЬ')+'</span>'+
          '<span class="m3stars">'+[0,1,2].map(i=>'<span class="m3star'+(i<st?' on':'')+'">'+STAR_SVG+'</span>').join('')+'</span>'+
        '</div>'+
        '<div class="m3track"><div class="m3fill" style="width:'+pct+'%"></div></div>'+
      '</div>';
  }

  /* ── панель усилителей (Jewels Planet) ── */
  let barTimer=null;
  function renderBar(){
    regenAll();
    const p=(window.App&&App.profile)||{};
    _bar.innerHTML=BOOST_DEF.map(b=>{
      const n=p[b.field]||0; const ms=boostLeftMs(b);
      const timer=(n<b.max&&ms>0)?('<span class="btimer">'+fmt(ms)+'</span>'):'<span class="btimer">готов</span>';
      return '<div class="m3boost'+(invMode===b.k?' on':'')+(n<=0?' empty':'')+'" data-k="'+b.k+'">'+
        '<span class="bi">'+b.ico+'</span><span class="bn">'+n+'</span>'+timer+
        '<span class="bplus" data-buy="'+b.k+'">+</span></div>';
    }).join('');
    _bar.querySelectorAll('.m3boost').forEach(el=>{ el.onclick=(e)=>{
      if(e.target.getAttribute('data-buy')){ buyBoost(el.dataset.k); return; }
      const b=BOOST_DEF.find(x=>x.k===el.dataset.k); const n=(p[b.field]||0);
      if(n<=0){ Sound.error&&Sound.error(); buyBoost(el.dataset.k); return; }
      invMode=invMode===el.dataset.k?null:el.dataset.k; Sound.tap&&Sound.tap(); renderBar(); }; });
    clearTimeout(barTimer); if(running) barTimer=setTimeout(renderBar,1000); // тикает таймер пополнения
  }
  function buyBoost(k){ const b=BOOST_DEF.find(x=>x.k===k); const p=(window.App&&App.profile); if(!p)return;
    if((p.bucks||0)<b.price){ Sound.error&&Sound.error(); if(window.toast)toast('Мало баксов',b.name+' — '+b.price+' 💵','✗');
      if(window.openBuckShop)openBuckShop(); return; }
    p.bucks-=b.price; p[b.field]=(p[b.field]||0)+1; saveP(); Sound.coin&&Sound.coin();
    if(window.toast)toast('Куплено',b.name,'🛍'); if(window.renderHUD)renderHUD(); renderBar(); }
  function fmt(ms){ const s=Math.ceil(ms/1000); const m=Math.floor(s/60); return m>0?(m+':'+String(s%60).padStart(2,'0')):(s+'с'); }

  /* ── подсказка ── */
  function scheduleHint(){ clearTimeout(hintTimer); if(!running)return;
    hintTimer=setTimeout(()=>{ if(busy||!running)return; const h=findHint();
      if(h)h.forEach(k=>{ if(grid[k].el)grid[k].el.classList.add('hint'); }); }, HINT_DELAY); }
  function clearHint(){ for(let k=0;k<N*N;k++) if(grid[k]&&grid[k].el) grid[k].el.classList.remove('hint'); scheduleHint(); }
})();

