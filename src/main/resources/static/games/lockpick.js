/* ═══════════════════════════════════════════════════════
   СДВИГ · Мини-игра «ВЗЛОМ» (головоломка с ходами)
   Контракт: Lockpick.start(container,{mission,onWin,onLose}) / .stop()
   Подбери комбинацию замка за N ходов. После каждой попытки —
   подсказки: цифра на месте (●) или есть, но не там (○).
═══════════════════════════════════════════════════════ */
(function(){
  var root,opts=null,running=false;
  var LEN=3, DIGITS=6, code=[], guesses=[], cur=[], movesLeft=0, maxMoves=8, dialRot=0;

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

    var ticks='';
    for(var t=0;t<36;t++){ var ta=t*10; ticks+='<line x1="50" y1="8" x2="50" y2="'+(t%6===0?15:11.5)+'" transform="rotate('+ta+' 50 50)"/>'; }
    var nums='';
    for(var nd=1;nd<=DIGITS;nd++){ var na=(nd-1)*(360/DIGITS);
      nums+='<text x="50" y="24" transform="rotate('+na+' 50 50)" text-anchor="middle" class="ld-num">'+nd+'</text>'; }
    var rivets='';
    for(var rv=0;rv<6;rv++){ var rva=rv*60+30;
      rivets+='<circle cx="50" cy="11" r="1.8" transform="rotate('+rva+' 50 50)" class="ld-rivet"/>'; }
    root.innerHTML=
      '<div class="lp-wrap">'+
        '<div class="lp-dialwrap">'+
          '<svg class="lp-dial" viewBox="0 0 100 100" style="transform:rotate('+dialRot+'deg)">'+
            '<circle cx="50" cy="50" r="47" class="ld-outer"/>'+
            '<circle cx="50" cy="50" r="42" class="ld-rim"/>'+
            rivets+
            '<circle cx="50" cy="50" r="31" class="ld-face"/>'+
            '<g class="ld-ticks">'+ticks+'</g>'+nums+
            '<circle cx="50" cy="50" r="10" class="ld-hub"/>'+
            '<circle cx="50" cy="50" r="4.5" class="ld-hub2"/>'+
          '</svg>'+
          '<svg class="lp-pointer" viewBox="0 0 100 100"><polygon points="50,2 44,14 56,14" class="ld-arrow"/></svg>'+
        '</div>'+
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
    cur.push(d);
    // довести цифру d под стрелку: несколько лишних оборотов для веса
    var targetAng=-(d-1)*(360/DIGITS);
    var spins=(cur.length%2? -360:360)*1;
    dialRot = Math.round(dialRot/360)*360 + spins + targetAng;
    try{navigator.vibrate&&navigator.vibrate(6);}catch(_){}
    render();
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

  function win(){ running=false; dialRot+=360; var dl=root.querySelector('.lp-dial'); if(dl){dl.style.transform='rotate('+dialRot+'deg)';} flash('#46d89b','ЗАМОК ОТКРЫТ'); setTimeout(function(){opts&&opts.onWin&&opts.onWin();},800); }
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
    '.lp-wrap{position:relative;width:100%;max-width:380px;margin:0 auto;color:#e8e2d4;font-family:Manrope,sans-serif;padding:8px;}'+'.lp-dialwrap{position:relative;display:flex;justify-content:center;margin-bottom:12px;}'+'.lp-dial{width:150px;height:150px;transition:transform .65s cubic-bezier(.25,1.2,.4,1);filter:drop-shadow(0 10px 22px rgba(0,0,0,.65));}'+'.lp-pointer{position:absolute;top:0;left:50%;width:150px;height:150px;transform:translateX(-50%);pointer-events:none;filter:drop-shadow(0 2px 3px rgba(0,0,0,.6));}'+'.ld-outer{fill:#0b0a0e;stroke:#000;stroke-width:2;}'+'.ld-rim{fill:#23202a;stroke:rgba(255,255,255,.10);stroke-width:1;}'+'.ld-rivet{fill:#5c6572;stroke:#0b0a0e;stroke-width:.6;}'+'.ld-face{fill:#17141c;stroke:rgba(255,255,255,.07);stroke-width:1;}'+'.ld-ticks line{stroke:#8b96a6;stroke-width:1.3;opacity:.8;}'+'.ld-num{font:700 9px Unbounded,sans-serif;fill:#cfd8e3;}'+'.ld-arrow{fill:#e0546e;}'+'.ld-hub{fill:#201d26;stroke:#8b96a6;stroke-width:1.2;}'+'.ld-hub2{fill:#0c0a10;stroke:#5c6572;stroke-width:1;}'+
    '.lp-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;}'+
    '.lp-title{font:800 14px Unbounded,sans-serif;letter-spacing:.12em;color:#cfd8e3;}'+
    '.lp-moves{font-size:13px;color:#9aa8b8;}.lp-moves b{color:#fff;}'+
    '.lp-board{display:flex;flex-direction:column;gap:7px;margin-bottom:12px;min-height:40px;}'+
    '.lp-row{display:flex;align-items:center;gap:8px;}'+
    '.lp-cell{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;justify-content:center;'+
      'font:700 20px "Playfair Display",serif;background:rgba(0,0,0,.3);border:1px solid rgba(255,255,255,.08);}'+
    '.lp-past{background:rgba(207,216,227,.07);border-color:rgba(207,216,227,.2);color:#cfd8e3;}'+
    '.lp-cur{border-color:rgba(224,84,110,.45);background:rgba(0,0,0,.45);}'+
    '.lp-empty{color:#46506080;}'+
    '.lp-active .lp-cell{border-color:rgba(224,84,110,.55);}'+
    '.lp-pins{display:flex;flex-wrap:wrap;gap:3px;width:34px;margin-left:4px;}'+
    '.lp-pin{width:9px;height:9px;border-radius:50%;}'+
    '.lp-exact{background:#46d89b;}.lp-present{background:#ffcf6b;}'+
    '.lp-miss{background:rgba(255,255,255,.12);}'+
    '.lp-legend{font-size:11px;color:#7a8494;text-align:center;margin-bottom:14px;}'+
    '.lp-pad{display:grid;grid-template-columns:repeat(6,1fr);gap:7px;margin-bottom:12px;}'+
    '.lp-key{aspect-ratio:1;border:none;border-radius:10px;background:linear-gradient(165deg,#211d26,#0f0d12);'+
      'color:#cfd8e3;font:700 18px "Playfair Display",serif;cursor:pointer;border:1px solid #000;box-shadow:inset 0 1px 0 rgba(255,255,255,.07),0 3px 8px rgba(0,0,0,.4);'+
      'transition:transform .1s;}'+
    '.lp-key:active{transform:scale(.92);background:rgba(224,84,110,.2);}'+
    '.lp-actions{display:flex;gap:10px;}'+
    '.lp-clear,.lp-try{flex:1;padding:13px;border:none;border-radius:12px;font:700 14px Inter,sans-serif;cursor:pointer;}'+
    '.lp-clear{background:rgba(255,255,255,.06);color:#9aa8b8;}'+
    '.lp-try{background:linear-gradient(135deg,#e0546e,#8e1e36);color:#fff;box-shadow:0 6px 16px rgba(142,30,54,.4);}'+
    '.lp-try:active,.lp-clear:active{transform:scale(.97);}'+
    '@keyframes lpShake{0%,100%{transform:translateX(0)}25%{transform:translateX(-6px)}75%{transform:translateX(6px)}}'+
    '@keyframes lpFade{from{opacity:0}to{opacity:1}}';
    document.head.appendChild(s);
  }

  function start(container,o){
    opts=o||{}; running=true;
    LEN=3; DIGITS=6; maxMoves=8;
    // сложность: аркадный уровень (mission.lvl) или сюжетная миссия (target)
    if(opts.mission&&opts.mission.lvl){
      var L=opts.mission.lvl;
      LEN=3+Math.min(2,Math.floor((L-1)/4));          // 3 цифры → 4 (ур.5) → 5 (ур.9)
      maxMoves=(LEN===3)?8:((LEN===4)?9:10);          // длиннее код — больше попыток
      if(L>=13) maxMoves--;                            // поздние уровни жёстче
    } else if(opts.mission&&opts.mission.target){
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
