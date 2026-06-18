/* ═══════════════════════════════════════════════════════════
   СДВИГ · match3.js v8 — «Самоцветы улик» (исправленный AAA)
   Фиксы v8: фишки больше не пропадают (позиции по индексу, без _ox на объекте),
   нет лагов (один цикл рендера, анимации через таймстемпы),
   глянец-перелив, поле на весь экран, подсказка реже.
   Контракт: Match3.start(container,{mission,boosters,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  const GEMS=[
    {id:'trace',  a:'#ff6470', b:'#a51f2c', hi:'#ffd9dd', glow:'#ff5d6c'},
    {id:'witness',a:'#5cd0ff', b:'#155e8a', hi:'#d6f4ff', glow:'#5cd0ff'},
    {id:'exhibit',a:'#46d89b', b:'#10704c', hi:'#d6fff0', glow:'#46d89b'},
    {id:'alibi',  a:'#f3c963', b:'#9a6a18', hi:'#fff3cf', glow:'#ffcf6b'},
    {id:'link',   a:'#b69cff', b:'#5a3fb0', hi:'#ece4ff', glow:'#a98bff'}
  ];
  const NC=GEMS.length, N=8;
  const SP={NONE:0,LINEH:1,LINEV:2,BOMB:3,RAINBOW:4};

  let cvs,ctx,W,H,DPR,cell,ox,oy,boardPx;
  // grid[k] = {c, sp}   — ТОЛЬКО данные, без визуальных полей
  let grid=[];
  // визуальное состояние отдельно, по индексу (не теряется при swap данных)
  let vis=[];   // vis[k] = {dy, scale, glow, pop}
  let sel=null;
  let busy=false, raf=null, running=false;
  let opts=null, mission=null, moves=0, score=0, progress=0, combo=0, comboMax=0;
  let invMode=null, particles=[], floaters=[];
  let idleT=0, hintCells=null, shakeT=0, last=0;
  // анимация свапа (не на объекте фишки!)
  let swapAnim=null; // {a,b,t0,dur,back,done}
  const HINT_DELAY=6000; // подсказка реже (6 c)

  window.Match3={
    start(container,o){
      opts=o||{}; mission=opts.mission||{type:'score',target:600,moves:14};
      moves=mission.moves||14; score=0; progress=0; combo=0; comboMax=0;
      sel=null; invMode=null; particles=[]; floaters=[]; idleT=0; hintCells=null; shakeT=0; swapAnim=null;
      running=true; busy=false;
      try{ if(window.BgFx&&BgFx.pause) BgFx.pause(); }catch(e){}
      buildDOM(container); initGrid(); bindInput(); hud();
      last=performance.now(); loop(last);
    },
    stop(){
      running=false; if(raf)cancelAnimationFrame(raf);
      try{ window.removeEventListener('resize',_resize); }catch(e){}
      if(_root&&_root.parentNode) _root.parentNode.innerHTML='';
    }
  };

  /* ── DOM ── */
  let _root,_bar,_hud,_resize;
  function buildDOM(container){
    container.innerHTML='';
    _root=document.createElement('div');
    _root.style.cssText='position:absolute;inset:0;display:flex;flex-direction:column;';
    const wrap=document.createElement('div');
    wrap.style.cssText='position:relative;flex:1 1 auto;min-height:0;';
    DPR=Math.min(window.devicePixelRatio||1,2);
    cvs=document.createElement('canvas');
    cvs.style.cssText='display:block;width:100%;height:100%;touch-action:none;position:relative;z-index:1;';
    wrap.appendChild(cvs); ctx=cvs.getContext('2d');
    _bar=document.createElement('div');
    _bar.style.cssText='display:flex;gap:8px;justify-content:center;padding:6px 6px max(6px,env(safe-area-inset-bottom));flex:0 0 auto;';
    _hud=document.createElement('div');
    _hud.style.cssText='position:absolute;top:0;left:0;right:0;z-index:5;padding:6px 14px;pointer-events:none;font-family:Unbounded,sans-serif;';
    wrap.appendChild(_hud);
    _root.appendChild(wrap); _root.appendChild(_bar);
    container.appendChild(_root);
    _resize=()=>resize(wrap); window.addEventListener('resize',_resize);
    resize(wrap); renderBar();
  }
  function resize(wrap){
    const r=wrap.getBoundingClientRect();
    W=Math.max(220,r.width); H=Math.max(220,r.height);
    cvs.width=W*DPR; cvs.height=H*DPR; cvs.style.width=W+'px'; cvs.style.height=H+'px';
    ctx.setTransform(DPR,0,0,DPR,0,0);
    // поле занимает почти всю ширину; верх отдаём под HUD (48px)
    const top=48;
    const avail=Math.min(W, H-top);
    cell=Math.floor((avail-6)/N); boardPx=cell*N;
    ox=Math.floor((W-boardPx)/2);
    oy=top+Math.floor((H-top-boardPx)/2);
  }

  /* ── сетка ── */
  function initGrid(){
    grid=new Array(N*N); vis=new Array(N*N);
    for(let i=0;i<N*N;i++){ grid[i]={c:rnd(),sp:SP.NONE}; vis[i]={dy:0,scale:1,glow:0,pop:0}; }
    let guard=0;
    while(findMatches().length && guard++<200){ findMatches().forEach(g=>g.forEach(k=>grid[k].c=rnd())); }
  }
  function rnd(){ return Math.floor(Math.random()*NC); }
  const idx=(x,y)=>y*N+x;
  const inb=(x,y)=>x>=0&&x<N&&y>=0&&y<N;
  const cxy=k=>[ox+(k%N)*cell+cell/2, oy+((k/N|0))*cell+cell/2];

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
    for(let y=0;y<N;y++)for(let x=0;x<N;x++){
      for(const[dx,dy] of [[1,0],[0,1]]){
        if(!inb(x+dx,y+dy))continue;
        swapData(idx(x,y),idx(x+dx,y+dy));
        const m=findMatches().length>0;
        swapData(idx(x,y),idx(x+dx,y+dy));
        if(m) return [idx(x,y),idx(x+dx,y+dy)];
      }
    } return null;
  }
  /* меняем ТОЛЬКО данные (c,sp), визуал остаётся привязан к индексу */
  function swapData(a,b){ const t=grid[a]; grid[a]=grid[b]; grid[b]=t; }

  /* ── ход игрока ── */
  function trySwap(a,b){
    if(busy||!running) return;
    const ax=a%N,ay=a/N|0,bx=b%N,by=b/N|0;
    if(Math.abs(ax-bx)+Math.abs(ay-by)!==1) return;
    sel=null; idleT=0; hintCells=null;

    if(grid[a].sp===SP.RAINBOW||grid[b].sp===SP.RAINBOW){
      const rk=grid[a].sp===SP.RAINBOW?a:b, ok=rk===a?b:a;
      busy=true; Sound.gemSwap&&Sound.gemSwap();
      startSwap(a,b,false,()=>{ swapData(a,b); const col=grid[rk].c; detonateRainbow(rk,col); spendMove(); });
      return;
    }
    busy=true; Sound.gemSwap&&Sound.gemSwap();
    startSwap(a,b,false,()=>{
      swapData(a,b);
      const ms=findMatches();
      if(ms.length===0){
        Sound.error&&Sound.error();
        startSwap(a,b,true,()=>{ swapData(a,b); busy=false; });
      }else{ spendMove(); resolveBoard(ms); }
    });
  }
  function spendMove(){ moves--; combo=0; idleT=0; hintCells=null; hud(); }

  /* анимация свапа через таймстемпы (рендерит главный цикл) */
  function startSwap(a,b,back,done){ swapAnim={a,b,t0:performance.now(),dur:back?120:150,back,done}; }

  /* ── каскады ── */
  function resolveBoard(first){
    let cascade=0;
    function step(matches){
      if(!matches) matches=findMatches();
      if(matches.length===0){ busy=false; checkEnd(); return; }
      cascade++; combo++; comboMax=Math.max(comboMax,combo);
      if(combo>=2) showCombo(combo);
      if(mission.type==='combo') progress=comboMax;

      const toClear=new Set(); const specials=[];
      matches.forEach(g=>{ const len=g.length,c=grid[g[0]].c;
        g.forEach(k=>toClear.add(k));
        if(len===4) specials.push({k:g[len>>1],sp:(isHoriz(g)?SP.LINEH:SP.LINEV),c});
        else if(len>=5) specials.push({k:g[len>>1],sp:SP.RAINBOW,c});
      });
      detectL(matches,specials);
      const expand=new Set(toClear);
      toClear.forEach(k=>{ if(grid[k].sp) triggerSpecial(k,expand); });

      let gained=0;
      expand.forEach(k=>{ if(grid[k].c<0)return; gained+=10+cascade*2; burst(k,grid[k].c);
        if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
        if(mission.type==='clear')progress++; });
      score+=gained+(combo>1?combo*5:0);
      if(mission.type==='score')progress=score;
      Sound.gemMatch&&Sound.gemMatch(matches.length);
      if(cascade>1){Sound.gemCascade&&Sound.gemCascade(cascade);vibrate(8);} else vibrate(12);

      expand.forEach(k=>{ if(!specials.some(s=>s.k===k)){ grid[k]={c:-1,sp:SP.NONE}; vis[k].pop=1; } });
      specials.forEach(s=>{ grid[s.k]={c:s.c,sp:s.sp}; vis[s.k].pop=1; vis[s.k].glow=1; spawnRing(s.k,s.c); });
      hud();
      setTimeout(()=>{ collapse(); setTimeout(()=>step(null),240); },200);
    }
    step(first);
  }
  function isHoriz(g){ return (g[1]-g[0])===1; }
  function detectL(matches,specials){
    const inH={},inV={};
    matches.forEach(g=>{ const h=isHoriz(g); g.forEach(k=>{(h?inH:inV)[k]=true;}); });
    Object.keys(inH).forEach(k=>{ if(inV[k]){ const kk=+k;
      if(!specials.some(s=>s.k===kk)) specials.push({k:kk,sp:SP.BOMB,c:grid[kk].c}); } });
  }
  function triggerSpecial(k,set){
    const x=k%N,y=k/N|0,sp=grid[k].sp; Sound.booster&&Sound.booster(); spawnRing(k,grid[k].c); shakeT=8;
    if(sp===SP.LINEH){ for(let xx=0;xx<N;xx++)set.add(idx(xx,y)); }
    else if(sp===SP.LINEV){ for(let yy=0;yy<N;yy++)set.add(idx(x,yy)); }
    else if(sp===SP.BOMB){ for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++)if(inb(x+dx,y+dy))set.add(idx(x+dx,y+dy)); }
    else if(sp===SP.RAINBOW){ const c=grid[k].c; for(let i=0;i<N*N;i++)if(grid[i].c===c)set.add(i); }
  }
  function detonateRainbow(rk,color){
    const set=new Set(); for(let i=0;i<N*N;i++)if(grid[i].c===color)set.add(i); set.add(rk);
    shakeT=10; Sound.special&&Sound.special(); let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=14; burst(k,grid[k].c);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
      if(mission.type==='clear')progress++; grid[k]={c:-1,sp:SP.NONE}; vis[k].pop=1; });
    score+=gained; if(mission.type==='score')progress=score; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),240); },220);
  }

  /* гравитация: переносим данные вниз, визуальный dy для анимации падения */
  function collapse(){
    for(let x=0;x<N;x++){
      let write=N-1;
      for(let y=N-1;y>=0;y--){ const k=idx(x,y);
        if(grid[k].c>=0){ const w=idx(x,write);
          if(w!==k){ grid[w]={c:grid[k].c,sp:grid[k].sp}; vis[w].dy=(write-y)*cell; vis[w].scale=1; vis[w].glow=vis[k].glow;
            grid[k]={c:-1,sp:SP.NONE}; }
          write--; } }
      for(let y=write;y>=0;y--){ const k=idx(x,y);
        grid[k]={c:rnd(),sp:SP.NONE}; vis[k].dy=-(write-y+2)*cell; vis[k].scale=1; vis[k].glow=0; }
    }
    Sound.gemFall&&Sound.gemFall();
  }

  /* ── бустеры инвентаря ── */
  function applyInventory(k){
    const p=(window.App&&App.profile)||{};
    if(invMode==='ashtray'){ if(p.boosters>0)p.boosters--; saveP(); clearSet(new Set([k])); }
    else if(invMode==='siren'){ if(p.bSiren>0)p.bSiren--; saveP();
      const x=k%N,y=k/N|0,set=new Set(); for(let i=0;i<N;i++){set.add(idx(i,y));set.add(idx(x,i));} shakeT=8; clearSet(set); }
    else if(invMode==='shuffle'){ if(p.bShuffle>0)p.bShuffle--; saveP(); shuffleBoard(); }
    invMode=null; renderBar();
  }
  function clearSet(set){
    Sound.booster&&Sound.booster(); vibrate([10,30]); busy=true; let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=12; burst(k,grid[k].c);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
      if(mission.type==='clear')progress++; grid[k]={c:-1,sp:SP.NONE}; vis[k].pop=1; });
    score+=gained; if(mission.type==='score')progress=score; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),240); },220);
  }
  function shuffleBoard(){
    const cs=grid.map(g=>g.c).filter(c=>c>=0);
    for(let i=cs.length-1;i>0;i--){ const j=Math.random()*(i+1)|0; [cs[i],cs[j]]=[cs[j],cs[i]]; }
    let p=0; for(let i=0;i<N*N;i++){ grid[i]={c:cs[p++],sp:SP.NONE}; vis[i].scale=0; }
    let guard=0; while(findMatches().length&&guard++<100){ findMatches().forEach(g=>g.forEach(k=>grid[k].c=rnd())); }
    Sound.transition&&Sound.transition(); busy=true;
    setTimeout(()=>{ busy=false; checkEnd(); },300);
  }
  function saveP(){ try{ window.saveProfile&&saveProfile(); }catch(e){} }

  /* ── конец ── */
  function checkEnd(){
    const target=mission.target||600;
    if(progress>=target){ win(); return; }
    if(moves<=0) lose();
  }
  function win(){ running=false; Sound.win&&Sound.win(); vibrate([10,40,10,40]); overlay(true); setTimeout(()=>opts.onWin&&opts.onWin(),1000); }
  function lose(){ running=false; Sound.deny&&Sound.deny(); overlay(false); setTimeout(()=>opts.onLose&&opts.onLose(),1500); }
  function overlay(won){
    const o=document.createElement('div');
    o.style.cssText='position:absolute;inset:0;z-index:10;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;'+
      'background:radial-gradient(60% 50% at 50% 45%,rgba(10,14,22,.72),rgba(4,7,12,.95));animation:m3fade .4s ease;';
    o.innerHTML='<div style="font-family:Unbounded,sans-serif;font-weight:900;font-size:26px;color:'+(won?'#46d89b':'#ff6470')+
      ';text-shadow:0 0 24px '+(won?'#46d89b':'#ff6470')+'">'+(won?'УЛИКА ПОЛУЧЕНА':'УЛИКА УТЕРЯНА')+'</div>'+
      '<div style="font-size:13px;color:#9aa3b2">'+(won?'Свайп разблокирован':'Сдвиг недоволен')+'</div>';
    _root.appendChild(o);
  }

  /* ── частицы / текст ── */
  function burst(k,c){ const[cx,cy]=cxy(k),g=GEMS[c]||GEMS[0];
    for(let i=0;i<7;i++){ const a=Math.random()*Math.PI*2,sp=1+Math.random()*3.5;
      particles.push({x:cx,y:cy,vx:Math.cos(a)*sp,vy:Math.sin(a)*sp-1,life:1,col:g.a,sz:2+Math.random()*3}); } }
  function spawnRing(k,c){ const[cx,cy]=cxy(k); particles.push({ring:1,x:cx,y:cy,r:cell*0.2,life:1,col:(GEMS[c]||GEMS[0]).glow}); }
  function showCombo(n){ const w=['','','Хорошо!','Отлично!','Превосходно!','Блестяще!','Гениально!'];
    floaters.push({txt:w[Math.min(n,6)]||'Комбо!',x:W/2,y:H*0.42,life:1,vy:-0.5}); Sound.approve&&Sound.approve(); }

  /* ── рендер фишки с глянцем-переливом ── */
  let shinePhase=0;
  function drawGem(cx,cy,r,g,sp,glow){
    ctx.save();
    if(glow>0){ ctx.shadowColor=g.glow; ctx.shadowBlur=16*glow; }
    const grad=ctx.createLinearGradient(cx-r,cy-r,cx+r,cy+r);
    grad.addColorStop(0,g.a); grad.addColorStop(1,g.b);
    ctx.fillStyle=grad; roundGem(cx,cy,r); ctx.fill(); ctx.restore();

    // внутренняя тень снизу
    ctx.save(); roundGem(cx,cy,r); ctx.clip();
    const ish=ctx.createLinearGradient(cx,cy,cx,cy+r);
    ish.addColorStop(0,'rgba(0,0,0,0)'); ish.addColorStop(1,'rgba(0,0,0,.32)');
    ctx.fillStyle=ish; ctx.fillRect(cx-r,cy-r,r*2,r*2);

    // ── ПЕРЕЛИВ: движущийся диагональный блик ──
    const sweep=((shinePhase + (cx+cy)*0.002)%1);
    const sx=cx-r + sweep*r*2.4;
    const sg=ctx.createLinearGradient(sx-r*0.5,cy-r,sx+r*0.5,cy+r);
    sg.addColorStop(0,'rgba(255,255,255,0)');
    sg.addColorStop(.5,'rgba(255,255,255,.5)');
    sg.addColorStop(1,'rgba(255,255,255,0)');
    ctx.fillStyle=sg; ctx.fillRect(cx-r,cy-r,r*2,r*2);
    ctx.restore();

    // верхний глянцевый блик
    ctx.save();
    const hl=ctx.createRadialGradient(cx-r*0.3,cy-r*0.4,1,cx-r*0.3,cy-r*0.4,r*0.95);
    hl.addColorStop(0,'rgba(255,255,255,.9)'); hl.addColorStop(.4,'rgba(255,255,255,.22)'); hl.addColorStop(1,'rgba(255,255,255,0)');
    ctx.fillStyle=hl; ctx.beginPath(); ctx.ellipse(cx-r*0.26,cy-r*0.32,r*0.52,r*0.36,-0.5,0,7); ctx.fill();
    ctx.restore();

    // эмблема улики
    ctx.save(); ctx.strokeStyle=g.hi; ctx.fillStyle=g.hi; ctx.lineWidth=Math.max(1.4,r*0.1);
    ctx.lineCap='round'; ctx.lineJoin='round'; ctx.globalAlpha=.92; emblem(g.id,cx,cy,r*0.46); ctx.restore();

    if(sp){ ctx.save(); ctx.lineWidth=2.4; ctx.strokeStyle='#fff'; ctx.shadowColor=g.glow; ctx.shadowBlur=10;
      roundGem(cx,cy,r*0.98); ctx.stroke();
      ctx.globalAlpha=.92; ctx.fillStyle='#fff'; ctx.font='bold '+(r*0.66)+'px sans-serif';
      ctx.textAlign='center'; ctx.textBaseline='middle';
      ctx.fillText(sp===SP.LINEH?'↔':sp===SP.LINEV?'↕':sp===SP.BOMB?'✸':'★',cx,cy+r*0.02); ctx.restore(); }
  }
  function roundGem(cx,cy,r){ const k=r*0.46; ctx.beginPath();
    ctx.moveTo(cx-r+k,cy-r); ctx.lineTo(cx+r-k,cy-r); ctx.quadraticCurveTo(cx+r,cy-r,cx+r,cy-r+k);
    ctx.lineTo(cx+r,cy+r-k); ctx.quadraticCurveTo(cx+r,cy+r,cx+r-k,cy+r);
    ctx.lineTo(cx-r+k,cy+r); ctx.quadraticCurveTo(cx-r,cy+r,cx-r,cy+r-k);
    ctx.lineTo(cx-r,cy-r+k); ctx.quadraticCurveTo(cx-r,cy-r,cx-r+k,cy-r); ctx.closePath(); }
  function emblem(id,cx,cy,s){
    ctx.beginPath();
    if(id==='trace'){ ctx.moveTo(cx,cy-s); ctx.quadraticCurveTo(cx+s*0.85,cy+s*0.2,cx,cy+s); ctx.quadraticCurveTo(cx-s*0.85,cy+s*0.2,cx,cy-s); ctx.fill(); }
    else if(id==='witness'){ ctx.ellipse(cx,cy,s,s*0.6,0,0,7); ctx.stroke(); ctx.beginPath(); ctx.arc(cx,cy,s*0.3,0,7); ctx.fill(); }
    else if(id==='exhibit'){ ctx.arc(cx-s*0.3,cy,s*0.42,0,7); ctx.stroke(); ctx.beginPath();
      ctx.moveTo(cx+s*0.05,cy); ctx.lineTo(cx+s*0.85,cy); ctx.moveTo(cx+s*0.6,cy); ctx.lineTo(cx+s*0.6,cy+s*0.32); ctx.stroke(); }
    else if(id==='alibi'){ ctx.arc(cx,cy,s*0.82,0,7); ctx.stroke(); ctx.beginPath();
      ctx.moveTo(cx,cy); ctx.lineTo(cx,cy-s*0.5); ctx.moveTo(cx,cy); ctx.lineTo(cx+s*0.42,cy+s*0.2); ctx.stroke(); }
    else { ctx.arc(cx,cy,s*0.86,Math.PI*0.15,Math.PI*0.85); ctx.stroke(); ctx.beginPath();
      ctx.arc(cx-s*0.62,cy+s*0.32,s*0.22,0,7); ctx.arc(cx+s*0.62,cy+s*0.32,s*0.22,0,7); ctx.fill(); }
  }

  function draw(now){
    ctx.clearRect(0,0,W,H);
    const bg=ctx.createLinearGradient(0,0,0,H); bg.addColorStop(0,'#1a1611'); bg.addColorStop(1,'#0d0b08');
    ctx.fillStyle=bg; ctx.fillRect(0,0,W,H);

    let shx=0,shy=0;
    if(shakeT>0){ shx=(Math.random()-.5)*shakeT; shy=(Math.random()-.5)*shakeT; shakeT*=0.85; if(shakeT<0.5)shakeT=0; }
    ctx.save(); ctx.translate(shx,shy);

    ctx.fillStyle='rgba(20,16,12,.55)'; rrect(ox-4,oy-4,boardPx+8,boardPx+8,10); ctx.fill();
    for(let y=0;y<N;y++)for(let x=0;x<N;x++){ ctx.fillStyle=(x+y)%2?'rgba(255,255,255,.02)':'rgba(0,0,0,.1)';
      ctx.fillRect(ox+x*cell,oy+y*cell,cell,cell); }

    if(hintCells){ hintCells.forEach(k=>{ const[cx,cy]=cxy(k);
      ctx.save(); ctx.globalAlpha=.35+0.25*Math.sin(now/220); ctx.strokeStyle='#ffcf6b'; ctx.lineWidth=3;
      rrect(cx-cell/2+3,cy-cell/2+3,cell-6,cell-6,8); ctx.stroke(); ctx.restore(); }); }

    const r=cell*0.40;
    // вычисляем смещения свапа НА ЛЕТУ (по индексу, не на объекте)
    let swA=null,swB=null,swE=0;
    if(swapAnim){ const p=Math.min(1,(now-swapAnim.t0)/swapAnim.dur);
      swE=swapAnim.back?p:backOut(p); swA=swapAnim.a; swB=swapAnim.b;
      if(p>=1){ const d=swapAnim.done; swapAnim=null; if(d)d(); }
    }

    for(let y=0;y<N;y++)for(let x=0;x<N;x++){
      const k=idx(x,y),gd=grid[k]; if(gd.c<0) continue;
      const v=vis[k];
      if(v.dy<0) v.dy=Math.min(0,v.dy+Math.max(8,cell*0.2));
      else if(v.dy>0) v.dy=Math.max(0,v.dy-Math.max(8,cell*0.2));
      if(v.pop>0) v.pop=Math.max(0,v.pop-0.08);
      if(v.glow>0) v.glow=Math.max(0,v.glow-0.02);
      if(v.scale<1) v.scale=Math.min(1,v.scale+0.08);

      let cx=ox+x*cell+cell/2, cy=oy+y*cell+cell/2+v.dy;
      // смещение свапа
      if(swA===k||swB===k){ const a=swapAnim||{a:swA,b:swB}; const other=(k===swA?swB:swA);
        const[okx,oky]=cxy(other); const[mx,my]=cxy(k);
        cx+=(okx-mx)*swE; cy+=(oky-my)*swE; }
      let rr=r*(v.scale||1);
      if(sel===k) rr*=1.1+0.05*Math.sin(now/120);
      drawGem(cx,cy,rr,GEMS[gd.c]||GEMS[0],gd.sp,v.glow+v.pop);
    }

    for(let i=particles.length-1;i>=0;i--){ const p=particles[i];
      if(p.ring){ p.r+=cell*0.06; p.life-=0.05; ctx.save(); ctx.globalAlpha=Math.max(0,p.life);
        ctx.strokeStyle=p.col; ctx.lineWidth=3; ctx.beginPath(); ctx.arc(p.x,p.y,p.r,0,7); ctx.stroke(); ctx.restore();
        if(p.life<=0)particles.splice(i,1); continue; }
      p.x+=p.vx; p.y+=p.vy; p.vy+=0.18; p.life-=0.03;
      ctx.save(); ctx.globalAlpha=Math.max(0,p.life); ctx.fillStyle=p.col;
      ctx.beginPath(); ctx.arc(p.x,p.y,p.sz*p.life,0,7); ctx.fill(); ctx.restore();
      if(p.life<=0)particles.splice(i,1); }

    for(let i=floaters.length-1;i>=0;i--){ const f=floaters[i]; f.y+=f.vy; f.life-=0.018;
      ctx.save(); ctx.globalAlpha=Math.max(0,f.life); ctx.font='900 '+Math.round(W*0.07)+'px Unbounded,sans-serif';
      ctx.textAlign='center'; ctx.fillStyle='#ffcf6b'; ctx.shadowColor='#c8860a'; ctx.shadowBlur=20;
      ctx.fillText(f.txt,f.x,f.y); ctx.restore(); if(f.life<=0)floaters.splice(i,1); }

    ctx.restore();
  }
  function rrect(x,y,w,h,r){ ctx.beginPath(); ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r);
    ctx.arcTo(x+w,y+h,x,y+h,r); ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }
  function backOut(p){ const c1=1.70158,c3=c1+1; return 1+c3*Math.pow(p-1,3)+c1*Math.pow(p-1,2); }

  /* ── HUD ── */
  function hud(){
    if(!_hud) return;
    const target=mission.target||600, pct=Math.min(100,Math.round(progress/target*100));
    _hud.innerHTML=
      '<div style="display:flex;align-items:flex-end;gap:12px">'+
        '<div style="flex:1">'+
          '<div style="font-size:9px;letter-spacing:.08em;color:#c8a05a;margin-bottom:4px">'+(mission.label||'ЦЕЛЬ')+'</div>'+
          '<div style="height:7px;border-radius:6px;background:rgba(255,255,255,.08);overflow:hidden">'+
            '<div style="height:100%;width:'+pct+'%;border-radius:6px;background:linear-gradient(90deg,#b3741c,#ffcf6b);box-shadow:0 0 8px #c8860a;transition:width .3s"></div>'+
          '</div></div>'+
        '<div style="text-align:center;min-width:50px">'+
          '<div style="font-size:9px;color:#c8a05a;letter-spacing:.06em">ХОДЫ</div>'+
          '<div style="font-size:21px;font-weight:900;line-height:1;color:'+(moves<=3?'#ff6470':'#fff')+'">'+moves+'</div>'+
        '</div></div>';
  }
  function renderBar(){
    if(!_bar) return;
    const p=(window.App&&App.profile)||{};
    const items=[{k:'ashtray',n:p.boosters||0,ico:'🪨',t:'Пепельница'},
                 {k:'siren',n:p.bSiren||0,ico:'🚨',t:'Мигалка'},
                 {k:'shuffle',n:p.bShuffle||0,ico:'📼',t:'Плёнка'}];
    _bar.innerHTML=items.map(it=>'<button data-k="'+it.k+'" title="'+it.t+'" style="pointer-events:auto;cursor:pointer;'+
      'border:1px solid '+(invMode===it.k?'#ffcf6b':'rgba(240,169,58,.4)')+';border-radius:11px;'+
      'background:'+(invMode===it.k?'rgba(255,207,107,.2)':'rgba(255,255,255,.05)')+';color:#ffcf6b;'+
      'padding:8px 14px;font-weight:800;font-size:14px;min-width:56px;'+(it.n<=0?'opacity:.4;':'')+'">'+it.ico+' '+it.n+'</button>').join('');
    _bar.querySelectorAll('button').forEach(b=>b.onclick=()=>{ const k=b.dataset.k,n=items.find(i=>i.k===k).n;
      if(n<=0){ Sound.error&&Sound.error(); if(window.toast)toast('Нет бустера','Купи в Лавке','✗'); return; }
      invMode=invMode===k?null:k; Sound.tap&&Sound.tap(); renderBar(); });
  }

  /* ── ввод ── */
  function bindInput(){
    let downK=null,sx=0,sy=0;
    function pick(e){ const r=cvs.getBoundingClientRect();
      const px=(e.touches?e.touches[0].clientX:e.clientX)-r.left, py=(e.touches?e.touches[0].clientY:e.clientY)-r.top;
      const x=Math.floor((px-ox)/cell), y=Math.floor((py-oy)/cell); return inb(x,y)?idx(x,y):null; }
    cvs.onpointerdown=(e)=>{ if(busy||!running)return; const k=pick(e); if(k==null)return; idleT=0; hintCells=null;
      if(invMode){ applyInventory(k); return; } downK=k; sx=e.clientX; sy=e.clientY; sel=k; Sound.gemSelect&&Sound.gemSelect(); };
    cvs.onpointermove=(e)=>{ if(downK==null||busy)return; const dx=e.clientX-sx,dy=e.clientY-sy;
      if(Math.abs(dx)>cell*0.4||Math.abs(dy)>cell*0.4){ const x=downK%N,y=downK/N|0; let tx=x,ty=y;
        if(Math.abs(dx)>Math.abs(dy))tx+=dx>0?1:-1; else ty+=dy>0?1:-1;
        if(inb(tx,ty))trySwap(downK,idx(tx,ty)); downK=null; sel=null; } };
    cvs.onpointerup=(e)=>{ if(downK!=null){ const k=pick(e);
      if(k!=null&&k!==downK){ const ax=downK%N,ay=downK/N|0,bx=k%N,by=k/N|0;
        if(Math.abs(ax-bx)+Math.abs(ay-by)===1)trySwap(downK,k); else sel=null; }
      else if(k===downK) sel=downK; } downK=null; };
  }

  /* ── единственный цикл рендера ── */
  function loop(t){
    raf=requestAnimationFrame(loop);
    const dt=t-last; last=t; shinePhase=(shinePhase+dt/3400)%1; // скорость перелива
    if(running && !busy && !swapAnim){ idleT+=dt; if(idleT>HINT_DELAY && !hintCells) hintCells=findHint(); }
    draw(t);
  }
})();

