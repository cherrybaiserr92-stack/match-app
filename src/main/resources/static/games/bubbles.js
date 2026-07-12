/* ═══════════════════════════════════════════════════════
   СДВИГ · «ДОСКА СВЯЗЕЙ» — bubble shooter в нуаре.
   Целься и стреляй зацепками: три и больше одного цвета —
   гроздь лопается, повисшие без опоры срываются вниз.
   Каждые N выстрелов доска сползает. Очисти её всю.
   Контракт: Bubbles.start(container,{mission,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════ */
(function(){
  var COLS=9;
  var cv,ctx,raf=null,root,opts=null,running=false;
  var W=0,H=0,R=18,DPR=1;
  var rows=[];            // rows[r][c] = colorIdx | -1 ; чёт ряд: COLS, нечет: COLS-1 (со сдвигом)
  var offRows=0;          // сколько рядов «наросло» сверху (спуск)
  var cur=0,next=0,shots=0,descEvery=7,colors=4,lvl=1,score=0;
  var aim=null;           // {x,y} точка прицеливания
  var fly=null;           // летящий шар {x,y,vx,vy,c}
  var falling=[];         // падающие {x,y,vx,vy,c}
  var pops=[];            // частицы
  var shooterY=0, deadY=0;

  var HUES=[
    ['#ff9aa0','#e23b4e','#7d1020'],
    ['#9fe0ff','#2f9fe0','#0d4a75'],
    ['#8ff0c0','#22c07a','#0b5c3a'],
    ['#ffe3a0','#f0a52e','#8a5408'],
    ['#d9c2ff','#8f5fe8','#45247e'],
    ['#cfd8e3','#93a1b3','#39424e']
  ];

  function lvlOf(m){ if(m&&m.lvl)return m.lvl; if(m&&m.chapter)return m.chapter*2-1; return 1; }
  function rowLen(r){ return ((r+offRows)%2===0)?COLS:COLS-1; }
  function cellXY(r,c){
    var off=((r+offRows)%2===0)?0:R;
    return { x:R+off+c*2*R, y:R+r*R*1.732 };
  }

  function resize(){
    var b=root.getBoundingClientRect();
    DPR=Math.min(2,window.devicePixelRatio||1);
    cv.width=b.width*DPR; cv.height=b.height*DPR;
    W=b.width; H=b.height;
    ctx.setTransform(DPR,0,0,DPR,0,0);
    R=W/(COLS*2);
    shooterY=H-64;
    deadY=shooterY-70;
  }

  function initRows(nRows){
    rows=[]; offRows=0;
    for(var r=0;r<nRows;r++){
      var line=[];
      for(var c=0;c<rowLen(r);c++) line.push((Math.random()*colors)|0);
      rows.push(line);
    }
  }
  function colorsOnBoard(){
    var s={};
    rows.forEach(function(line){ line.forEach(function(v){ if(v>=0)s[v]=1; }); });
    var arr=Object.keys(s).map(Number);
    return arr.length?arr:[0];
  }
  function pickBall(){ var arr=colorsOnBoard(); return arr[(Math.random()*arr.length)|0]; }

  /* ── соседи в гекс-сетке ── */
  function neighbors(r,c){
    var even=((r+offRows)%2===0);
    var res=[[r,c-1],[r,c+1]];
    if(even){ res.push([r-1,c-1],[r-1,c],[r+1,c-1],[r+1,c]); }
    else{ res.push([r-1,c],[r-1,c+1],[r+1,c],[r+1,c+1]); }
    return res.filter(function(p){
      return p[0]>=0&&p[0]<rows.length&&p[1]>=0&&p[1]<rowLen(p[0])&&rows[p[0]][p[1]]>=0;
    });
  }
  function cluster(r,c,sameColor){
    var col=rows[r][c], seen={}, st=[[r,c]], out=[];
    seen[r+','+c]=1;
    while(st.length){
      var p=st.pop(); out.push(p);
      neighbors(p[0],p[1]).forEach(function(n){
        var k=n[0]+','+n[1]; if(seen[k])return;
        if(sameColor&&rows[n[0]][n[1]]!==col)return;
        seen[k]=1; st.push(n);
      });
    }
    return out;
  }
  function dropFloaters(){
    var anchored={};
    if(rows.length) for(var c=0;c<rowLen(0);c++) if(rows[0][c]>=0)
      cluster(0,c,false).forEach(function(p){ anchored[p[0]+','+p[1]]=1; });
    var dropped=0;
    for(var r=0;r<rows.length;r++)for(var c2=0;c2<rowLen(r);c2++){
      if(rows[r][c2]>=0&&!anchored[r+','+c2]){
        var xy=cellXY(r,c2);
        falling.push({x:xy.x,y:xy.y,vx:(Math.random()-0.5)*2,vy:-1-Math.random()*1.5,c:rows[r][c2]});
        rows[r][c2]=-1; dropped++;
      }
    }
    if(dropped){ score+=dropped*20; try{Sound.gemCascade&&Sound.gemCascade(2);}catch(_){} }
    return dropped;
  }
  function trimEmptyRows(){ while(rows.length&&rows[rows.length-1].every(function(v){return v<0;})) rows.pop(); }
  function boardEmpty(){ return rows.every(function(line){ return line.every(function(v){return v<0;}); }); }

  function descend(){
    offRows++;
    var line=[];
    for(var c=0;c<rowLen(0);c++) line.push((Math.random()*colors)|0);
    // rowLen поменялся из-за offRows — пересобрать: вставляем СВЕРХУ
    rows.unshift(line);
    try{ Sound.transition&&Sound.transition(); navigator.vibrate&&navigator.vibrate(12); }catch(_){}
  }
  function lowestY(){
    var ly=0;
    for(var r=0;r<rows.length;r++)for(var c=0;c<rowLen(r);c++)
      if(rows[r][c]>=0){ var y=cellXY(r,c).y; if(y>ly)ly=y; }
    return ly;
  }

  /* ── выстрел ── */
  function shoot(){
    if(!aim||fly||!running) return;
    var dx=aim.x-W/2, dy=aim.y-shooterY;
    var len=Math.hypot(dx,dy); if(len<10||dy>-14) return;
    var sp=13;
    fly={x:W/2,y:shooterY,vx:dx/len*sp,vy:dy/len*sp,c:cur};
    cur=next; next=pickBall();
    shots++;
    try{ Sound.shot?Sound.shot():(Sound.tap&&Sound.tap()); navigator.vibrate&&navigator.vibrate(8); }catch(_){}
  }
  function snapFly(){
    // ближайшая свободная ячейка
    var bestR=-1,bestC=-1,bd=1e9;
    var maxR=Math.max(rows.length+1, Math.ceil((fly.y-R)/(R*1.732))+2);
    for(var r=0;r<maxR;r++){
      for(var c=0;c<rowLen(r);c++){
        if(rows[r]&&rows[r][c]>=0) continue;
        var xy=cellXY(r,c);
        var d=(xy.x-fly.x)*(xy.x-fly.x)+(xy.y-fly.y)*(xy.y-fly.y);
        if(d<bd){ bd=d; bestR=r; bestC=c; }
      }
    }
    while(rows.length<=bestR){ var nl=[]; for(var i=0;i<rowLen(rows.length);i++)nl.push(-1); rows.push(nl); }
    rows[bestR][bestC]=fly.c;
    var cl=cluster(bestR,bestC,true);
    if(cl.length>=3){
      cl.forEach(function(p){
        var xy=cellXY(p[0],p[1]);
        for(var i=0;i<6;i++) pops.push({x:xy.x,y:xy.y,vx:(Math.random()-0.5)*4,vy:(Math.random()-0.5)*4-1,
          life:1,c:rows[p[0]][p[1]]});
        rows[p[0]][p[1]]=-1;
      });
      score+=cl.length*10;
      try{ Sound.gemMatch&&Sound.gemMatch(cl.length); navigator.vibrate&&navigator.vibrate([8,25]); }catch(_){}
      dropFloaters();
    } else {
      try{ Sound.gemFall&&Sound.gemFall(); }catch(_){}
    }
    trimEmptyRows();
    fly=null;
    if(boardEmpty()){ win(); return; }
    if(shots>0&&shots%descEvery===0) descend();
    if(lowestY()>deadY-R) lose();
  }

  /* ── рендер ── */
  function ball(x,y,c,r){
    var h=HUES[c]||HUES[0];
    var g=ctx.createRadialGradient(x-r*0.35,y-r*0.4,r*0.15,x,y,r);
    g.addColorStop(0,h[0]); g.addColorStop(0.55,h[1]); g.addColorStop(1,h[2]);
    ctx.beginPath(); ctx.arc(x,y,r,0,6.283);
    ctx.fillStyle=g; ctx.fill();
    ctx.strokeStyle='rgba(0,0,0,.55)'; ctx.lineWidth=1.2; ctx.stroke();
    // окно-блик
    ctx.beginPath(); ctx.ellipse(x-r*0.32,y-r*0.42,r*0.28,r*0.16,-0.5,0,6.283);
    ctx.fillStyle='rgba(255,255,255,.75)'; ctx.fill();
  }

  function draw(){
    ctx.clearRect(0,0,W,H);
    // фон
    var bg=ctx.createRadialGradient(W/2,H*0.2,40,W/2,H*0.5,H);
    bg.addColorStop(0,'#16141a'); bg.addColorStop(1,'#050507');
    ctx.fillRect(0,0,W,H); ctx.fillStyle=bg; ctx.fillRect(0,0,W,H);
    // нити доски связей (лёгкая сетка)
    ctx.strokeStyle='rgba(224,84,110,.05)'; ctx.lineWidth=1;
    for(var gx=0;gx<W;gx+=46){ ctx.beginPath(); ctx.moveTo(gx,0); ctx.lineTo(gx,H); ctx.stroke(); }
    // шары
    for(var r=0;r<rows.length;r++)for(var c=0;c<rowLen(r);c++){
      if(rows[r][c]<0) continue;
      var xy=cellXY(r,c);
      ball(xy.x,xy.y,rows[r][c],R-1.5);
    }
    // линия провала
    ctx.setLineDash([7,7]);
    ctx.strokeStyle='rgba(224,84,110,.5)'; ctx.lineWidth=1.5;
    ctx.beginPath(); ctx.moveTo(8,deadY); ctx.lineTo(W-8,deadY); ctx.stroke();
    ctx.setLineDash([]);
    // прицел
    if(aim&&!fly){
      var dx=aim.x-W/2, dy=aim.y-shooterY, len=Math.hypot(dx,dy);
      if(len>10&&dy<-14){
        var ux=dx/len,uy=dy/len,px=W/2,py=shooterY;
        ctx.fillStyle='rgba(255,255,255,.5)';
        for(var i=0;i<26;i++){
          px+=ux*16; py+=uy*16;
          if(px<R){ px=R+(R-px); ux=-ux; }
          if(px>W-R){ px=W-R-(px-(W-R)); ux=-ux; }
          if(py<R) break;
          ctx.beginPath(); ctx.arc(px,py,2,0,6.283); ctx.fill();
        }
      }
    }
    // пушка
    ctx.beginPath(); ctx.arc(W/2,shooterY,R+7,0,6.283);
    ctx.fillStyle='#17141c'; ctx.fill();
    ctx.strokeStyle='#5c6572'; ctx.lineWidth=2; ctx.stroke();
    ball(W/2,shooterY,cur,R-1);
    // следующий
    ctx.globalAlpha=0.8;
    ball(W/2+R*2.6,shooterY+14,next,R*0.6);
    ctx.globalAlpha=1;
    ctx.font='700 9px Unbounded,sans-serif'; ctx.fillStyle='#93a1b3'; ctx.textAlign='center';
    ctx.fillText('СЛЕД.',W/2+R*2.6,shooterY+14+R*0.6+12);
    // счёт и спуск
    ctx.font='800 12px Unbounded,sans-serif'; ctx.fillStyle='#cfd8e3'; ctx.textAlign='left';
    ctx.fillText(score+' очк.',10,H-12);
    ctx.textAlign='right';
    ctx.fillStyle='#93a1b3';
    ctx.fillText('спуск через '+(descEvery-(shots%descEvery)),W-10,H-12);
    // летящий
    if(fly) ball(fly.x,fly.y,fly.c,R-1.5);
    // падающие
    falling.forEach(function(f){ ball(f.x,f.y,f.c,R-2); });
    // частицы
    pops.forEach(function(p){
      ctx.globalAlpha=Math.max(0,p.life);
      ctx.beginPath(); ctx.arc(p.x,p.y,3.2*p.life,0,6.283);
      ctx.fillStyle=(HUES[p.c]||HUES[0])[0]; ctx.fill();
      ctx.globalAlpha=1;
    });
  }

  function step(){
    if(!running) return;
    if(fly){
      fly.x+=fly.vx; fly.y+=fly.vy;
      if(fly.x<R){ fly.x=R+(R-fly.x); fly.vx=-fly.vx; }
      if(fly.x>W-R){ fly.x=W-R-(fly.x-(W-R)); fly.vx=-fly.vx; }
      var hit=fly.y<=R;
      if(!hit){
        outer:
        for(var r=0;r<rows.length;r++)for(var c=0;c<rowLen(r);c++){
          if(rows[r][c]<0)continue;
          var xy=cellXY(r,c);
          if((xy.x-fly.x)*(xy.x-fly.x)+(xy.y-fly.y)*(xy.y-fly.y)<(R*1.8)*(R*1.8)){ hit=true; break outer; }
        }
      }
      if(hit) snapFly();
    }
    falling.forEach(function(f){ f.vy+=0.45; f.x+=f.vx; f.y+=f.vy; });
    falling=falling.filter(function(f){ return f.y<H+40; });
    pops.forEach(function(p){ p.x+=p.vx; p.y+=p.vy; p.vy+=0.12; p.life-=0.04; });
    pops=pops.filter(function(p){ return p.life>0; });
    draw();
    raf=requestAnimationFrame(step);
  }

  function bindInput(){
    cv.addEventListener('pointerdown',function(e){ var b=cv.getBoundingClientRect();
      var x=e.clientX-b.left,y=e.clientY-b.top;
      // тап по пушке — свап шаров
      if(Math.hypot(x-W/2,y-shooterY)<R+10||Math.hypot(x-(W/2+R*2.6),y-(shooterY+14))<R){
        var t=cur; cur=next; next=t; try{Sound.tap&&Sound.tap();}catch(_){} return; }
      aim={x:x,y:y}; });
    cv.addEventListener('pointermove',function(e){ if(!aim)return; var b=cv.getBoundingClientRect();
      aim={x:e.clientX-b.left,y:e.clientY-b.top}; });
    cv.addEventListener('pointerup',function(){ shoot(); aim=null; });
  }

  function flash(col,msg,sub){
    var o=document.createElement('div');
    o.style.cssText='position:absolute;inset:0;display:flex;align-items:center;justify-content:center;z-index:9;'+
      'background:rgba(8,8,11,.84);font:800 21px Unbounded,sans-serif;letter-spacing:.08em;color:'+col+';';
    o.innerHTML='<div style="text-align:center">'+msg+(sub?'<div style="font:600 12px Manrope,sans-serif;color:#93a1b3;margin-top:8px">'+sub+'</div>':'')+'</div>';
    root.appendChild(o);
  }
  function win(){ if(!running)return; running=false; cancelAnimationFrame(raf);
    try{ Sound.win&&Sound.win(); navigator.vibrate&&navigator.vibrate([10,40,10,40]); }catch(_){}
    flash('#46d89b','ДОСКА ЧИСТА','Все связи распутаны. +'+score);
    setTimeout(function(){ opts&&opts.onWin&&opts.onWin(); },900); }
  function lose(){ if(!running)return; running=false; cancelAnimationFrame(raf);
    try{ Sound.deny&&Sound.deny(); }catch(_){}
    flash('#ff6470','ДОСКА ПЕРЕПОЛНЕНА','Зацепки задавили. Попробуй снова.');
    setTimeout(function(){ opts&&opts.onLose&&opts.onLose(); },900); }

  function start(container,o){
    opts=o||{}; running=true;
    lvl=lvlOf(opts.mission);
    colors=4+Math.min(2,(lvl/4)|0);
    var nRows=4+Math.min(3,((lvl-1)/2)|0);
    descEvery=Math.max(5,8-((lvl/3)|0));
    shots=0; score=0; fly=null; falling=[]; pops=[]; aim=null;
    root=document.createElement('div');
    root.style.cssText='position:absolute;inset:0;overflow:hidden;touch-action:none;user-select:none;';
    cv=document.createElement('canvas');
    cv.style.cssText='width:100%;height:100%;display:block;';
    root.appendChild(cv);
    container.innerHTML=''; container.appendChild(root);
    ctx=cv.getContext('2d');
    resize(); window.addEventListener('resize',resize);
    initRows(nRows);
    cur=pickBall(); next=pickBall();
    bindInput();
    raf=requestAnimationFrame(step);
  }
  function stop(){ running=false; cancelAnimationFrame(raf);
    try{ window.removeEventListener('resize',resize); }catch(_){} }

  window.Bubbles={ start:start, stop:stop,
    _dbg:{
      state:function(){ return {rows:rows.length,score:score,shots:shots,
        left:rows.reduce(function(a,l){return a+l.filter(function(v){return v>=0;}).length;},0)}; },
      grid:function(){ return rows.map(function(l){return l.slice();}); },
      clearAll:function(){ rows.forEach(function(l,r){ l.forEach(function(v,c){ rows[r][c]=-1; }); });
        trimEmptyRows(); if(boardEmpty())win(); },
      popAt:function(r,c){ var cl=cluster(r,c,true);
        cl.forEach(function(p){ rows[p[0]][p[1]]=-1; }); dropFloaters(); trimEmptyRows();
        if(boardEmpty())win(); return cl.length; },
      shootStraight:function(){ aim={x:W/2,y:0}; shoot(); }
    } };
})();
