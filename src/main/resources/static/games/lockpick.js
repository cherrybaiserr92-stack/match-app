/* ═══════════════════════════════════════════════════════
   СДВИГ · Мини-игра «ВЗЛОМ» (головоломка с ходами)
   Контракт: Lockpick.start(container,{mission,onWin,onLose}) / .stop()
   Подбери комбинацию замка за N ходов. После каждой попытки —
   подсказки: цифра на месте (●) или есть, но не там (○).
═══════════════════════════════════════════════════════ */
(function(){
  var root,opts=null,running=false;
  var LEN=3, DIGITS=6, code=[], guesses=[], cur=[], movesLeft=0, maxMoves=8;

  function rnd(n){return (Math.random()*n)|0;}

  function genCode(){
    code=[];
    for(var i=0;i<LEN;i++) code.push(rnd(DIGITS)+1);
  }

  // подсказки: how many exact (right digit & place), how many present (right digit wrong place)
  function evaluate(g){
    var exact=0,present=0;
    var cc=code.slice(), gg=g.slice();
    // точные
    for(var i=0;i<LEN;i++){ if(gg[i]===cc[i]){ exact++; cc[i]=-1; gg[i]=-2; } }
    // присутствует не на месте
    for(var i=0;i<LEN;i++){
      if(gg[i]<0) continue;
      var idx=cc.indexOf(gg[i]);
      if(idx>=0){ present++; cc[idx]=-1; }
    }
    return {exact:exact,present:present};
  }

  function render(){
    var rows='';
    for(var r=0;r<guesses.length;r++){
      var g=guesses[r];
      var cells='';
      for(var i=0;i<LEN;i++){
        cells+='<div class="lp-cell lp-past">'+g.val[i]+'</div>';
      }
      // пины подсказок
      var pins='';
      for(var e=0;e<g.res.exact;e++) pins+='<span class="lp-pin lp-exact"></span>';
      for(var p=0;p<g.res.present;p++) pins+='<span class="lp-pin lp-present"></span>';
      for(var m=0;m<LEN-g.res.exact-g.res.present;m++) pins+='<span class="lp-pin lp-miss"></span>';
      rows+='<div class="lp-row">'+cells+'<div class="lp-pins">'+pins+'</div></div>';
    }
    // текущая строка ввода
    var curCells='';
    for(var i=0;i<LEN;i++){
      curCells+='<div class="lp-cell lp-cur'+(cur[i]?'':' lp-empty')+'" data-pos="'+i+'">'+(cur[i]||'·')+'</div>';
    }
    var pad='';
    for(var d=1;d<=DIGITS;d++) pad+='<button class="lp-key" data-d="'+d+'">'+d+'</button>';

    root.innerHTML=
      '<div class="lp-wrap">'+
        '<div class="lp-head"><span class="lp-title">ВЗЛОМ ЗАМКА</span>'+
          '<span class="lp-moves">Ходов: <b>'+movesLeft+'</b></span></div>'+
        '<div class="lp-board">'+rows+
          '<div class="lp-row lp-active">'+curCells+'<div class="lp-pins"></div></div>'+
        '</div>'+
        '<div class="lp-legend">● на месте&nbsp;&nbsp;○ есть, не там&nbsp;&nbsp;· мимо</div>'+
        '<div class="lp-pad">'+pad+'</div>'+
        '<div class="lp-actions">'+
          '<button class="lp-clear" id="lp-clear">Сброс</button>'+
          '<button class="lp-try" id="lp-try">Проверить</button>'+
        '</div>'+
      '</div>';

    // обработчики
    root.querySelectorAll('.lp-key').forEach(function(b){
      b.onclick=function(){ addDigit(parseInt(this.getAttribute('data-d'),10)); };
    });
    root.querySelector('#lp-clear').onclick=function(){ cur=[]; render(); };
    root.querySelector('#lp-try').onclick=tryGuess;
  }

  function addDigit(d){
    if(cur.length>=LEN){ cur=[]; }
    cur.push(d); render();
  }

  function tryGuess(){
    if(cur.length<LEN){ shake(); return; }
    var res=evaluate(cur);
    guesses.push({val:cur.slice(),res:res});
    movesLeft--;
    try{navigator.vibrate&&navigator.vibrate(15);}catch(_){}
    if(res.exact===LEN){ cur=[]; render(); win(); return; }
    cur=[];
    if(movesLeft<=0){ render(); lose(); return; }
    render();
  }

  function shake(){
    var a=root.querySelector('.lp-active');
    if(a){ a.style.animation='lpShake .3s'; setTimeout(function(){a.style.animation='';},300); }
  }

  function win(){ running=false; flash('#46d89b','ЗАМОК ОТКРЫТ'); setTimeout(function(){opts&&opts.onWin&&opts.onWin();},800); }
  function lose(){ running=false; flash('#d84646','ЗАКЛИНИЛО'); setTimeout(function(){opts&&opts.onLose&&opts.onLose();},800); }

  function flash(col,msg){
    var o=document.createElement('div');
    o.style.cssText='position:absolute;inset:0;display:flex;align-items:center;justify-content:center;'+
      'background:rgba(8,8,11,.8);color:'+col+';font:800 22px Unbounded,sans-serif;letter-spacing:.1em;'+
      'border-radius:14px;z-index:5;animation:lpFade .4s;';
    o.textContent=msg; root.appendChild(o);
  }

  function injectCSS(){
    if(document.getElementById('lp-css')) return;
    var s=document.createElement('style'); s.id='lp-css';
    s.textContent=
    '.lp-wrap{position:relative;width:100%;max-width:380px;margin:0 auto;color:#e8e2d4;font-family:Inter,sans-serif;padding:8px;}'+
    '.lp-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;}'+
    '.lp-title{font:800 14px Unbounded,sans-serif;letter-spacing:.12em;color:#ffcf6b;}'+
    '.lp-moves{font-size:13px;color:#9aa8b8;}.lp-moves b{color:#fff;}'+
    '.lp-board{display:flex;flex-direction:column;gap:7px;margin-bottom:12px;min-height:40px;}'+
    '.lp-row{display:flex;align-items:center;gap:8px;}'+
    '.lp-cell{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;justify-content:center;'+
      'font:700 20px "Playfair Display",serif;background:rgba(0,0,0,.3);border:1px solid rgba(255,255,255,.08);}'+
    '.lp-past{background:rgba(200,134,10,.12);border-color:rgba(200,134,10,.25);color:#e0b057;}'+
    '.lp-cur{border-color:rgba(200,134,10,.4);background:rgba(0,0,0,.4);}'+
    '.lp-empty{color:#46506080;}'+
    '.lp-active .lp-cell{border-color:rgba(200,134,10,.5);}'+
    '.lp-pins{display:flex;flex-wrap:wrap;gap:3px;width:34px;margin-left:4px;}'+
    '.lp-pin{width:9px;height:9px;border-radius:50%;}'+
    '.lp-exact{background:#46d89b;}.lp-present{background:#ffcf6b;}'+
    '.lp-miss{background:rgba(255,255,255,.12);}'+
    '.lp-legend{font-size:11px;color:#7a8494;text-align:center;margin-bottom:14px;}'+
    '.lp-pad{display:grid;grid-template-columns:repeat(6,1fr);gap:7px;margin-bottom:12px;}'+
    '.lp-key{aspect-ratio:1;border:none;border-radius:10px;background:linear-gradient(135deg,#2a2620,#1a1714);'+
      'color:#e0b057;font:700 18px "Playfair Display",serif;cursor:pointer;border:1px solid rgba(200,134,10,.2);'+
      'transition:transform .1s;}'+
    '.lp-key:active{transform:scale(.92);background:rgba(200,134,10,.25);}'+
    '.lp-actions{display:flex;gap:10px;}'+
    '.lp-clear,.lp-try{flex:1;padding:13px;border:none;border-radius:12px;font:700 14px Inter,sans-serif;cursor:pointer;}'+
    '.lp-clear{background:rgba(255,255,255,.06);color:#9aa8b8;}'+
    '.lp-try{background:linear-gradient(135deg,#c8860a,#a06d08);color:#fff;}'+
    '.lp-try:active,.lp-clear:active{transform:scale(.97);}'+
    '@keyframes lpShake{0%,100%{transform:translateX(0)}25%{transform:translateX(-6px)}75%{transform:translateX(6px)}}'+
    '@keyframes lpFade{from{opacity:0}to{opacity:1}}';
    document.head.appendChild(s);
  }

  function start(container,o){
    opts=o||{}; running=true;
    LEN=3; DIGITS=6; maxMoves=8;
    // сложность от миссии
    if(opts.mission&&opts.mission.target){
      if(opts.mission.target>=16){ LEN=4; maxMoves=9; }
    }
    movesLeft=maxMoves; guesses=[]; cur=[];
    genCode();
    injectCSS();
    root=document.createElement('div');
    root.style.cssText='position:relative;width:100%;height:100%;display:flex;align-items:center;justify-content:center;min-height:380px;';
    container.innerHTML=''; container.appendChild(root);
    render();
  }
  function stop(){ running=false; }

  window.Lockpick={start:start,stop:stop};
})();
