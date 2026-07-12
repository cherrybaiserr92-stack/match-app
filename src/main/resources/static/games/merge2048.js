/* ═══════════════════════════════════════════════════════
   СДВИГ · «ДЕДУКЦИЯ» — 2048 в нуаре.
   Свайпай: одинаковые факты сливаются в вывод покрупнее.
   Собери плитку-цель. Поле забито и ходов нет — тупик.
   Контракт: Merge2048.start(container,{mission,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════ */
(function(){
  var N=4;
  var root,opts=null,running=false,busy=false;
  var grid=[],score=0,best=0,targetTile=128,lvl=1,tileId=0;
  var _board,_cell=72,_score,_targetEl;

  function lvlOf(m){ if(m&&m.lvl)return m.lvl; if(m&&m.chapter)return m.chapter*2-1; return 1; }
  var idx=function(x,y){return y*N+x;};

  /* стиль номинала: сталь → синий → зелёный → янтарь → кармин → радуга */
  function tileStyle(v){
    var T={
      2:   ['#2a2e37','#171a20','#cfd8e3'],
      4:   ['#343a46','#1b1f27','#e6edf5'],
      8:   ['#1f4e6e','#0d2a40','#9fdcff'],
      16:  ['#2a6a94','#123449','#d6f2ff'],
      32:  ['#1c6e4b','#0b3a26','#a9f0cf'],
      64:  ['#23955f','#0e4a2e','#e2ffef'],
      128: ['#9a6a18','#4d3106','#ffe9b0'],
      256: ['#c68a1e','#5e4008','#fff3d0'],
      512: ['#8e1e36','#460e1b','#ffc4d1'],
      1024:['#c13350','#5e1526','#ffe0e6'],
      2048:['#e0546e','#8e1e36','#ffffff']
    };
    var t=T[v]||T[2048];
    return 'background:linear-gradient(165deg,'+t[0]+','+t[1]+');color:'+t[2]+';';
  }
  function tileGlow(v){
    if(v>=2048) return 'box-shadow:0 0 22px rgba(224,84,110,.8),inset 0 1px 0 rgba(255,255,255,.2);';
    if(v>=512) return 'box-shadow:0 0 16px rgba(224,84,110,.5),inset 0 1px 0 rgba(255,255,255,.14);';
    if(v>=128) return 'box-shadow:0 0 14px rgba(255,207,107,.4),inset 0 1px 0 rgba(255,255,255,.12);';
    if(v>=32)  return 'box-shadow:0 0 12px rgba(70,216,155,.35),inset 0 1px 0 rgba(255,255,255,.1);';
    if(v>=8)   return 'box-shadow:0 0 10px rgba(92,208,255,.3),inset 0 1px 0 rgba(255,255,255,.1);';
    return 'box-shadow:inset 0 1px 0 rgba(255,255,255,.08),0 3px 8px rgba(0,0,0,.4);';
  }

  function injectCSS(){
    if(document.getElementById('mg2-css')) return;
    var s=document.createElement('style'); s.id='mg2-css';
    s.textContent=
    '.mg2-root{position:absolute;inset:0;display:flex;flex-direction:column;overflow:hidden;'+
      'background:radial-gradient(circle at 50% 18%,#16141a,#050507);font-family:Manrope,sans-serif;'+
      'color:#e8e2d4;touch-action:none;user-select:none;-webkit-user-select:none;}'+
    '.mg2-top{flex:0 0 auto;margin:10px 12px 6px;display:flex;gap:8px;}'+
    '.mg2-chip{flex:1;padding:7px 12px;border-radius:14px;display:flex;flex-direction:column;align-items:center;gap:1px;'+
      'background:linear-gradient(165deg,rgba(26,22,28,.93),rgba(10,8,12,.97));border:1px solid #000;'+
      'box-shadow:0 8px 18px rgba(0,0,0,.55),inset 0 1px 0 rgba(255,255,255,.09);}'+
    '.mg2-chip .l{font:700 8px Unbounded,sans-serif;letter-spacing:.12em;color:#93a1b3;}'+
    '.mg2-chip .n{font:900 19px Unbounded,sans-serif;color:#fff;font-variant-numeric:tabular-nums;}'+
    '.mg2-chip.tgt .n{color:#ff8fa8;text-shadow:0 0 12px rgba(224,84,110,.5);}'+
    '.mg2-stage{flex:1 1 auto;display:flex;align-items:center;justify-content:center;min-height:0;position:relative;}'+
    '.mg2-board{position:relative;border-radius:16px;padding:5px;border:1px solid #000;'+
      'background:linear-gradient(160deg,rgba(33,32,38,.93),rgba(9,9,12,.95) 60%,rgba(0,0,0,.97));'+
      'box-shadow:inset 0 0 34px rgba(0,0,0,.6),0 16px 38px rgba(0,0,0,.65),0 0 0 1px rgba(255,255,255,.06);}'+
    '.mg2-cellbg{position:absolute;border-radius:10px;background:rgba(255,255,255,.035);box-shadow:inset 0 1px 3px rgba(0,0,0,.55);}'+
    '.mg2-tile{position:absolute;border-radius:10px;display:flex;align-items:center;justify-content:center;'+
      'font-family:Unbounded,sans-serif;font-weight:900;border:1px solid rgba(0,0,0,.85);will-change:transform;'+
      'transition:transform .13s cubic-bezier(.3,1,.4,1);}'+
    '.mg2-tile::after{content:"";position:absolute;left:10%;right:10%;top:8%;height:26%;border-radius:8px;'+
      'background:linear-gradient(180deg,rgba(255,255,255,.16),transparent);pointer-events:none;}'+
    '.mg2-tile.spawn{animation:mg2Spawn .18s ease;}'+
    '@keyframes mg2Spawn{from{transform:scale(.4);opacity:0}}'+
    '.mg2-tile.bump{animation:mg2Bump .22s cubic-bezier(.3,1.6,.4,1);}'+
    '@keyframes mg2Bump{40%{scale:1.2}100%{scale:1}}'+
    '.mg2-hint{flex:0 0 auto;text-align:center;font-size:11px;color:#93a1b3;letter-spacing:.04em;'+
      'padding:6px 10px max(12px,env(safe-area-inset-bottom));}'+
    '.mg2-pts{position:absolute;z-index:7;pointer-events:none;transform:translate(-50%,0);'+
      'font:800 14px Unbounded,sans-serif;color:#fff;text-shadow:0 0 10px rgba(255,255,255,.7),0 2px 4px #000;'+
      'animation:mg2Pts .7s ease-out forwards;}'+
    '@keyframes mg2Pts{0%{opacity:0}20%{opacity:1}100%{opacity:0;transform:translate(-50%,-28px)}}'+
    '.mg2-flash{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;z-index:9;'+
      'background:rgba(8,8,11,.84);font:800 21px Unbounded,sans-serif;letter-spacing:.08em;animation:mg2Fade .4s;}'+
    '@keyframes mg2Fade{from{opacity:0}to{opacity:1}}';
    document.head.appendChild(s);
  }

  function build(container){
    root=document.createElement('div'); root.className='mg2-root';
    root.innerHTML=
      '<div class="mg2-top">'+
        '<div class="mg2-chip"><span class="l">ОЧКИ</span><span class="n" id="mg2-sc">0</span></div>'+
        '<div class="mg2-chip tgt"><span class="l">ЦЕЛЬ — ПЛИТКА</span><span class="n" id="mg2-tg">'+targetTile+'</span></div>'+
      '</div>'+
      '<div class="mg2-stage"><div class="mg2-board" id="mg2-board"></div></div>'+
      '<div class="mg2-hint">Свайпай — одинаковые факты сливаются в вывод</div>';
    container.innerHTML=''; container.appendChild(root);
    _board=root.querySelector('#mg2-board');
    _score=root.querySelector('#mg2-sc');
    _targetEl=root.querySelector('#mg2-tg');
    var st=root.querySelector('.mg2-stage').getBoundingClientRect();
    var avail=Math.min(st.width,st.height)-18;
    _cell=Math.max(56,Math.floor(avail/N));
    var px=_cell*N;
    _board.style.width=px+'px'; _board.style.height=px+'px';
    for(var y=0;y<N;y++)for(var x=0;x<N;x++){
      var c=document.createElement('div'); c.className='mg2-cellbg';
      c.style.left=(x*_cell+7)+'px'; c.style.top=(y*_cell+7)+'px';
      c.style.width=(_cell-9)+'px'; c.style.height=(_cell-9)+'px';
      _board.appendChild(c);
    }
    bindInput();
  }

  function fontFor(v){ return v>=1024?(_cell*0.3):(v>=128?(_cell*0.36):(_cell*0.42)); }
  function placeTile(t,animate){
    var el=t.el;
    el.style.width=(_cell-9)+'px'; el.style.height=(_cell-9)+'px';
    el.style.fontSize=fontFor(t.v)+'px';
    el.style.transform='translate3d('+(t.x*_cell+7)+'px,'+(t.y*_cell+7)+'px,0)';
    if(animate==='spawn') el.classList.add('spawn');
  }
  function mkTile(x,y,v){
    var t={id:++tileId,x:x,y:y,v:v,el:document.createElement('div')};
    t.el.className='mg2-tile'; t.el.textContent=v;
    t.el.style.cssText+=tileStyle(v)+tileGlow(v);
    _board.appendChild(t.el);
    grid[idx(x,y)]=t;
    placeTile(t,'spawn');
    return t;
  }
  function restyle(t){
    t.el.textContent=t.v;
    t.el.style.cssText+=tileStyle(t.v)+tileGlow(t.v);
    t.el.style.fontSize=fontFor(t.v)+'px';
    t.el.classList.remove('bump'); void t.el.offsetWidth; t.el.classList.add('bump');
  }
  function spawn(){
    var free=[]; for(var k=0;k<N*N;k++) if(!grid[k]) free.push(k);
    if(!free.length) return null;
    var k=free[(Math.random()*free.length)|0];
    return mkTile(k%N,(k/N)|0, Math.random()<0.9?2:4);
  }

  function bindInput(){
    var sx=0,sy=0,down=false;
    root.addEventListener('pointerdown',function(e){ down=true; sx=e.clientX; sy=e.clientY; });
    root.addEventListener('pointerup',function(e){
      if(!down) return; down=false;
      var dx=e.clientX-sx, dy=e.clientY-sy;
      if(Math.max(Math.abs(dx),Math.abs(dy))<24) return;
      var dir=Math.abs(dx)>Math.abs(dy)?(dx>0?'right':'left'):(dy>0?'down':'up');
      move(dir);
    });
    window.addEventListener('keydown',keyMove);
  }
  function keyMove(e){
    var M={ArrowLeft:'left',ArrowRight:'right',ArrowUp:'up',ArrowDown:'down'};
    if(M[e.key]&&running){ e.preventDefault(); move(M[e.key]); }
  }

  function move(dir){
    if(!running||busy) return;
    var vx=dir==='left'?-1:dir==='right'?1:0;
    var vy=dir==='up'?-1:dir==='down'?1:0;
    var xs=[],ys=[];
    for(var i=0;i<N;i++){ xs.push(vx>0?N-1-i:i); ys.push(vy>0?N-1-i:i); }
    var moved=false, merges=[], gained=0;
    ys.forEach(function(y){ xs.forEach(function(x){
      var t=grid[idx(x,y)]; if(!t) return;
      var nx=x,ny=y;
      while(true){
        var tx=nx+vx,ty=ny+vy;
        if(tx<0||tx>=N||ty<0||ty>=N) break;
        var o=grid[idx(tx,ty)];
        if(!o){ nx=tx; ny=ty; continue; }
        if(o.v===t.v&&!o.merged&&!t.merged){ nx=tx; ny=ty; }
        break;
      }
      if(nx===x&&ny===y) return;
      var dest=grid[idx(nx,ny)];
      grid[idx(x,y)]=null;
      if(dest){ // слияние
        dest.merged=true; grid[idx(nx,ny)]=dest;
        t.x=nx; t.y=ny; placeTile(t);
        merges.push({eat:t,into:dest});
        gained+=dest.v*2;
      } else {
        t.x=nx; t.y=ny; grid[idx(nx,ny)]=t; placeTile(t);
      }
      moved=true;
    }); });
    if(!moved){ try{Sound.error&&Sound.error();}catch(_){} return; }
    busy=true;
    try{ Sound.gemSwap&&Sound.gemSwap(); navigator.vibrate&&navigator.vibrate(6); }catch(_){}
    setTimeout(function(){
      var newBest=best;
      merges.forEach(function(m){
        if(m.eat.el.parentNode)m.eat.el.parentNode.removeChild(m.eat.el);
        m.into.v*=2; m.into.merged=false; restyle(m.into);
        newBest=Math.max(newBest,m.into.v);
        var d=document.createElement('div'); d.className='mg2-pts'; d.textContent='+'+m.into.v;
        d.style.left=(m.into.x*_cell+_cell/2)+'px'; d.style.top=(m.into.y*_cell)+'px';
        _board.appendChild(d); setTimeout(function(){ if(d.parentNode)d.parentNode.removeChild(d); },720);
      });
      if(merges.length){
        score+=gained;
        try{ (gained>=64?Sound.approve:Sound.coin)&&(gained>=64?Sound.approve():Sound.coin()); }catch(_){}
      }
      if(newBest>best){ best=newBest;
        if(best>=32){ try{ Sound.starChime&&Sound.starChime(); }catch(_){} } }
      _score.textContent=score;
      spawn();
      busy=false;
      if(best>=targetTile){ win(); return; }
      if(!anyMove()) lose();
    },140);
  }
  function anyMove(){
    for(var k=0;k<N*N;k++) if(!grid[k]) return true;
    for(var y=0;y<N;y++)for(var x=0;x<N;x++){
      var t=grid[idx(x,y)];
      if(x+1<N&&grid[idx(x+1,y)].v===t.v) return true;
      if(y+1<N&&grid[idx(x,y+1)].v===t.v) return true;
    }
    return false;
  }

  function flash(col,msg,sub){
    var o=document.createElement('div'); o.className='mg2-flash'; o.style.color=col;
    o.innerHTML='<div style="text-align:center">'+msg+(sub?'<div style="font:600 12px Manrope,sans-serif;color:#93a1b3;margin-top:8px">'+sub+'</div>':'')+'</div>';
    root.appendChild(o);
  }
  function win(){ if(!running)return; running=false;
    try{ Sound.win&&Sound.win(); navigator.vibrate&&navigator.vibrate([10,40,10,40]); }catch(_){}
    flash('#46d89b','ВЫВОД СДЕЛАН','Факты сложились: '+best+'.');
    setTimeout(function(){ opts&&opts.onWin&&opts.onWin(); },900); }
  function lose(){ if(!running)return; running=false;
    try{ Sound.deny&&Sound.deny(); }catch(_){}
    flash('#ff6470','ТУПИК','Версии исчерпаны. Начни заново.');
    setTimeout(function(){ opts&&opts.onLose&&opts.onLose(); },900); }

  function start(container,o){
    opts=o||{}; running=true; busy=false; score=0; best=0; tileId=0;
    lvl=lvlOf(opts.mission);
    targetTile=64<<Math.min(3,((lvl-1)/2)|0);   // 64 → 128 → 256 → 512
    grid=new Array(N*N).fill(null);
    injectCSS(); build(container);
    spawn(); spawn();
  }
  function stop(){ running=false; window.removeEventListener('keydown',keyMove); }

  window.Merge2048={ start:start, stop:stop,
    _dbg:{
      move:move,
      grid:function(){ return grid.map(function(t){return t?t.v:0;}); },
      state:function(){ return {score:score,best:best,target:targetTile}; },
      setAt:function(x,y,v){ var old=grid[idx(x,y)];
        if(old&&old.el.parentNode)old.el.parentNode.removeChild(old.el);
        grid[idx(x,y)]=null; if(v) mkTile(x,y,v); }
    } };
})();
