/* ═══════════════════════════════════════════════════════
   СДВИГ · «ПРОСЛУШКА» — код на плёнке (Simon).
   Магнитофон проигрывает последовательность сигналов —
   повтори её по кнопкам-частотам. Каждый раунд код длиннее.
   Ошибся — сжёг плёнку (их три). Доведи код до цели — победа.
   Контракт: Wiretap.start(container,{mission,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════ */
(function(){
  var root,opts=null,running=false,phase='idle';
  var seq=[],pos=0,tapes=3,targetLen=6,speed=460,lvl=1;
  var _btns,_status,_segs,_tapes,_reels,timers=[];

  var COLORS=[
    {c:'#e0546e',glow:'rgba(224,84,110,.8)'},
    {c:'#5cd0ff',glow:'rgba(92,208,255,.8)'},
    {c:'#ffcf6b',glow:'rgba(255,207,107,.8)'},
    {c:'#46d89b',glow:'rgba(70,216,155,.8)'}
  ];

  function lvlOf(m){ if(m&&m.lvl)return m.lvl; if(m&&m.chapter)return m.chapter*2-1; return 1; }
  function later(fn,ms){ var t=setTimeout(fn,ms); timers.push(t); return t; }
  function clearTimers(){ timers.forEach(clearTimeout); timers=[]; }

  function injectCSS(){
    if(document.getElementById('wt-css')) return;
    var s=document.createElement('style'); s.id='wt-css';
    s.textContent=
    '.wt-root{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:space-between;'+
      'padding:14px 12px;background:radial-gradient(circle at 50% 20%,#16141a,#050507);'+
      'font-family:Manrope,sans-serif;color:#e8e2d4;touch-action:manipulation;user-select:none;-webkit-user-select:none;}'+
    '.wt-title{font:800 14px Unbounded,sans-serif;letter-spacing:.14em;color:#cfd8e3;}'+
    '.wt-progress{display:flex;gap:5px;margin-top:8px;}'+
    '.wt-seg{width:14px;height:8px;border-radius:4px;background:rgba(255,255,255,.08);box-shadow:inset 0 1px 2px rgba(0,0,0,.5);transition:all .25s;}'+
    '.wt-seg.on{background:linear-gradient(90deg,#2a9d6f,#46d89b);box-shadow:0 0 8px rgba(70,216,155,.6);}'+
    '.wt-deck{position:relative;width:min(86%,300px);padding:16px 18px 14px;border-radius:18px;'+
      'background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(10,8,12,.98));border:1px solid #000;'+
      'box-shadow:0 10px 26px rgba(0,0,0,.6),inset 0 1px 0 rgba(255,255,255,.08),0 0 0 1px rgba(255,255,255,.05);}'+
    '.wt-reels{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;}'+
    '.wt-reel{width:58px;height:58px;border-radius:50%;position:relative;'+
      'background:radial-gradient(circle,#23202a 30%,#17141c 70%);border:2px solid #0a0a0c;'+
      'box-shadow:inset 0 0 12px rgba(0,0,0,.7),0 2px 6px rgba(0,0,0,.5);}'+
    '.wt-reel::before{content:"";position:absolute;inset:38%;border-radius:50%;background:#0c0a10;border:1.5px solid #5c6572;}'+
    '.wt-reel i{position:absolute;left:50%;top:6%;width:8%;height:38%;margin-left:-4%;border-radius:3px;'+
      'background:#454e5b;transform-origin:50% 116%;}'+
    '.wt-reel i:nth-child(2){transform:rotate(120deg)}.wt-reel i:nth-child(3){transform:rotate(240deg)}'+
    '.wt-reel.run{animation:wtSpin 1.2s linear infinite;}'+
    '@keyframes wtSpin{to{transform:rotate(360deg)}}'+
    '.wt-tape{flex:1;height:5px;margin:0 8px;border-radius:3px;background:linear-gradient(90deg,#2c2732,#1b1721);'+
      'box-shadow:inset 0 1px 2px rgba(0,0,0,.7);}'+
    '.wt-status{text-align:center;font:800 13px Unbounded,sans-serif;letter-spacing:.12em;height:18px;transition:color .2s;}'+
    '.wt-status.listen{color:#ff8fa8;animation:wtPulse 1s ease-in-out infinite;}'+
    '.wt-status.input{color:#46d89b;}'+
    '@keyframes wtPulse{0%,100%{opacity:.55}50%{opacity:1}}'+
    '.wt-tapesrow{display:flex;gap:7px;justify-content:center;margin-top:9px;}'+
    '.wt-tapeic{width:20px;height:13px;border-radius:3px;background:linear-gradient(180deg,#3a3542,#221e29);'+
      'border:1px solid #0a0a0c;position:relative;box-shadow:0 0 6px rgba(224,84,110,.35);transition:all .25s;}'+
    '.wt-tapeic::before,.wt-tapeic::after{content:"";position:absolute;top:3px;width:5px;height:5px;border-radius:50%;'+
      'border:1.2px solid #8b96a6;}'+
    '.wt-tapeic::before{left:3px}.wt-tapeic::after{right:3px}'+
    '.wt-tapeic.off{opacity:.22;box-shadow:none;}'+
    '.wt-pad{display:grid;grid-template-columns:repeat(2,1fr);gap:14px;width:min(72%,240px);margin-bottom:6px;}'+
    '.wt-btn{aspect-ratio:1;border-radius:50%;border:2px solid #000;cursor:pointer;position:relative;'+
      'background:linear-gradient(165deg,rgba(30,26,34,.98),rgba(12,10,16,.99));'+
      'box-shadow:0 6px 16px rgba(0,0,0,.55),inset 0 1px 0 rgba(255,255,255,.08);'+
      'transition:transform .08s,box-shadow .15s;}'+
    '.wt-btn::before{content:"";position:absolute;inset:26%;border-radius:50%;opacity:.5;transition:all .12s;'+
      'background:radial-gradient(circle at 38% 32%,var(--wc),transparent 75%);}'+
    '.wt-btn::after{content:"";position:absolute;inset:10%;border-radius:50%;border:1.5px solid var(--wc);opacity:.4;transition:opacity .12s;}'+
    '.wt-btn.lit{transform:scale(1.07);box-shadow:0 0 22px var(--wg),inset 0 1px 0 rgba(255,255,255,.1);}'+
    '.wt-btn.lit::before{opacity:1;inset:16%;}'+
    '.wt-btn.lit::after{opacity:.95;}'+
    '.wt-btn:active{transform:scale(.94);}'+
    '.wt-hint{font-size:11px;color:#93a1b3;letter-spacing:.04em;text-align:center;}'+
    '.wt-flash{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;z-index:6;'+
      'background:rgba(8,8,11,.84);font:800 21px Unbounded,sans-serif;letter-spacing:.08em;animation:wtFade .4s;}'+
    '@keyframes wtFade{from{opacity:0}to{opacity:1}}'+
    '.wt-deck.err{animation:wtErr .35s ease;}'+
    '@keyframes wtErr{0%,100%{transform:none}25%{transform:translateX(-7px)}75%{transform:translateX(7px)}}';
    document.head.appendChild(s);
  }

  function build(container){
    var segs=''; for(var i=0;i<targetLen;i++) segs+='<span class="wt-seg" data-i="'+i+'"></span>';
    var tps=''; for(var j=0;j<3;j++) tps+='<span class="wt-tapeic" data-j="'+j+'"></span>';
    var pad=''; for(var b=0;b<4;b++) pad+='<button class="wt-btn" data-b="'+b+'" style="--wc:'+COLORS[b].c+';--wg:'+COLORS[b].glow+'"></button>';
    root=document.createElement('div'); root.className='wt-root';
    root.innerHTML=
      '<div style="text-align:center"><div class="wt-title">ПРОСЛУШКА</div><div class="wt-progress">'+segs+'</div></div>'+
      '<div class="wt-deck" id="wt-deck">'+
        '<div class="wt-reels"><div class="wt-reel" id="wt-r1"><i></i><i></i><i></i></div>'+
        '<div class="wt-tape"></div>'+
        '<div class="wt-reel" id="wt-r2"><i></i><i></i><i></i></div></div>'+
        '<div class="wt-status" id="wt-status"></div>'+
        '<div class="wt-tapesrow">'+tps+'</div>'+
      '</div>'+
      '<div class="wt-pad">'+pad+'</div>'+
      '<div class="wt-hint">Запомни сигналы с плёнки и повтори их по кнопкам</div>';
    container.innerHTML=''; container.appendChild(root);
    _btns=root.querySelectorAll('.wt-btn');
    _status=root.querySelector('#wt-status');
    _segs=root.querySelectorAll('.wt-seg');
    _tapes=root.querySelectorAll('.wt-tapeic');
    _reels=[root.querySelector('#wt-r1'),root.querySelector('#wt-r2')];
    _btns.forEach(function(b){ b.addEventListener('pointerdown',function(){ press(+b.dataset.b); }); });
    paint();
  }

  function paint(){
    _segs.forEach(function(s,i){ s.classList.toggle('on', i<seq.length-(phase==='play'||phase==='input'?0:0) && i<doneLen()); });
    _tapes.forEach(function(t,j){ t.classList.toggle('off', j>=tapes); });
  }
  function doneLen(){ return Math.max(0,seq.length-1); } // засчитан прошлый раунд

  function tone(i){ try{ Sound.simon?Sound.simon(i):(Sound.nav&&Sound.nav()); }catch(_){} }
  function light(i,ms){
    var b=_btns[i]; if(!b) return;
    b.classList.add('lit'); later(function(){ b.classList.remove('lit'); }, ms||speed*0.55);
  }

  function playSeq(){
    phase='play'; pos=0;
    _status.textContent='СЛУШАЙ…'; _status.className='wt-status listen';
    _reels.forEach(function(r){ r.classList.add('run'); });
    seq.forEach(function(ci,i){
      later(function(){ if(!running)return; light(ci); tone(ci); }, 500+i*speed);
    });
    later(function(){ if(!running)return;
      phase='input'; pos=0;
      _reels.forEach(function(r){ r.classList.remove('run'); });
      _status.textContent='ТВОЙ ХОД'; _status.className='wt-status input';
    }, 500+seq.length*speed+120);
  }

  function press(i){
    if(!running||phase!=='input') return;
    light(i,180); tone(i);
    try{ navigator.vibrate&&navigator.vibrate(8); }catch(_){}
    if(i===seq[pos]){
      pos++;
      if(pos>=seq.length){ roundDone(); }
      return;
    }
    // ошибка
    tapes--;
    paint();
    var deck=root.querySelector('#wt-deck');
    deck.classList.remove('err'); void deck.offsetWidth; deck.classList.add('err');
    try{ Sound.deny&&Sound.deny(); navigator.vibrate&&navigator.vibrate([15,50]); }catch(_){}
    _status.textContent='ПОМЕХИ… ЕЩЁ РАЗ'; _status.className='wt-status listen';
    phase='wait';
    if(tapes<=0){ lose(); return; }
    later(playSeq,900);
  }

  function roundDone(){
    phase='wait';
    try{ Sound.approve&&Sound.approve(); }catch(_){}
    paint();
    if(seq.length>=targetLen){ win(); return; }
    _status.textContent='ЕСТЬ. ДАЛЬШЕ…'; _status.className='wt-status input';
    seq.push((Math.random()*4)|0);
    later(playSeq,750);
  }

  function flash(col,msg,sub){
    var o=document.createElement('div'); o.className='wt-flash'; o.style.color=col;
    o.innerHTML='<div style="text-align:center">'+msg+(sub?'<div style="font:600 12px Manrope,sans-serif;color:#93a1b3;margin-top:8px">'+sub+'</div>':'')+'</div>';
    root.appendChild(o);
  }
  function win(){ if(!running)return; running=false; clearTimers();
    _segs.forEach(function(s){ s.classList.add('on'); });
    try{ Sound.win&&Sound.win(); navigator.vibrate&&navigator.vibrate([10,40,10,40]); }catch(_){}
    flash('#46d89b','КОД РАСШИФРОВАН','Запись у нас.');
    setTimeout(function(){ opts&&opts.onWin&&opts.onWin(); },900); }
  function lose(){ if(!running)return; running=false; clearTimers();
    try{ Sound.deny&&Sound.deny(); }catch(_){}
    flash('#ff6470','ПЛЁНКА СГОРЕЛА','Сигнал потерян.');
    setTimeout(function(){ opts&&opts.onLose&&opts.onLose(); },900); }

  function start(container,o){
    opts=o||{}; running=true; clearTimers();
    lvl=lvlOf(opts.mission);
    targetLen=4+Math.ceil(lvl*0.7);            // длина финального кода
    speed=Math.max(250,520-lvl*20);            // темп воспроизведения
    tapes=3; phase='idle';
    var startLen=Math.min(targetLen-1, 2+((lvl/3)|0));
    seq=[]; for(var i=0;i<startLen;i++) seq.push((Math.random()*4)|0);
    injectCSS(); build(container);
    later(playSeq,600);
  }
  function stop(){ running=false; clearTimers(); }

  window.Wiretap={ start:start, stop:stop,
    _dbg:{ seq:function(){return seq.slice();}, phase:function(){return phase;},
           press:press, state:function(){return {len:seq.length,target:targetLen,tapes:tapes};} } };
})();
