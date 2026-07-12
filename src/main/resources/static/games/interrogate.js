/* ═══════════════════════════════════════════════════════
   СДВИГ · «ДОПРОС» — нуар-кликер.
   Тапай по подозреваемому — ломай его ВОЛЮ. Но каждый тап
   поднимает шкалу СРЫВА: перегнёшь — он замкнётся. Лови
   «нервные тики» (мишени) — крит по воле и сброс срыва.
   Контракт: Interrogate.start(container,{mission,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════ */
(function(){
  var root,opts=null,running=false,tick=null;
  var will=50,willMax=50,panic=0,lvl=1;
  var panicTap=2.2,critDmg=8,weakEvery=2600,weakLife=1100;
  var weakT=0,weakEl=null,weakAlive=0,warned=false;
  var _willBar,_willNum,_panicBar,_stage,_sil;

  function lvlOf(m){ if(m&&m.lvl)return m.lvl; if(m&&m.chapter)return m.chapter*2-1; return 1; }

  function injectCSS(){
    if(document.getElementById('itg-css')) return;
    var s=document.createElement('style'); s.id='itg-css';
    s.textContent=
    '.itg-root{position:absolute;inset:0;display:flex;flex-direction:column;overflow:hidden;'+
      'background:radial-gradient(circle at 50% 12%,#1b1720,#070609 70%);font-family:Manrope,sans-serif;'+
      'color:#e8e2d4;touch-action:manipulation;user-select:none;-webkit-user-select:none;}'+
    '.itg-top,.itg-bot{position:relative;z-index:2;flex:0 0 auto;margin:10px 12px;padding:8px 12px;border-radius:14px;'+
      'background:linear-gradient(165deg,rgba(26,22,28,.93),rgba(10,8,12,.97));border:1px solid #000;'+
      'box-shadow:0 8px 18px rgba(0,0,0,.55),inset 0 1px 0 rgba(255,255,255,.09);}'+
    '.itg-lbl{display:flex;justify-content:space-between;font:700 10px Unbounded,sans-serif;letter-spacing:.12em;color:#93a1b3;margin-bottom:5px;}'+
    '.itg-lbl b{color:#fff;font-variant-numeric:tabular-nums;}'+
    '.itg-bar{height:10px;border-radius:6px;background:rgba(255,255,255,.07);box-shadow:inset 0 1px 2px rgba(0,0,0,.6);overflow:hidden;}'+
    '.itg-fill{height:100%;border-radius:6px;transition:width .15s ease;}'+
    '.itg-will .itg-fill{background:linear-gradient(90deg,#93a1b3,#cfd8e3);box-shadow:0 0 8px rgba(207,216,227,.4);}'+
    '.itg-panic .itg-fill{background:linear-gradient(90deg,#8e1e36,#e0546e);box-shadow:0 0 8px rgba(224,84,110,.5);}'+
    '.itg-bot.hot{animation:itgHot .7s ease-in-out infinite;}'+
    '@keyframes itgHot{0%,100%{box-shadow:0 8px 18px rgba(0,0,0,.55),inset 0 1px 0 rgba(255,255,255,.09)}'+
      '50%{box-shadow:0 0 22px rgba(224,84,110,.65),inset 0 1px 0 rgba(255,255,255,.09)}}'+
    '.itg-stage{position:relative;flex:1 1 auto;min-height:0;cursor:pointer;}'+
    '.itg-lamp{position:absolute;top:0;left:50%;transform:translateX(-50%);width:78%;height:72%;pointer-events:none;'+
      'background:linear-gradient(180deg,rgba(255,236,190,.20),rgba(255,236,190,.05) 55%,transparent);'+
      'clip-path:polygon(46% 0,54% 0,96% 100%,4% 100%);animation:itgSway 7s ease-in-out infinite;transform-origin:top center;}'+
    '@keyframes itgSway{0%,100%{transform:translateX(-50%) rotate(-1.6deg)}50%{transform:translateX(-50%) rotate(1.6deg)}}'+
    '.itg-lamp.flick{animation:itgFlick .28s steps(2) 2, itgSway 7s ease-in-out infinite;}'+
    '@keyframes itgFlick{50%{opacity:.35}}'+
    '.itg-sil{position:absolute;left:50%;bottom:0;transform:translateX(-50%);height:88%;pointer-events:none;'+
      'filter:drop-shadow(0 -2px 24px rgba(0,0,0,.8));animation:itgBreath 4.5s ease-in-out infinite;transform-origin:bottom center;}'+
    '@keyframes itgBreath{0%,100%{transform:translateX(-50%) scaleY(1)}50%{transform:translateX(-50%) scaleY(1.012)}}'+
    '.itg-sil.hitfx{animation:itgHit .18s ease, itgBreath 4.5s ease-in-out infinite;}'+
    '@keyframes itgHit{30%{transform:translateX(-50%) translateY(2px) rotate(.8deg)}}'+
    '.itg-eye{animation:itgBlink 5.2s infinite;}'+
    '@keyframes itgBlink{0%,94%,100%{opacity:1}96%,98%{opacity:.1}}'+
    '.itg-weak{position:absolute;width:44px;height:44px;margin:-22px 0 0 -22px;z-index:3;cursor:pointer;'+
      'border-radius:50%;border:2.5px solid #ff8fa8;box-shadow:0 0 14px rgba(224,84,110,.85),inset 0 0 10px rgba(224,84,110,.5);'+
      'animation:itgWeak .8s ease-in-out infinite;}'+
    '.itg-weak::after{content:"";position:absolute;inset:32%;border-radius:50%;'+
      'background:radial-gradient(circle,#fff 25%,rgba(255,143,168,.5) 65%,transparent);}'+
    '@keyframes itgWeak{0%,100%{transform:scale(1)}50%{transform:scale(1.16)}}'+
    '.itg-pts{position:absolute;z-index:4;pointer-events:none;transform:translate(-50%,0);'+
      'font:800 14px Unbounded,sans-serif;color:#cfd8e3;text-shadow:0 2px 4px #000;animation:itgPts .7s ease-out forwards;}'+
    '.itg-pts.crit{font-size:19px;color:#ff8fa8;text-shadow:0 0 12px rgba(224,84,110,.9),0 2px 4px #000;}'+
    '@keyframes itgPts{0%{opacity:0;transform:translate(-50%,4px) scale(.7)}20%{opacity:1;transform:translate(-50%,-4px) scale(1.1)}'+
      '100%{opacity:0;transform:translate(-50%,-34px)}}'+
    '.itg-hint{font-size:11px;color:#93a1b3;text-align:center;letter-spacing:.04em;margin-top:5px;}'+
    '.itg-flash{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;z-index:6;'+
      'background:rgba(8,8,11,.84);font:800 21px Unbounded,sans-serif;letter-spacing:.08em;text-align:center;animation:itgFade .4s;}'+
    '@keyframes itgFade{from{opacity:0}to{opacity:1}}';
    document.head.appendChild(s);
  }

  function silSVG(){
    return '<svg viewBox="0 0 200 240" style="height:100%;display:block">'+
      '<ellipse cx="100" cy="234" rx="80" ry="8" fill="#000" opacity=".55"/>'+
      // пальто/плечи
      '<path d="M34 240 C36 186 60 162 100 162 C140 162 164 186 166 240 Z" fill="#141820"/>'+
      '<path d="M34 240 C36 186 60 162 100 162 L100 240 Z" fill="#0f1319"/>'+
      // лацканы
      '<path d="M82 168 L100 208 L100 165 Z" fill="#0a0d12"/>'+
      '<path d="M118 168 L100 208 L100 165 Z" fill="#0c0f15"/>'+
      '<path d="M100 208 L96 240 L104 240 Z" fill="#0a0d12"/>'+
      // голова
      '<circle cx="100" cy="138" r="27" fill="#161a22"/>'+
      '<path d="M73 138 A27 27 0 0 1 100 111 L100 165 A27 27 0 0 1 73 138 Z" fill="#12151c"/>'+
      // шляпа
      '<ellipse cx="100" cy="121" rx="42" ry="9.5" fill="#0b0e13"/>'+
      '<path d="M70 121 C70 96 82 87 100 87 C118 87 130 96 130 121 Z" fill="#10141b"/>'+
      '<rect x="70" y="112" width="60" height="7" rx="3.5" fill="#1d232c"/>'+
      '<path d="M72 118 C72 98 84 89 100 89" stroke="#5a6b80" stroke-width="1.6" fill="none" opacity=".75"/>'+
      // глаза — янтарные щёлки в тени полей
      '<rect class="itg-eye" x="85" y="133" width="10" height="3.2" rx="1.6" fill="#c9a227" opacity=".95"/>'+
      '<rect class="itg-eye" x="106" y="133" width="10" height="3.2" rx="1.6" fill="#c9a227" opacity=".95"/>'+
      // руки на столе
      '<path d="M52 240 C56 222 70 214 84 216 L88 240 Z" fill="#11151c"/>'+
      '<path d="M148 240 C144 222 130 214 116 216 L112 240 Z" fill="#11151c"/>'+
    '</svg>';
  }

  function build(container){
    root=document.createElement('div'); root.className='itg-root';
    root.innerHTML=
      '<div class="itg-top itg-will"><div class="itg-lbl"><span>ВОЛЯ ПОДОЗРЕВАЕМОГО</span><b id="itg-wn"></b></div>'+
        '<div class="itg-bar"><div class="itg-fill" id="itg-wf" style="width:100%"></div></div></div>'+
      '<div class="itg-stage" id="itg-stage">'+
        '<div class="itg-lamp" id="itg-lamp"></div>'+
        '<div class="itg-sil" id="itg-sil">'+silSVG()+'</div>'+
      '</div>'+
      '<div class="itg-bot itg-panic"><div class="itg-lbl"><span>СРЫВ</span><span>не дави слишком быстро</span></div>'+
        '<div class="itg-bar"><div class="itg-fill" id="itg-pf" style="width:0%"></div></div>'+
        '<div class="itg-hint">Тапай — дави. Лови <span style="color:#ff8fa8">нервный тик</span> — крит и сброс срыва.</div></div>';
    container.innerHTML=''; container.appendChild(root);
    _willBar=root.querySelector('#itg-wf'); _willNum=root.querySelector('#itg-wn');
    _panicBar=root.querySelector('#itg-pf');
    _stage=root.querySelector('#itg-stage'); _sil=root.querySelector('#itg-sil');
    _stage.addEventListener('pointerdown',onTap);
    paint();
  }

  function paint(){
    _willBar.style.width=Math.max(0,will/willMax*100)+'%';
    _willNum.textContent=Math.max(0,Math.ceil(will));
    _panicBar.style.width=Math.min(100,panic)+'%';
    var bot=root.querySelector('.itg-bot');
    bot.classList.toggle('hot',panic>=75);
  }

  function floatPts(x,y,txt,crit){
    var d=document.createElement('div'); d.className='itg-pts'+(crit?' crit':'');
    d.textContent=txt; d.style.left=x+'px'; d.style.top=y+'px';
    _stage.appendChild(d); setTimeout(function(){ if(d.parentNode)d.parentNode.removeChild(d); },720);
  }

  function onTap(e){
    if(!running) return;
    var r=_stage.getBoundingClientRect();
    var x=e.clientX-r.left, y=e.clientY-r.top;
    // попадание в «нервный тик»?
    if(weakEl){
      var wx=parseFloat(weakEl.style.left), wy=parseFloat(weakEl.style.top);
      if(Math.hypot(x-wx,y-wy)<34){ crit(wx,wy); return; }
    }
    will-=1; panic=Math.min(100,panic+panicTap);
    try{ Sound.tap&&Sound.tap(); navigator.vibrate&&navigator.vibrate(8); }catch(_){}
    _sil.classList.remove('hitfx'); void _sil.offsetWidth; _sil.classList.add('hitfx');
    floatPts(x,y,'-1',false);
    if(panic>=100){ paint(); lose(); return; }
    if(panic>=80&&!warned){ warned=true; try{Sound.error&&Sound.error();}catch(_){} }
    if(panic<70) warned=false;
    paint(); checkWin();
  }
  function crit(x,y){
    will-=critDmg; panic=Math.max(0,panic-16);
    try{ Sound.approve&&Sound.approve(); navigator.vibrate&&navigator.vibrate([12,30,12]); }catch(_){}
    floatPts(x,y,'В ТОЧКУ −'+critDmg,true);
    var lamp=root.querySelector('#itg-lamp');
    lamp.classList.remove('flick'); void lamp.offsetWidth; lamp.classList.add('flick');
    killWeak();
    paint(); checkWin();
  }
  function checkWin(){ if(will<=0) win(); }

  function spawnWeak(){
    killWeak();
    var r=_stage.getBoundingClientRect();
    // в пределах силуэта: центральная зона
    var x=r.width*(0.34+Math.random()*0.32);
    var y=r.height*(0.30+Math.random()*0.45);
    weakEl=document.createElement('div'); weakEl.className='itg-weak';
    weakEl.style.left=x+'px'; weakEl.style.top=y+'px';
    _stage.appendChild(weakEl);
    weakAlive=weakLife;
    try{ Sound.nav&&Sound.nav(); }catch(_){}
  }
  function killWeak(){ if(weakEl&&weakEl.parentNode)weakEl.parentNode.removeChild(weakEl); weakEl=null; weakAlive=0; }

  function flash(col,msg,sub){
    var o=document.createElement('div'); o.className='itg-flash'; o.style.color=col;
    o.innerHTML=msg+(sub?'<div style="font:600 12px Manrope,sans-serif;color:#93a1b3;margin-top:8px;letter-spacing:.03em">'+sub+'</div>':'');
    root.appendChild(o);
  }
  function win(){ if(!running)return; running=false; clearInterval(tick); killWeak();
    try{ Sound.win&&Sound.win(); navigator.vibrate&&navigator.vibrate([10,40,10,40]); }catch(_){}
    flash('#46d89b','РАСКОЛОЛСЯ','Он выложил всё.');
    setTimeout(function(){ opts&&opts.onWin&&opts.onWin(); },900); }
  function lose(){ if(!running)return; running=false; clearInterval(tick); killWeak();
    try{ Sound.deny&&Sound.deny(); }catch(_){}
    flash('#ff6470','ОН ЗАМКНУЛСЯ','Перегнул. Адвокат уже в дверях.');
    setTimeout(function(){ opts&&opts.onLose&&opts.onLose(); },900); }

  function start(container,o){
    opts=o||{}; running=true;
    lvl=lvlOf(opts.mission);
    willMax=will=40+lvl*12;
    panicTap=2.1+lvl*0.16;
    critDmg=8+((lvl/2)|0);
    weakEvery=Math.max(1800,3000-lvl*80);
    weakLife=Math.max(650,1350-lvl*45);
    panic=0; warned=false; weakT=weakEvery*0.6;
    injectCSS(); build(container);
    tick=setInterval(function(){
      if(!running) return;
      panic=Math.max(0,panic-0.5); // давление спадает — пауза лечит
      if(weakEl){ weakAlive-=100; if(weakAlive<=0) killWeak(); }
      else{ weakT-=100; if(weakT<=0){ spawnWeak(); weakT=weakEvery; } }
      paint();
    },100);
  }
  function stop(){ running=false; clearInterval(tick); }

  window.Interrogate={ start:start, stop:stop,
    _dbg:{ state:function(){return {will:will,panic:panic,lvl:lvl};},
           tapN:function(n){ for(var i=0;i<n&&running;i++){ will--; panic=Math.min(100,panic+panicTap);} paint(); if(panic>=100){lose();} else checkWin(); },
           calm:function(){ panic=0; paint(); } } };
})();
