/* ═══════════════════════════════════════════════════════
   СДВИГ · «АРХИВ» — блок-пазл (формат Block Blast / Woodoku).
   Перетаскивай папки-фигуры на полку 8×8. Полный ряд или
   колонка схлопывается. Набери цель очков. Нет места — провал.
   Контракт: Blocks.start(container,{mission,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════ */
(function(){
  var N=8;
  var root,opts=null,running=false;
  var grid=[],tray=[],score=0,target=600,lvl=1,combo=0;
  var _board,_tray,_fill,_score,_stars,_cell=38,_tiles=null;
  var drag=null; // {slot,piece,el,ok,gx,gy}

  var HUES=[
    {c1:'#ff6d7c',c2:'#a51f2c',glow:'#ff5d6c'},
    {c1:'#5fc6ff',c2:'#155e8a',glow:'#5cd0ff'},
    {c1:'#5ce8ab',c2:'#10704c',glow:'#46d89b'},
    {c1:'#ffd06a',c2:'#9a6a18',glow:'#ffcf6b'},
    {c1:'#c09aff',c2:'#5a3fb0',glow:'#a98bff'}
  ];
  var SHAPES=[
    [[0,0]],
    [[0,0],[1,0]],[[0,0],[0,1]],
    [[0,0],[1,0],[2,0]],[[0,0],[0,1],[0,2]],
    [[0,0],[1,0],[2,0],[3,0]],[[0,0],[0,1],[0,2],[0,3]],
    [[0,0],[1,0],[2,0],[3,0],[4,0]],[[0,0],[0,1],[0,2],[0,3],[0,4]],
    [[0,0],[1,0],[0,1],[1,1]],
    [[0,0],[1,0],[2,0],[0,1],[1,1],[2,1],[0,2],[1,2],[2,2]],
    [[0,0],[1,0],[0,1]],[[0,0],[1,0],[1,1]],[[0,0],[0,1],[1,1]],[[1,0],[0,1],[1,1]],
    [[0,0],[0,1],[0,2],[1,2]],[[1,0],[1,1],[1,2],[0,2]],[[0,0],[1,0],[0,1],[0,2]],[[0,0],[1,0],[1,1],[1,2]],
    [[0,0],[1,0],[2,0],[1,1]]
  ];
  var STARS=[0.4,0.7,1.0];
  var STAR_SVG='<svg viewBox="0 0 24 24"><path d="M12 2l3 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.9 21l1.2-6.8-5-4.9 6.9-1z"/></svg>';

  function lvlOf(m){ if(m&&m.lvl)return m.lvl; if(m&&m.chapter)return m.chapter*2-1; return 1; }
  var idx=function(x,y){return y*N+x;};

  function injectCSS(){
    if(document.getElementById('bk-css')) return;
    var s=document.createElement('style'); s.id='bk-css';
    s.textContent=
    '.bk-root{position:absolute;inset:0;display:flex;flex-direction:column;overflow:hidden;'+
      'background:radial-gradient(circle at 50% 18%,#16141a,#050507);font-family:Manrope,sans-serif;'+
      'color:#e8e2d4;touch-action:none;user-select:none;-webkit-user-select:none;}'+
    '.bk-top{flex:0 0 auto;margin:10px 12px 6px;padding:7px 12px;border-radius:14px;display:flex;flex-direction:column;gap:6px;'+
      'background:linear-gradient(165deg,rgba(26,22,28,.93),rgba(10,8,12,.97));border:1px solid #000;'+
      'box-shadow:0 8px 18px rgba(0,0,0,.55),inset 0 1px 0 rgba(255,255,255,.09);}'+
    '.bk-goalrow{display:flex;align-items:center;gap:8px;font-family:Unbounded,sans-serif;}'+
    '.bk-goalico{width:22px;height:22px;flex:0 0 auto;}'+
    '.bk-goaltxt{font-weight:700;font-size:12px;color:#e6edf5;letter-spacing:.03em;}'+
    '.bk-track{position:relative;height:8px;border-radius:6px;background:rgba(255,255,255,.08);margin-right:10px;'+
      'box-shadow:inset 0 1px 2px rgba(0,0,0,.5);}'+
    '.bk-fill{height:100%;border-radius:6px;background:linear-gradient(90deg,#2a9d6f,#46d89b);'+
      'transition:width .35s cubic-bezier(.3,1,.4,1);box-shadow:0 0 8px rgba(70,216,155,.45);}'+
    '.bk-star{position:absolute;top:50%;width:18px;height:18px;color:#3a3f48;transform:translate(-50%,-50%);transition:color .3s;}'+
    '.bk-star svg{width:100%;height:100%;fill:currentColor;stroke:#0a0c10;stroke-width:1.2;}'+
    '.bk-star.on{color:#46d89b;filter:drop-shadow(0 0 6px rgba(70,216,155,.8));transform:translate(-50%,-50%) scale(1.15);}'+
    '.bk-stage{flex:1 1 auto;display:flex;align-items:center;justify-content:center;min-height:0;position:relative;}'+
    '.bk-board{position:relative;border-radius:14px;padding:3px;border:1px solid #000;'+
      'background:linear-gradient(160deg,rgba(33,32,38,.93),rgba(9,9,12,.95) 60%,rgba(0,0,0,.97));'+
      'box-shadow:inset 0 0 34px rgba(0,0,0,.6),0 16px 38px rgba(0,0,0,.65),0 0 0 1px rgba(255,255,255,.06);}'+
    '.bk-cellbg{position:absolute;border-radius:7px;background:rgba(255,255,255,.022);box-shadow:inset 0 1px 2px rgba(0,0,0,.5);}'+
    '.bk-cellbg.alt{background:rgba(255,255,255,.055);}'+
    '.bk-cellbg.ok{background:rgba(70,216,155,.22);box-shadow:inset 0 0 8px rgba(70,216,155,.35);}'+
    '.bk-cellbg.okline{background:rgba(70,216,155,.38);}'+
    '.bk-tile{position:absolute;border-radius:7px;will-change:transform;'+
      'border:1px solid rgba(0,0,0,.8);'+
      'box-shadow:inset 0 2px 0 rgba(255,255,255,.22),inset 0 -3px 6px rgba(0,0,0,.4),0 2px 5px rgba(0,0,0,.45);}'+
    '.bk-tile::after{content:"";position:absolute;left:12%;right:12%;top:14%;height:22%;border-radius:5px;'+
      'background:linear-gradient(180deg,rgba(255,255,255,.4),transparent);}'+
    '.bk-tile.ink{filter:saturate(.15) brightness(.6);}'+
    '.bk-tile.pop{animation:bkPop .3s ease forwards;}'+
    '@keyframes bkPop{40%{transform:scale(1.15);filter:brightness(2)}100%{transform:scale(0);opacity:0}}'+
    '.bk-tile.land{animation:bkLand .18s cubic-bezier(.2,1.4,.4,1);}'+
    '@keyframes bkLand{0%{transform:scale(1.12)}100%{transform:scale(1)}}'+
    '.bk-tray{flex:0 0 auto;display:flex;justify-content:center;gap:16px;align-items:center;'+
      'padding:10px 10px max(12px,env(safe-area-inset-bottom));min-height:86px;}'+
    '.bk-slot{position:relative;width:92px;height:76px;display:flex;align-items:center;justify-content:center;'+
      'border-radius:14px;background:linear-gradient(165deg,rgba(26,22,28,.9),rgba(10,8,12,.96));'+
      'border:1px solid #000;box-shadow:0 6px 16px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.07);}'+
    '.bk-slot.empty{opacity:.35;}'+
    '.bk-slot svg{pointer-events:none;}'+
    '.bk-slot.dead{opacity:.5;}'+
    '.bk-slot.dead svg{filter:saturate(.2) brightness(.55);}'+
    '.bk-drag{position:fixed;z-index:99;pointer-events:none;filter:drop-shadow(0 10px 18px rgba(0,0,0,.6));}'+
    '.bk-pts{position:absolute;z-index:7;pointer-events:none;transform:translate(-50%,0);'+
      'font:800 15px Unbounded,sans-serif;color:#fff;text-shadow:0 0 10px rgba(255,255,255,.7),0 2px 4px #000;'+
      'animation:bkPts .8s ease-out forwards;}'+
    '@keyframes bkPts{0%{opacity:0;transform:translate(-50%,4px) scale(.7)}18%{opacity:1;transform:translate(-50%,-4px) scale(1.15)}'+
      '100%{opacity:0;transform:translate(-50%,-32px)}}'+
    '.bk-combo{position:absolute;top:34%;left:0;right:0;text-align:center;pointer-events:none;z-index:7;'+
      'font:900 26px Unbounded,sans-serif;color:#ff8fa8;text-shadow:0 0 22px #8e1e36;animation:bkCombo 1s ease forwards;}'+
    '@keyframes bkCombo{0%{opacity:0;transform:translateY(10px) scale(.8)}25%{opacity:1;transform:none}100%{opacity:0;transform:translateY(-24px)}}'+
    '.bk-lineflash{position:absolute;z-index:6;pointer-events:none;border-radius:8px;'+
      'background:linear-gradient(90deg,transparent,rgba(255,255,255,.75),transparent);animation:bkLf .4s ease-out forwards;}'+
    '@keyframes bkLf{0%{opacity:0}30%{opacity:1}100%{opacity:0}}'+
    '.bk-flash{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;z-index:9;'+
      'background:rgba(8,8,11,.84);font:800 21px Unbounded,sans-serif;letter-spacing:.08em;animation:bkFade .4s;}'+
    '@keyframes bkFade{from{opacity:0}to{opacity:1}}';
    document.head.appendChild(s);
  }

  /* svg-рендер фигуры (для лотка и drag-призрака) */
  function pieceSVG(p,cell){
    var maxX=0,maxY=0;
    p.cells.forEach(function(c){ maxX=Math.max(maxX,c[0]); maxY=Math.max(maxY,c[1]); });
    var w=(maxX+1)*cell, h=(maxY+1)*cell, hu=HUES[p.hue];
    var r='';
    p.cells.forEach(function(c){
      var x=c[0]*cell,y=c[1]*cell;
      r+='<rect x="'+(x+1)+'" y="'+(y+1)+'" width="'+(cell-2)+'" height="'+(cell-2)+'" rx="5" '+
        'fill="url(#bkg'+p.hue+')" stroke="rgba(0,0,0,.8)"/>'+
        '<rect x="'+(x+cell*0.14)+'" y="'+(y+cell*0.14)+'" width="'+(cell*0.72)+'" height="'+(cell*0.24)+'" rx="4" fill="rgba(255,255,255,.32)"/>';
    });
    var defs='<defs><linearGradient id="bkg'+p.hue+'" x1="0" y1="0" x2="0" y2="1">'+
      '<stop offset="0%" stop-color="'+hu.c1+'"/><stop offset="100%" stop-color="'+hu.c2+'"/></linearGradient></defs>';
    return '<svg width="'+w+'" height="'+h+'" viewBox="0 0 '+w+' '+h+'">'+defs+r+'</svg>';
  }

  function newPiece(){ var si=(Math.random()*SHAPES.length)|0;
    return { cells:SHAPES[si], hue:(Math.random()*HUES.length)|0 }; }
  function refillTray(){ tray=[newPiece(),newPiece(),newPiece()]; }

  function build(container){
    root=document.createElement('div'); root.className='bk-root';
    var stars='';
    for(var i=0;i<3;i++) stars+='<span class="bk-star" data-i="'+i+'" style="left:'+(STARS[i]*100)+'%">'+STAR_SVG+'</span>';
    root.innerHTML=
      '<div class="bk-top">'+
        '<div class="bk-goalrow">'+
          '<span class="bk-goalico"><svg viewBox="0 0 24 24" style="width:100%;height:100%">'+
            '<rect x="3" y="5" width="18" height="15" rx="2.5" fill="none" stroke="#cfd8e3" stroke-width="1.8"/>'+
            '<path d="M3 9.5h18M8.5 5v15M14.5 5v15" stroke="#93a1b3" stroke-width="1.4"/>'+
            '<rect x="9.5" y="10.5" width="4" height="3" rx="1" fill="#e0546e"/></svg></span>'+
          '<span class="bk-goaltxt" id="bk-goal"></span>'+
        '</div>'+
        '<div class="bk-track"><div class="bk-fill" id="bk-fill" style="width:0%"></div>'+stars+'</div>'+
      '</div>'+
      '<div class="bk-stage"><div class="bk-board" id="bk-board"></div></div>'+
      '<div class="bk-tray" id="bk-tray"></div>';
    container.innerHTML=''; container.appendChild(root);
    _board=root.querySelector('#bk-board');
    _tray=root.querySelector('#bk-tray');
    _fill=root.querySelector('#bk-fill');
    _score=root.querySelector('#bk-goal');
    _stars=root.querySelectorAll('.bk-star');
    layout(); renderTray(); paint();
  }
  function layout(){
    var st=root.querySelector('.bk-stage').getBoundingClientRect();
    var avail=Math.min(st.width,st.height)-14;
    _cell=Math.max(28,Math.floor(avail/N));
    var px=_cell*N;
    _board.style.width=px+'px'; _board.style.height=px+'px';
    _board.innerHTML=''; _tiles={};
    for(var y=0;y<N;y++)for(var x=0;x<N;x++){
      var c=document.createElement('div');
      c.className='bk-cellbg'+(((x+y)%2)?' alt':''); c.dataset.k=idx(x,y);
      c.style.left=(x*_cell+2)+'px'; c.style.top=(y*_cell+2)+'px';
      c.style.width=(_cell-4)+'px'; c.style.height=(_cell-4)+'px';
      _board.appendChild(c);
    }
    for(var k=0;k<N*N;k++) if(grid[k]) addTileEl(k,grid[k]);
  }
  function addTileEl(k,cellVal){
    var x=k%N,y=(k/N)|0;
    var d=document.createElement('div'); d.className='bk-tile'+(cellVal.ink?' ink':'');
    var hu=HUES[cellVal.hue||0];
    d.style.cssText='left:'+(x*_cell+2)+'px;top:'+(y*_cell+2)+'px;width:'+(_cell-4)+'px;height:'+(_cell-4)+'px;'+
      'background:linear-gradient(180deg,'+hu.c1+','+hu.c2+');';
    _board.appendChild(d); _tiles[k]=d;
    return d;
  }

  function renderTray(){
    _tray.innerHTML='';
    tray.forEach(function(p,i){
      var slot=document.createElement('div'); slot.className='bk-slot'+(p?'':' empty'); slot.dataset.slot=i;
      if(p){
        var cell=Math.min(20, 68/Math.max.apply(null,p.cells.map(function(c){return Math.max(c[0],c[1])+1;})));
        slot.innerHTML=pieceSVG(p,cell);
        if(!canFitAnywhere(p)) slot.classList.add('dead');
        slot.addEventListener('pointerdown',function(e){ startDrag(e,i); });
      }
      _tray.appendChild(slot);
    });
  }

  function paint(){
    var pct=Math.min(100,Math.round(score/target*100));
    _fill.style.width=pct+'%';
    _score.textContent=score+' / '+target;
    var st=0; STARS.forEach(function(t){ if(score>=target*t)st++; });
    _stars.forEach(function(el,i){ el.classList.toggle('on',i<st); });
  }

  /* ── drag & drop ── */
  function startDrag(e,slot){
    if(!running||drag) return;
    var p=tray[slot]; if(!p) return;
    e.preventDefault();
    var el=document.createElement('div'); el.className='bk-drag';
    el.innerHTML=pieceSVG(p,_cell);
    document.body.appendChild(el);
    drag={slot:slot,piece:p,el:el,ok:false,gx:-1,gy:-1};
    moveDrag(e);
    window.addEventListener('pointermove',moveDrag);
    window.addEventListener('pointerup',endDrag);
    try{ Sound.tap&&Sound.tap(); }catch(_){}
  }
  function moveDrag(e){
    if(!drag) return;
    var maxX=0,maxY=0;
    drag.piece.cells.forEach(function(c){ maxX=Math.max(maxX,c[0]); maxY=Math.max(maxY,c[1]); });
    var w=(maxX+1)*_cell,h=(maxY+1)*_cell;
    // фигура над пальцем, чтобы её было видно
    var px=e.clientX-w/2, py=e.clientY-h-28;
    drag.el.style.left=px+'px'; drag.el.style.top=py+'px';
    // проекция на доску
    var br=_board.getBoundingClientRect();
    var gx=Math.round((px-br.left-2)/_cell), gy=Math.round((py-br.top-2)/_cell);
    drag.gx=gx; drag.gy=gy;
    drag.ok=canPlace(drag.piece,gx,gy);
    ghost();
  }
  function ghost(){
    _board.querySelectorAll('.bk-cellbg.ok,.bk-cellbg.okline').forEach(function(c){ c.classList.remove('ok','okline'); });
    if(!drag||!drag.ok) return;
    var cells=drag.piece.cells.map(function(c){ return idx(drag.gx+c[0],drag.gy+c[1]); });
    var lines=linesIfPlaced(cells);
    cells.forEach(function(k){
      var c=_board.querySelector('.bk-cellbg[data-k="'+k+'"]'); if(c)c.classList.add('ok');
    });
    lines.rows.concat(lines.cols).length&&cells.forEach(function(k){
      var x=k%N,y=(k/N)|0;
      if(lines.rows.indexOf(y)>=0||lines.cols.indexOf(x)>=0){
        var c=_board.querySelector('.bk-cellbg[data-k="'+k+'"]'); if(c)c.classList.add('okline');
      }
    });
  }
  function endDrag(e){
    window.removeEventListener('pointermove',moveDrag);
    window.removeEventListener('pointerup',endDrag);
    if(!drag) return;
    var d=drag; drag=null;
    if(d.el.parentNode)d.el.parentNode.removeChild(d.el);
    _board.querySelectorAll('.bk-cellbg.ok,.bk-cellbg.okline').forEach(function(c){ c.classList.remove('ok','okline'); });
    if(d.ok&&running){ place(d.piece,d.gx,d.gy,d.slot); }
  }

  function canPlace(p,gx,gy){
    for(var i=0;i<p.cells.length;i++){
      var x=gx+p.cells[i][0], y=gy+p.cells[i][1];
      if(x<0||x>=N||y<0||y>=N) return false;
      if(grid[idx(x,y)]) return false;
    }
    return true;
  }
  function canFitAnywhere(p){
    for(var y=0;y<N;y++)for(var x=0;x<N;x++) if(canPlace(p,x,y)) return true;
    return false;
  }
  function linesIfPlaced(cells){
    var g=grid.slice(); cells.forEach(function(k){ g[k]={hue:0}; });
    var rows=[],cols=[];
    for(var y=0;y<N;y++){ var full=true; for(var x=0;x<N;x++) if(!g[idx(x,y)]){full=false;break;} if(full)rows.push(y); }
    for(var x2=0;x2<N;x2++){ var f2=true; for(var y2=0;y2<N;y2++) if(!g[idx(x2,y2)]){f2=false;break;} if(f2)cols.push(x2); }
    return {rows:rows,cols:cols};
  }

  function place(p,gx,gy,slot){
    var cells=p.cells.map(function(c){ return idx(gx+c[0],gy+c[1]); });
    cells.forEach(function(k){
      grid[k]={hue:p.hue};
      var el=addTileEl(k,grid[k]); el.classList.add('land');
    });
    tray[slot]=null;
    score+=cells.length*10;
    try{ Sound.gemFall&&Sound.gemFall(); navigator.vibrate&&navigator.vibrate(8); }catch(_){}
    var lines=linesIfPlaced([]);
    var nLines=lines.rows.length+lines.cols.length;
    if(nLines>0){ clearLines(lines,cells[0]); combo++; }
    else combo=0;
    if(tray.every(function(t){return !t;})) refillTray();
    renderTray(); paint();
    if(score>=target){ win(); return; }
    // провал: ни одна оставшаяся фигура никуда не влезает
    var any=tray.some(function(t){ return t&&canFitAnywhere(t); });
    if(!any) lose();
  }

  function clearLines(lines,anchorK){
    var toClear={};
    lines.rows.forEach(function(y){ for(var x=0;x<N;x++) toClear[idx(x,y)]=1; });
    lines.cols.forEach(function(x){ for(var y=0;y<N;y++) toClear[idx(x,y)]=1; });
    var n=lines.rows.length+lines.cols.length;
    var gained=n*80+(n>1?(n-1)*60:0)+(combo>0?combo*40:0);
    score+=gained;
    // вспышки линий
    lines.rows.forEach(function(y){
      var f=document.createElement('div'); f.className='bk-lineflash';
      f.style.cssText='left:0;right:0;top:'+(y*_cell+2)+'px;height:'+(_cell-4)+'px;';
      _board.appendChild(f); setTimeout(function(){ if(f.parentNode)f.parentNode.removeChild(f); },420);
    });
    lines.cols.forEach(function(x){
      var f=document.createElement('div'); f.className='bk-lineflash';
      f.style.cssText='top:0;bottom:0;left:'+(x*_cell+2)+'px;width:'+(_cell-4)+'px;'+
        'background:linear-gradient(180deg,transparent,rgba(255,255,255,.75),transparent);';
      _board.appendChild(f); setTimeout(function(){ if(f.parentNode)f.parentNode.removeChild(f); },420);
    });
    Object.keys(toClear).forEach(function(k){
      k=+k; grid[k]=null;
      var el=_tiles[k];
      if(el){ el.classList.add('pop'); (function(e){ setTimeout(function(){ if(e.parentNode)e.parentNode.removeChild(e); },320); })(el); delete _tiles[k]; }
    });
    // очки всплывают
    var ax=anchorK%N, ay=(anchorK/N)|0;
    var d=document.createElement('div'); d.className='bk-pts'; d.textContent='+'+gained;
    d.style.left=(ax*_cell+_cell/2)+'px'; d.style.top=(ay*_cell)+'px';
    _board.appendChild(d); setTimeout(function(){ if(d.parentNode)d.parentNode.removeChild(d); },820);
    if(n>1||combo>1){
      var cb=document.createElement('div'); cb.className='bk-combo';
      cb.textContent=(n>1?'Двойная линия!':'Серия ×'+combo);
      root.querySelector('.bk-stage').appendChild(cb);
      setTimeout(function(){ if(cb.parentNode)cb.parentNode.removeChild(cb); },1000);
    }
    try{ Sound.lineBlast?Sound.lineBlast():(Sound.gemMatch&&Sound.gemMatch(3)); navigator.vibrate&&navigator.vibrate([10,30]); }catch(_){}
  }

  function flash(col,msg,sub){
    var o=document.createElement('div'); o.className='bk-flash'; o.style.color=col;
    o.innerHTML='<div style="text-align:center">'+msg+(sub?'<div style="font:600 12px Manrope,sans-serif;color:#93a1b3;margin-top:8px">'+sub+'</div>':'')+'</div>';
    root.appendChild(o);
  }
  function win(){ if(!running)return; running=false;
    try{ Sound.win&&Sound.win(); navigator.vibrate&&navigator.vibrate([10,40,10,40]); }catch(_){}
    flash('#46d89b','АРХИВ СОБРАН','Каждая папка на месте.');
    setTimeout(function(){ opts&&opts.onWin&&opts.onWin(); },900); }
  function lose(){ if(!running)return; running=false;
    try{ Sound.deny&&Sound.deny(); }catch(_){}
    flash('#ff6470','МЕСТА НЕТ','Полки забиты. Дело развалилось.');
    setTimeout(function(){ opts&&opts.onLose&&opts.onLose(); },900); }

  function start(container,o){
    opts=o||{}; running=true; drag=null; combo=0; score=0;
    lvl=lvlOf(opts.mission);
    target=(opts.mission&&opts.mission.target&&opts.mission.type==='score')?opts.mission.target:(300+lvl*120);
    grid=new Array(N*N).fill(null);
    // «кляксы» на старших уровнях — мешают, чистятся линиями
    if(lvl>=4){
      var n=Math.min(10,(lvl-3)*2);
      var cand=[]; for(var k=0;k<N*N;k++)cand.push(k);
      cand.sort(function(){return Math.random()-0.5;});
      for(var i=0;i<n;i++) grid[cand[i]]={hue:(Math.random()*HUES.length)|0,ink:true};
    }
    refillTray();
    injectCSS(); build(container);
  }
  function stop(){ running=false;
    window.removeEventListener('pointermove',moveDrag);
    window.removeEventListener('pointerup',endDrag);
    if(drag&&drag.el&&drag.el.parentNode)drag.el.parentNode.removeChild(drag.el); drag=null; }

  window.Blocks={ start:start, stop:stop,
    _dbg:{
      state:function(){ return {score:score,target:target,grid:grid.map(function(g){return g?1:0;})}; },
      tray:function(){ return tray.map(function(t){ return t?t.cells.length:0; }); },
      put:function(slot,x,y){ var p=tray[slot]; if(p&&canPlace(p,x,y)){ place(p,x,y,slot); return true;} return false; },
      fillRowExcept:function(y,exceptX){ for(var x=0;x<N;x++){ if(x===exceptX)continue; var k=idx(x,y);
        if(!grid[k]){ grid[k]={hue:0}; addTileEl(k,grid[k]); } } },
      setTray:function(cells){ tray[0]={cells:cells,hue:0}; tray[1]=null; tray[2]=null; renderTray(); },
      fillAll:function(){ for(var k=0;k<N*N;k++){ if(!grid[k]){ grid[k]={hue:1}; addTileEl(k,grid[k]); } } renderTray(); }
    } };
})();
