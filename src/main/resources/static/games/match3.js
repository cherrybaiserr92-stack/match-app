/* ═══════════════════════════════════════════════════════════
   СДВИГ · match3.js v7 — «Самоцветы улик» (AAA-уровень)
   Canvas 2D · 8×8 · спецэлементы · каскады · частицы · комбо
   Нуар-фишки улик с глянцем. Контракт сохранён:
   Match3.start(container,{mission,boosters,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  /* ── 5 типов улик (нуар-палитра + светлый блик) ──
     0 след(красный) 1 показания(синий) 2 вещдок(зелёный)
     3 алиби(золотой) 4 связь(фиолетовый) ── */
  const GEMS=[
    {id:'trace',  a:'#ff6470', b:'#a51f2c', hi:'#ffd9dd', glow:'#ff5d6c'},
    {id:'witness',a:'#5cd0ff', b:'#155e8a', hi:'#d6f4ff', glow:'#5cd0ff'},
    {id:'exhibit',a:'#46d89b', b:'#10704c', hi:'#d6fff0', glow:'#46d89b'},
    {id:'alibi',  a:'#f3c963', b:'#9a6a18', hi:'#fff3cf', glow:'#ffcf6b'},
    {id:'link',   a:'#b69cff', b:'#5a3fb0', hi:'#ece4ff', glow:'#a98bff'}
  ];
  const NC=GEMS.length;
  const N=8;                         // поле 8×8

  // спецтипы фишки: 0 обычная, 1 лупа-гор, 2 лупа-верт, 3 бомба, 4 радуга
  const SP={NONE:0,LINEH:1,LINEV:2,BOMB:3,RAINBOW:4};

  let cvs,ctx,W,H,DPR,cell,ox,oy,boardPx;
  let grid=[];                       // [{c,sp,scale,dy,glow,pop}]
  let sel=null, hover=null;
  let anim=false, raf=null, running=false;
  let opts=null, mission=null, moves=0, score=0, progress=0, combo=0, comboMax=0;
  let invMode=null;                  // активный бустер из инвентаря
  let particles=[], floaters=[];     // частицы и всплывающий текст
  let idleT=0, hintCells=null, last=0, shakeT=0;

  /* ── публичный API ─────────────────────────── */
  window.Match3={
    start(container,o){
      opts=o||{};
      mission=opts.mission||{type:'score',target:600,moves:14};
      moves=mission.moves||14; score=0; progress=0; combo=0; comboMax=0;
      sel=null; invMode=null; particles=[]; floaters=[]; idleT=0; hintCells=null; shakeT=0;
      running=true; anim=false;
      try{ if(window.BgFx&&BgFx.pause) BgFx.pause(); }catch(e){}
      buildDOM(container);
      initGrid();
      bindInput();
      hud();
      last=performance.now();
      loop(last);
    },
    stop(){
      running=false; if(raf)cancelAnimationFrame(raf);
      try{ window.removeEventListener('resize',_resize); }catch(e){}
      if(_root&&_root.parentNode) _root.parentNode.innerHTML='';
    }
  };

  /* ── DOM: canvas + HUD-бар бустеров ────────── */
  let _root,_bar,_resize;
  function buildDOM(container){
    container.innerHTML='';
    _root=document.createElement('div');
    _root.style.cssText='position:relative;width:100%;height:100%;display:flex;flex-direction:column;';

    const wrap=document.createElement('div');
    wrap.style.cssText='position:relative;flex:1;min-height:0;';
    DPR=Math.min(window.devicePixelRatio||1,2);
    cvs=document.createElement('canvas');
    cvs.style.cssText='display:block;width:100%;height:100%;touch-action:none;position:relative;z-index:1;';
    wrap.appendChild(cvs);
    ctx=cvs.getContext('2d');

    _bar=document.createElement('div');
    _bar.style.cssText='display:flex;gap:8px;justify-content:center;padding:8px 6px 4px;flex:0 0 auto;';

    _root.appendChild(wrap); _root.appendChild(_bar);
    container.appendChild(_root);

    _resize=()=>resize(wrap);
    window.addEventListener('resize',_resize);
    resize(wrap);
    renderBar();
  }

  function resize(wrap){
    const r=wrap.getBoundingClientRect();
    W=Math.max(200,r.width); H=Math.max(200,r.height);
    cvs.width=W*DPR; cvs.height=H*DPR;
    cvs.style.width=W+'px'; cvs.style.height=H+'px';
    ctx.setTransform(DPR,0,0,DPR,0,0);
    boardPx=Math.min(W,H)-8;
    cell=Math.floor(boardPx/N);
    boardPx=cell*N;
    ox=Math.floor((W-boardPx)/2);
    oy=Math.floor((H-boardPx)/2);
  }

  /* ── сетка без стартовых матчей ────────────── */
  function initGrid(){
    grid=new Array(N*N);
    for(let i=0;i<N*N;i++) grid[i]={c:rnd(),sp:SP.NONE,scale:1,dy:0,glow:0,pop:0};
    // убрать готовые тройки на старте
    let guard=0;
    while(findMatches().length && guard++<200){
      findMatches().forEach(g=>g.forEach(k=>grid[k].c=rnd()));
    }
  }
  function rnd(){ return Math.floor(Math.random()*NC); }
  const idx=(x,y)=>y*N+x;
  const inb=(x,y)=>x>=0&&x<N&&y>=0&&y<N;

  /* ════════════════════════════════════════════
     ПОИСК СОВПАДЕНИЙ
  ════════════════════════════════════════════ */
  function findMatches(){
    const groups=[]; const seen=new Uint8Array(N*N);
    // горизонтали
    for(let y=0;y<N;y++){
      let run=1;
      for(let x=1;x<=N;x++){
        const same = x<N && grid[idx(x,y)].c===grid[idx(x-1,y)].c && grid[idx(x,y)].c>=0;
        if(same){ run++; }
        else{
          if(run>=3){ const g=[]; for(let k=x-run;k<x;k++) g.push(idx(k,y)); groups.push(g); }
          run=1;
        }
      }
    }
    // вертикали
    for(let x=0;x<N;x++){
      let run=1;
      for(let y=1;y<=N;y++){
        const same = y<N && grid[idx(x,y)].c===grid[idx(x,y-1)].c && grid[idx(x,y)].c>=0;
        if(same){ run++; }
        else{
          if(run>=3){ const g=[]; for(let k=y-run;k<y;k++) g.push(idx(x,k)); groups.push(g); }
          run=1;
        }
      }
    }
    return groups;
  }

  /* любая возможная пара для подсказки */
  function findHint(){
    for(let y=0;y<N;y++)for(let x=0;x<N;x++){
      for(const[dx,dy] of [[1,0],[0,1]]){
        if(!inb(x+dx,y+dy)) continue;
        swap(idx(x,y),idx(x+dx,y+dy),true);
        const m=findMatches().length>0;
        swap(idx(x,y),idx(x+dx,y+dy),true);
        if(m) return [idx(x,y),idx(x+dx,y+dy)];
      }
    }
    return null;
  }

  function swap(a,b,silent){
    const t=grid[a]; grid[a]=grid[b]; grid[b]=t;
    if(!silent){ /* визуальный своп делается в анимации */ }
  }

  /* ════════════════════════════════════════════
     ХОД ИГРОКА
  ════════════════════════════════════════════ */
  function trySwap(a,b){
    if(anim||!running) return;
    const ax=a%N,ay=a/N|0,bx=b%N,by=b/N|0;
    if(Math.abs(ax-bx)+Math.abs(ay-by)!==1) return; // только соседи

    // радужная улика: своп с обычной → убрать весь цвет
    if(grid[a].sp===SP.RAINBOW||grid[b].sp===SP.RAINBOW){
      const rk=grid[a].sp===SP.RAINBOW?a:b, ok=rk===a?b:a;
      anim=true; Sound.gemSwap&&Sound.gemSwap();
      animateSwap(a,b,()=>{ detonateRainbow(rk,grid[ok].c); spendMove(); afterPlayer(); });
      return;
    }

    Sound.gemSwap&&Sound.gemSwap();
    anim=true;
    animateSwap(a,b,()=>{
      swap(a,b,true);
      const ms=findMatches();
      // спец-комбо при свопе двух спец-фишек
      const specialCombo = grid[a].sp&&grid[b].sp;
      if(ms.length===0 && !specialCombo){
        // откат — невалидный ход
        Sound.error&&Sound.error();
        animateSwap(a,b,()=>{ swap(a,b,true); anim=false; }, true);
      }else{
        spendMove();
        resolveBoard(ms);
      }
    });
  }

  function spendMove(){
    moves--; combo=0;
    idleT=0; hintCells=null;
    hud();
  }

  /* ════════════════════════════════════════════
     РАЗРЕШЕНИЕ ПОЛЯ (каскады)
  ════════════════════════════════════════════ */
  function resolveBoard(firstMatches){
    let cascade=0;
    function step(matches){
      if(!matches) matches=findMatches();
      if(matches.length===0){ // конец каскада
        anim=false;
        checkEnd();
        return;
      }
      cascade++; combo++; comboMax=Math.max(comboMax,combo);
      if(combo>=2) showCombo(combo);
      if(mission.type==='combo') progress=comboMax;

      // создаём спецэлементы из длинных/угловых матчей
      const toClear=new Set();
      const specials=[]; // {k,sp,c}
      matches.forEach(g=>{
        const len=g.length;
        const c=grid[g[0]].c;
        g.forEach(k=>toClear.add(k));
        if(len===4){ specials.push({k:g[Math.floor(len/2)], sp:(isHoriz(g)?SP.LINEH:SP.LINEV), c}); }
        else if(len>=5){ specials.push({k:g[Math.floor(len/2)], sp:SP.RAINBOW, c}); }
      });
      detectLShapes(matches,specials,toClear);

      // активируем уже существующие спецэлементы среди очищаемых
      const expand=new Set(toClear);
      toClear.forEach(k=>{ if(grid[k].sp){ triggerSpecial(k,expand); } });

      // счёт + частицы + прогресс
      let gained=0;
      expand.forEach(k=>{
        if(grid[k].c<0) return;
        gained+=10+cascade*2;
        burst(k,grid[k].c);
        if(mission.type==='color' && grid[k].c===(mission.color||0)) progress++;
        if(mission.type==='clear') progress++;
      });
      score+=gained + (combo>1?combo*5:0);
      if(mission.type==='score') progress=score;

      Sound.gemMatch&&Sound.gemMatch(matches.length);
      if(cascade>1){ Sound.gemCascade&&Sound.gemCascade(cascade); vibrate(8); }
      else vibrate(12);

      // помечаем очищаемые
      expand.forEach(k=>{ if(!isSpecialKeep(k,specials)){ grid[k].c=-1; grid[k].sp=SP.NONE; grid[k].pop=1; } });
      // ставим новые спецэлементы
      specials.forEach(s=>{ grid[s.k].c=s.c; grid[s.k].sp=s.sp; grid[s.k].pop=1; grid[s.k].glow=1; spawnRing(s.k,s.c); });

      hud();
      // падение + добор, потом следующий каскад
      setTimeout(()=>{ collapse(); setTimeout(()=>step(null), 230); }, 200);
    }
    step(firstMatches);
  }

  function isHoriz(g){ return (g[1]-g[0])===1; }
  function isSpecialKeep(k,specials){ return specials.some(s=>s.k===k); }

  // L/T-образные → бомба
  function detectLShapes(matches,specials,toClear){
    // простая эвристика: если ячейка входит и в гориз., и в верт. группу
    const inH={}, inV={};
    matches.forEach(g=>{ const h=isHoriz(g); g.forEach(k=>{ (h?inH:inV)[k]=true; }); });
    Object.keys(inH).forEach(k=>{ if(inV[k]){ const kk=+k;
      if(!specials.some(s=>s.k===kk)){ specials.push({k:kk,sp:SP.BOMB,c:grid[kk].c}); } } });
  }

  /* активация спецэлемента → расширяет область очистки */
  function triggerSpecial(k,set){
    const x=k%N,y=k/N|0, sp=grid[k].sp;
    Sound.booster&&Sound.booster();
    spawnRing(k,grid[k].c); shakeT=8;
    if(sp===SP.LINEH){ for(let xx=0;xx<N;xx++) set.add(idx(xx,y)); }
    else if(sp===SP.LINEV){ for(let yy=0;yy<N;yy++) set.add(idx(x,yy)); }
    else if(sp===SP.BOMB){ for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++) if(inb(x+dx,y+dy)) set.add(idx(x+dx,y+dy)); }
    else if(sp===SP.RAINBOW){ const c=grid[k].c; for(let i=0;i<N*N;i++) if(grid[i].c===c) set.add(i); }
  }

  function detonateRainbow(rk,color){
    const set=new Set();
    for(let i=0;i<N*N;i++) if(grid[i].c===color) set.add(i);
    set.add(rk); shakeT=10; Sound.special&&Sound.special();
    let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=14; burst(k,grid[k].c);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
      if(mission.type==='clear')progress++;
      grid[k].c=-1; grid[k].sp=SP.NONE; grid[k].pop=1; });
    score+=gained; if(mission.type==='score')progress=score;
    hud(); setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),230); },220);
  }

  /* ── гравитация + добор новых ──────────────── */
  function collapse(){
    for(let x=0;x<N;x++){
      let write=N-1;
      for(let y=N-1;y>=0;y--){
        const k=idx(x,y);
        if(grid[k].c>=0){
          const w=idx(x,write);
          if(w!==k){ grid[w].c=grid[k].c; grid[w].sp=grid[k].sp;
            grid[w].dy=(write-y)*cell; grid[w].scale=1; grid[w].glow=grid[k].glow;
            grid[k].c=-1; grid[k].sp=SP.NONE; }
          write--;
        }
      }
      // добор сверху
      for(let y=write;y>=0;y--){ const k=idx(x,y);
        grid[k].c=rnd(); grid[k].sp=SP.NONE; grid[k].dy=-(write-y+2)*cell; grid[k].scale=1; grid[k].glow=0; }
    }
    Sound.gemFall&&Sound.gemFall();
  }

  /* ════════════════════════════════════════════
     БУСТЕРЫ ИЗ ИНВЕНТАРЯ (профиль)
  ════════════════════════════════════════════ */
  function applyInventory(k){
    const p=(window.App&&App.profile)||{};
    if(invMode==='ashtray'){ // убрать 1 фишку
      if(p.boosters>0)p.boosters--; saveP();
      const set=new Set([k]); clearSet(set,'Пепельница');
    } else if(invMode==='siren'){ // ряд+столбец
      if(p.bSiren>0)p.bSiren--; saveP();
      const x=k%N,y=k/N|0,set=new Set();
      for(let i=0;i<N;i++){ set.add(idx(i,y)); set.add(idx(x,i)); }
      shakeT=8; clearSet(set,'Мигалка');
    } else if(invMode==='shuffle'){ // перемешать всё
      if(p.bShuffle>0)p.bShuffle--; saveP();
      shuffleBoard();
    }
    invMode=null; renderBar();
  }
  function clearSet(set,label){
    Sound.booster&&Sound.booster(); vibrate([10,30]);
    let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=12; burst(k,grid[k].c);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
      if(mission.type==='clear')progress++;
      grid[k].c=-1; grid[k].sp=SP.NONE; grid[k].pop=1; });
    score+=gained; if(mission.type==='score')progress=score;
    anim=true; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),230); },220);
  }
  function shuffleBoard(){
    const cs=grid.map(g=>g.c).filter(c=>c>=0);
    for(let i=cs.length-1;i>0;i--){ const j=Math.random()*(i+1)|0; [cs[i],cs[j]]=[cs[j],cs[i]]; }
    let p=0; for(let i=0;i<N*N;i++){ grid[i].c=cs[p++]; grid[i].sp=SP.NONE; grid[i].scale=0; }
    let guard=0; while(findMatches().length&&guard++<100){ findMatches().forEach(g=>g.forEach(k=>grid[k].c=rnd())); }
    Sound.transition&&Sound.transition();
    anim=true; setTimeout(()=>{ anim=false; checkEnd(); },300);
  }
  function saveP(){ try{ window.saveProfile&&saveProfile(); }catch(e){} }

  /* ════════════════════════════════════════════
     КОНЕЦ
  ════════════════════════════════════════════ */
  function checkEnd(){
    const target=mission.target||600;
    if(progress>=target){ win(); return; }
    if(moves<=0){
      // нет ходов — предложить +5 (донат), иначе проигрыш
      if(opts.onBuyMoves){ /* интеграция позже */ }
      lose();
    }
  }
  function win(){ running=false; Sound.win&&Sound.win(); vibrate([10,40,10,40]);
    overlay(true); setTimeout(()=>{ opts.onWin&&opts.onWin(); },1000); }
  function lose(){ running=false; Sound.deny&&Sound.deny();
    overlay(false); setTimeout(()=>{ opts.onLose&&opts.onLose(); },1500); }

  function overlay(won){
    const o=document.createElement('div');
    o.style.cssText='position:absolute;inset:0;z-index:10;display:flex;align-items:center;justify-content:center;'+
      'background:radial-gradient(60% 50% at 50% 45%,rgba(10,14,22,.7),rgba(4,7,12,.94));'+
      'animation:m3fade .4s ease;flex-direction:column;gap:10px;';
    o.innerHTML='<div style="font-family:Unbounded,sans-serif;font-weight:900;font-size:26px;'+
      'color:'+(won?'#46d89b':'#ff6470')+';text-shadow:0 0 24px '+(won?'#46d89b':'#ff6470')+';">'+
      (won?'УЛИКА ПОЛУЧЕНА':'УЛИКА УТЕРЯНА')+'</div>'+
      '<div style="font-size:13px;color:#9aa3b2;">'+(won?'Свайп разблокирован':'Сдвиг недоволен')+'</div>';
    _root.appendChild(o);
  }

  /* ════════════════════════════════════════════
     ЧАСТИЦЫ / ТЕКСТ / АНИМАЦИИ
  ════════════════════════════════════════════ */
  function cxy(k){ const x=k%N,y=k/N|0; return [ox+x*cell+cell/2, oy+y*cell+cell/2]; }
  function burst(k,c){
    const [cx,cy]=cxy(k); const g=GEMS[c]||GEMS[0];
    for(let i=0;i<7;i++){
      const a=Math.random()*Math.PI*2, sp=1+Math.random()*3.5;
      particles.push({x:cx,y:cy,vx:Math.cos(a)*sp,vy:Math.sin(a)*sp-1,life:1,col:g.a,sz:2+Math.random()*3});
    }
  }
  function spawnRing(k,c){ const [cx,cy]=cxy(k); particles.push({ring:1,x:cx,y:cy,r:cell*0.2,life:1,col:(GEMS[c]||GEMS[0]).glow}); }
  function showCombo(n){
    const words=['','','Хорошо!','Отлично!','Превосходно!','Блестяще!','Гениально!'];
    floaters.push({txt:words[Math.min(n,6)]||'Комбо!',x:W/2,y:H*0.42,life:1,vy:-0.5});
    Sound.approve&&Sound.approve();
  }

  function animateSwap(a,b,done,back){
    const [ax,ay]=cxy(a),[bx,by]=cxy(b);
    const A=grid[a],B=grid[b]; const dur=back?120:150; const t0=performance.now();
    A._ox=0;A._oy=0;B._ox=0;B._oy=0;
    (function fr(t){
      let p=Math.min(1,(t-t0)/dur); const e=back?p:backOut(p);
      A._ox=(bx-ax)*e; A._oy=(by-ay)*e; B._ox=(ax-bx)*e; B._oy=(ay-by)*e;
      if(p<1) requestAnimationFrame(fr);
      else{ A._ox=A._oy=B._ox=B._oy=0; done&&done(); }
    })(t0);
  }
  function backOut(p){ const c1=1.70158,c3=c1+1; return 1+c3*Math.pow(p-1,3)+c1*Math.pow(p-1,2); }

  /* ════════════════════════════════════════════
     РЕНДЕР
  ════════════════════════════════════════════ */
  function drawGemShape(cx,cy,r,g,sp,glow){
    // тень-подложка
    ctx.save();
    if(glow>0){ ctx.shadowColor=g.glow; ctx.shadowBlur=18*glow; }
    // тело (скруглённый ромб-кристалл)
    const grad=ctx.createLinearGradient(cx-r,cy-r,cx+r,cy+r);
    grad.addColorStop(0,g.a); grad.addColorStop(1,g.b);
    ctx.fillStyle=grad;
    roundGem(cx,cy,r); ctx.fill();
    ctx.restore();

    // внутренняя тень снизу
    ctx.save(); roundGem(cx,cy,r); ctx.clip();
    const ish=ctx.createLinearGradient(cx,cy,cx,cy+r);
    ish.addColorStop(0,'rgba(0,0,0,0)'); ish.addColorStop(1,'rgba(0,0,0,.35)');
    ctx.fillStyle=ish; ctx.fillRect(cx-r,cy-r,r*2,r*2);
    ctx.restore();

    // глянцевый блик (леденец)
    ctx.save();
    const hl=ctx.createRadialGradient(cx-r*0.32,cy-r*0.4,1,cx-r*0.32,cy-r*0.4,r*0.9);
    hl.addColorStop(0,'rgba(255,255,255,.85)'); hl.addColorStop(.4,'rgba(255,255,255,.2)'); hl.addColorStop(1,'rgba(255,255,255,0)');
    ctx.fillStyle=hl; ctx.beginPath(); ctx.ellipse(cx-r*0.28,cy-r*0.34,r*0.5,r*0.36,-0.5,0,7); ctx.fill();
    ctx.restore();

    // эмблема улики (символ типа)
    ctx.save(); ctx.strokeStyle=g.hi; ctx.fillStyle=g.hi; ctx.lineWidth=Math.max(1.4,r*0.1);
    ctx.lineCap='round'; ctx.lineJoin='round'; ctx.globalAlpha=.92;
    drawEmblem(g.id,cx,cy,r*0.5);
    ctx.restore();

    // обводка спецэлемента
    if(sp){
      ctx.save(); ctx.lineWidth=2.4; ctx.strokeStyle='#fff';
      ctx.shadowColor=g.glow; ctx.shadowBlur=10;
      roundGem(cx,cy,r*0.98); ctx.stroke();
      // значок спецтипа
      ctx.globalAlpha=.9; ctx.fillStyle='#fff'; ctx.font='bold '+(r*0.7)+'px sans-serif';
      ctx.textAlign='center'; ctx.textBaseline='middle';
      const m=sp===SP.LINEH?'↔':sp===SP.LINEV?'↕':sp===SP.BOMB?'✸':'★';
      ctx.fillText(m,cx,cy+r*0.02);
      ctx.restore();
    }
  }
  function roundGem(cx,cy,r){
    const k=r*0.42; ctx.beginPath();
    ctx.moveTo(cx,cy-r);
    ctx.quadraticCurveTo(cx+r,cy-r,cx+r,cy);
    ctx.quadraticCurveTo(cx+r,cy+r,cx,cy+r);
    ctx.quadraticCurveTo(cx-r,cy+r,cx-r,cy);
    ctx.quadraticCurveTo(cx-r,cy-r,cx,cy-r);
    ctx.closePath();
  }
  function drawEmblem(id,cx,cy,s){
    ctx.beginPath();
    if(id==='trace'){ // капля-след
      ctx.moveTo(cx,cy-s); ctx.quadraticCurveTo(cx+s*0.8,cy+s*0.2,cx,cy+s);
      ctx.quadraticCurveTo(cx-s*0.8,cy+s*0.2,cx,cy-s); ctx.fill();
    } else if(id==='witness'){ // глаз
      ctx.ellipse(cx,cy,s,s*0.6,0,0,7); ctx.stroke();
      ctx.beginPath(); ctx.arc(cx,cy,s*0.28,0,7); ctx.fill();
    } else if(id==='exhibit'){ // ключ
      ctx.arc(cx-s*0.3,cy,s*0.4,0,7); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(cx-s*0.0,cy); ctx.lineTo(cx+s*0.8,cy);
      ctx.moveTo(cx+s*0.6,cy); ctx.lineTo(cx+s*0.6,cy+s*0.3); ctx.stroke();
    } else if(id==='alibi'){ // часы
      ctx.arc(cx,cy,s*0.8,0,7); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(cx,cy); ctx.lineTo(cx,cy-s*0.5);
      ctx.moveTo(cx,cy); ctx.lineTo(cx+s*0.4,cy+s*0.2); ctx.stroke();
    } else { // link — трубка
      ctx.arc(cx,cy,s*0.85,Math.PI*0.15,Math.PI*0.85); ctx.stroke();
      ctx.beginPath(); ctx.arc(cx-s*0.6,cy+s*0.3,s*0.22,0,7);
      ctx.arc(cx+s*0.6,cy+s*0.3,s*0.22,0,7); ctx.fill();
    }
  }

  function draw(){
    ctx.clearRect(0,0,W,H);
    // фон — старая бумага/пробка
    const bg=ctx.createLinearGradient(0,0,0,H);
    bg.addColorStop(0,'#1a1611'); bg.addColorStop(1,'#0d0b08');
    ctx.fillStyle=bg; ctx.fillRect(0,0,W,H);

    let shx=0,shy=0;
    if(shakeT>0){ shx=(Math.random()-.5)*shakeT; shy=(Math.random()-.5)*shakeT; shakeT*=0.85; if(shakeT<0.5)shakeT=0; }
    ctx.save(); ctx.translate(shx,shy);

    // доска
    ctx.fillStyle='rgba(20,16,12,.6)';
    rrect(ox-4,oy-4,boardPx+8,boardPx+8,10); ctx.fill();
    // клетки
    for(let y=0;y<N;y++)for(let x=0;x<N;x++){
      ctx.fillStyle=(x+y)%2?'rgba(255,255,255,.02)':'rgba(0,0,0,.12)';
      ctx.fillRect(ox+x*cell,oy+y*cell,cell,cell);
    }

    // подсказка
    if(hintCells){ hintCells.forEach(k=>{ const[cx,cy]=cxy(k);
      ctx.save(); ctx.globalAlpha=.4+0.3*Math.sin(performance.now()/200);
      ctx.strokeStyle='#ffcf6b'; ctx.lineWidth=3; rrect(cx-cell/2+3,cy-cell/2+3,cell-6,cell-6,8); ctx.stroke(); ctx.restore();
    }); }

    // фишки
    const r=cell*0.40;
    for(let y=0;y<N;y++)for(let x=0;x<N;x++){
      const k=idx(x,y),g=grid[k]; if(g.c<0) continue;
      // падение
      if(g.dy<0){ g.dy=Math.min(0,g.dy+Math.max(8,cell*0.18)); }
      else if(g.dy>0){ g.dy=Math.max(0,g.dy-Math.max(8,cell*0.18)); }
      // pop-вспышка
      if(g.pop>0){ g.pop=Math.max(0,g.pop-0.08); }
      if(g.glow>0){ g.glow=Math.max(0,g.glow-0.02); }
      let cx=ox+x*cell+cell/2+(g._ox||0);
      let cy=oy+y*cell+cell/2+g.dy+(g._oy||0);
      let rr=r*(g.scale||1);
      if(g.scale<1){ g.scale=Math.min(1,g.scale+0.08); }
      // выбранная — пульс
      if(sel===k){ rr*=1.1+0.05*Math.sin(performance.now()/120); }
      const gem=GEMS[g.c]||GEMS[0];
      drawGemShape(cx,cy,rr,gem,g.sp,g.glow+(g.pop));
    }

    // частицы
    for(let i=particles.length-1;i>=0;i--){ const p=particles[i];
      if(p.ring){ p.r+=cell*0.06; p.life-=0.05;
        ctx.save(); ctx.globalAlpha=Math.max(0,p.life); ctx.strokeStyle=p.col; ctx.lineWidth=3;
        ctx.beginPath(); ctx.arc(p.x,p.y,p.r,0,7); ctx.stroke(); ctx.restore();
        if(p.life<=0)particles.splice(i,1); continue; }
      p.x+=p.vx; p.y+=p.vy; p.vy+=0.18; p.life-=0.03;
      ctx.save(); ctx.globalAlpha=Math.max(0,p.life); ctx.fillStyle=p.col;
      ctx.beginPath(); ctx.arc(p.x,p.y,p.sz*p.life,0,7); ctx.fill(); ctx.restore();
      if(p.life<=0)particles.splice(i,1);
    }

    // всплывающий текст комбо
    for(let i=floaters.length-1;i>=0;i--){ const f=floaters[i];
      f.y+=f.vy; f.life-=0.018;
      ctx.save(); ctx.globalAlpha=Math.max(0,f.life);
      ctx.font='900 '+Math.round(W*0.07)+'px Unbounded, sans-serif';
      ctx.textAlign='center'; ctx.fillStyle='#ffcf6b';
      ctx.shadowColor='#c8860a'; ctx.shadowBlur=20;
      ctx.fillText(f.txt,f.x,f.y); ctx.restore();
      if(f.life<=0)floaters.splice(i,1);
    }

    ctx.restore();
  }

  function rrect(x,y,w,h,r){ ctx.beginPath();
    ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r);
    ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }

  /* ── HUD: цель + ходы (рисуется в DOM поверх) ── */
  let _hud;
  function hud(){
    if(!_hud){ _hud=document.createElement('div');
      _hud.style.cssText='position:absolute;top:0;left:0;right:0;z-index:5;display:flex;'+
        'justify-content:space-between;align-items:center;padding:8px 12px;pointer-events:none;'+
        'font-family:Unbounded,sans-serif;';
      cvs.parentNode.appendChild(_hud);
    }
    const target=mission.target||600;
    const pct=Math.min(100,Math.round(progress/target*100));
    _hud.innerHTML=
      '<div style="flex:1;margin-right:10px">'+
        '<div style="font-size:9px;letter-spacing:.1em;color:#c8a05a;margin-bottom:3px">'+(mission.label||'ЦЕЛЬ')+'</div>'+
        '<div style="height:6px;border-radius:6px;background:rgba(255,255,255,.08);overflow:hidden">'+
          '<div style="height:100%;width:'+pct+'%;border-radius:6px;background:linear-gradient(90deg,#b3741c,#ffcf6b);box-shadow:0 0 8px #c8860a;transition:width .3s"></div>'+
        '</div>'+
      '</div>'+
      '<div style="text-align:center;min-width:56px">'+
        '<div style="font-size:9px;color:#c8a05a;letter-spacing:.08em">ХОДЫ</div>'+
        '<div style="font-size:22px;font-weight:900;color:'+(moves<=3?'#ff6470':'#fff')+'">'+moves+'</div>'+
      '</div>';
  }

  /* ── бар бустеров из инвентаря ──────────────── */
  function renderBar(){
    if(!_bar) return;
    const p=(window.App&&App.profile)||{};
    const items=[
      {k:'ashtray',n:p.boosters||0, ico:'🪨', t:'Пепельница — убрать 1 фишку'},
      {k:'siren',  n:p.bSiren||0,   ico:'🚨', t:'Мигалка — ряд + столбец'},
      {k:'shuffle',n:p.bShuffle||0, ico:'📼', t:'Плёнка — перемешать поле'}
    ];
    _bar.innerHTML=items.map(it=>
      '<button data-k="'+it.k+'" title="'+it.t+'" style="pointer-events:auto;cursor:pointer;'+
      'border:1px solid '+(invMode===it.k?'#ffcf6b':'rgba(240,169,58,.4)')+';border-radius:11px;'+
      'background:'+(invMode===it.k?'rgba(255,207,107,.2)':'rgba(255,255,255,.05)')+';'+
      'color:#ffcf6b;padding:7px 12px;font-weight:800;font-size:14px;min-width:54px;'+
      (it.n<=0?'opacity:.4;':'')+'">'+it.ico+' '+it.n+'</button>'
    ).join('');
    _bar.querySelectorAll('button').forEach(b=>b.onclick=()=>{
      const k=b.dataset.k, n=items.find(i=>i.k===k).n;
      if(n<=0){ Sound.error&&Sound.error(); if(window.toast)toast('Нет бустера','Купи в Лавке','✗'); return; }
      invMode=invMode===k?null:k; Sound.tap&&Sound.tap(); renderBar();
    });
  }

  /* ── ввод: тап + свайп ─────────────────────── */
  function bindInput(){
    let downK=null,sx=0,sy=0;
    function pick(e){ const r=cvs.getBoundingClientRect();
      const px=(e.touches?e.touches[0].clientX:e.clientX)-r.left;
      const py=(e.touches?e.touches[0].clientY:e.clientY)-r.top;
      const x=Math.floor((px-ox)/cell), y=Math.floor((py-oy)/cell);
      return inb(x,y)?idx(x,y):null;
    }
    cvs.onpointerdown=(e)=>{ if(anim||!running)return; const k=pick(e); if(k==null)return;
      idleT=0; hintCells=null;
      if(invMode){ applyInventory(k); return; }
      downK=k; sx=e.clientX; sy=e.clientY; sel=k; Sound.gemSelect&&Sound.gemSelect();
    };
    cvs.onpointermove=(e)=>{ if(downK==null||anim)return;
      const dx=e.clientX-sx, dy=e.clientY-sy;
      if(Math.abs(dx)>cell*0.4||Math.abs(dy)>cell*0.4){
        const x=downK%N,y=downK/N|0; let tx=x,ty=y;
        if(Math.abs(dx)>Math.abs(dy)) tx+=dx>0?1:-1; else ty+=dy>0?1:-1;
        if(inb(tx,ty)){ trySwap(downK,idx(tx,ty)); }
        downK=null; sel=null;
      }
    };
    cvs.onpointerup=(e)=>{
      if(downK!=null){
        const k=pick(e);
        if(k!=null&&k!==downK){ const ax=downK%N,ay=downK/N|0,bx=k%N,by=k/N|0;
          if(Math.abs(ax-bx)+Math.abs(ay-by)===1){ trySwap(downK,k); } else { sel=null; } }
        else if(k===downK){ /* оставить выбранным для тап-тап */ sel=downK; }
      }
      downK=null;
    };
  }

  /* ── главный цикл ──────────────────────────── */
  function loop(t){
    if(!running && particles.length===0 && floaters.length===0){ draw(); return; }
    raf=requestAnimationFrame(loop);
    const dt=t-last; last=t;
    // подсказка по бездействию
    if(running && !anim){ idleT+=dt;
      if(idleT>3000 && !hintCells){ hintCells=findHint(); }
    }
    draw();
  }

})();

