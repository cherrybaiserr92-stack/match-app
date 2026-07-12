/* ═══════════════════════════════════════════════════════
   СДВИГ · «ВЗЛОМ СЕЙФА» v3 — тайминг-кольцо.
   Стрелка бежит по циферблату. Тапни, когда она в красной зоне —
   защёлка щёлкает, зона прыгает и сужается, стрелка ускоряется.
   Собери все защёлки до того, как кончатся попытки.
   Контракт: Lockpick.start(container,{mission,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════ */
(function(){
  var root,opts=null,running=false,raf=null;
  var angle=0,dir=1,speed=120,arcC=90,arcW=40,latches=3,got=0,tries=5,lastT=0;
  var _needle,_arcEl,_pins,_tries,_hint;

  function lvlOf(m){
    if(m&&m.lvl) return m.lvl;
    if(m&&m.chapter) return m.chapter*2-1;
    return 1;
  }

  function polar(r,aDeg){ var a=(aDeg-90)*Math.PI/180; return [50+r*Math.cos(a), 50+r*Math.sin(a)]; }
  function arcPath(r,a0,a1){
    var p0=polar(r,a0),p1=polar(r,a1);
    var large=(((a1-a0)%360)+360)%360>180?1:0;
    return 'M'+p0[0].toFixed(2)+' '+p0[1].toFixed(2)+' A'+r+' '+r+' 0 '+large+' 1 '+p1[0].toFixed(2)+' '+p1[1].toFixed(2);
  }

  function injectCSS(){
    if(document.getElementById('lp3-css')) return;
    var s=document.createElement('style'); s.id='lp3-css';
    s.textContent=
    '.lp-wrap{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:14px;'+
      'background:radial-gradient(circle at 50% 30%,#16141a,#050507);font-family:Manrope,sans-serif;color:#e8e2d4;touch-action:manipulation;}'+
    '.lp-title{font:800 14px Unbounded,sans-serif;letter-spacing:.14em;color:#cfd8e3;}'+
    '.lp-pinsrow{display:flex;gap:10px;}'+
    '.lp-pin3{width:16px;height:16px;border-radius:50%;background:rgba(255,255,255,.07);border:1.5px solid rgba(255,255,255,.15);'+
      'box-shadow:inset 0 1px 2px rgba(0,0,0,.6);transition:all .2s;}'+
    '.lp-pin3.on{background:radial-gradient(circle at 35% 30%,#fff,#46d89b 60%);border-color:#46d89b;'+
      'box-shadow:0 0 10px rgba(70,216,155,.7);transform:scale(1.12);}'+
    '.lp-dialwrap{position:relative;width:210px;height:210px;filter:drop-shadow(0 12px 26px rgba(0,0,0,.65));}'+
    '.lp-dialwrap svg{position:absolute;inset:0;width:100%;height:100%;}'+
    '.ld-outer{fill:#0b0a0e;stroke:#000;stroke-width:2;}'+
    '.ld-rim{fill:#23202a;stroke:rgba(255,255,255,.10);stroke-width:1;}'+
    '.ld-rivet{fill:#5c6572;stroke:#0b0a0e;stroke-width:.6;}'+
    '.ld-face{fill:#17141c;stroke:rgba(255,255,255,.07);stroke-width:1;}'+
    '.ld-ticks line{stroke:#8b96a6;stroke-width:1.1;opacity:.7;}'+
    '.ld-hub{fill:#201d26;stroke:#8b96a6;stroke-width:1.2;}'+
    '.ld-hub2{fill:#0c0a10;stroke:#5c6572;stroke-width:1;}'+
    '.ld-zone{fill:none;stroke:#e0546e;stroke-width:7;stroke-linecap:round;opacity:.95;'+
      'filter:drop-shadow(0 0 6px rgba(224,84,110,.9));}'+
    '.ld-zonesoft{fill:none;stroke:rgba(224,84,110,.28);stroke-width:13;stroke-linecap:round;}'+
    '.lp-needlewrap{position:absolute;inset:0;will-change:transform;}'+
    '.ld-needle{fill:#ff8fa8;filter:drop-shadow(0 0 5px rgba(255,143,168,.9));}'+
    '.lp-dialwrap.hitfx .ld-face{fill:#1d2a22;}'+
    '.lp-dialwrap.missfx{animation:lp3shake .3s;}'+
    '@keyframes lp3shake{0%,100%{transform:none}25%{transform:translateX(-7px)}75%{transform:translateX(7px)}}'+
    '.lp-triesrow{display:flex;gap:8px;align-items:center;}'+
    '.lp-try3{width:11px;height:11px;border-radius:50%;background:radial-gradient(circle at 35% 30%,#ff8fa8,#8e1e36);'+
      'box-shadow:0 0 7px rgba(224,84,110,.6);transition:all .2s;}'+
    '.lp-try3.off{background:rgba(255,255,255,.08);box-shadow:none;}'+
    '.lp-hint{font-size:12px;color:#93a1b3;letter-spacing:.05em;animation:lp3pulse 1.8s ease-in-out infinite;}'+
    '@keyframes lp3pulse{0%,100%{opacity:.5}50%{opacity:1}}'+
    '.lp-flash{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;z-index:5;'+
      'background:rgba(8,8,11,.82);font:800 22px Unbounded,sans-serif;letter-spacing:.1em;animation:lp3fade .4s;}'+
    '@keyframes lp3fade{from{opacity:0}to{opacity:1}}';
    document.head.appendChild(s);
  }

  function build(container){
    var ticks='';
    for(var t=0;t<36;t++){ ticks+='<line x1="50" y1="9" x2="50" y2="'+(t%6===0?15:12)+'" transform="rotate('+(t*10)+' 50 50)"/>'; }
    var rivets='';
    for(var rv=0;rv<6;rv++){ rivets+='<circle cx="50" cy="11" r="1.8" transform="rotate('+(rv*60+30)+' 50 50)" class="ld-rivet"/>'; }
    var pins='';
    for(var i=0;i<latches;i++) pins+='<span class="lp-pin3" data-i="'+i+'"></span>';
    var trs='';
    for(var j=0;j<tries;j++) trs+='<span class="lp-try3" data-j="'+j+'"></span>';
    root=document.createElement('div'); root.className='lp-wrap';
    root.innerHTML=
      '<div class="lp-title">ВЗЛОМ СЕЙФА</div>'+
      '<div class="lp-pinsrow">'+pins+'</div>'+
      '<div class="lp-dialwrap" id="lp-dial">'+
        '<svg viewBox="0 0 100 100">'+
          '<circle cx="50" cy="50" r="47" class="ld-outer"/>'+
          '<circle cx="50" cy="50" r="42" class="ld-rim"/>'+rivets+
          '<circle cx="50" cy="50" r="31" class="ld-face"/>'+
          '<g class="ld-ticks">'+ticks+'</g>'+
        '</svg>'+
        '<svg viewBox="0 0 100 100"><path id="lp-zonesoft" class="ld-zonesoft" d=""/><path id="lp-zone" class="ld-zone" d=""/></svg>'+
        '<div class="lp-needlewrap" id="lp-needle"><svg viewBox="0 0 100 100">'+
          '<polygon points="50,7 47.4,46 52.6,46" class="ld-needle"/>'+
          '<circle cx="50" cy="50" r="10" class="ld-hub"/><circle cx="50" cy="50" r="4.5" class="ld-hub2"/>'+
        '</svg></div>'+
      '</div>'+
      '<div class="lp-triesrow">'+trs+'</div>'+
      '<div class="lp-hint">Тапни, когда стрелка в красной зоне</div>';
    container.innerHTML=''; container.appendChild(root);
    _needle=root.querySelector('#lp-needle');
    _arcEl=root.querySelector('#lp-zone');
    _pins=root.querySelectorAll('.lp-pin3');
    _tries=root.querySelectorAll('.lp-try3');
    _hint=root.querySelector('.lp-hint');
    drawZone();
    root.addEventListener('pointerdown',onTap);
  }

  function drawZone(){
    var a0=arcC-arcW/2, a1=arcC+arcW/2;
    _arcEl.setAttribute('d',arcPath(36.5,a0,a1));
    root.querySelector('#lp-zonesoft').setAttribute('d',arcPath(36.5,a0,a1));
  }
  function moveZone(){
    var next=arcC+90+Math.random()*180; // всегда далеко от текущей
    arcC=((next%360)+360)%360;
    arcW=Math.max(12,arcW*0.87);
    drawZone();
  }

  function loop(now){
    if(!running) return;
    if(!lastT) lastT=now;
    var dt=Math.min(50,now-lastT)/1000; lastT=now;
    angle=((angle+speed*dir*dt)%360+360)%360;
    _needle.style.transform='rotate('+angle+'deg)';
    raf=requestAnimationFrame(loop);
  }

  function angDist(a,b){ var d=Math.abs(a-b)%360; return d>180?360-d:d; }

  function onTap(){
    if(!running) return;
    if(angDist(angle,arcC)<=arcW/2+2.5) hit(); else miss();
  }
  function hit(){
    got++;
    try{ Sound.latch?Sound.latch():(Sound.coin&&Sound.coin()); }catch(_){}
    try{ navigator.vibrate&&navigator.vibrate(18); }catch(_){}
    if(_pins[got-1]) _pins[got-1].classList.add('on');
    var dw=root.querySelector('#lp-dial');
    dw.classList.add('hitfx'); setTimeout(function(){dw.classList.remove('hitfx');},180);
    if(got>=latches){ win(); return; }
    speed*=1.13; dir*=(Math.random()<0.4?-1:1); // иногда меняет направление
    moveZone();
  }
  function miss(){
    tries--;
    try{ Sound.error&&Sound.error(); }catch(_){}
    try{ navigator.vibrate&&navigator.vibrate([10,40]); }catch(_){}
    if(_tries[tries]) _tries[tries].classList.add('off');
    var dw=root.querySelector('#lp-dial');
    dw.classList.add('missfx'); setTimeout(function(){dw.classList.remove('missfx');},320);
    dir*=-1;
    if(tries<=0) lose();
  }

  function flash(col,msg){
    var o=document.createElement('div'); o.className='lp-flash'; o.style.color=col;
    o.textContent=msg; root.appendChild(o);
  }
  function win(){ running=false; cancelAnimationFrame(raf);
    try{ Sound.win&&Sound.win(); navigator.vibrate&&navigator.vibrate([10,40,10,40]); }catch(_){}
    flash('#46d89b','СЕЙФ ОТКРЫТ');
    setTimeout(function(){ opts&&opts.onWin&&opts.onWin(); },900); }
  function lose(){ running=false; cancelAnimationFrame(raf);
    try{ Sound.deny&&Sound.deny(); }catch(_){}
    flash('#ff6470','ЗАКЛИНИЛО');
    setTimeout(function(){ opts&&opts.onLose&&opts.onLose(); },900); }

  function start(container,o){
    opts=o||{}; running=true; lastT=0;
    var lvl=lvlOf(opts.mission);
    latches=3+Math.min(3,((lvl-1)/2)|0);       // 3 → 6 защёлок
    speed=115+lvl*9;                            // стартовая скорость
    arcW=Math.max(15,40-lvl*1.6);               // ширина зоны
    tries=5; got=0; dir=1;
    angle=Math.random()*360; arcC=Math.random()*360;
    injectCSS(); build(container);
    raf=requestAnimationFrame(loop);
  }
  function stop(){ running=false; cancelAnimationFrame(raf); }

  window.Lockpick={ start:start, stop:stop,
    _dbg:{ state:function(){return {angle:angle,arcC:arcC,arcW:arcW,got:got,tries:tries,latches:latches};},
           forceHit:function(){ angle=arcC; onTap(); },
           forceMiss:function(){ angle=(arcC+180)%360; onTap(); } } };
})();
