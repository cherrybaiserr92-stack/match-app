/* ═══════════════════════════════════════════════
   СДВИГ · match3.js v5 — Canvas «Улики»
   На весь контейнер · тапы + свайпы · ходы · бустеры
═══════════════════════════════════════════════ */
(function(){
  const COLORS=[
    {a:'#ff5d6c',b:'#b3202d',pg:'#ffe8ea'}, // 0 красная книга
    {a:'#6be0ff',b:'#1f7da8',pg:'#e6f9ff'}, // 1 голубая
    {a:'#35d49b',b:'#127a52',pg:'#e3fff4'}, // 2 зелёная
    {a:'#ffcf6b',b:'#b3741c',pg:'#fff6e0'}, // 3 золотая
    {a:'#a98bff',b:'#5b3fb0',pg:'#f1ebff'}, // 4 фиолетовая
    {a:'#2b2f3a',b:'#0e1016',pg:'#f4f6fb'}  // 5 чёрная (как в референсе)
  ];
  // тематический эмблема на обложке каждой книги
  const EMBLEM=['star','sparkle','triangle','bigstar','pentagon','question'];
  const N=8; // 8×8

  let cvs,ctx,W,H,DPR,cell,ox,oy;
  let grid=[];                 // [{c,scale,dy,glow}]
  let sel=null;                // выбранная ячейка
  let anim=false, raf=null;
  let opts=null, moves=0, score=0, progress=0, combo=0, comboMax=0;
  let booster=0, boosterMode=null, lamp=2;
  let running=false;
  let particles=[];
  let last=0;

  /* ── публичный API ─────────────────────────── */
  window.Match3={
    start(container,o){
      opts=o||{}; const m=opts.mission||{type:'score',target:600,moves:14};
      moves=m.moves||14; score=0; progress=0; combo=0; comboMax=0;
      booster=opts.boosters||0; boosterMode=null; lamp=2; particles=[];
      running=true;
      try{ if(window.BgFx&&BgFx.pause) BgFx.pause(); }catch(e){}
      buildCanvas(container);
      initGrid();
      bindInput();
      loop();
      hud();
    },
    stop(){ running=false; if(raf)cancelAnimationFrame(raf);
      try{ window.removeEventListener('resize',window._m3resize); }catch(e){}
      if(cvs&&cvs.parentNode) cvs.parentNode.innerHTML='';
      try{ if(window.BgFx&&BgFx.resume) BgFx.resume(); }catch(e){} }
  };

  /* ── canvas ────────────────────────────────── */
  function buildCanvas(container){
    container.innerHTML='';
    DPR=Math.min(window.devicePixelRatio||1,2);
    cvs=document.createElement('canvas');
    cvs.style.cssText='display:block;width:100%;height:100%;touch-action:none;'+
      'pointer-events:auto;position:relative;z-index:1';
    container.appendChild(cvs);
    ctx=cvs.getContext('2d');
    resize(container);
    window._m3resize=()=>resize(container);
    window.addEventListener('resize',window._m3resize);
  }
  function resize(container){
    const r=container.getBoundingClientRect();
    W=r.width; H=r.height;
    cvs.width=W*DPR; cvs.height=H*DPR; ctx.setTransform(DPR,0,0,DPR,0,0);
    const pad=14, hudH=64;
    const avail=Math.min(W-pad*2, H-hudH-pad*2);
    cell=Math.floor(avail/N);
    ox=(W-cell*N)/2; oy=hudH+(H-hudH-cell*N)/2;
  }

  /* ── grid ──────────────────────────────────── */
  function initGrid(){
    grid=[];
    for(let i=0;i<N*N;i++) grid.push({c:rnd(),scale:1,dy:0,glow:0});
    // убрать стартовые матчи
    let guard=0;
    while(findMatches().length && guard++<60){
      findMatches().forEach(idx=>grid[idx].c=rnd());
    }
  }
  function rnd(){ return Math.floor(Math.random()*COLORS.length); }
  const idx=(x,y)=>y*N+x;
  const inb=(x,y)=>x>=0&&y>=0&&x<N&&y<N;

  /* ── поиск совпадений ──────────────────────── */
  function findMatches(){
    const set=new Set();
    // горизонталь
    for(let y=0;y<N;y++) for(let x=0;x<N-2;x++){
      const c=grid[idx(x,y)].c;
      if(c===grid[idx(x+1,y)].c && c===grid[idx(x+2,y)].c){
        set.add(idx(x,y)); set.add(idx(x+1,y)); set.add(idx(x+2,y));
        let k=x+3; while(k<N&&grid[idx(k,y)].c===c){ set.add(idx(k,y)); k++; }
      }
    }
    // вертикаль
    for(let x=0;x<N;x++) for(let y=0;y<N-2;y++){
      const c=grid[idx(x,y)].c;
      if(c===grid[idx(x,y+1)].c && c===grid[idx(x,y+2)].c){
        set.add(idx(x,y)); set.add(idx(x,y+1)); set.add(idx(x,y+2));
        let k=y+3; while(k<N&&grid[idx(x,k)].c===c){ set.add(idx(x,k)); k++; }
      }
    }
    return [...set];
  }

  /* ── ход игрока ────────────────────────────── */
  function trySwap(a,b){
    if(anim||moves<=0) return;
    const ax=a%N,ay=(a/N|0),bx=b%N,by=(b/N|0);
    if(Math.abs(ax-bx)+Math.abs(ay-by)!==1) return;
    swap(a,b);
    const m=findMatches();
    if(!m.length){ // откат
      Sound.error();
      swap(a,b);
      shakeCells([a,b]);
      return;
    }
    Sound.gemSwap(); vibrate(8);
    moves--; combo=0;
    resolveCascade();
    hud();
  }
  function swap(a,b){ const t=grid[a].c; grid[a].c=grid[b].c; grid[b].c=t; }

  /* ── каскад ────────────────────────────────── */
  function resolveCascade(){
    const m=findMatches();
    if(!m.length){ checkEnd(); return; }
    combo++; comboMax=Math.max(comboMax,combo);
    Sound.gemMatch(m.length); if(combo>1) Sound.gemCascade(combo);
    vibrate(combo>1?[6,20,6]:6);

    // очки + миссия
    const gain=m.length*30*combo; score+=gain;
    m.forEach(i=>{
      const x=i%N,y=(i/N|0);
      spawnBurst(ox+x*cell+cell/2, oy+y*cell+cell/2, grid[i].c);
      grid[i].glow=1;
      // миссии color/clear
      if(opts.mission){
        const mi=opts.mission;
        if(mi.type==='color'&&grid[i].c===mi.color) progress++;
        if(mi.type==='clear') progress++;
      }
    });
    if(opts.mission){
      const mi=opts.mission;
      if(mi.type==='score') progress=score;
      if(mi.type==='combo') progress=comboMax;
    }

    // удалить и обрушить
    anim=true;
    setTimeout(()=>{
      m.forEach(i=>grid[i].c=-1);
      collapse();
      anim=false;
      hud();
      setTimeout(()=>resolveCascade(),120);
    },140);
  }

  function collapse(){
    for(let x=0;x<N;x++){
      let write=N-1;
      for(let y=N-1;y>=0;y--){
        if(grid[idx(x,y)].c!==-1){
          if(write!==y){ grid[idx(x,write)].c=grid[idx(x,y)].c;
            grid[idx(x,write)].dy=(write-y)*cell; }
          write--;
        }
      }
      for(let y=write;y>=0;y--){ grid[idx(x,y)].c=rnd(); grid[idx(x,y)].dy=(write+2)*cell; }
    }
    Sound.gemFall();
  }

  /* ── бустер: разбить ячейку и соседей ──────── */
  function useBooster(i){
    if(booster<=0){ Sound.error(); return; }
    booster--; boosterMode=null; Sound.booster(); vibrate([10,30,10]);
    const x=i%N,y=(i/N|0); const hit=[];
    for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++){
      if(inb(x+dx,y+dy)) hit.push(idx(x+dx,y+dy)); }
    hit.forEach(k=>{ const xx=k%N,yy=(k/N|0);
      spawnBurst(ox+xx*cell+cell/2,oy+yy*cell+cell/2,grid[k].c);
      grid[k].c=-1; });
    score+=hit.length*40;
    if(opts.mission&&opts.mission.type==='clear') progress+=hit.length;
    anim=true; setTimeout(()=>{ collapse(); anim=false; resolveCascade(); hud(); },140);
  }

  /* ── конец ─────────────────────────────────── */
  function checkEnd(){
    const mi=opts.mission||{type:'score',target:600};
    const target=mi.target||600;
    if(progress>=target){ win(); return; }
    if(moves<=0){ lose(); }
  }
  function win(){ running=false; Sound.win(); vibrate([10,40,10,40]);
    overlay(true); setTimeout(()=>{ opts.onWin&&opts.onWin(); },900); }
  function lose(){ running=false; Sound.deny(); overlay(false);
    setTimeout(()=>{ opts.onLose&&opts.onLose(); },1400); }

  function overlay(ok){
    const o=document.createElement('div');
    o.style.cssText='position:absolute;inset:0;display:flex;flex-direction:column;'+
      'align-items:center;justify-content:center;gap:14px;text-align:center;'+
      'background:rgba(7,9,13,.82);backdrop-filter:blur(6px);z-index:5;'+
      'font-family:Unbounded,sans-serif;color:#f2f5fb';
    o.innerHTML=ok
      ? `<div style="font-size:54px">🔍</div><div style="font-size:22px;color:#35d49b">УЛИКИ НАЙДЕНЫ</div>
         <div style="font-size:13px;color:#b7c0d4">Очки: ${score} · Каскад x${comboMax}</div>`
      : `<div style="font-size:54px">🚫</div><div style="font-size:22px;color:#ff5d6c">ХОДЫ ЗАКОНЧИЛИСЬ</div>
         <div style="font-size:13px;color:#b7c0d4">Попробуйте ещё раз</div>`;
    cvs.parentNode.appendChild(o);
  }

  /* ── input: тап + свайп ───────────────────── */
  let down=null;
  function bindInput(){
    cvs.onpointerdown=e=>{ if(!running||anim)return;
      const c=hitCell(e); if(!c)return; down={...c,sx:e.clientX,sy:e.clientY}; };
    cvs.onpointerup=e=>{ handleUp(e.clientX,e.clientY); };
    cvs.oncontextmenu=e=>e.preventDefault();

    // ── Touch fallback (некоторые мобильные браузеры глушат pointer-события) ──
    cvs.addEventListener('touchstart',e=>{
      if(!running||anim)return;
      const t=e.changedTouches[0]; const c=hitCell(t);
      if(c) down={...c,sx:t.clientX,sy:t.clientY};
    },{passive:true});
    cvs.addEventListener('touchend',e=>{
      const t=e.changedTouches[0];
      handleUp(t.clientX,t.clientY);
      e.preventDefault();
    },{passive:false});
  }

  function handleUp(cx,cy){
    if(!running||anim||!down){ down=null; return; }
    const c=hitCell({clientX:cx,clientY:cy});
    const dx=cx-down.sx, dy=cy-down.sy;
    const dist=Math.hypot(dx,dy);
    if(boosterMode){ if(c) useBooster(c.i); down=null; return; }
    if(dist<14){ // ТАП
      if(sel==null){ sel=down.i; grid[sel].glow=.6; Sound.gemSelect(); }
      else if(sel===down.i){ grid[sel].glow=0; sel=null; }
      else { grid[sel].glow=0; const a=sel; sel=null; trySwap(a,down.i); }
    }else{ // СВАЙП
      let nx=down.x,ny=down.y;
      if(Math.abs(dx)>Math.abs(dy)) nx+=dx>0?1:-1; else ny+=dy>0?1:-1;
      if(inb(nx,ny)){ if(sel!=null){grid[sel].glow=0;sel=null;} trySwap(down.i,idx(nx,ny)); }
    }
    down=null;
  }
  function hitCell(e){
    const r=cvs.getBoundingClientRect();
    const px=e.clientX-r.left, py=e.clientY-r.top;
    const x=Math.floor((px-ox)/cell), y=Math.floor((py-oy)/cell);
    if(!inb(x,y)) return null; return {x,y,i:idx(x,y)};
  }

  /* ── частицы ───────────────────────────────── */
  function spawnBurst(x,y,c){
    const col=COLORS[c]?COLORS[c].a:'#fff';
    for(let i=0;i<6;i++){ const a=Math.random()*Math.PI*2,s=1+Math.random()*3;
      particles.push({x,y,vx:Math.cos(a)*s,vy:Math.sin(a)*s-1,life:1,col,r:2+Math.random()*3}); }
  }
  function shakeCells(arr){ arr.forEach(i=>grid[i].glow=.4); setTimeout(()=>arr.forEach(i=>grid[i].glow=0),200); }

  /* ── HUD (поверх canvas, лёгкий DOM) ───────── */
  function hud(){
    let bar=cvs.parentNode.querySelector('.m3-hud');
    const mi=opts.mission||{type:'score',target:600}; const target=mi.target||600;
    if(!bar){ bar=document.createElement('div'); bar.className='m3-hud';
      bar.style.cssText='position:absolute;top:0;left:0;right:0;height:60px;display:flex;'+
        'align-items:center;justify-content:space-between;padding:0 16px;'+
        'font-family:Manrope,sans-serif;color:#f2f5fb;z-index:4;pointer-events:none';
      cvs.parentNode.appendChild(bar); }
    const pct=Math.min(100,progress/target*100);
    bar.innerHTML=`
      <div style="text-align:left">
        <div style="font-size:10px;letter-spacing:1px;color:#7d8699;text-transform:uppercase">${mi.label||'Цель'}</div>
        <div style="width:130px;height:6px;background:rgba(255,255,255,.08);border-radius:6px;margin-top:5px;overflow:hidden">
          <div style="width:${pct}%;height:100%;background:linear-gradient(90deg,#b3741c,#ffcf6b);border-radius:6px"></div></div>
      </div>
      <div style="display:flex;gap:10px;align-items:center">
        <div style="text-align:center"><div style="font-family:Unbounded;font-weight:700;font-size:18px;color:#ffcf6b">${moves}</div>
          <div style="font-size:9px;color:#7d8699">ХОДЫ</div></div>
        <div style="text-align:center"><div style="font-family:Unbounded;font-weight:700;font-size:18px">${score}</div>
          <div style="font-size:9px;color:#7d8699">ОЧКИ</div></div>
        <button class="m3-lamp" style="pointer-events:auto;border:none;cursor:pointer;
          background:rgba(255,255,255,.06);color:#ffcf6b;
          border:1px solid rgba(240,169,58,.4);border-radius:10px;padding:6px 9px;font-weight:800;font-size:13px"
          title="Лампа: +3 хода">💡 ${lamp}</button>
        <button class="m3-boost" style="pointer-events:auto;border:none;cursor:pointer;
          background:${boosterMode?'#ffcf6b':'rgba(255,255,255,.06)'};color:${boosterMode?'#1a1206':'#ffcf6b'};
          border:1px solid rgba(240,169,58,.4);border-radius:10px;padding:6px 9px;font-weight:800;font-size:13px"
          title="Бомба: убрать книгу">💥 ${booster}</button>
      </div>`;
    const bb=bar.querySelector('.m3-boost');
    if(bb) bb.onclick=()=>{ if(booster<=0){Sound.error();return;}
      boosterMode=boosterMode?null:'bomb'; Sound.tap(); hud(); };
    const lb=bar.querySelector('.m3-lamp');
    if(lb) lb.onclick=()=>{ if(lamp<=0){Sound.error();return;}
      lamp--; moves+=3; Sound.booster&&Sound.booster(); vibrate([10,20]); hud(); };
  }

  /* ── render loop ───────────────────────────── */
  function loop(t){
    if(!running && particles.length===0){ draw(); return; }
    raf=requestAnimationFrame(loop);
    const dt=Math.min(40,(t||0)-last); last=t||0;
    // плавное падение
    for(const g of grid){ if(g.dy>0){ g.dy=Math.max(0,g.dy-cell*0.04*(dt/16)*4); }
      if(g.glow>0) g.glow=Math.max(0,g.glow-0.04); g.scale+=(1-g.scale)*0.2; }
    // частицы
    particles=particles.filter(p=>{ p.x+=p.vx; p.y+=p.vy; p.vy+=0.25; p.life-=0.03; return p.life>0; });
    draw();
  }

  function draw(){
    ctx.clearRect(0,0,W,H);
    // фон поля
    roundRect(ox-8,oy-8,cell*N+16,cell*N+16,18);
    ctx.fillStyle='rgba(18,22,32,.55)'; ctx.fill();
    ctx.strokeStyle='rgba(255,255,255,.07)'; ctx.lineWidth=1; ctx.stroke();

    for(let y=0;y<N;y++)for(let x=0;x<N;x++){
      const g=grid[idx(x,y)]; if(g.c<0) continue;
      const cx=ox+x*cell+cell/2, cy=oy+y*cell+cell/2 - g.dy;
      drawGem(cx,cy,g,(sel===idx(x,y)));
    }
    // частицы
    for(const p of particles){ ctx.globalAlpha=Math.max(0,p.life);
      ctx.fillStyle=p.col; ctx.beginPath(); ctx.arc(p.x,p.y,p.r,0,7); ctx.fill(); }
    ctx.globalAlpha=1;

    if(boosterMode){ ctx.fillStyle='rgba(240,169,58,.06)'; ctx.fillRect(0,0,W,H); }
  }

  function drawGem(cx,cy,g,selected){
    const col=COLORS[g.c];
    const s=cell*0.42*g.scale;          // полу-высота книги
    const w=s*1.55, h=s*2;              // ширина/высота обложки
    const x=cx-w/2, y=cy-h/2;
    const sp=w*0.16;                    // ширина корешка

    // glow при матче/выборе
    if(g.glow>0||selected){
      ctx.save(); ctx.globalAlpha=(selected?0.55:g.glow);
      ctx.fillStyle=col.a;
      ctx.beginPath(); ctx.arc(cx,cy,s*1.7,0,7); ctx.fill(); ctx.restore();
    }

    ctx.save();
    // тень книги
    ctx.fillStyle='rgba(0,0,0,.35)';
    bookPath(x+2,y+3,w,h,w*0.12); ctx.fill();

    // страницы (низ, белые полоски справа)
    ctx.fillStyle=col.pg;
    roundRectC(x+w*0.5,y+h*0.1,w*0.52,h*0.84,w*0.06); ctx.fill();
    ctx.strokeStyle='rgba(0,0,0,.12)'; ctx.lineWidth=1;
    for(let i=1;i<=3;i++){ const yy=y+h*0.1+ (h*0.84)*(i/4);
      ctx.beginPath(); ctx.moveTo(x+w*0.55,yy); ctx.lineTo(x+w*0.98,yy); ctx.stroke(); }

    // обложка (градиент)
    const grd=ctx.createLinearGradient(x,y,x+w,y+h);
    grd.addColorStop(0,col.a); grd.addColorStop(1,col.b);
    bookPath(x,y,w,h,w*0.12); ctx.fillStyle=grd; ctx.fill();

    // корешок (темнее) + золотые перетяжки
    ctx.fillStyle=col.b;
    roundRectC(x,y,sp,h,w*0.08); ctx.fill();
    ctx.strokeStyle='rgba(255,255,255,.18)'; ctx.lineWidth=1.2;
    ctx.beginPath(); ctx.moveTo(x+sp*1.4,y+h*0.04); ctx.lineTo(x+sp*1.4,y+h*0.96); ctx.stroke();
    ctx.fillStyle='#ffcf6b';
    for(let i=1;i<=3;i++){ const yy=y+h*(0.22*i);
      roundRectC(x-w*0.02,yy,sp*1.5,h*0.06,2); ctx.fill(); }

    // блик на обложке
    ctx.fillStyle='rgba(255,255,255,.16)';
    ctx.beginPath(); ctx.ellipse(cx+w*0.05,y+h*0.2,w*0.28,h*0.1,-0.4,0,7); ctx.fill();

    // эмблема по центру обложки
    drawEmblem(cx+w*0.12, cy, s*0.7, EMBLEM[g.c], col);

    ctx.restore();

    if(selected){
      ctx.strokeStyle='#fff'; ctx.lineWidth=2.5;
      bookPath(x,y,w,h,w*0.12); ctx.stroke();
    }
  }

  function bookPath(x,y,w,h,r){
    ctx.beginPath();
    ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r);
    ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath();
  }

  function drawEmblem(cx,cy,r,kind,col){
    ctx.save();
    ctx.fillStyle='#ffcf6b';
    ctx.strokeStyle='rgba(0,0,0,.25)'; ctx.lineWidth=1;
    if(kind==='star'||kind==='bigstar'){
      // белый овал + звезда (как в референсе)
      if(kind==='star'){ ctx.fillStyle='#fff';
        ctx.beginPath(); ctx.ellipse(cx,cy-r*0.5,r*0.6,r*0.42,0,0,7); ctx.fill(); }
      drawStar(cx,cy-(kind==='star'?r*0.5:0),(kind==='star'?r*0.28:r*0.6),5,'#ffcf6b');
    } else if(kind==='sparkle'){
      drawSpark(cx,cy,r*0.7);
    } else if(kind==='triangle'){
      ctx.beginPath(); ctx.moveTo(cx,cy-r*0.6); ctx.lineTo(cx+r*0.55,cy+r*0.45);
      ctx.lineTo(cx-r*0.55,cy+r*0.45); ctx.closePath(); ctx.fill();
    } else if(kind==='pentagon'){
      ctx.beginPath();
      for(let i=0;i<5;i++){ const a=-Math.PI/2+i*2*Math.PI/5;
        const px=cx+Math.cos(a)*r*0.6, py=cy+Math.sin(a)*r*0.6;
        i?ctx.lineTo(px,py):ctx.moveTo(px,py); }
      ctx.closePath(); ctx.fill();
    } else if(kind==='question'){
      // белый овал + звезда сверху + знак вопроса (чёрная книга)
      ctx.fillStyle='#fff';
      ctx.beginPath(); ctx.ellipse(cx,cy-r*0.7,r*0.45,r*0.32,0,0,7); ctx.fill();
      drawStar(cx,cy-r*0.7,r*0.2,5,'#ffcf6b');
      ctx.fillStyle='#ffcf6b'; ctx.font=`bold ${Math.floor(r*1.1)}px sans-serif`;
      ctx.textAlign='center'; ctx.textBaseline='middle';
      ctx.fillText('?',cx,cy+r*0.25);
    }
    ctx.restore();
  }

  function drawStar(cx,cy,r,n,fill){
    ctx.fillStyle=fill; ctx.beginPath();
    for(let i=0;i<n*2;i++){ const rr=i%2?r*0.45:r;
      const a=-Math.PI/2+i*Math.PI/n;
      const px=cx+Math.cos(a)*rr, py=cy+Math.sin(a)*rr;
      i?ctx.lineTo(px,py):ctx.moveTo(px,py); }
    ctx.closePath(); ctx.fill();
  }

  function drawSpark(cx,cy,r){
    // четырёхлучевой бриллиант-блеск
    ctx.fillStyle='#ffcf6b'; ctx.beginPath();
    ctx.moveTo(cx,cy-r); ctx.quadraticCurveTo(cx+r*0.18,cy-r*0.18,cx+r,cy);
    ctx.quadraticCurveTo(cx+r*0.18,cy+r*0.18,cx,cy+r);
    ctx.quadraticCurveTo(cx-r*0.18,cy+r*0.18,cx-r,cy);
    ctx.quadraticCurveTo(cx-r*0.18,cy-r*0.18,cx,cy-r);
    ctx.closePath(); ctx.fill();
  }

  function roundRect(x,y,w,h,r){ ctx.beginPath();
    ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r);
    ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }
  function roundRectC(x,y,w,h,r){ ctx.beginPath();
    ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r);
    ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }

  function vibrate(ms){ try{ navigator.vibrate&&navigator.vibrate(ms);}catch(e){} }
})();

