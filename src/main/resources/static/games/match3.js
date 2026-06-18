/* ═══════════════════════════════════════════════════════════
   СДВИГ · match3.js v9 — DOM/CSS движок (без Canvas)
   Почему DOM: каждая фишка — отдельный <div> с GPU-transform.
   Это убирает лаги Canvas, баг исчезновения (элемент не теряется),
   и даёт качественный SVG-перелив через CSS-анимацию.
   Контракт: Match3.start(container,{mission,boosters,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  // 5 типов улик: цвет + SVG-эмблема (рисуется один раз, переиспользуется)
  const GEMS=[
    {id:'trace',  c1:'#ff7a86',c2:'#a51f2c',glow:'#ff5d6c'},
    {id:'witness',c1:'#6fd6ff',c2:'#155e8a',glow:'#5cd0ff'},
    {id:'exhibit',c1:'#52e0a6',c2:'#10704c',glow:'#46d89b'},
    {id:'alibi',  c1:'#f6d27a',c2:'#9a6a18',glow:'#ffcf6b'},
    {id:'link',   c1:'#bda6ff',c2:'#5a3fb0',glow:'#a98bff'}
  ];
  const NC=GEMS.length, N=8;
  const SP={NONE:0,LINEH:1,LINEV:2,BOMB:3,RAINBOW:4};

  // SVG-эмблемы улик (чистые, читаемые)
  const EMBLEM={
    trace:'<path d="M12 3C12 3 19 12 19 16a7 7 0 0 1-14 0c0-4 7-13 7-13z" fill="rgba(255,255,255,.92)"/>',
    witness:'<ellipse cx="12" cy="12" rx="9" ry="6" fill="none" stroke="rgba(255,255,255,.92)" stroke-width="2"/><circle cx="12" cy="12" r="3.4" fill="rgba(255,255,255,.92)"/>',
    exhibit:'<circle cx="8" cy="12" r="4.5" fill="none" stroke="rgba(255,255,255,.92)" stroke-width="2.2"/><path d="M12 12h8M17 12v4" stroke="rgba(255,255,255,.92)" stroke-width="2.2" stroke-linecap="round"/>',
    alibi:'<circle cx="12" cy="12" r="8.5" fill="none" stroke="rgba(255,255,255,.92)" stroke-width="2"/><path d="M12 12V6.5M12 12l4.5 2.5" stroke="rgba(255,255,255,.92)" stroke-width="2.2" stroke-linecap="round"/>',
    link:'<path d="M5 9c0 7 5 11 7 11s7-4 7-11" fill="none" stroke="rgba(255,255,255,.92)" stroke-width="2.2" stroke-linecap="round"/><circle cx="5" cy="8.5" r="2.4" fill="rgba(255,255,255,.92)"/><circle cx="19" cy="8.5" r="2.4" fill="rgba(255,255,255,.92)"/>'
  };
  const SPMARK={1:'↔',2:'↕',3:'✸',4:'★'};

  let opts=null, mission=null, moves=0, score=0, progress=0, combo=0, comboMax=0;
  let grid=[];          // grid[k]={c,sp,el}
  let invMode=null, running=false, busy=false;
  let sel=null, idleT=0, hintTimer=null;
  let _root,_board,_hud,_bar,_cellPx=40,N_=N;
  const HINT_DELAY=6000;

  window.Match3={
    start(container,o){
      opts=o||{}; mission=opts.mission||{type:'score',target:600,moves:14};
      moves=mission.moves||14; score=0; progress=0; combo=0; comboMax=0;
      invMode=null; sel=null; busy=false; running=true; idleT=0;
      try{ if(window.BgFx&&BgFx.pause) BgFx.pause(); }catch(e){}
      injectCSS(); buildDOM(container); initGrid(); renderBar(); hud();
      scheduleHint();
    },
    stop(){
      running=false; clearTimeout(hintTimer);
      try{ window.removeEventListener('resize',_resize); }catch(e){}
      if(_root&&_root.parentNode) _root.parentNode.innerHTML='';
    }
  };

  /* ── CSS (один раз) ── */
  function injectCSS(){
    if(document.getElementById('m3v9-css')) return;
    const s=document.createElement('style'); s.id='m3v9-css';
    s.textContent=`
    .m3root{position:absolute;inset:0;display:flex;flex-direction:column;background:linear-gradient(180deg,#1a1611,#0d0b08);}
    .m3hud{padding:10px 16px 4px;font-family:Unbounded,sans-serif;flex:0 0 auto;}
    .m3hud-row{display:flex;align-items:flex-end;gap:12px;}
    .m3goal{flex:1;font-size:9px;letter-spacing:.08em;color:#c8a05a;}
    .m3track{height:7px;border-radius:6px;background:rgba(255,255,255,.08);overflow:hidden;margin-top:5px;}
    .m3fill{height:100%;border-radius:6px;background:linear-gradient(90deg,#b3741c,#ffcf6b);box-shadow:0 0 8px #c8860a;transition:width .35s cubic-bezier(.3,1,.4,1);}
    .m3moves{text-align:center;min-width:50px;}
    .m3moves .lbl{font-size:9px;color:#c8a05a;letter-spacing:.06em;}
    .m3moves .num{font-size:22px;font-weight:900;line-height:1;color:#fff;}
    .m3moves .num.low{color:#ff6470;}
    .m3stage{flex:1 1 auto;display:flex;align-items:center;justify-content:center;min-height:0;position:relative;}
    .m3board{position:relative;touch-action:none;border-radius:12px;background:rgba(20,16,12,.5);padding:3px;}
    .m3cellbg{position:absolute;border-radius:8px;}
    .m3gem{position:absolute;will-change:transform,opacity;cursor:pointer;
      transition:transform .16s cubic-bezier(.34,1.56,.64,1),opacity .2s ease;}
    .m3gem.fall{transition:transform .28s cubic-bezier(.34,1.4,.5,1);}
    .m3gem.pop{animation:m3pop .26s ease forwards;}
    @keyframes m3pop{0%{transform:scale(1)}45%{transform:scale(1.25)}100%{transform:scale(0);opacity:0}}
    .m3gem.sel .gembody{filter:brightness(1.18);animation:m3sel .6s ease-in-out infinite;}
    @keyframes m3sel{0%,100%{transform:scale(1)}50%{transform:scale(1.08)}}
    .m3gem.hintglow .gembody{animation:m3hint 1s ease-in-out infinite;}
    @keyframes m3hint{0%,100%{box-shadow:0 0 0 0 rgba(255,207,107,0)}50%{box-shadow:0 0 0 3px rgba(255,207,107,.8),0 0 16px rgba(255,207,107,.6)}}
    .gembody{position:absolute;inset:6%;border-radius:30%;overflow:hidden;
      box-shadow:inset 0 -22% 30% rgba(0,0,0,.4),inset 0 14% 22% rgba(255,255,255,.28),0 3px 8px rgba(0,0,0,.45);}
    /* перелив — бегущая светлая полоса */
    .gembody::after{content:'';position:absolute;top:-30%;left:-60%;width:50%;height:160%;
      background:linear-gradient(90deg,transparent,rgba(255,255,255,.55),transparent);
      transform:rotate(18deg);animation:m3shine 3.2s linear infinite;}
    @keyframes m3shine{0%{left:-60%}55%{left:140%}100%{left:140%}}
    .gemhi{position:absolute;top:12%;left:16%;width:42%;height:34%;border-radius:50%;
      background:radial-gradient(ellipse at 35% 35%,rgba(255,255,255,.9),rgba(255,255,255,0) 70%);}
    .gememb{position:absolute;inset:22%;}
    .gememb svg{width:100%;height:100%;display:block;}
    .gemspmark{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
      font-weight:900;color:#fff;text-shadow:0 0 8px rgba(255,255,255,.9);pointer-events:none;}
    .gemspring{position:absolute;inset:2%;border-radius:30%;border:2.5px solid rgba(255,255,255,.9);
      box-shadow:0 0 12px currentColor;pointer-events:none;}
    .m3bar{display:flex;gap:8px;justify-content:center;padding:6px 6px max(8px,env(safe-area-inset-bottom));flex:0 0 auto;}
    .m3bbtn{cursor:pointer;border-radius:11px;background:rgba(255,255,255,.05);
      border:1px solid rgba(240,169,58,.4);color:#ffcf6b;padding:9px 14px;font-weight:800;font-size:14px;min-width:58px;
      display:flex;align-items:center;gap:6px;justify-content:center;transition:transform .1s,background .15s;}
    .m3bbtn.on{background:rgba(255,207,107,.22);border-color:#ffcf6b;}
    .m3bbtn:active{transform:scale(.94);}
    .m3bbtn.empty{opacity:.4;}
    .m3bbtn .bico{width:18px;height:18px;}
    .m3burst{position:absolute;width:6px;height:6px;border-radius:50%;pointer-events:none;will-change:transform,opacity;}
    .m3combo{position:absolute;top:38%;left:0;right:0;text-align:center;pointer-events:none;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:30px;color:#ffcf6b;text-shadow:0 0 22px #c8860a;
      animation:m3combo 1s ease forwards;}
    @keyframes m3combo{0%{opacity:0;transform:translateY(10px) scale(.8)}25%{opacity:1;transform:translateY(0) scale(1.1)}100%{opacity:0;transform:translateY(-26px) scale(1)}}
    .m3end{position:absolute;inset:0;z-index:10;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;
      background:radial-gradient(60% 50% at 50% 45%,rgba(10,14,22,.75),rgba(4,7,12,.96));animation:m3fade .4s ease;}
    @keyframes m3fade{from{opacity:0}to{opacity:1}}
    .m3end .v{font-family:Unbounded,sans-serif;font-weight:900;font-size:26px;}
    .m3end .s{font-size:13px;color:#9aa3b2;}
    `;
    document.head.appendChild(s);
  }

  /* ── DOM-каркас ── */
  let _resize;
  function buildDOM(container){
    container.innerHTML='';
    _root=document.createElement('div'); _root.className='m3root';
    _hud=document.createElement('div'); _hud.className='m3hud';
    const stage=document.createElement('div'); stage.className='m3stage';
    _board=document.createElement('div'); _board.className='m3board';
    stage.appendChild(_board);
    _bar=document.createElement('div'); _bar.className='m3bar';
    _root.appendChild(_hud); _root.appendChild(stage); _root.appendChild(_bar);
    container.appendChild(_root);
    _stage=stage;
    _resize=()=>layout(); window.addEventListener('resize',_resize);
    requestAnimationFrame(layout);
  }
  let _stage;
  function layout(){
    if(!_stage) return;
    const r=_stage.getBoundingClientRect();
    const avail=Math.min(r.width, r.height)-6;
    _cellPx=Math.floor(avail/N);
    const px=_cellPx*N;
    _board.style.width=px+'px'; _board.style.height=px+'px';
    // фоновые клетки
    if(!_board.querySelector('.m3cellbg')){
      for(let y=0;y<N;y++)for(let x=0;x<N;x++){
        const c=document.createElement('div'); c.className='m3cellbg';
        c.style.background=(x+y)%2?'rgba(255,255,255,.02)':'rgba(0,0,0,.12)';
        _board.appendChild(c);
      }
    }
    const bgs=_board.querySelectorAll('.m3cellbg');
    let bi=0; for(let y=0;y<N;y++)for(let x=0;x<N;x++){ const c=bgs[bi++];
      c.style.left=(x*_cellPx+2)+'px'; c.style.top=(y*_cellPx+2)+'px';
      c.style.width=(_cellPx-4)+'px'; c.style.height=(_cellPx-4)+'px'; }
    // позиции фишек
    for(let k=0;k<N*N;k++){ if(grid[k]&&grid[k].el) placeGem(grid[k].el,k); }
  }

  /* ── сетка ── */
  function initGrid(){
    grid=new Array(N*N);
    for(let k=0;k<N*N;k++) grid[k]={c:rnd(),sp:SP.NONE,el:null};
    let guard=0; while(findMatches().length&&guard++<200){ findMatches().forEach(g=>g.forEach(k=>grid[k].c=rnd())); }
    // создаём элементы
    for(let k=0;k<N*N;k++){ grid[k].el=makeGem(grid[k].c,grid[k].sp); _board.appendChild(grid[k].el); placeGem(grid[k].el,k); }
    bindInput();
  }
  function rnd(){ return Math.floor(Math.random()*NC); }
  const idx=(x,y)=>y*N+x;
  const inb=(x,y)=>x>=0&&x<N&&y>=0&&y<N;

  function makeGem(c,sp){
    const g=GEMS[c]||GEMS[0];
    const el=document.createElement('div'); el.className='m3gem';
    const sz=()=>_cellPx;
    el.innerHTML=
      '<div class="gembody" style="background:radial-gradient(circle at 38% 32%,'+g.c1+','+g.c2+');color:'+g.glow+'"></div>'+
      '<div class="gemhi"></div>'+
      '<div class="gememb"><svg viewBox="0 0 24 24">'+(EMBLEM[g.id]||'')+'</svg></div>'+
      (sp?'<div class="gemspring" style="color:'+g.glow+'"></div><div class="gemspmark" style="font-size:'+(_cellPx*0.4)+'px">'+(SPMARK[sp]||'')+'</div>':'');
    el._c=c; el._sp=sp;
    return el;
  }
  function placeGem(el,k){
    const x=k%N,y=k/N|0;
    el.style.width=_cellPx+'px'; el.style.height=_cellPx+'px';
    el.style.transform='translate3d('+(x*_cellPx)+'px,'+(y*_cellPx)+'px,0)';
  }
  function moveGem(el,k,fall){
    const x=k%N,y=k/N|0;
    if(fall){ el.classList.add('fall'); setTimeout(()=>el.classList.remove('fall'),300); }
    el.style.transform='translate3d('+(x*_cellPx)+'px,'+(y*_cellPx)+'px,0)';
  }

  /* ── совпадения ── */
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
  function findHint(){
    for(let y=0;y<N;y++)for(let x=0;x<N;x++) for(const[dx,dy] of [[1,0],[0,1]]){
      if(!inb(x+dx,y+dy))continue; sd(idx(x,y),idx(x+dx,y+dy));
      const m=findMatches().length>0; sd(idx(x,y),idx(x+dx,y+dy));
      if(m) return [idx(x,y),idx(x+dx,y+dy)];
    } return null;
  }
  function sd(a,b){ const t=grid[a].c; grid[a].c=grid[b].c; grid[b].c=t;
    const ts=grid[a].sp; grid[a].sp=grid[b].sp; grid[b].sp=ts; } // swap только данных (для проверок)

  /* ── ход ── */
  function bindInput(){
    let downK=null,sx=0,sy=0;
    function pick(e){ const r=_board.getBoundingClientRect();
      const px=(e.touches?e.touches[0].clientX:e.clientX)-r.left, py=(e.touches?e.touches[0].clientY:e.clientY)-r.top;
      const x=Math.floor(px/_cellPx), y=Math.floor(py/_cellPx); return inb(x,y)?idx(x,y):null; }
    _board.onpointerdown=(e)=>{ if(busy||!running)return; const k=pick(e); if(k==null)return;
      clearHintGlow(); idleT=0;
      if(invMode){ applyInventory(k); return; }
      downK=k; sx=e.clientX; sy=e.clientY; setSel(k); Sound.gemSelect&&Sound.gemSelect(); };
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

  /* физический обмен двух фишек (данные + элементы) */
  function swapFull(a,b){
    const ta=grid[a], tb=grid[b];
    grid[a]=tb; grid[b]=ta;
    moveGem(grid[a].el,a); moveGem(grid[b].el,b);
  }

  function trySwap(a,b){
    if(busy||!running) return;
    const ax=a%N,ay=a/N|0,bx=b%N,by=b/N|0;
    if(Math.abs(ax-bx)+Math.abs(ay-by)!==1) return;
    setSel(null); idleT=0; clearHintGlow();

    // радуга
    if(grid[a].sp===SP.RAINBOW||grid[b].sp===SP.RAINBOW){
      busy=true; Sound.gemSwap&&Sound.gemSwap(); swapFull(a,b);
      setTimeout(()=>{ const rk=grid[a].sp===SP.RAINBOW?a:b; const col=grid[rk===a?b:a].c; detonateRainbow(rk,col); spendMove(); },170);
      return;
    }
    busy=true; Sound.gemSwap&&Sound.gemSwap(); swapFull(a,b);
    setTimeout(()=>{
      const ms=findMatches();
      if(ms.length===0){ Sound.error&&Sound.error(); swapFull(a,b); setTimeout(()=>{busy=false;},170); }
      else{ spendMove(); resolveBoard(ms); }
    },170);
  }
  function spendMove(){ moves--; combo=0; idleT=0; hud(); }

  /* ── каскады ── */
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
      const expand=new Set(toClear);
      toClear.forEach(k=>{ if(grid[k].sp) triggerSpecial(k,expand); });

      let gained=0;
      expand.forEach(k=>{ if(grid[k].c<0)return; gained+=10+cascade*2; burst(k);
        if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
        if(mission.type==='clear')progress++; });
      score+=gained+(combo>1?combo*5:0);
      if(mission.type==='score')progress=score;
      Sound.gemMatch&&Sound.gemMatch(matches.length);
      if(cascade>1){Sound.gemCascade&&Sound.gemCascade(cascade);vibrate(8);} else vibrate(12);

      // удаляем (pop-анимация) кроме тех, что станут спец
      expand.forEach(k=>{ if(specials.some(s=>s.k===k)) return;
        const el=grid[k].el; if(el){ el.classList.add('pop'); const ee=el; setTimeout(()=>{ if(ee.parentNode)ee.parentNode.removeChild(ee); },260); }
        grid[k].c=-1; grid[k].sp=SP.NONE; grid[k].el=null; });
      // превращаем в спец
      specials.forEach(s=>{ const old=grid[s.k].el; if(old&&old.parentNode)old.parentNode.removeChild(old);
        grid[s.k].c=s.c; grid[s.k].sp=s.sp; grid[s.k].el=makeGem(s.c,s.sp); _board.appendChild(grid[s.k].el); placeGem(grid[s.k].el,s.k);
        ring(s.k); });
      hud();
      setTimeout(()=>{ collapse(); setTimeout(()=>step(null),300); },270);
    }
    step(first);
  }
  function detectL(matches,specials){
    const inH={},inV={};
    matches.forEach(g=>{ const h=(g[1]-g[0]===1); g.forEach(k=>{(h?inH:inV)[k]=true;}); });
    Object.keys(inH).forEach(k=>{ if(inV[k]){ const kk=+k; if(!specials.some(s=>s.k===kk)) specials.push({k:kk,sp:SP.BOMB,c:grid[kk].c}); } });
  }
  function triggerSpecial(k,set){
    const x=k%N,y=k/N|0,sp=grid[k].sp; Sound.booster&&Sound.booster(); ring(k);
    if(sp===SP.LINEH){ for(let xx=0;xx<N;xx++)set.add(idx(xx,y)); }
    else if(sp===SP.LINEV){ for(let yy=0;yy<N;yy++)set.add(idx(x,yy)); }
    else if(sp===SP.BOMB){ for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++)if(inb(x+dx,y+dy))set.add(idx(x+dx,y+dy)); }
    else if(sp===SP.RAINBOW){ const c=grid[k].c; for(let i=0;i<N*N;i++)if(grid[i].c===c)set.add(i); }
  }
  function detonateRainbow(rk,color){
    const set=new Set(); for(let i=0;i<N*N;i++)if(grid[i].c===color)set.add(i); set.add(rk);
    Sound.special&&Sound.special(); let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=14; burst(k);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
      if(mission.type==='clear')progress++;
      const el=grid[k].el; if(el){ el.classList.add('pop'); const ee=el; setTimeout(()=>{ if(ee.parentNode)ee.parentNode.removeChild(ee); },260); }
      grid[k].c=-1; grid[k].sp=SP.NONE; grid[k].el=null; });
    score+=gained; if(mission.type==='score')progress=score; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),300); },270);
  }

  /* гравитация: переносим существующие элементы вниз, доспавниваем новые сверху */
  function collapse(){
    for(let x=0;x<N;x++){
      let write=N-1;
      for(let y=N-1;y>=0;y--){ const k=idx(x,y);
        if(grid[k].c>=0){ const w=idx(x,write);
          if(w!==k){ grid[w]={c:grid[k].c,sp:grid[k].sp,el:grid[k].el}; grid[k]={c:-1,sp:SP.NONE,el:null};
            moveGem(grid[w].el,w,true); }
          write--; } }
      for(let y=write;y>=0;y--){ const k=idx(x,y);
        const c=rnd(); const el=makeGem(c,SP.NONE);
        // появление сверху за полем
        el.style.transform='translate3d('+(x*_cellPx)+'px,'+((y-write-2)*_cellPx)+'px,0)';
        _board.appendChild(el); grid[k]={c,sp:SP.NONE,el};
        // в следующий кадр — на место (анимация падения)
        requestAnimationFrame(()=>requestAnimationFrame(()=>moveGem(el,k,true)));
      }
    }
    Sound.gemFall&&Sound.gemFall();
  }

  /* ── бустеры инвентаря ── */
  function applyInventory(k){
    const p=(window.App&&App.profile)||{};
    if(invMode==='ashtray'){ if(p.boosters>0)p.boosters--; saveP(); clearSet(new Set([k])); }
    else if(invMode==='siren'){ if(p.bSiren>0)p.bSiren--; saveP();
      const x=k%N,y=k/N|0,set=new Set(); for(let i=0;i<N;i++){set.add(idx(i,y));set.add(idx(x,i));} clearSet(set); }
    else if(invMode==='shuffle'){ if(p.bShuffle>0)p.bShuffle--; saveP(); shuffleBoard(); }
    invMode=null; renderBar();
  }
  function clearSet(set){
    Sound.booster&&Sound.booster(); vibrate([10,30]); busy=true; let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=12; burst(k);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
      if(mission.type==='clear')progress++;
      const el=grid[k].el; if(el){ el.classList.add('pop'); const ee=el; setTimeout(()=>{ if(ee.parentNode)ee.parentNode.removeChild(ee); },260); }
      grid[k]={c:-1,sp:SP.NONE,el:null}; });
    score+=gained; if(mission.type==='score')progress=score; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),300); },270);
  }
  function shuffleBoard(){
    busy=true; const cs=[]; for(let k=0;k<N*N;k++) if(grid[k].c>=0) cs.push(grid[k].c);
    for(let i=cs.length-1;i>0;i--){ const j=Math.random()*(i+1)|0; [cs[i],cs[j]]=[cs[j],cs[i]]; }
    let p=0; for(let k=0;k<N*N;k++){ const c=cs[p++]; grid[k].c=c;
      if(grid[k].el&&grid[k].el.parentNode) grid[k].el.parentNode.removeChild(grid[k].el);
      grid[k].sp=SP.NONE; grid[k].el=makeGem(c,SP.NONE); _board.appendChild(grid[k].el); placeGem(grid[k].el,k); }
    let guard=0; while(findMatches().length&&guard++<100){ findMatches().forEach(g=>g.forEach(k=>{ grid[k].c=rnd();
      grid[k].el.querySelector('.gembody').style.background='radial-gradient(circle at 38% 32%,'+GEMS[grid[k].c].c1+','+GEMS[grid[k].c].c2+')'; })); }
    Sound.transition&&Sound.transition();
    setTimeout(()=>{ busy=false; checkEnd(); },350);
  }
  function saveP(){ try{ window.saveProfile&&saveProfile(); }catch(e){} }

  /* ── эффекты ── */
  function burst(k){
    const g=GEMS[grid[k].c]||GEMS[0]; const x=k%N,y=k/N|0;
    for(let i=0;i<6;i++){ const p=document.createElement('div'); p.className='m3burst';
      p.style.background=g.c1; p.style.left=(x*_cellPx+_cellPx/2)+'px'; p.style.top=(y*_cellPx+_cellPx/2)+'px';
      const a=Math.random()*6.28, d=10+Math.random()*26;
      _board.appendChild(p);
      requestAnimationFrame(()=>{ p.style.transition='transform .5s ease-out,opacity .5s ease-out';
        p.style.transform='translate('+(Math.cos(a)*d)+'px,'+(Math.sin(a)*d-10)+'px) scale(.2)'; p.style.opacity='0'; });
      setTimeout(()=>{ if(p.parentNode)p.parentNode.removeChild(p); },520);
    }
  }
  function ring(k){ const x=k%N,y=k/N|0; const r=document.createElement('div');
    r.style.cssText='position:absolute;border-radius:50%;border:3px solid '+(GEMS[grid[k].c]||GEMS[0]).glow+';pointer-events:none;'+
      'left:'+(x*_cellPx+_cellPx/2)+'px;top:'+(y*_cellPx+_cellPx/2)+'px;width:0;height:0;transform:translate(-50%,-50%);opacity:.9;';
    _board.appendChild(r); requestAnimationFrame(()=>{ r.style.transition='all .5s ease-out';
      r.style.width=(_cellPx*1.8)+'px'; r.style.height=(_cellPx*1.8)+'px'; r.style.opacity='0'; });
    setTimeout(()=>{ if(r.parentNode)r.parentNode.removeChild(r); },520);
  }
  function showCombo(n){ const w=['','','Хорошо!','Отлично!','Превосходно!','Блестяще!','Гениально!'];
    const d=document.createElement('div'); d.className='m3combo'; d.textContent=w[Math.min(n,6)]||'Комбо!';
    _stage.appendChild(d); setTimeout(()=>{ if(d.parentNode)d.parentNode.removeChild(d); },1000);
    Sound.approve&&Sound.approve();
  }

  /* ── конец ── */
  function checkEnd(){ const target=mission.target||600;
    if(progress>=target){ win(); return; } if(moves<=0) lose(); }
  function win(){ running=false; clearTimeout(hintTimer); Sound.win&&Sound.win(); vibrate([10,40,10,40]); end(true); setTimeout(()=>opts.onWin&&opts.onWin(),1000); }
  function lose(){ running=false; clearTimeout(hintTimer); Sound.deny&&Sound.deny(); end(false); setTimeout(()=>opts.onLose&&opts.onLose(),1500); }
  function end(won){ const o=document.createElement('div'); o.className='m3end';
    o.innerHTML='<div class="v" style="color:'+(won?'#46d89b':'#ff6470')+';text-shadow:0 0 24px '+(won?'#46d89b':'#ff6470')+'">'+
      (won?'УЛИКА ПОЛУЧЕНА':'УЛИКА УТЕРЯНА')+'</div><div class="s">'+(won?'Свайп разблокирован':'Сдвиг недоволен')+'</div>';
    _root.appendChild(o);
  }

  /* ── HUD ── */
  function hud(){
    const target=mission.target||600, pct=Math.min(100,Math.round(progress/target*100));
    _hud.innerHTML='<div class="m3hud-row"><div class="m3goal">'+(mission.label||'ЦЕЛЬ')+
      '<div class="m3track"><div class="m3fill" style="width:'+pct+'%"></div></div></div>'+
      '<div class="m3moves"><div class="lbl">ХОДЫ</div><div class="num'+(moves<=3?' low':'')+'">'+moves+'</div></div></div>';
  }
  function renderBar(){
    const p=(window.App&&App.profile)||{};
    const items=[{k:'ashtray',n:p.boosters||0,svg:gemBarIco('ashtray'),t:'Пепельница'},
                 {k:'siren',n:p.bSiren||0,svg:gemBarIco('siren'),t:'Мигалка'},
                 {k:'shuffle',n:p.bShuffle||0,svg:gemBarIco('tape'),t:'Плёнка'}];
    _bar.innerHTML=items.map(it=>'<button class="m3bbtn'+(invMode===it.k?' on':'')+(it.n<=0?' empty':'')+'" data-k="'+it.k+'" title="'+it.t+'">'+
      '<span class="bico">'+it.svg+'</span> '+it.n+'</button>').join('');
    _bar.querySelectorAll('.m3bbtn').forEach(b=>b.onclick=()=>{ const k=b.dataset.k,n=items.find(i=>i.k===k).n;
      if(n<=0){ Sound.error&&Sound.error(); if(window.toast)toast('Нет бустера','Купи в Лавке','✗'); return; }
      invMode=invMode===k?null:k; Sound.tap&&Sound.tap(); renderBar(); });
  }
  function gemBarIco(k){
    if(window.GEM_SVG && window.GEM_SVG[k]) return window.GEM_SVG[k];
    const M={ashtray:'🪨',siren:'🚨',tape:'📼'}; return M[k]||'•';
  }

  /* ── подсказка ── */
  function scheduleHint(){ clearTimeout(hintTimer); if(!running)return;
    hintTimer=setTimeout(()=>{ if(busy||!running)return; const h=findHint();
      if(h) h.forEach(k=>{ if(grid[k].el)grid[k].el.classList.add('hintglow'); }); }, HINT_DELAY); }
  function clearHintGlow(){ clearTimeout(hintTimer);
    for(let k=0;k<N*N;k++) if(grid[k]&&grid[k].el) grid[k].el.classList.remove('hintglow'); scheduleHint(); }
})();

